public class CASETriggerhandler {
/* public static void linkFileToSubcase(List<Case> newList){
        //ParentId, Subcases
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();

        //For some reason caseMap.keySet is not working in the soql statement so we create a set of parentIds instead
        Set<Id> parentIds = new Set<Id>();

        //Create map structure
        for(Case c :newList){
                        System.debug(c.ParentId != null );
            if(c.RecordTypeId == '012i0000001AY2k' && c.ParentId != null ){
                if(caseMap.get(c.ParentId) == null){
                    caseMap.put(c.ParentId, new List<Case>{c});
                }else{
                    caseMap.get(c.ParentId).add(c);
                }

                parentIds.add(c.ParentId);
            }
        }
          System.debug('###'+parentIds);
     System.debug('&&&'+caseMap);

        if(!caseMap.keySet().isEmpty()){
            //Get links
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl :[SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :parentIds]){
                for(Case c :caseMap.get(cdl.LinkedEntityId)){
                    System.debug('!!!!'+caseMap.get(cdl.LinkedEntityId));
                    ContentDocumentLink clonedCdl = cdl.Clone();
                    clonedCdl.LinkedEntityId = c.Id;
                    links.add(clonedCdl);
                }
            }
            System.debug('^^^^'+links);
            insert links;
        }
    } */
    
    public static void copyFilesSubCase(list<case> lstcases){
        set<id> parentcaseids = new set<id>();
        set<id> emIds = new set<id>();
        set<id> pemIds = new set<id>();
        Id subcaseId;
        list<case> subcases = new list<case>();
        ID rectypeid = '012i0000001AY2k';  
        system.debug('rectypeid=='+lstcases+'TTT'+rectypeid);
        for(case c : lstcases){
            if( c.recordtypeid == rectypeid ){
                parentcaseids.add(c.Parentid);
                subcases.add(c); 
            }
        }
        //       system.debug('parentcaseids=='+parentcaseids);
        if(lstcases.size()>0)
            subcaseId =lstcases[0].Id;
        List<attachment>updatedlist = new List<attachment>();
        list<ContentDocumentLink> cfiles = new list<ContentDocumentLink>();
        list<EmailMessage> emails = new list<EmailMessage>();
        list<case> parentcases = [select id,(select id,parentid from cases where Id =:subcaseId),(select id,ParentId from attachments),(select id,ParentId,Subject,status,HasAttachment, Incoming, Headers,FromAddress,ToAddress,FromName, HtmlBody, TextBody from EmailMessages),(select id,LinkedEntityId,ContentDocumentId,ContentDocument.FileType,ContentDocument.title,ShareType from ContentDocumentLinks) from case where id IN:parentcaseids];
        for(case pcase : parentcases){
      //      if(checkRecursive.isFirstTime){
        //        checkRecursive.isFirstTime = false;
                if( pcase.cases.size()!=0){
                    for(case subcase : pcase.cases){
                        if(pcase.ContentDocumentLinks.size()!=0){
                            for(ContentDocumentLink cdl : pcase.ContentDocumentLinks){
                                ContentDocumentLink cd = new ContentDocumentLink();
                                cd = cdl.clone();
                                cd.LinkedEntityId = subcaseId;
                                cfiles.add(cd);
                            }
                        }
                        if(pcase.EmailMessages.size()!=0){
                            for(EmailMessage em : pcase.EmailMessages){
                                system.debug('###'+em);
                                pemIds.add(em.Id);
                                EmailMessage e = new EmailMessage();
                                e = em.clone();
                                e.parentid = subcaseId;
                                emails.add(e);
                            }
                        }   
                    }
                    
                }
            // }
        }
        if(cfiles.size()!=0)
            try{
                insert cfiles;
            }catch(exception e){
                system.debug('exception=='+e);
            }
        if(emails.size()!=0)
            database.insert(emails,false);
 		List<Attachment> a1 = [select Id, body,ContentType,Name from attachment where parentId IN :pemIds];
        For (EmailMessage pem : emails){
            for(Attachment att : a1){
            Attachment attObj = new Attachment();
            Blob b = att.body;
            attObj.ParentId=pem.Id;
            attObj.contentType = att.ContentType;
            attObj.body=b;
            attObj.Name=att.Name;
                updatedlist.add(attObj);
        }
        }
        system.debug('$$$'+updatedlist+'size:-'+updatedlist.size());
        database.insert(updatedlist,false);
    }
   
}