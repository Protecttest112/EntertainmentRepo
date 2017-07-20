public class pop1
{
public pop1(){}
public static void test11(){
List<SyncObject1__c> asd1 = [Select Id,testdate__c from SyncObject1__c where testdate__c < :system.today().adddays(-10)];
system.debug('####'+asd1);
}
}