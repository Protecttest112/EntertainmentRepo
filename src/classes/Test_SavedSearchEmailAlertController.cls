@isTest
public class Test_SavedSearchEmailAlertController
{
    public static testMethod void testSavedSearchEmailAlertController() {
        //create test data
        TestUtils.createNotificationSettings(); // create notification setting
        contact  testCon = TestUtils.createContact(); //create contact
        TestUtils.createSavedSearch(testCon.Id); // create saved search
        TestUtils.createRequisition(); //create requisitions
        
        
        SavedSearchEmailAlertController con = new SavedSearchEmailAlertController();
        con.contactId = testCon.Id;
        saved_search__c  search = con.getSearch();
        System.assert(search != null);
        
        List<Requisition__c> reqs = con.getRequisitions();
        System.assert(reqs != null);
    }
}