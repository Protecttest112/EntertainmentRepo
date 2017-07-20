public class CampingListController  {

    @Auraenabled
    public static List<Camping_Item__c> getItems (){
        return [select Id,name,Packed__c,Price__c,Quantity__c from Camping_Item__c];
    }
    
    @Auraenabled
    public static Camping_Item__c saveItem  (Camping_Item__c item){
        upsert item;
        return item;
    }
}