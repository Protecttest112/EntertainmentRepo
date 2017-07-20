@isTest
public class Test_contactTrigger
{
    static testmethod void testcontacttrigger()
    {
        Account newAcc=new Account(name='test account');
        insert newAcc;
        
        Contact newCon=new Contact(lastname='test123', accountid=newacc.id, email='test@test.com',Referred_Candidate__c='Yes');
        insert newCon;
        
        Contact newCon1=new Contact(lastname='test1234', accountid=newacc.id,email='test@gmail.com');
        insert newCon1;
          Requisition__c req = new Requisition__c();
          req.Number_of_openings__c = 10;
          req.Requisition_Title__c = 'Title'  ;
          req.Title_By_Manager__c = 'Test';
          req.Recruiting_Team__c = 'Engineering';
          req.Job_Function__c = 'Mechanical';
          req.Skill__c = 'Quality Assurance';
          req.Requisition_Type__c = 'Contract';
          req.DOT_Drug_Screen__c = 'No';
          req.Branch__c = 'test';
          req.Job_Duration__c = 12 ;
         
          req.Recruiter__c = userinfo.getuserid();
          insert req;
          
          Referral__c ref=new Referral__c();
          ref.Referred_Candidate__c=newcon.id;
          ref.requisition__c=req.id;
          ref.active__c=true;
          ref.Referrer__c=newCon1.id;
          insert ref;
          
          newcon.Referred_Candidate__c='No';
          update newcon;
    }
}