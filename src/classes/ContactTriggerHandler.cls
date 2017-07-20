public class ContactTriggerHandler
{
    public static void OnAfterUpdate(Map<Id,Contact> newMap,Map<Id,Contact> oldMap)
    {
        Set<Id> inactiveContactIds=new Set<Id>();
        try
        {
            for(Id contId:newMap.keyset())
            {
                Contact newcontact=newmap.get(contId);
                Contact oldContact=oldmap.get(contId);
                if(newContact.Referred_Candidate__c=='No' && newcontact.Referred_Candidate__c!=oldcontact.Referred_Candidate__c)
                {
                    inactiveContactIds.add(contId);
                }
            }
            if(inactiveContactIds.size()>0)
            {
                List<Referral__c> referrallist=[Select id,Referred_Candidate__c,active__c from Referral__c where 
                                                Referred_Candidate__c=:inactiveContactIds and active__c=true];
                for(Referral__c ref:referrallist)
                {
                    ref.active__c=false;
                }
                update referralList;
            }
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }
}