@isTest
public class Test_ReferralAgentFormController
{
    public static testMethod void testReferralAgentForm() {        
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
        
        System.runAs(u) {
            ReferralAgentFormController refController = new ReferralAgentFormController();            
            refController.addLocationFilter();
            refController.addLocationFilter();
            refController.rowNumToDel = 1;
            refController.remLocationFilter();
            
            refController.addCategoryFilter();
            refController.addCategoryFilter();
            refController.rowNumToDel = 1;
            refController.remCategoryFilter();
            
            refController.locationFilter.state='Viginia';
            refController.locationFilter.city='Herndon';
            refController.locationFilter.zip='20171';
            
            Requisition__c testReq = new Requisition__c(Job_Function__c='Engineering',Skill__c='Civil');
            refController.categoryFilter.req = testReq;            
            
            refController.submitAgentForm();
        }
    }
}