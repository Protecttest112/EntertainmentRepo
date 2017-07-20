public class SaveSearchTriggerHandler
{
    //Method used to update existing active saved searches when a new search is made active
    public static void DeactivateOtherSearches(Map<Id,Saved_Search__c> newmap,Map<Id,Saved_Search__c> oldmap)
    {
        Map<Id,Saved_search__c> contactsearchMap=new Map<Id,saved_search__c>();
        Set<Id> searchIds=new Set<Id>();
        try
        {
        for(Id sid:newmap.keyset())
        {
            Saved_Search__c newsearch=newmap.get(sid);
            //getting the old ma for the record
            Saved_Search__c oldsearch=null;
            if(oldmap!=null && oldmap.keyset().contains(sid))
            oldsearch=oldmap.get(sid);
            //checking if the  record has active checked
            if(newsearch.active__c && ((oldsearch!=null && newsearch.active__c!=oldsearch.active__c ) || oldsearch==null))
            {
                //creating a map of contact and search
                contactsearchMap.put(newsearch.Contact__c,newsearch);
                searchIds.add(newsearch.id);
            }
        }
        //query for existing searches if any new searches are active
        if(contactsearchMap.size()>0)
        {
            List<Saved_Search__c> allSearches=[select id,contact__c,active__c from Saved_Search__c 
                                                where contact__c in :contactsearchMap.keyset() and active__c=true and Id not in :searchIds];
            if(allsearches.size()>0)
            {
                //update the existing active searches to false
                for(saved_search__c s:allsearches)
                {
                    s.active__c=false;
                    
                }
                update allSearches;
            }
        }
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }
}