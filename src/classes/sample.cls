public class sample
{    
    public String ownership {get;set;}
      
    public sample()
    {
        
    }

    public List<System.SelectOption> getownershipOptions()    
    {    
        List<SelectOption> options =  new List<SelectOption>();    
        options.add(new selectOption('None','--- None ---'));    
        Schema.DescribeFieldResult fieldResult = Case.Origin.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        system.debug('@@@@'+ple);
                system.debug('####'+fieldResult );
         for(Schema.picklistEntry f:ple)    
        {    
            options.add(new selectOption(f.getLabel(),f.getValue()));                    
        }    
        return Options;    
    }   
    
    public void text(){
    system.debug('****'+ownership);
        
    }   
}