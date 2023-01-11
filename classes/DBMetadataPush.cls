@RestResource(urlMapping='/dbmp/*')
global with sharing class DBMetadataPush {
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug(req);
        return '123@ABC';
    }
  
    @HttpPost
    global static String doPost()  //String name, String phone, String website
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //system.debug(req);
        Map<String, String> hdrs = req.headers;
        for(string h : hdrs.keySet()){
            system.debug(h + '=' + hdrs.get(h));
        }
        return '345@ABC';
    }
}