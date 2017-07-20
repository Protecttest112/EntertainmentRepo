@isTest
public class TestBatchNewRequisitionEmailAlert {

    public static testMethod void testBatchNewRequisitionEmail() {
        //create test data
        contact  testCon = TestUtils.createContact(); //create contact
        TestUtils.createSavedSearch(testCon.Id); // create saved search
        TestUtils.createNotificationSettings(); // create notification setting
        
        //instantiate batch class & execute batch
        batchNewRequisitionEmailAlert bat = new batchNewRequisitionEmailAlert();
        database.executebatch(bat);
        
        //get custom setting & assert
        Notification_Setting__c ns = Notification_Setting__c.getInstance();
        System.assertEquals(ns.Last_Notification_Date__c, System.TODAY());
    }

}