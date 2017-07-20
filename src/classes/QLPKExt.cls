public with sharing class QLPKExt {

    public QLPKExt(Apexpages.Standardcontroller controller){
    }

    @RemoteAction
    public static List<Account> queryChunk(String firstId, String lastId, Boolean isLast) {
        //last Id range uses <=, all others use <
        String lastClause = 'AND Id < \''+ lastId +'\'  ';
        if (isLast) {
            lastClause = 'AND Id <= \''+ lastId +'\'  ';    
        }       
        
        String SOQL =   'SELECT Id, Some_Number__c ' +
                        'FROM Account ' +
                        'WHERE Some_Number__c > 15' +
                        'AND Id >= \'' + firstId + '\' ' +
                        lastClause;
                        
        return database.query(SOQL);
    }    
}