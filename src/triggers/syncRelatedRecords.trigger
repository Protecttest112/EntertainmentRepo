// Trigger to fire for custom object SyncObject2__c after any records been updated

trigger syncRelatedRecords on SyncObject2__c (after update) {
    //Initializing the handler class
    SyncObject2triggerHandler handler = new SyncObject2triggerHandler ();
    if(trigger.isAfter){
        if(trigger.isUpdate){
             //Controlling the recursive re-updation of triggers
            // if(SyncObject1triggerHandler.chkTrigger !='called'){
            //calling the handler class method with list of new and old versions of the sObject records
            handler.afterUpdate(trigger.new,trigger.old);
        }}
}