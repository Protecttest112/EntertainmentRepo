@isTest
public class TestReferralFormController {
    public static testMethod void testReferralForm() {
        Account a0 = new Account(Name='test account0');
        insert a0;
        
        Contact c0 = new Contact(FirstName='tfn0', LastName='tln0', AccountId=a0.Id);
        insert c0;
        
        Profile[] profiles = [Select p.name, p.id From Profile p where p.UserLicense.Name like '%Customer Portal%'];
         User u = new User(
            ContactId = c0.Id,
            Username = 'testportaluser@test.com',
            Email = 'testportaluser@test.com',
            LastName = 'lastname',
            Alias = 'alias',
            ProfileID = profiles[0].Id,
            PortalRole = 'Manager',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey='UTF-8'
        );
        insert u;
        
        Attachment att = new Attachment(Name='test', body=Blob.valueOf('test body'), ParentId=c0.Id);
        insert att;
        
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
        
        System.runAs(u) {
            ApexPages.currentPage().getParameters().put('id', req.Id);
            ReferralFormController rfc = new ReferralFormController();
            rfc.referral.Name='test referral';
            rfc.referral.Contact_Email__c='test@test.com';
            rfc.agreed = true;
            rfc.referral.Referral_Name__c='test referral';
            rfc.referral.Referrer_Comments__c='test comments';
            rfc.referral.Referred_Candidate__c = c0.Id;
            rfc.attach.name = att.name;
            rfc.attach.body = att.body;
            
            rfc.SubmitReferral();
            
            RequisitionCandidate__c app = new RequisitionCandidate__c(id=rfc.referral.application__c);
            app.hire_date__c = System.today();
            update app;
            
            //rfc.createApplication();
            
            rfc.createNewContact();
            
            rfc.question='test question';
            //rfc.submitcase();
            
            rfc = new ReferralFormController();
            rfc.SubmitReferral();
           // rfc.submitcase();
        }
    }
}