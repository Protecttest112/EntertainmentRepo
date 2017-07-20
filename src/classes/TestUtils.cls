@istest
public class TestUtils
{
    public static contact createContact()
    {
        Account a0 = new Account(Name='test account0');
        insert a0;
        
        Contact c0 = new Contact(FirstName='tfn0', LastName='tln0', AccountId=a0.Id);
        insert c0;
        return c0;
    }
    public static Requisition__c createRequisition()
    {
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
        req.Location_state__c='New York';
        req.Recruiter__c = userinfo.getuserid();
        req.Posted_Date__c=System.TODAY()+10;
        insert req; 
        return req; 
    }
    public static Saved_search__c createSavedSearch(Id conid)
    {
        Saved_search__c search=new Saved_search__c();
        search.Search_Name__c='test';
        search.Active__c=true;
        search.Query__c='Select Id, requisition_title__c,Posted_date__c,Location_City__c,Location_State__c,Location_Zip__c from Requisition__c where Location_State__c=\'New York\'';

        search.contact__c=conid;
        insert search;
        return search;
    }
    
    public static Notification_Setting__c createNotificationSettings() {
        Notification_Setting__c ns = new Notification_Setting__c();
        ns.Last_Notification_Date__c=System.Today();
        insert ns;
        return ns;
    }
}