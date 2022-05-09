//根据给定字符串或JSON解析其中的周数与课程
import 'dart:io';
import 'dart:convert';

class GDGM_KC{

  late List<dynamic> _kb;

  GDGM_KC(this._kb);

  GDGM_KC.file(String route){
    //读取JSON 然后写入kb
    try{
      File s = File(route);
      String wjson = s.readAsStringSync();
      _kb = json.decode(wjson);
    }
    catch(e){}
  }


  List<String> kc_week(int ord, int week) //星期几 第几周
  {
    List<String> sec = [];
    for(int i = 1; i <= 6; i++){
      sec.add(kc_day(i, ord, week));
    }
    return sec;
  }

  List<String> bzkc_week(int ord) //星期几 第几周
  {
    List<String> sec = [];
    for(int i = 1; i <= 6; i++){
      sec.add(bzkc_day(i, ord));
    }
    return sec;
  }
  String kc_day(int sec,int ord, int week) { //第几大节, 星期几，第几周
    List day = _kb[sec][ord];
    List now ;
    List now_week;
    List now_sec;
    String now_str = "";

    for (int i = 0; i < day.length; i++){
      now = day[i].split(" ");
      // '9-11-16(周)[01-02节]'
      // List - day -
      // - 0 课程名- 形势与政策I
      // - 1 教师- 钟凯龙
      // - 2 周数- 14-17(周)[01-02节]
      // - 3 地点- 综405
      now_week = new RegExp(r'(\S)*\(').allMatches(day[i]).map((m) => m.group(0)).toString().replaceAll(new RegExp(r'[() ]'), '').split(',');
      /*
        if (now_week.length <= 2) {
          //如果表诉形式是1-16周或者1周
          for (int i = int.parse(now_week[0]); i <int.parse(now_week[now_week.length - 1]); i++) {
            if (i == week) {
              now_str += now[0] + now[1] + now[2] + now[3];
              break;
            }
          }
        }
       */
      //判断所属周
      for (var value in now_week) {
        if (value != ""){
        now_sec = value.split('-');
        for (int i = int.parse(now_sec[0]); i <= int.parse(now_sec[now_sec.length - 1]); i++) {
          if(i == week){
            now_str += now[0] + now[1] + now[2] + now[3];
            break;
          }
        }}
      }
    }
    if (now_str == "") {now_str = "第" + sec.toString() + "大节没有课哦！";}
    return now_str;
  }

  String bzkc_day(int sec,int ord) { //第几大节, 星期几
    String day = _kb[sec][ord];
    if(day == ""){day = "第" + sec.toString() + "大节没有课哦！";}
    return day;
  }

  String kc_mail(List<String> body){
    String str = '<h1>今日课表！</h1>\n';
    for (var value in body) {
      str += '<h3>' + value + "</h3>\n";
    }
    return str;
  }

  void Byte2file(List<int>bytes, String f) {
    try {
      File s = File(f);
      s.writeAsBytesSync(bytes, mode: FileMode.write, flush: true);
    } catch (e) {}
  }
  String kc_json(){
    return json.encode(_kb);
  }

  void kc_Json2file(String route){
    try{
      String str = kc_json();
      File s = File(route);
      s.writeAsStringSync(str,mode:FileMode.write,flush: true);
    } catch(e){}
  }




}