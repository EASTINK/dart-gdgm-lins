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
late String _failed_status;
late Map<String, String> _loginoption;
late List<dynamic> _stuinfo;
late String _OCR_AK;
late String _OCR_SK;
late String _OCR_token;
late String _id ;
late String _pwd;
late List<dynamic> _kb;
bool status = false;//登录状态
int _num_verify = 0; //验证码计次器
String _verifycode = '';
String _sess = '';
String _session = "";

class GDGM_JW {

  GDGM_JW(String id, String pwd, String AK, String SK) {
    _OCR_AK = AK;
    _OCR_SK = SK;
    _id = id;
    _pwd = pwd;
    gdgm_jw = GDGM_S();
  }

  //@lins 4.24,11.50  增加session参数
  init() async {
   /* var teststr;
    if (instr != "") {
      _session = instr;
      _stuinfo = await get_stuinfo(false); //存储登入学生的学籍信息
      _kb = await get_xskb(false); //存储初始格式化后的课表信息
    } else {*/
    var s = await Set_login(_id, _pwd);
    status = await login_jw();
    if (status) {
      _stuinfo = await get_stuinfo(true);
      _kb = await get_xskb(true);
      print("OCR识别次数" + _num_verify.toString());
    } else {
      print("登录尝试失败！");
    }
    //}
  }

  set_session(String ses) async {
    _session = ses;
  }

  Future<String> get_session() async {
    return _session;
  }

  Future<Response> get_HOME() async {
    Response get = await gdgm_jw.get(
        GDGM_Constant.jw_verify, GDGM_Constant.verifycode_head, Bytes: true);
    return get;
  }


  Future<String> get_AccessToken() async {
    Map<String, String> header = {'': ''};
    Response token = await gdgm_jw.get(
        GDGM_Constant.accesstoken + 'client_id=' + _OCR_AK + '&client_secret=' +
            _OCR_SK, header);
    return token.data['access_token'];
  }

  List<int> Get_verifycode2bytes() {
    List<int> bytes = _HOME.data;
    _verifycode2bytes = bytes;
    return bytes;
  }

  String verifybytes2base64(List<int> bytes) {
    return base64Encode(bytes);
  }

  Future<String> Get_verifycode() async {
    Map<String, String> header = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Map<String, String> data = {
      'image': verifybytes2base64(Get_verifycode2bytes()),
    };
    Map<String, String> query = {
      'access_token': _OCR_token,
    };
    Response post = await gdgm_jw.post(
        GDGM_Constant.ocr, header, data: data, queryPar: query);
    //_verifycode = post.data['words_result'][0]['words'];
    //由于Dart的String没有提供很好的字符比较，也无法像ascii那样手动Foreach，改选正则表达式进行字符串的格式化
    String? code = RegExp(r'\w+').stringMatch(
        post.data['words_result'][0]['words'].replaceAll(
            new RegExp(r'\s'), ''));
    if (code!.length != 4) {
      code = "failed";
    }
    return code;
  }


  // 设置Cookie1列表和返回Cookie字符串
  Future<String> cookie1() async {
    _cookie1 = await gdgm_jw.Cookies_List(GDGM_Constant.jw_verify);
    return _cookie1.toString();
  }

  Future<Map<String, String>> get_logon_header() async {
    Map<String, String> header =
    {
      'cookie': await cookie1(),
    };
    header.addAll(GDGM_Constant.jw_logon_header);
    return header;
  }

  Future<String> get_logon() async {
    Response post = await gdgm_jw.post(
        GDGM_Constant.jw_login_sess,
        await get_logon_header(),
        queryPar: {
          'method': 'logon',
          'flag': 'sess',
        }
    );
    return post.data.toString();
  }

  Future<String> get_sess(String id, String pwd) async {
    return gdgm_jw.encodedToString(id, pwd, await get_logon());
  }

  Future<Map<String, String>> get_login_header() async {
    Map<String, String> header =
    {
      'cookie': await cookie1(),
    };
    header.addAll(GDGM_Constant.jw_login_header);
    return header;
  }

  String Set_session(List<Cookie> cookie1, List<Cookie> cookie2) {
    _session = gdgm_jw.Cookie_Trim(_cookie1, _cookie2);
    return _session;
  }

  Future<bool> Set_login(String id, String pwd) async {
    _OCR_token = await get_AccessToken();
    do {
      _num_verify += 1; // _num_verify + 1;
      print("尝试自动识别第" + _num_verify.toString() + "次验证码,返回结果：");
      _HOME = await get_HOME();
      _verifycode = await Get_verifycode();
      print(_verifycode);
    } while (_verifycode == "failed");
    _sess = await get_sess(id, pwd);
    return true;
  }

