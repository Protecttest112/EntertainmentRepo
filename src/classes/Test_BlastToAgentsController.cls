@isTest
public class Test_BlastToAgentsController
{
    public static testMethod void testBlastToAgents() {
        
        Account a0 = new Account(Name='test account0');
        insert a0;
        
        Contact c0 = new Contact(FirstName='tfn0', LastName='tln0', AccountId=a0.Id,Agent_Interested_Categories__c='Mechanical:Quality Assurance;',
                                email='test@test.com',
                                Agent_Interested_Locations__c='testcity,teststate,1111;',Referral_Agent__c='Yes',Receive_Position_Notifications__c=true);
        insert c0;
        
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
        req.Location_zip__c='1111';
        req.Location_city__c='testcity';
        req.Location_state__c='teststate';       
        req.Recruiter__c = userinfo.getuserid();
        insert req;
        
        
        
        PageReference pageRef = Page.BlastToAgents;
        pageref.getparameters().put('id',req.Id);
        Test.setCurrentPage(pageRef);
        BlastToAgentsController ba=new BlastToAgentsController();
        ba.process();
        system.assertEquals(ba.noOfContacts,1);
        
    }
}