public class DynamicBindingDML {  
      
    public sObject sObjectToBind  {get;set;}  
    public List<String> listObjectFields {get;set;}  
    public string sCustomObjSelected  {get;set;} 
    public string ISelected  {get;set;} 
 
    //Constructor 
    public DynamicBindingDML () {
        List<Account> acc = [select id from Account LIMIT 1];
        ISelected = acc[0].id;
        Getfields();
    }   
       
    //Populate the Listbox with all Custom Objects        
    public List<SelectOption> getCustomObjects()
    {    
      string strObjName ='';
      List<SelectOption> options = new List<SelectOption>();
                
      for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())  
      {
         if ( objTyp.getDescribe().isCustom() )
         { strObjName = objTyp.getDescribe().getName();
         options.add(new SelectOption(strObjName ,strObjName )); }
      }  
      return options;
    }

public pagereference RefreshsObjFields()  
    {  
         Getfields();    
         return null;
    } 

  public pagereference ExpGetData()  
    {  
    listObjectFields =  new List<String>();  
    Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        
    // Note:  hardcode a custom object for now   
    if (sCustomObjSelected  == null)
    {     sCustomObjSelected  = 'SyncObject1__c';
    }

    Schema.sObjectType sObjType = globalDescription.get(sCustomObjSelected);  
    Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
    Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();  
    
    string query = 'SELECT'+ string.join(new List<string>(r1.Fields.getMap().keySet()),',')
                   + 'FRO'+ sCustomObjSelected + 'LIMIT 1';
    system.debug(query);   
   
    try{
            sObject sObjectOne = Database.query(query) ;
            sObjectToBind = sObjectOne ;
       } catch(exception e){
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,
             'No records found.' );
            ApexPages.addmessage(msg);
            sObjectToBind = sObjType.newSObject();
       }
   
    for(Schema.SObjectField field : mapFieldList.values())  
        {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
            if(fieldResult.isAccessible() && fieldResult.isUpdateable())  
                {  
                    listObjectFields.add(fieldResult.getName());  
                }  
        }  
            
         return null;
    } 
    
public void Getfields()  
    {
    listObjectFields =  new List<String>();  
    Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        
    // Note:  hardcode a custom object for now   
    if (sCustomObjSelected  == null)
    {     sCustomObjSelected  = 'SyncObject1__c';
    }

    Schema.sObjectType sObjType = globalDescription.get(sCustomObjSelected);  
    sObjectToBind = sObjType.newSObject();  

    Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
    Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();  

    for(Schema.SObjectField field : mapFieldList.values())  
        {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
            if(fieldResult.isAccessible() && fieldResult.isUpdateable())  
                {  
                    listObjectFields.add(fieldResult.getName());  
                }  
        }  
    }
}