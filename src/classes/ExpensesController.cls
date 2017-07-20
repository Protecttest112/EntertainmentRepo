public class ExpensesController {

    @AuraEnabled
    public static List<Expense__c> getExpenses(){
        return [Select Id,Amount__c,Client__c,Date__c,Reimbursed__c,Name from Expense__c] ;       
    } 
    
     @AuraEnabled
    public static Expense__c saveExpenses(Expense__C exp){
             upsert exp;
        return exp;
    } 
}