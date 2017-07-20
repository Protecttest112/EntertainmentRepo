global class DailyChatterPostBatchClass implements Database.Batchable<sObject> {   
    
    // Set Group name , where the reflections should be posted
   String email='abhik.dey2704@gmail.com';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name FROM Account LIMIT 2';
        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext BC, List<Account> listOfAccounts) {
        List<SyncObject1__c> listOfPosts = new List<SyncObject1__c>();
        for(Account obj: listOfAccounts) {
                SyncObject1__c post = new SyncObject1__c();
                post.Name = obj.Name;
                post.account__c= obj.Id;
                listOfPosts.add(post);
            }
       
        if(listOfPosts != Null && listOfPosts.size() > 0) {
            try {
                Database.insert(listOfPosts, false);
            } Catch(Exception e) { }
        }
    }  
   
    global void finish(Database.BatchableContext BC) { 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

mail.setToAddresses(new String[] {email});
mail.setReplyTo('abhik.dey2704@gmail.com');
mail.setSenderDisplayName('Batch Processing');
mail.setSubject('Batch Process Completed');
mail.setPlainTextBody('Batch Process has completed');

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    
    
    }
}