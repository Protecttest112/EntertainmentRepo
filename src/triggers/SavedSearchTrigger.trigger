trigger SavedSearchTrigger on Saved_Search__c (after insert,after update) 
{
   SaveSearchTriggerHandler.DeactivateOtherSearches(trigger.newmap,trigger.oldmap);
}