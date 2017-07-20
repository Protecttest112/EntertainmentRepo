global class batchNewRequisitionEmailAlert implements Database.batchable<sObject> {
    //query to retrieve only active cadidates from save search object
    String query = 'SELECT Contact__c FROM Saved_Search__c WHERE Active__c = true';
    
    //query results for scope
    global Database.QueryLocator start(Database.BatchableContext info) { 
        return Database.getQueryLocator(query);
    }
    
    //loop through saved searches for candidates and send emails with template
    global void execute(Database.BatchableContext info, List<Saved_Search__c> scope) {
        List<Saved_Search__c> searches = new List<Saved_Search__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<String> contactIds = new Set<string>();
        try {
            // get the template id based on name : NEW_REQUISITION_EMAIL_ALERT.
            EmailTemplate template=[Select Id from EmailTemplate where developerName=: Constants.NEW_REQUISITION_EMAIL_ALERT];
            for(Saved_Search__c s : scope){
                contactIds.add(s.Contact__c);
            }
            //loop through contacts and build mail list
            for(string cId : contactIds){ 
                // Create Email and Send
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setTemplateId(template.Id);
                msg.setTargetObjectId(cId);
                msg.setWhatId(cId);
                msg.setSaveAsActivity(false);
                mails.add(msg);
            }
            //send email
            Messaging.sendEmail(mails);
            
            //update the last notification date to batch job run date
            Notification_Setting__c setting = Notification_Setting__c.getOrgDefaults();
            if(setting == null) 
              setting = new Notification_Setting__c();
    
            setting.Last_Notification_Date__c = System.TODAY();
            upsert setting;
        } catch(Exception ex) {
            System.debug('Exception : '+ex.getMessage());
        }
    }
   
    global void finish(Database.BatchableContext info) {     
    } 
}