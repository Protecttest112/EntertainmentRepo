public class SavedSearchEmailAlertController
{
    public string contactId{get;set;}
    public saved_search__c search;
    
    public saved_search__c getsearch()
    {
       try {
           //get active saved searches for passed in contact id
           List<Saved_search__c> sList = [select id,Query__c,contact__c,Search_Name__c,CreatedDate 
                                          from Saved_search__c 
                                          where contact__c =:contactId
                                            and Active__c = true
                                          limit 1];
           if(sList != null && sList.size() > 0)
             return sList[0];
           else
             return null;
        } catch(Exception ex) {
            System.debug('Exception : '+ex.getMessage());
            return null;
        }         
    }
    
    public List<Requisition__c> getRequisitions()
    {
        try {
            //get Saved Search
            Saved_Search__c s = getSearch();
            //Notification settings to retrieve Last Notification Data
            Notification_Setting__c ns = Notification_Setting__c.getInstance();
            Date pDate;
            List<Requisition__c> reqList;
            
            if(ns != null)
              pDate=ns.Last_Notification_Date__c;
            
            // If the Last Notification Date is null, set it to TODAY()-3
            if(pDate==null)
              pDate=System.TODAY()-3;
                  
            if(s!=null)
            {
                //add posted date filter
                String querystring=s.query__c +' AND Posted_Date__c>:pDate LIMIT 10';
                reqList=Database.query(querystring);
            }
            
            return reqList;
        } catch(Exception ex) {
            System.debug('Exception : '+ex.getMessage());
            return null;
        }     
    }
}