global class batchAccountUpdate implements Database.Batchable<sObject>, Database.Stateful {
    global integer count;
    
    global batchAccountUpdate (){
    count=0;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name FROM Account';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
         for(Account a : scope)
         {
             if(a.Name == 'asdUpdated'){
             system.debug('&&&'+a);
                 a.Name = a.Name + 'Updated';
                 count= count+1;
             }
         }
        system.debug('%%%'+scope+'###'+count);
         update scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
    system.debug('$$$$'+count);
    }
}