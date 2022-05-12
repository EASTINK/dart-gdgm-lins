import 'package:gdgm_lins/gdgm_Jw.dart';
import 'package:gdgm_lins/gdgm_msg.dart';
import 'package:gdgm_lins/gdgm_kc.dart';
import 'package:gdgm_lins/gdgm_umooc.dart';
import 'dart:io';
import 'package:alfred/alfred.dart';
import 'dart:convert';
//test parm @lins:

int errmes(String modname,int err,Mail msg){
  if(err > 3){
    msg.base("运行错误", "启动异常", DateTime.now().toString() + modname + "模块启动失败");//，即将退出程式!");
    //exit(0);
  }
  print(modname + "模块启动失败，重试状态：" + err.toString() + "/3");
  err +=1;
  return err;
}

Future<GDGM_JW> r_jw(dynamic jw,Mail msg,dynamic ss) async{
  print("正在请求登入教务系统");
  int err = 1;
  bool sss = true;
  bool loginS;
  jw = GDGM_JW(ss['jw']['jw_user'], ss['jw']['jw_pwd'], ss['jw']['ocr_AK'], ss['jw']['ocr_SK']);
  while (sss) {
    try {
      loginS = await jw.login_jw();
      if(loginS) {sss = false;}else{err = errmes("教务模块", err,msg);}
    }
    catch (e) {err = errmes("教务模块", err,msg);}
  }
  return jw;
}

Future<GDGM_UC> r_umooc(dynamic uc,Mail msg,dynamic ss) async{
  print("正在请求登录优慕课系统");
  int err = 1;
  bool sss = true;
  bool loginS;
  uc = GDGM_UC(ss['umooc']['umooc_user'], ss['umooc']['umooc_pwd']);
  while (sss) {
    try {
      loginS = await uc.login();
      if (loginS) {sss = false;} else {err = errmes("优慕课模块", err,msg);}
    }
    catch (e) {err = errmes("优慕课模块", err,msg);}
  }
  return uc;
}

config() async{
  String config;
  try{
    File s = File(r".\gdgm.json");
    config = await s.readAsString();
  } catch(e){
    print("读配置异常，即将退出程式!");
    exit(0);
  }
  return json.decode(config);
}

void main() async {

  final app = Alfred();
  int strport = 8080;
  var ss;
  dynamic jw;
  dynamic xs_kb;
  dynamic bz_kb;
  dynamic uc;

  ss = await config();

  Mail msg = Mail(ss['msg']['mail']['host'], ss['msg']['mail']['port'], ss['msg']['mail']['uid'], ss['msg']['mail']['pwd'], ss['msg']['mail']['ciphost']);
  strport = int.parse(ss['port']);


  if(ss['jw']['enabled']){
    jw = null;
    jw = await r_jw(jw,msg,ss);
    xs_kb = GDGM_KC(jw.kb());
    bz_kb = GDGM_KC(jw.bzkb());
    //api config @lins 5-9
    app.get('/today',(req, res) async{
      try {
        var week_xq = int.parse(req.uri.queryParameters['xq']!);
        res.writeln(json.encode(bz_kb.bzkc_week(week_xq)));
      }catch(e){
        res.writeln("请求有误！");
      }
    });
    app.get('/day', (req, res) async {
      try {
        var week_xq = int.parse(req.uri.queryParameters['xq']!);
        var week_zs = int.parse(req.uri.queryParameters['zs']!);
        res.writeln(json.encode(xs_kb.kc_week(week_xq, week_zs)));
      }catch(e){
        res.writeln("请求有误！");
      }
    });
    app.get('/jwc', (req, res) async {
      try{
        var jw_sec = req.uri.queryParameters['sec']!;
        if(jw_sec == ss['jw']['jw-sec']){
          res.write(await jw.get_session());
        }
      }catch(e){
        res.writeln("请求有误！");
      }
    });
  }

  if(ss['umooc']['enabled']) {
    uc = null;
    uc = await r_umooc(uc, msg,ss);
    app.get('/todo', (req, res) => json.encode(uc.map_todo()));

    app.get('/uwc', (req, res) async {
      try{
        var uc_sec = req.uri.queryParameters['sec']!;
        if(uc_sec == ss['umooc']['uc-sec']){
          res.write(await uc.get_session());
        }
      }catch(e){
        res.writeln("请求有误！");
      }
    });

  }

  app.get('/Refresh', (req, res) async {
    try {
      var server = req.uri.queryParameters['server']!;
      var session = req.uri.queryParameters['session']!;

    if (server == 'jw') {
      if (ss['jw']['enabled']) {
        if (jw != null) {
          if (await jw.get_session() == session) {
            jw = null;
            jw = await r_jw(jw, msg, ss);
            xs_kb = GDGM_KC(jw.kb());
            bz_kb = GDGM_KC(jw.bzkb());
          }
        }else{
          jw = await r_jw(jw, msg, ss);
          xs_kb = GDGM_KC(jw.kb());
          bz_kb = GDGM_KC(jw.bzkb());
        }
      }
    }
    if(server == 'umooc') {
      if (ss['umooc']['enabled']) {
        if (uc != null) {
          if (await uc.get_session() == session) {
            uc = null;
            uc = await r_umooc(uc, msg, ss);
          }
        }else{
          uc = await r_umooc(uc, msg, ss);
        }
      }
    }

    }catch(e){
      if(e.toString() == "Null check operator used on a null value"){res.write("非法请求");}else res.write(e.toString());
    }
  });

  app.get('/status', (req, res) async {
    try {
      //给出运行状态
      var server = req.uri.queryParameters['server']!;
      var status = "stop";

      if(server == 'jw'){
        if (ss['jw']['enabled']) {
          if(jw != null){
            status = "run";
          }
        }
      }

      if(server == 'uc'){
        if (ss['umooc']['enabled']) {
          if(uc != null){
           status = "run";
          }
        }
      }
      res.write(status);
    }catch(e){
      res.write('非法请求');
    }
  });

  print("服务器启动，目的端口=>" + strport.toString());
  await app.listen(strport);

  //kc.kc_Json2file(r".\kc.json"); //保存课表到本地
  //List<String> today = kc.kc_week(3, 11);
  //print(json.encode(umooc.map_todo()));
  //app.get('/today', (req, res) => json.encode(today));

}
