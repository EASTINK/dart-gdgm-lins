import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

//SMTP推送的轻微封装
class Mail{
  Mail(String host,int port,String? uid,String? pwd,
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
}