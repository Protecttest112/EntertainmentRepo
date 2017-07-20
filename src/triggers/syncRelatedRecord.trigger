// Trigger to fire for custom object SyncObject1__c after any records been updated
trigger syncRelatedRecord on SyncObject1__c (after update) {
    
    //Initializing the handler class for custom object SyncObject1__c 
    SyncObject1triggerHandler handler = new SyncObject1triggerHandler();
    
    //Controlling the re-updation of records with the help of the static variable defined in other object handler class
    if(trigger.isAfter){
        if(trigger.isUpdate){
            if(SyncObject2triggerHandler.checkTrigger != 'called'){
                //calling the SyncObject1__c handler class method with list of new and old versions of the sObject records
                handler.afterUpdate(trigger.new,trigger.old);
            }}}
}