import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'gdgm.dart';
import 'gdgm_Constant.dart';

late GDGM_S gdgm_umooc;
late String _uid ;
late String _pwd;
late String _cookie;
late List<dynamic> _tdlist;
class GDGM_UC {
  GDGM_UC(String uid, String pwd) {
    _uid = uid;
    _pwd = pwd;
    gdgm_umooc = GDGM_S();
  }

  Future<bool> login() async {
    Response post = await gdgm_umooc.post(
        GDGM_Constant.umooc_login,
        GDGM_Constant.jw_login_header,
        data: {
          "j_password": md5.convert(Utf8Encoder().convert(_pwd)),
          'j_username': _uid,
        }, queryPar: {});
    if (post.statusCode == 302) {
        _cookie = await gdgm_umooc.Cookies_List(GDGM_Constant.umooc_login).toString();
        Map<String, String> login302option = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': _cookie
        };
        Response login_302 = await gdgm_umooc.get(
            GDGM_Constant.umooc + post.headers['location']![0], login302option);
        _cookie = "JSESSIONID=" + json.decode(login_302.data.toString())["sessionid"] + ";";
        await _worktodo(); //get-workTodo
        return true;
    }else{return false;}
  }

  _worktodo() async {
    Response get = await gdgm_umooc.get(
        GDGM_Constant.umooc_work,{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': _cookie
      });
    /*
      courseName -> 数据库原理及应用
      id -> 21456
      title -> 第7周作业2
      deadline -> 2022-06-10 22:00
      courseId -> 15343
     */
    _tdlist = json.decode(get.data.toString())['datas']['hwtList'];
  }


  Map<String, String> _todo(){
    //String str = "";
    List<String> work_time = [];
    Map<dynamic,dynamic> now ;
    //str += "课程名：" + now['courseName'] + "课程id" + now['id'] + "作业标题" + now['title'] + "截止时间" + now['deadline'];
    for (int i = 0; i < _tdlist.length; i++){
      now = _tdlist[i];
      work_time.add(now["deadline"] + ' ' +i.toString() );
    }
    work_time.sort((a,b) => a.compareTo(b));
    //按照datetime顺序放入map
    Map<String,String> work_now = Map();
    int x = 0;
    for (int i = 0; i < work_time.length; i++) {
      x = int.parse(work_time[i].split(' ')[2]);
      now = _tdlist[x];
      work_now[i.toString()] = now['courseName'] + ":   " + now["title"] + "    截止时间:    " + now["deadline"] + '\n';
    }
    return work_now;
  }


  /*
  String todo(){
    String str = "";
    Map<dynamic,dynamic> now ;
    for (int i = 0; i < _tdlist.length; i++){
      now = _tdlist[i];
      //str += "课程名：" + now['courseName'] + "课程id" + now['id'] + "作业标题" + now['title'] + "截止时间" + now['deadline'];
      str += now['courseName'] + ":   " + now["title"] + "    截止时间:    " + now["deadline"] + '\n';
    }
  }
  */

  String todo(){
    String str = "";
    Map<String, String> work_now = _todo();
    for (int i = 0; i < _tdlist.length; i++) {
      str+= work_now[i.toString()]!;
    }
    return str;
  }

  Map<String,String> map_todo(){
    Map<String, String> work_now = _todo();
    return work_now;
  }

  List<dynamic> todolist(){
    return _tdlist;
  }

  Future<String> get_session() async {
    return _cookie;
  }


}