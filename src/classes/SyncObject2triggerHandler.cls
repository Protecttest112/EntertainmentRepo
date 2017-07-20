/*Handler Class for Syncing the SyncObject2__c object records with custom object SyncObject1__c 
when ever any update happens in SyncObject2__c records 
*/

global without sharing class SyncObject2triggerHandler {
    //Variable to control the re-update of records in both objects
    global static string checkTrigger='uncalled';
    
    //Method called after the update operation
    public void afterUpdate(List<SyncObject2__c> syncObj2,List<SyncObject2__c> syncOldObj2){
        try{
            checkTrigger = 'called';
            Map<String,String> custMap= new Map<String,String>();
            Map<Id,SyncObject2__c> oldMap= new Map <Id,SyncObject2__c>();
            Integer i,j,k,p,t;
            Integer count=0;
            List<SyncObject1__c> listObj1 = new List<SyncObject1__c>();
            List<SyncObject1__c> newList = new List<SyncObject1__c>();
            Map<Integer,String> mapofrecordType= new Map<Integer,String>();
            SET<ID>setOfIds = new SET<ID>();
            
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
            
            //Querying the recordtype for the custom object 'SObject_2__c'
            Map<Id, RecordType> mapOfRecordTypeIDAndRecord = new Map<ID, RecordType>(
                [SELECT ID, Name FROM Recordtype WHERE SobjectType =: custSync.SObject_2__c]);
            Boolean isRecordtype=false;
            //Adding the new record Ids in the SET
            for(SyncObject2__c c: syncObj2){
                setOfIds.add(c.Id);}
            //Iterating in for loop and checking with the custom settings records
            for(p=0;p<syncObj2.size();p++){
                for(t=0;t<RecordTypeList2.size();t++){
                    //Checking the object RecordType with the custom settings values
                    if(mapOfRecordTypeIDAndRecord.get(syncObj2[p].RecordTypeId).Name == RecordTypeList2[t] && custSync.SObject_2__c =='SyncObject2__c'){
                        isRecordtype=true;
                        mapofrecordType.put(t,RecordTypeList1[t]);
                        count=t;
                    }}}
            //Quering the related SyncObject1__c records for the sync to happen
            newList=[SELECT EmailField1__c,LinkObject2__c,TextField1__c,txtField1__c FROM SyncObject1__c where RecordType.Name IN :mapofrecordType.Values() AND LinkObject2__c IN :setOfIds];
            
            //Assigning the trigger.old records into the map for checking the field updation   
            for (SyncObject2__c obj : syncOldObj2){
                oldMap.put(obj.Id,obj);}
            
            // Iterating in for loop to check if the field is updated and then update the corresponding objects
            for (i=0;i<syncObj2.size();i++){
                //Iterating in SyncObject1__c records based on the recordtype 
                for(j=0;j<newList.size();j++){
                    // Checking if the field has been updated
                    if((syncObj2[i].EmailField2__c != oldMap.get(syncObj2[i].Id).EmailField2__c || syncObj2[i].TextField2__c != oldMap.get(syncObj2[i].Id).TextField2__c ||  syncObj2[i].txtField2__c != oldMap.get(syncObj2[i].Id).txtField2__c)){
                        for(k=0;k<fieldList1.size();k++){
                            if(isRecordtype==true){
                                // Checking if the field is present in custom settings
                                if(fieldList2[k] =='EmailField2__c' && fieldList1[k] =='EmailField1__c'){
                                    newList[j].EmailField1__c= syncObj2[i].EmailField2__c ;
                                }
                                if(fieldList2[k] =='TextField2__c' && fieldList1[k] =='TextField1__c'){
                                    newList[j].TextField1__c= syncObj2[i].TextField2__c;
                                }
                                if(fieldList2[k] =='txtField2__c' && fieldList1[k] =='txtField1__c'){
                                    newList[j].txtField1__c= syncObj2[i].txtField2__c;
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