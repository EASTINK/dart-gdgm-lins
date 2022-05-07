import 'package:gdgm_lins/gdgm_Jw.dart';
import 'package:gdgm_lins/gdgm_msg.dart' as Mail;
import 'package:gdgm_lins/gdgm_kc.dart';
import 'package:gdgm_lins/gdgm_umooc.dart';

//test parm @lins:
void main() async {
  /*GDGM_JW jw =
              GDGM_JW(
                  '教务系统账号', '教务系统密码', //uid,passwd
                  '百度云OCRAK', //AK
                  '百度云OCRSK'); //SK
   */
  //await jw.init(); //初始化

  //从jw.kb()加载课表
  //GDGM_KC kc = await GDGM_KC(jw.kb());
  // kc.kc_Json2file(r".\kc.json"); //保存课表到本地

  //从本地加载课表
  //GDGM_KC kc = GDGM_KC.file(r".\kc.json");

  //var body =   kc.kc_week(5, 9);//得到第九周星期5的课表

/*  await Mail.Mail(
    '邮件服务器', 端口, '邮箱账户', '登录密钥/密码',
    '课表推送', '收信人','上课咯！',  //发信人名称，收信人，邮件标题
     htmlbody: body);   //发信内容
*/

/*GDGM_UC umooc = GDGM_UC("优慕课账户", "优慕课密码");
  await umooc.login();
  print(umooc.todo());
*/







}