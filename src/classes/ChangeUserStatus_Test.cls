@isTest
public class ChangeUserStatus_Test {
    public static User userAct = null;
    public static User userDeAct = null;
    public static Account acc1 = null;
    public static Account acc2 = null;
    public static Contact con1 = null;
    public static Contact con2 = null;
    public static set<Id>testAccIds;
    
   static void init()
    {
        // create an account
        acc1 = new account();
        acc1.name='Test Account 1';
        insert acc1; 
        // create an Contact
        con1 = new Contact();
        con1.lastname='Test Contact 1';
        con1.accountId=acc1.Id;
        insert con1; 
        acc2 = new account();
        acc2.name='Test Account 2';
        insert acc2; 
        // create an Contact
        con2 = new Contact();
        con2.lastname='Test Contact 2';
        con2.accountId=acc2.Id;
        insert con2; 
      
        // create user to activate
        userAct = new User();
        Profile p = [SELECT Id FROM Profile WHERE UserType IN ('PowerCustomerSuccess','CustomerPortalUser') limit 1];
        userAct.Alias = 'UserAct';
        userAct.Email='standarduserACT@testorg.com';
        userAct.profileId=p.Id;
        userAct.EmailEncodingKey='UTF-8';
        userAct.LastName='Testing32ACT';
        userAct.LanguageLocaleKey='en_US';
        userAct.LocaleSidKey='en_US';
        userAct.TimeZoneSidKey='America/Los_Angeles';
        userAct.UserName='DemouserACT@testorg.com';
        userAct.isActive = true;
        userAct.Active_Previously__c=false;
        userAct.ContactId = con1.Id;
        insert userAct;
        // create user to Deactivate
        userDeAct = new User();
        userDeAct.isActive = false;
        userDeAct.Active_Previously__c=true;
        userDeAct.Alias = 'Demouser';
        userDeAct.Email='standarduser@testorg.com';
        userDeAct.EmailEncodingKey='UTF-8';
        userDeAct.LastName='Testing32';
        userDeAct.LanguageLocaleKey='en_US';
        userDeAct.LocaleSidKey='en_US';
        userDeAct.ProfileId = p.Id;
        userDeAct.TimeZoneSidKey='America/Los_Angeles';
        userDeAct.ContactId = con2.Id;
        userDeAct.UserName='Demouser@testorg.com';
        insert userDeAct;
        testAccIds = new set<Id>{acc1.id,acc2.Id};
            
            } 
    static testMethod void updateUserStatusTestMethod()
    {
        Test.startTest();
        init();  
        ChangeUserStatus.updateUserStatus(testAccIds,true);
        ChangeUserStatus.updateUserStatus(testAccIds,false);
        Test.stopTest();
    }
    
    
    
}