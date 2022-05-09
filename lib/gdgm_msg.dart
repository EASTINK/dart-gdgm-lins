import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

//SMTP推送的轻微封装
class Mail{

  var _host = '',
      _port = 25,
      _uid = '',
      _pwd = '',
      _ciphost = '';
  /*
      _fromname = '',
      _ciphost = '',
      _subject = '';
   */
  Mail(String host,int port,String uid,String pwd,String ciphost){
    _host = host;
    _port = port;
    _uid = uid;
    _pwd = pwd;
    _ciphost = ciphost;
  }

  //上课啦
  _Mail_skl(String host,int port,String? uid,String? pwd,
      String fromname,String ciphost,String subject,
      {String htmlbody = ' ',String imgroute = 'kbts.png', String cid = "<img>"}
      ) {
    final smtpServer = SmtpServer(host,port: port,username: uid,password: pwd);
    final NewMessage= Message()
      ..from = Address(uid!, fromname)
      ..recipients.add(Address(ciphost))
      ..ccRecipients.addAll([Address(ciphost)])
      ..bccRecipients.add(ciphost)
      ..subject = subject
      ..text = ''
      ..html = htmlbody + '<img src="cid:img"/>'
      ..attachments = [ FileAttachment(File(imgroute))
          ..location = Location.inline
          ..cid = cid  //'<img>'
      ];
    _send(smtpServer, NewMessage);
  }

  _send(SmtpServer server,Message msg) async{
    var connection = PersistentConnection(server);
    await connection.send(msg);
    await connection.close();
  }

  //简单body发信
  _Mail_Base(String host,int port,String? uid,String? pwd,
      String fromname,String ciphost,String subject,
      {String htmlbody = ' '}
      ) {
    final smtpServer = SmtpServer(host,port: port,username: uid,password: pwd);
    final NewMessage= Message()
      ..from = Address(uid!, fromname)
      ..recipients.add(Address(ciphost))
      ..ccRecipients.addAll([Address(ciphost)])
      ..bccRecipients.add(ciphost)
      ..subject = subject
      ..text = ''
      ..html = htmlbody;
    _send(smtpServer, NewMessage);
  }
  skl(String fromname,String subject,String htmlbody){
    _Mail_skl(_host, _port, _uid, _pwd, fromname, _ciphost, subject,htmlbody: htmlbody);
  }
  base(String fromname,String subject,String htmlbody){
    print(htmlbody);
    _Mail_Base(_host, _port, _uid, _pwd, fromname, _ciphost, subject,htmlbody: htmlbody);
  }
}