  Future<bool> login_jw() async {
    Response post = await gdgm_jw.post(
        GDGM_Constant.jw_login_sess,
        await get_login_header(),
        data: {
          "userAccount": '',
          "userPassword": '', //sess登录不需要填写
          "RANDOMCODE": _verifycode,
          "encoded": _sess,
        },
        queryPar: GDGM_Constant.jw_login_seee_query
    );
    if (post.statusCode == 302) {
      Map<String, String> login302option = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': await cookie1(),
      };
      Response login_302 = await gdgm_jw.get(
          post.headers['location']![0], login302option);
      _cookie2 = await gdgm_jw.cookieJar.loadForRequest(
          Uri.parse(post.headers['location']![0]));
    }
    else {
      _failed_status = showMsg(post.data);
      print(_failed_status);
      return false;
    }
    return true;
  }

  Future <List<dynamic>> get_stuinfo(bool refresh) async {
    _loginoption = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': refresh ? Set_session(_cookie1, _cookie2) : _session,
    };
    Response xsxx = await gdgm_jw.get(GDGM_Constant.jw_xsxx, _loginoption);
    List stuinfo = Table2List(xsxx.data)[0][2]; //存储登入学生的学籍信息
    //print("当前登入学生信息： \n" + _stuinfo.toString());
    return stuinfo;
  }

  Future <List<dynamic>> get_xskb(bool refresh) async {
    _loginoption = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': refresh ? Set_session(_cookie1, _cookie2) : _session,
      //refresh为真时重新计算cookie，否则按原有值替代
    };
    Response xskb = await gdgm_jw.get(GDGM_Constant.jw_xskb, _loginoption);
    List kb = Table2List(xskb.data)[0]; //存储登入学生的课表信息
    List new_kb = [];
    List tmp;
    for (int x = 0; x < kb.length; x++) {
      new_kb.add(kb[x]);
      for (int y = 0; y < kb[x].length; y++) {
        tmp = xskb_Trim(kb[x][y].toString());
        new_kb[x][y] = tmp;
      }
    }
    return new_kb;
  }
  //解析table标签
  List<dynamic> Table2List(String data) {
    Document ss = parse(data);
    List<dynamic> tables = [];
    List<Element> tablesHtml = ss.querySelectorAll('table');
    for (var tb in tablesHtml) {
      List<dynamic> table = [];
      tb.querySelectorAll('tr').forEach((tr) {
        List<dynamic> line = [];
        tr.querySelectorAll('th, td').forEach((td) {
          line.add(td.innerHtml);
        });
        table.add(line);
      });
      tables.add(table);
    }
    return tables;
  }

  String showMsg(String data) {
    Document tt = parse(data);
    String error = '';
    try {
      error = tt.querySelector('#showMsg')!.nodes[0].text!.trim();
      if (error == '') {
        error = "Error:未知的错误";
      }
    } catch (e) {
      error = 'Error：报错异常';
    }
    return error;
  }

  List<dynamic> xskb_Trim(String someDigits) {
    var someDigits_s = new RegExp(r"\<div [\s\S]*?\<\/div\>").allMatches(
        someDigits).map((m) => m.group(0)).toString();
    //.split('<div')[2];
    if (someDigits_s == "()") {
      return [];
    } else {
      someDigits_s = someDigits_s.split('<div')[2];
      var numbers = new RegExp(r'\>([\S]*?)\<');
      assert(numbers.hasMatch(someDigits_s));
      var out = [];
      var tmp = "";
      //test - ljcode
      //如果有调课记录，需要做标记分割
      for (var match in numbers.allMatches(someDigits_s)) {
        //去除无效字符后是否为空
        if (match.group(0).toString().replaceAll(
            new RegExp(r'[><, .);&nbspP]'), '') != '') {
          //是否有调课记录的尾标记 是就重置tmp
          if (match.group(0).toString().replaceAll(
              new RegExp(r'[><, .;&nbspP]'), '') == "---------------------") {
            out.add(tmp);
            tmp = "";
          } else { //不是就继续记下去
            tmp += match.group(0).toString().replaceAll(
                new RegExp(r'[><.;&]'), '') + " ";
          }
        }
      }
      //当不存在调课情况时自动添加上
      if (tmp != "") {
        out.add(tmp);
        tmp = "";
      }
      return out;
    }
  }
  List stuinfo() {
    return _stuinfo;
  }
  List kb(){
    return _kb;
  }

}