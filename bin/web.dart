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
    msg.base("运行错误", "启动异常", DateTime.now().toString() + modname + "模块启动失败，即将退出程式!");
    exit(0);
  }
  print(modname + "模块启动失败，重试状态：" + err.toString() + "/3");
  err +=1;
  return err;
}

void main() async {
  final app = Alfred();
  int strport = 8080;
  var ss;

  try{
    File s = File(r".\gdgm.json");
    var config = await s.readAsString();
    ss = json.decode(config);
  } catch(e){
    print("读配置异常，即将退出程式!");
    exit(0);
  }

  Mail msg = Mail(ss['msg']['mail']['host'], ss['msg']['mail']['port'], ss['msg']['mail']['uid'], ss['msg']['mail']['pwd'], ss['msg']['mail']['ciphost']);

  int err = 1;
  bool sss = true;
  bool login_s;

  if(ss['jw']['enabled']){
    GDGM_JW jw = GDGM_JW(ss['jw']['jw_user'], ss['jw']['jw_pwd'], ss['jw']['ocr_AK'], ss['jw']['ocr_SK']);
    print("正在请求登入教务系统");
    while (sss) {
      try {
        login_s = await jw.login_jw();
        if(login_s) {sss = false;}else{err = errmes("教务模块", err,msg);}
      }
      catch (e) {err = errmes("教务模块", err,msg);}
    }
    GDGM_KC xs_kb = GDGM_KC(jw.kb());
    GDGM_KC bz_kb = GDGM_KC(jw.bzkb());
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
  }

  if(ss['umooc']['enabled']) {
    err = 1;
    sss = true;
    print("正在请求登录优慕课系统");
    GDGM_UC umooc = GDGM_UC(ss['umooc']['umooc_user'], ss['umooc']['umooc_pwd']);

    while (sss) {
      try {
        login_s = await umooc.login();
        if (login_s) {sss = false;} else {err = errmes("优慕课模块", err,msg);}
      }
      catch (e) {err = errmes("优慕课模块", err,msg);}
    }
    app.get('/todo', (req, res) => json.encode(umooc.map_todo()));
  }
  
  print("服务器启动，目的端口=>" + strport.toString());

  await app.listen(strport);

  //kc.kc_Json2file(r".\kc.json"); //保存课表到本地
  //List<String> today = kc.kc_week(3, 11);
  //print(json.encode(umooc.map_todo()));
  //app.get('/today', (req, res) => json.encode(today));

}
