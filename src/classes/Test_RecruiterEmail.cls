@isTest
public class Test_RecruiterEmail{
    
    public static testMethod void testRecruiterEmail() 
    {
        Account a0 = new Account(Name='test account0');
        insert a0;
        
        Contact c0 = new Contact(FirstName='tfn0', LastName='tln0', AccountId=a0.Id,Agent_Interested_Categories__c='Mechanical:Quality Assurance;',
                                email='test@test.com',
                                Agent_Interested_Locations__c='testcity,teststate,1111;',Referral_Agent__c='Yes',Receive_Position_Notifications__c=true);
        insert c0;
        
        contact c1=new contact(lastname='test',email='test2@test.gmail');
        insert c1;
        
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
        
        Referral__c ref=new Referral__c();
        ref.Requisition__c=req.id;
        ref.referred_candidate__c=c0.id;
        ref.Referrer__c=c1.id;
        ref.active__c=true;
        insert ref;
        
        RecruiterEmailTemplateController re=new RecruiterEmailTemplateController();
        re.recruiterId=userinfo.getuserid();
        re.getReferrals();
        
        batchEmailRecruiters btemail=new batchEmailRecruiters();
        Id p= Database.executeBatch(btemail);
    }
    
}