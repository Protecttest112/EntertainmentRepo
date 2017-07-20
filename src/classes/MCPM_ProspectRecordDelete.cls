global class MCPM_ProspectRecordDelete  implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,createdDate FROM Account where createdDate < :system.today().adddays(-560)]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        system.debug('%%%%'+scope.size());
        List<SObject> delSobj=new List<SObject>();
        List<Opportunity> InteractionRec = new List<Opportunity>();
        SET<Id> Ids = new SET<Id>();
        for(Account objRec : scope)
            ids.add(objRec.Id);
        InteractionRec = [Select Id,AccountId from Opportunity where AccountId IN :ids];
        for(Account prop: scope){
            if(system.today().adddays(-60) > prop.createdDate && InteractionRec.size() ==0){
                delSobj.add(prop);
            }
        }
      }  
    
    global void finish(Database.BatchableContext BC){
    }
}