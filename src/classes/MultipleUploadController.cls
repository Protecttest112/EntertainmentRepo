global class MultipleUploadController  
{     
    public String stringFileName{get;set;}
    public String stringFileType{get;set;}
    public String stringFileSize{get;set;}
    public String stringFileBody{get;set;}
    public String stringUploadedBy{get;set;}
    public List<Attachment>viewList{get;set;}   
   
      
    public MultipleUploadController(ApexPages.StandardController controller)  
    {  
        //Initialize 
    }  
      
    public void SaveAttachments()  
    {  
    system.debug('%%%%'+stringFileSize+'^^^'+stringFileType+'$$$$'+stringFileName+'&&&&'+stringFileBody);
        Blob myBlob = Blob.valueof(stringFileBody);
        system.debug('blobbb'+myBlob);
        String accId = System.currentPagereference().getParameters().get('id');  
       /* if(accId == null || accId == '')  
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'No record is associated. Please pass record Id in parameter.'));  */
           List<Attachment>  listToInsert = new List<Attachment>() ;  
           listToInsert.add(new Attachment(parentId = '001i000000kFhhn', name = stringFileName, body = myBlob)); 
        
          
        //Inserting attachments  
        if(listToInsert.size() > 0)  
        {  
            insert listToInsert ;  
            system.debug('sizeee'+listToInsert.size());
        } 
   }
   public void listView(){
        viewList= new List<Attachment>();
        viewList= [SELECT ContentType,BodyLength,CreatedDate,Description,Id,Name,ParentId,CreatedBy.Name FROM Attachment where ParentId='001i000000kFhhn']; 
        system.debug('bbb'+viewList);
       system.debug('bbb'+viewList.size());
   
   }  
}