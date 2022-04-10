import 'dart:convert';
import 'dart:io';
import 'gdgm.dart';
import 'gdgm_Constant.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
//------------------------
late GDGM_S gdgm_jw;
late List<Cookie> _cookie1;
late List<Cookie> _cookie2;
late Response _HOME;
late List<int> _verifycode2bytes;
late String _session;
late String _failed_status;
late Map<String, String> _loginoption;
late List<dynamic> _stuinfo;
late String _OCR_AK;
late String _OCR_SK;
late String _OCR_token;

bool status = false;//登录状态
int _num_verify = 0; //验证码计次器
String _verifycode = '';
String _sess = '';

class GDGM_JW{
  GDGM_JW(String id, String pwd, String AK, String SK){
   _OCR_AK = AK; _OCR_SK = SK;
   gdgm_jw = GDGM_S();
   init(id,pwd);
  }

  init(String id, String pwd) async{
    var s = await Set_login(id,pwd);
    status = await login_jw();
    if (status){
      print("OCR识别次数" + _num_verify.toString());
      print("当前登入学生信息： \n" + _stuinfo.toString());
    }else{
      print("登录尝试失败！");
    }
  }


  Future<Response> get_HOME() async{
    Response get = await gdgm_jw.get(GDGM_Constant.jw_verify, GDGM_Constant.verifycode_head,Bytes: true);
    return get;
  }


  Future<String> get_AccessToken() async{
    Map<String,String> header = {'':''};
    Response token = await gdgm_jw.get(GDGM_Constant.accesstoken + 'client_id=' + _OCR_AK +'&client_secret=' + _OCR_SK, header);
    return token.data['access_token'];
  }

  List<int> Get_verifycode2bytes() {
    List<int> bytes = _HOME.data;
    _verifycode2bytes = bytes;
    return bytes;
  }
  String verifybytes2base64(List<int> bytes){
    return base64Encode(bytes);
  }

  Future<String> Get_verifycode() async{
    Map<String,String> header = {'Content-Type':'application/x-www-form-urlencoded'};
    Map<String,String> data = {
      'image': verifybytes2base64(Get_verifycode2bytes()),
    };
    Map<String,String> query ={
      'access_token' : _OCR_token,
    };
    Response post = await gdgm_jw.post(GDGM_Constant.ocr, header,data: data, queryPar: query);
    //_verifycode = post.data['words_result'][0]['words'];
    //由于Dart的String没有提供很好的字符比较，无法像ascii那样手动Foreach，改选正则表达式进行字符串的格式化
    String? code = RegExp(r'\w+').stringMatch(post.data['words_result'][0]['words'].replaceAll(new RegExp(r'\s'), ''));
    if(code!.length !=4){
      code = "failed";
    }
    return code;
  }

  void Byte2file(List<int>bytes,String f) {
    try{
      File s = File(f);
      s.writeAsBytesSync(bytes,mode: FileMode.write,flush: true);
    }catch(e){}
  }

  // 设置Cookie1列表和返回Cookie字符串
  Future<String> cookie1() async {
    _cookie1 = await gdgm_jw.Cookies_List(GDGM_Constant.jw_verify);
    return _cookie1.toString();
  }

  Future<Map<String, String>>get_logon_header() async{
    Map<String, String> header =
    {
      'cookie': await cookie1(),
    };
    header.addAll(GDGM_Constant.jw_logon_header);
    return header;
  }

  Future<String> get_logon() async{
    Response post = await gdgm_jw.post(
        GDGM_Constant.jw_login_sess,
        await get_logon_header(),
        queryPar: {
          'method':'logon',
          'flag':'sess',
        }
    );
    return post.data.toString();
  }

  Future<String> get_sess(String id, String pwd) async {
    return gdgm_jw.encodedToString(id, pwd, await get_logon());
  }

  Future<Map<String, String>>get_login_header() async{
    Map<String, String> header =
    {
      'cookie': await cookie1(),
    };
    header.addAll(GDGM_Constant.jw_login_header);
    return header;
  }

  String Set_session(List<Cookie> cookie1,List<Cookie> cookie2) {
    _session = gdgm_jw.Cookie_Trim(_cookie1, _cookie2);
    return _session;
  }

  Future<bool> Set_login(String id, String pwd) async{
    _OCR_token = await get_AccessToken();
    do {
      _num_verify +=1;// _num_verify + 1;
      print("尝试自动识别第" + _num_verify.toString() + "次验证码,返回结果：");
      _HOME = await get_HOME();
      _verifycode = await Get_verifycode();
      print(_verifycode);
    } while (_verifycode == "failed");
    _sess = await get_sess(id, pwd);
    return true;
  }
  Future<bool> login_jw() async{
    Response post = await gdgm_jw.post(
        GDGM_Constant.jw_login_sess,
        await get_login_header(),
        data: {
          "userAccount": '',
          "userPassword": '',//sess登录不需要填写
          "RANDOMCODE": _verifycode,
          "encoded" : _sess,
        },
        queryPar: GDGM_Constant.jw_login_seee_query
    );
    if (post.statusCode == 302){
      Map<String, String> login302option = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': await cookie1(),
      };
      Response login_302 = await gdgm_jw.get(post.headers['location']![0],login302option);
      _cookie2 = await gdgm_jw.cookieJar.loadForRequest(Uri.parse(post.headers['location']![0]));
      _loginoption = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': Set_session(_cookie1, _cookie2),
      };
      Response xsxx = await gdgm_jw.get(GDGM_Constant.jw_xsxx,_loginoption);
      _stuinfo = Table2List(xsxx.data)[0][2]; //存储登入学生的学籍信息
    }
    else {
    _failed_status = showMsg(post.data);
    print(_failed_status);
    return false;
    }
    return true;
  }

  List<dynamic> Table2List(String data){
    Document ss = parse(data);
    List<dynamic> tables = [];
    List<Element> tablesHtml = ss.querySelectorAll('table');
    for (var tb in tablesHtml) {
      List<dynamic> table = [];
      tb.querySelectorAll('tr').forEach((tr){
        List<dynamic> line = [];
        tr.querySelectorAll('th, td').forEach((td){
          line.add(td.innerHtml);
        });
        table.add(line);
      });
      tables.add(table);
    }
    return tables;
  }
  
  String showMsg(String data){
    Document tt = parse(data);
    String error = '';
    try {
      error = tt.querySelector('#showMsg')!.nodes[0].text!.trim();
      if(error == ''){error = "Error:未知的错误";}
    }catch(e){
      error = 'Error：报错异常';
    }
    return error;
  }
}