class GDGM_Constant{
  static final jw_verify = "https://jw.gdgm.cn/verifycode.servlet";
  static final jw_login_sess = 'https://jw.gdgm.cn/Logon.do';
  static final jw_login_seee_query = {'method': 'logon'};
  static final jw_xsxx = "https://jw.gdgm.cn/jsxsd/grxx/xsxx";
  static final jw_bzkb = "https://jw.gdgm.cn/jsxsd/framework/main_index_loadkb.jsp";//?rq=2022-04-28&sjmsValue=qb"; 本周课表
  static final jw_xskb = "https://jw.gdgm.cn/jsxsd/xskb/xskb_list.do";
  static final accesstoken = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&";
  static final ocr = "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic";
  static final umooc = "https://umooc.gdgm.cn";
  static final umooc_login = 'https://umooc.gdgm.cn/mobile/login_check.do';
  static final umooc_work = 'https://umooc.gdgm.cn/mobile/hw/stu/findStuUnDoHwTaskList.do';
  static final Map<String,String> verifycode_head ={
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'
  };
  static final Map<String,String> jw_login_header = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Cache-Control': 'max-age=0',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Host': 'jw.gdgm.cn',
    'Origin': 'https://jw.gdgm.cn',
    'Referer': 'https://jw.gdgm.cn/',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'
  };
  static final Map<String, String> jw_logon_header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36',
    'content-type': 'application/json',
  };

}