import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class GDGM_S{
  static late Dio gdgm_s; //= new Dio();
  final CookieJar cookieJar = new CookieJar();

  GDGM_S(){
    init();
  }
//初始化设置
  init(){
    gdgm_s = new Dio();
    gdgm_s.interceptors.add(CookieManager(cookieJar));
    //302设置
    gdgm_s.options.followRedirects = false;
    gdgm_s.options.validateStatus = (status) {return status! < 500;};
    // 请求拦截器设置
    gdgm_s.interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          //发送前设置
          return handler.next(options);
        },

        onResponse:(response,handler) {
          // 在返回响应数据之前做一些预处理
          return handler.next(response);
        },

        onError: (DioError e, handler) {
          // 当请求失败时做一些预处理
          dynamic _onError(DioError e) {

            if (e.response?.statusCode == 302){
              //to do?
            }

            return e;
          }

          if (e.type == DioErrorType.other){
            print("网络错误或者服务器炸了！");
          }

          return  handler.next(e);
        }

      ));
  }
// Cookie输出 date 4.6
  Future<List<Cookie>> Cookies_List(String url) async{
    List<Cookie> result = await this.cookieJar.loadForRequest(Uri.parse(url));
    return result;
  }
// get封装 date 4.8
  Future<Response> get (String url,Map<String, String> header, {bool Bytes = false}) async{
    gdgm_s.options.headers = header;

    var result = Bytes?
    (await  gdgm_s.get(url,options: Options(responseType: ResponseType.bytes)))//Bytes为true时,gdgm_s.data为List<_Uint8List>
        :
    (await gdgm_s.get(url));
    return result;
  }
// post封装 date 4.8
  Future<Response> post (String url, Map<String, String> header,{dynamic data,required Map<String, String> queryPar}) async{
    gdgm_s.options.headers = header;
    var result = await gdgm_s.post(url,data: data,queryParameters: queryPar);
    return result;
  }
// Cookie拼接 date 4.8
  String Cookie_Trim(List<Cookie> Cookie1,List<Cookie> Cookie2){
    var a = Cookie1[0].name + '=' + Cookie1[0].value + ';';
    var b = Cookie2[0].name + '=' + Cookie1[0].value + ';';
    return a + b;
  }

//#lins 登录核心算法 date：4.4
  String encodedToString(String id, String pwd, String logon){
    var scode = logon.split("#")[0];
    var sxh = logon.split("#")[1];
    var encoded = "";
    var code = id + "%%%" + pwd;
    //核心算法
    for (var i = 0; i < code.length; i++)
    {
      if (i < 20) {
        encoded = encoded + code.substring(i, i + 1) +
            scode.substring(0, int.parse(sxh.substring(i, i + 1)));
        scode = scode.substring(int.parse(sxh.substring(i, i + 1)), scode.length);
      } else {
        encoded = encoded + code.substring(i, code.length);
        i = code.length;
      }
    }
    return encoded;
  }
}