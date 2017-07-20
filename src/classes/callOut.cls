public class callOut {
public String varCode {get;set;}

soapSforceComSchemasClassExposeserv.SessionHeader_element s=new soapSforceComSchemasClassExposeserv.SessionHeader_element();

    public callOut() {  
        varCode = ApexPages.currentPage().getParameters().get('code');
        system.debug('code'+varCode);
    }
    
    public boolean nVisible {get;set;}
    
    String clientId = '3MVG9Y6d_Btp4xp4pvIoes7juV9MOIUQSdI0mFzMvqoRUfYWrlGvyP1dQM_KxATvm.DVFdrZn3t50S8Ya1jIY';
    String clientSecret = '5969879287682473920';
    String eUrl='https://na15.salesforce.com';
   
    public pagereference getOAuthCode(){

        String reqbody = 'response_type=code&client_id='+clientId+'&client_secret='+clientSecret+'&redirect_uri=https://c.na15.visual.force.com/apex/SendServiceDetails';
        String ep = eUrl+'/services/oauth2/authorize?'+reqbody;
        system.debug('ep : '+ep);
        Pagereference pg = new PageReference(ep); 
            
        return pg;
    }
    
    public void makeServiceCall(){
        if(String.isBlank(varCode)) return;
        soapSforceComSchemasClassExposeserv.exposeService exposeClass = new soapSforceComSchemasClassExposeserv.exposeService();
        exposeClass.SessionHeader = new soapSforceComSchemasClassExposeserv.SessionHeader_element();
        exposeClass.SessionHeader.sessionId= varCode;
        exposeClass.payloadElement('Name','123456788','test');
    }

}