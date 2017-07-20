public class sessionCall {
    
    public String sid;
    public String Name{get;set;}
    public String Phone{get;set;}
    public String Descwe{get;set;}
    public String AccNum{get;set;}
    soapSforceComSchemasClassExposeserv.SessionHeader_element s=new soapSforceComSchemasClassExposeserv.SessionHeader_element();
    partnerSoapSforceCom.Soap partnerSoap= new partnerSoapSforceCom.Soap();
    partnerSoapSforceCom.loginResponse_element par = new partnerSoapSforceCom.loginResponse_element();
    partnerSoapSforceCom.SessionHeader_element header = new partnerSoapSforceCom.SessionHeader_element();
    
    String username='abhik.dey01@datasource.com';
    String Pwd = '%TGB6yhn';
    
    public void getOAuthCode(){
        partnerSoapSforceCom.LoginResult result = new partnerSoapSforceCom.LoginResult();
        result = partnerSoap.login(username,Pwd);
        sid = result.sessionId;
        system.debug('result11'+sid);
        makeServiceCall();
    }
    
    public void makeServiceCall(){
        soapSforceComSchemasClassExposeserv.exposeService exposeClass = new soapSforceComSchemasClassExposeserv.exposeService();
        exposeClass.SessionHeader = new soapSforceComSchemasClassExposeserv.SessionHeader_element();
        exposeClass.SessionHeader.sessionId= sid;
        exposeClass.payloadElement(Name,Phone,Descwe);
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Data Send Successfully');
        ApexPages.addMessage(myMsg);
    }
}