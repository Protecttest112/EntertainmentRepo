public class toolingRESTAPI {




public void restAPI(){

String a='01pi0000005agDZ';
HttpRequest req = new HttpRequest();
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
req.setHeader('Content-Type', 'application/json');
req.setEndpoint('https://na15.salesforce.com/services/data/v33.0/tooling/apexManifest/');
//req.setBody('{"Name":"Test Container"}');
req.setMethod('GET');
Http h = new Http();
HttpResponse res = h.send(req);
system.debug('Real Response:'+res.getBody());
}

}