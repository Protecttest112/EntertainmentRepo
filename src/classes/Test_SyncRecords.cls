@isTest
//Test Class been created for the handler class on both the custom objects
public class Test_SyncRecords {
    static testMethod void syncRecords(){
        //Creation of Records for the custom setting        
        Sync_Objects_Fields_RecordTypes__c TexdtField = new Sync_Objects_Fields_RecordTypes__c();
        TexdtField.Name = 'TexdtField';
        TexdtField.Field_List_1__c = 'EmailField1__c,TextField1__c';
        TexdtField.Field_List_2__c = 'EmailField2__c,TextField2__c';
        TexdtField.RecordTypeList_1__c = 'object1,object11';
        TexdtField.RecordTypeList_2__c = 'object22,object2';
        TexdtField.SObject_1__c = 'SyncObject1__c';
        TexdtField.SObject_2__c = 'SyncObject2__c';
        try{
            insert TexdtField; }
        Catch(Exception e){
            system.debug(e);
        }
        //Querying the record type for Object SyncObject1__c
        Map<String, ID> mapOfRecordTypeNameAndID = new Map<String, Id>();
        for(RecordType recType : [Select Id, Name FROM RecordType WHERE SObjectType = 'SyncObject1__c']){
            mapOfRecordTypeNameAndID.put(recType.Name, recType.Id);
        }
        //Querying the record type for Object SyncObject2__c
        Map<String, ID> mapOfRecordTypeNamesAndID = new Map<String, Id>();
        for(RecordType recType : [Select Id, Name FROM RecordType WHERE SObjectType = 'SyncObject2__c']){
            mapOfRecordTypeNamesAndID.put(recType.Name, recType.Id);
        }
        //Start the test execution
        test.startTest(); 
        //Creation of records
        SyncObject1__c syncObj1_1 = new SyncObject1__c();
        syncObj1_1.EmailField1__c='test_sync@gmail.com';
        syncObj1_1.txtField1__c='TestSync';
        syncObj1_1.TextField1__c='TextField';
        syncObj1_1.recordtypeId= mapOfRecordTypeNameAndID.get('object1');
        syncObj1_1.Name='FirstRecord';
        try{
            insert syncObj1_1;}
        Catch(Exception e){
            system.debug(e);
        }
        SyncObject2__c syncObj2_1 = new SyncObject2__c();        
        syncObj2_1.EmailField2__c='test_sync1@gmail.com';
        syncObj2_1.txtField2__c='TestSync1';
        syncObj2_1.TextField2__c='TextField1';
        syncObj2_1.recordtypeId= mapOfRecordTypeNamesAndID.get('object2');
        syncObj2_1.Name='FirstRecord1';
        try{
            insert syncObj2_1; }
        Catch(Exception e){
            system.debug(e);
        }
        SyncObject1__c syncObj1_2 = new SyncObject1__c();        
        syncObj1_2.EmailField1__c='test_sync1@gmail.com';
        syncObj1_2.txtField1__c='TestSync1';
        syncObj1_2.TextField1__c='TextField1';
        syncObj1_2.recordtypeId= mapOfRecordTypeNameAndID.get('object11');
        syncObj1_2.Name='FirstRecord1';
        syncObj1_2.LinkObject2__c=syncObj2_1.Id;
        try{
            insert syncObj1_2; }
        Catch(Exception e){
            system.debug(e);
        }
        SyncObject2__c syncObj2_2 = new SyncObject2__c();        
        syncObj2_2.EmailField2__c='test_sync1@gmail.com';
        syncObj2_2.txtField2__c='TestSync1';
        syncObj2_2.TextField2__c='TextField1';
        syncObj2_2.recordtypeId= mapOfRecordTypeNamesAndID.get('object22');
        syncObj2_2.Name='FirstRecord1';
        syncObj2_2.LinkObject1__c=syncObj1_1.Id;
        try{
            insert syncObj2_2; }
        Catch(Exception e){
            system.debug(e);
        }
        //Updating the fields 
        syncObj1_1.EmailField1__c='test_sync12345@gmail.com';
        syncObj1_1.txtField1__c='TestS9892';
        syncObj1_1.TextField1__c='Text9893';
        try{
            Update syncObj1_1; }
        Catch(Exception e){
            system.debug(e);
        }
        syncObj1_2.EmailField1__c='test_sync121232@gmail.com';
        syncObj1_2.txtField1__c='Testr';
        syncObj1_2.TextField1__c='TextFi1';
        syncObj1_2.recordtypeId= mapOfRecordTypeNameAndID.get('object11');
        
        SyncObject2triggerHandler.checkTrigger='called';
        try{
            Update syncObj1_2; }
        Catch(Exception e){
            system.debug(e);
        }
        syncObj2_1.EmailField2__c='test_sync21@gmail.com';
        syncObj2_1.txtField2__c='TestSync3';
        syncObj2_1.TextField2__c='TextField4';
        try{
            Update syncObj2_1; }
        Catch(Exception e){
            system.debug(e);
        }
        syncObj2_2.EmailField2__c='test_sync763431@gmail.com';
        syncObj2_2.TextField2__c='text1234';
        syncObj2_2.recordtypeId= mapOfRecordTypeNamesAndID.get('object22');
        try{
            Update syncObj2_2; }
        Catch(Exception e){
            system.debug(e);
        }
        //Stop the test execution        
        test.stopTest();
    }
}