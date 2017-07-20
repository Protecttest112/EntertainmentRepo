public class My_Form {

    private final ApexPages.StandardController theController;
    soapSforceComSchemasClassExposeserv.SessionHeader_element s=new soapSforceComSchemasClassExposeserv.SessionHeader_element();
    
    public My_Form(ApexPages.StandardController controller) {
        theController = controller;
    }
    
    public void callService(){
    
    String clientId = '3MVG9Y6d_Btp4xp4pvIoes7juV9MOIUQSdI0mFzMvqoRUfYWrlGvyP1dQM_KxATvm.DVFdrZn3t50S8Ya1jIY';
    String clientSecret = '5969879287682473920';
    String eUrl='https://na15.salesforce.com';
    String reqbody = 'response_type=code&client_id='+clientId+'&client_secret='+clientSecret;
    String ep = eUrl+'/services/oauth2/authorize?'+reqbody;
    System.debug('fullurl'+ep);
    }
    
    public void callSubmit(){
        soapSforceComSchemasClassExposeserv.exposeService exposeClass = new soapSforceComSchemasClassExposeserv.exposeService();
        exposeClass.SessionHeader = new soapSforceComSchemasClassExposeserv.SessionHeader_element();
        exposeClass.SessionHeader.sessionId= '00D90000000uWUk!AQUAQL8qAslxgdTqBVo520ddb1pcpAIxpDUj7EsHnNke1ZA8qp5NgVLiLX0D7wdGDCtTLLgezpqUbeMhO6sP1rY3JS561rv';
        exposeClass.payloadElement('Name','123456788','test');
    }

}