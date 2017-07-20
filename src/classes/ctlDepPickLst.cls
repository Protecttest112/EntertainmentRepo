public class ctlDepPickLst {
    public String country {get;set;}
    public String state {get;set;}
    public map<String, List<String>> mapStringtoLstString{get;set;}
    
    public ctlDepPickLst()
    {
        Map<String,List<States__c>> mapofstatescountry = new  Map<String,List<States__c>>();
        List<States__c> sts = new List<States__c>();
        for (Country__c c : [Select Id,Name from Country__c]){
            for(States__c s: [select Name,CountryName__r.Name from States__c]){
                if(c.Name == s.CountryName__r.Name){
                    sts.add(s);
                    mapofstatescountry.put(c.name,sts); 
                }
            }
            sts = new List<States__c>();
        }
        system.debug('###'+mapofstatescountry.get('India'));
        system.debug('###'+mapofstatescountry.get('UnitedKingdom'));
        system.debug('###'+mapofstatescountry.get('USA'));
    }
}