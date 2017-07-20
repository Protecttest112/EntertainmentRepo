public class CaseWSDL {

    public caseWSDL(){
        case c = [select Id,description from case where id = '500i000000v4rly'];
        schemaWsSfdcCasesse.CreateCaseRequest f1 = new schemaWsSfdcCasesse.CreateCaseRequest();
        schemaWsSfdcCasesse.CreateCaseResponse res = new schemaWsSfdcCasesse.CreateCaseResponse();
        schemaWsSfdcCasesse.ServiceRequestTicket restckt = new schemaWsSfdcCasesse.ServiceRequestTicket();
        schemaWsSfdcCasesse.Error  errorRes = new schemaWsSfdcCasesse.Error ();
    	f1.caseId = 'asd';
        f1.organizationNumber='123';
        f1.customerName='Reseller Account';
        f1.tcid='678';
        f1.problemSummary='Issues';
        f1.groupName='Test Group';
        f1.note='My note 4';
        f1.hasAttachment=False;
        serviceWsSfdcCasesse.ServicePortTypeEndpoint mainclass = new serviceWsSfdcCasesse.ServicePortTypeEndpoint();
        res = mainclass.createCase(f1);
        restckt= res.serviceRequestTicket;
        errorRes = res.error;
        String description = errorRes.description;
        String errcode = errorRes.code;
        
        datetime responseTime = restckt.resolveTime;
        String ticktnumber = restckt.serviceRequestNumber;
    }
}