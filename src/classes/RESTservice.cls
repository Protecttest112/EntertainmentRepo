@RestResource(urlMapping='/myrequest/*')

global class RESTservice {

@HttpPost

global static String resultsDisplay( String City){
List<Requisition__c> listReq= [SELECT Id,Job_Order_Challenges__c from Requisition__c where Location_City__c =: City Limit 1];
if(listReq.size()>1){
return listReq[0].Job_Order_Challenges__c ;
}
return 'No Match Found';
}
}