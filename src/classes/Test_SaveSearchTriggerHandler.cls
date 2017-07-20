@istest
public class Test_SaveSearchTriggerHandler
{
    //Method is use to test SaveSearchTriggerHandler
    public static testmethod void saveSearch()
    {
        //Creation contact
        Contact con=TestUtils.createContact();
        //creating requisition
        Requisition__c req=TestUtils.createRequisition();
        //creating saved search
        Saved_search__c s=TestUtils.createSavedSearch(con.id);
        //creating another saved search
        Saved_search__c s1=TestUtils.createSavedSearch(con.id);
       
       Saved_Search__c s2=[Select id,active__c from saved_search__c where id=:s.id];
       system.assertequals(s2.active__c,false);
        
    }
}