trigger asd on SyncObject1__c (before insert,after update ) {
List<SyncObject1__c> asd1 = [Select Id,testdate__c from SyncObject1__c where testdate__c > :system.today().adddays(-10)];
system.debug('####'+asd1);
}