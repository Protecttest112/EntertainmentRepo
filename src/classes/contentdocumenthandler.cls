public class contentdocumenthandler {
    public static void HasAttachment(List<ContentDocumentLink>oldList){
         SET<ID>caseIds = new SET<Id>();
         Case caseObj;
        
        for (ContentDocumentLink cd:oldList){
            caseIds.add(cd.LinkedEntityId);
        }
        system.debug('###'+caseIds);
        List<ContentDocumentLink> cdList = [select Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :caseIds ];
        system.debug('&&&'+cdList);
        if(cdList.size()>0){
            for (ContentDocumentLink cl : cdList){
                caseObj = new Case (Id=cl.LinkedEntityId);
                caseObj.hasAttachement__c=true;  
            }
        }else{
            caseObj.hasAttachement__c=false;
        }
        update caseObj;
    }
}