/*Handler Class for Syncing the SyncObject1__c object records with custom object SyncObject2__c 
when ever any update happens in SyncObject1__c records 
*/

global without sharing class SyncObject1triggerHandler {
    global static string chkTrigger='uncalled';
    //Method called after the update operation
    public void afterUpdate(List<SyncObject1__c> syncObj1,List<SyncObject1__c> syncOldObj1){
        try{
            chkTrigger='called';
            Map<String,String> custMap= new Map<String,String>();
            Map<Id,SyncObject1__c> oldMap= new Map <Id,SyncObject1__c>();
            Integer i,j,k,p,t;
            Integer count=0;
            List<SyncObject2__c> listObj2 = new List<SyncObject2__c>();
            List<SyncObject2__c> newList = new List<SyncObject2__c>();
            SET<ID>setOfIds = new SET<ID>();
            Map<Integer,String> mapofrecordType= new Map<Integer,String>();
            
            //Initializing the custom settings and getting the records for the instance TexdtField
            Sync_Objects_Fields_RecordTypes__c custSync =Sync_Objects_Fields_RecordTypes__c.getinstance('TexdtField'); 
            if(custSync !=null){
                custMap.put('Field_List_1__c',custSync.Field_List_1__c);  
                custMap.put('Field_List_2__c',custSync.Field_List_2__c);  
                custMap.put('RecordTypeList_1__c',custSync.RecordTypeList_1__c);  
                custMap.put('RecordTypeList_2__c',custSync.RecordTypeList_2__c);  
                custMap.put('SObject_1__c',custSync.SObject_1__c);  
                custMap.put('SObject_2__c',custSync.SObject_2__c);  
            }
            //Splitting the multiple fileds name and assign it to List of collection
            List<String> fieldList1 = custMap.get('Field_List_1__c').split(',');
            List<String> fieldList2 = custMap.get('Field_List_2__c').split(',');
            
            //Splitting the multiple fileds name and assign it to a Map of values
            List<String> RecordTypeList1 = custMap.get('RecordTypeList_1__c').split(',');
            List<String> RecordTypeList2 = custMap.get('RecordTypeList_2__c').split(',');
            
            //Querying the recordtype for the custom object 'SObject_1__c'
            Map<Id, RecordType> mapOfRecordTypeIDAndRecord = new Map<ID, RecordType>(
                [SELECT ID, Name FROM Recordtype WHERE SobjectType =: custSync.SObject_1__c]);
            Boolean isRecordtype=false;
            SyncObject2__c syncObj2;
            //Adding the new record Ids in the SET
            for(SyncObject1__c c: syncObj1) {
                setOfIds.add(c.Id);
            }
            //Iterating in for loop and checking with the custom settings records
            for(p=0;p<syncObj1.size();p++) {
                for(t=0;t<RecordTypeList1.size();t++) {
                    //Checking the object RecordType with the custom settings values
                    if(mapOfRecordTypeIDAndRecord.get(syncObj1[p].RecordTypeId).Name == RecordTypeList1[t] && custSync.SObject_1__c =='SyncObject1__c'){
                        isRecordtype=true;
                        mapofrecordType.put(t,RecordTypeList2[t]);
                        count=t;
                    }
                }
            }
            //Quering the related SyncObject2__c records for the sync to happen
            newList=[SELECT EmailField2__c,LinkObject1__c,TextField2__c,txtField2__c FROM SyncObject2__c where RecordType.Name IN :mapofrecordType.Values() AND LinkObject1__c IN :setOfIds];
            
            //Assigning the trigger.old records into the map for checking the field updation
            for (SyncObject1__c obj : syncOldObj1) {
                oldMap.put(obj.Id,obj);
            }
            
            // Iterating in for loop to check if the field is updated and then update the corresponding objects
            for (i=0;i<syncObj1.size();i++) {
                //Iterating in SyncObject2__c records based on the recordtype 
                for(j=0;j<newList.size();j++) {
                    // Checking if the field is has been updated
                    if((syncObj1[i].EmailField1__c != oldMap.get(syncObj1[i].Id).EmailField1__c || syncObj1[i].TextField1__c != oldMap.get(syncObj1[i].Id).TextField1__c ||  syncObj1[i].txtField1__c != oldMap.get(syncObj1[i].Id).txtField1__c)){
                        for(k=0;k<fieldList1.size();k++) {
                            if(isRecordtype==true){
                                // Checking if the field is present in custom settings
                                if(fieldList1[k] =='EmailField1__c' && fieldList2[k] =='EmailField2__c'){
                                    newList[j].EmailField2__c= syncObj1[i].EmailField1__c ;
                                }
                                if(fieldList1[k] =='TextField1__c' && fieldList2[k] =='TextField2__c'){
                                    newList[j].TextField2__c= syncObj1[i].TextField1__c;
                                }
                                if(fieldList1[k] =='txtField1__c' && fieldList2[k] =='txtField2__c'){
                                    newList[j].txtField2__c= syncObj1[i].txtField1__c;
                                }}}
                    }}}
            // Used the Database method to update the records and also SET yes for partial execution of records
            Database.SaveResult[] results = Database.update(newList, false);
            
        }
        //Catch Block for any exceptions apart from the DML operation
        catch(Exception e){
            System.debug(e);
        }
    }}