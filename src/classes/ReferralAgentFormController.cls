public class ReferralAgentFormController {
    //basic location filter
    public LocationWrapper locationFilter {get; set;}
    //additional location filters
    public List<LocationWrapper> addLocationFilters {get; set;}
    //basic category filter
    public CategoryWrapper categoryFilter {get; set;}
    //additional category filters
    public List<CategoryWrapper> addCategoryFilters {get; set;}
    
    public Integer rowNumToDel {get; set;}
    
    //State Select list options
    public List<SelectOption> stateOptions {get; set;}
    //public List<SelectOption> categoryOptions {get; set;}
    //public List<SelectOption> subCategoryOptions {get; set;}
    
    public Boolean receiveNotifications {get; set;}
    public Contact curUserContact {get; set;}
    
    //Constructor to handle all the initializations or load existing data
    public ReferralAgentFormController() {
        receiveNotifications = false;
        addLocationFilters = new List<LocationWrapper>();
        addCategoryFilters = new List<CategoryWrapper>();
        
        //get logged in users contact details
        curUserContact = [select Id, ContactId, Contact.Agent_Interested_Categories__c, Contact.Agent_Interested_Locations__c, 
                                 Contact.Referral_Agent__c, Contact.Receive_Position_Notifications__c 
                          from user 
                          where id=:userinfo.getuserid()].Contact;
        
        if(curUserContact != null) {
            //No agent locations, inialize to empty values
            if(String.IsBlank(curUserContact.Agent_Interested_Locations__c)) {                     
                locationFilter = new LocationWrapper('','','',addLocationFilters);                                   
            } else { // if there are agent locations, load from server
                List<String> locations = curUserContact.Agent_Interested_Locations__c.split(';');
                if(locations != null && locations.size() > 0) {
                    for(Integer i=0; i<locations.size(); i++) {
                        List<String> locDetails = locations[i].split(',');
                        if(i==0) {
                            locationFilter = new LocationWrapper(locDetails[0],locDetails[1],locDetails[2],addLocationFilters);
                        } else {
                            addLocationFilters.add(new LocationWrapper(locDetails[0],locDetails[1],locDetails[2],addLocationFilters));
                        }
                    }
                }
            }
            
            //No categories, inialize to empty values
            if(String.IsBlank(curUserContact.Agent_Interested_Categories__c)) {
                categoryFilter  = new CategoryWrapper(new Requisition__c(),addCategoryFilters);            
            } else { // if there are categories, load from server
                List<String> categories = curUserContact.Agent_Interested_Categories__c.split(';');
                if(categories != null && categories.size() > 0) {
                    for(Integer i=0; i<categories.size(); i++) {
                        List<String> catDetails = categories[i].split(':');
                        Requisition__c req = new Requisition__c(Job_Function__c=catDetails[0],Skill__c=catDetails[1]);
                        if(i==0) {
                            categoryFilter = new CategoryWrapper(req,addCategoryFilters);
                        } else {                        
                            addCategoryFilters.add(new CategoryWrapper(req,addCategoryFilters));
                        }
                    }
                }
            }
            
            receiveNotifications = curUserContact.Receive_Position_Notifications__c;
        }       
        
        stateOptions = new List<SelectOption>();
        //categoryOptions = new List<SelectOption>();
        //subCategoryOptions = new List<SelectOption>();
        
        //load state select options using describe call from referral
        Schema.DescribeFieldResult stateFieldDescription = Referral__c.State__c.getDescribe();
        for(Schema.Picklistentry pe : stateFieldDescription.getPicklistValues()){
            stateOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        
        /*
        Schema.DescribeFieldResult categoryFieldDescription = Requisition__c.Job_Function__c.getDescribe();
        for(Schema.Picklistentry pe : categoryFieldDescription.getPicklistValues()){
            categoryOptions.add(new SelectOption(pe.getValue(), pe.getLabel())); 
        }
        
        Schema.DescribeFieldResult subCategoryFieldDescription = Requisition__c.Skill__c.getDescribe();
        for(Schema.Picklistentry pe : subCategoryFieldDescription.getPicklistValues()){
            subCategoryOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        */
    }
    
    //Adding additional location filters
    public PageReference addLocationFilter() {
        Integer activeLocFilters = 0;
        if(addLocationFilters != null) {
            for(LocationWrapper lw : addLocationFilters) {
                if(lw.isDeleted==false)
                  activeLocFilters++;
            }
        }
        if(activeLocFilters < 4) {
            addLocationFilters.add(new LocationWrapper('','','',addLocationFilters));
        }
        return null;
    }
    
    //Removing additional location filters
    public PageReference remLocationFilter() {        
        addLocationFilters.get(rowNumToDel).isDeleted=true;
        return null;
    }
    
    //Adding additional category filters
    public PageReference addCategoryFilter() {
        Integer activeCatFilters = 0;
        if(addCategoryFilters != null) {
            for(CategoryWrapper cw : addCategoryFilters) {
                if(cw.isDeleted==false)
                  activeCatFilters++;
            }
        }
        if(activeCatFilters < 4) {
            addCategoryFilters.add(new CategoryWrapper(new Requisition__c(),addCategoryFilters));
        }
        return null;
    }
    
    //Removing additional category filters    
    public PageReference remCategoryFilter() {      
        addCategoryFilters.get(rowNumToDel).isDeleted=true;
        return null;
    }
    
    //Wrapper to store location specific details
    public class LocationWrapper {
        public String state {get; set;}
        public String city {get; set;}
        public String zip {get; set;}
        public Integer rowNum {get; set;}
        public Boolean isDeleted {get; set;}
        
        public LocationWrapper(String city, String state, String zip, List<LocationWrapper> addLocationFilters) {            
            this.city = city;
            this.state = state;
            this.zip = zip;
            this.rowNum = ((addLocationFilters==null)?0:addLocationFilters.size());   
            this.isDeleted = false;
        }
    }
    
    //Wrapper to store category specific details
    public class CategoryWrapper {
        public Requisition__c req {get; set;}
        public Integer rowNum {get; set;}
        public Boolean isDeleted {get; set;}
        
        public CategoryWrapper(Requisition__c req, List<CategoryWrapper> addCategoryFilters) {
            this.req = req;
            this.rowNum = ((addCategoryFilters==null)?0:addCategoryFilters.size());   
            this.isDeleted = false;
        }
    }
    
    //Register 
    public pagereference submitAgentForm()
    {
        String location='';
        string categories='';
        PageReference pr;
        
        try 
        {
            if(locationFilter != null) 
            {
                location=location+locationFilter.city+','+locationFilter.state+','+locationFilter.zip+';';
            }
            
            if(addLocationFilters.size()>0)
            {                
                for(LocationWrapper lw:addLocationFilters)
                {
                    if(lw.state!=null && lw.city!=null && lw.zip!=null && lw.isDeleted==false)
                    {
                        location=location+lw.city+','+lw.state+','+lw.zip+';';
                    }
                }
            }
            
            if(categoryFilter != null && categoryFilter.req.Job_Function__c!=null && 
               categoryFilter.req.Skill__c!=null && categoryFilter.isDeleted==false)
            {
                categories=categories+categoryFilter.req.Job_Function__c+':'+categoryFilter.req.Skill__c+';';
            }
            
            if(addCategoryFilters.size()>0)
            {
                
                for(CategoryWrapper cw:addCategoryFilters)
                {
                    if(cw.req.Job_Function__c!=null && cw.req.Skill__c!=null && cw.isDeleted==false)
                    {
                        categories=categories+cw.req.Job_Function__c+':'+cw.req.Skill__c+';';
                    }
                }
                
            }
            
            if(location!='' && categories!='')
            {                
                contact contacttobeupdated=new contact(id=curUserContact.Id);
                contacttobeupdated.Agent_Interested_Categories__c=categories;
                contacttobeupdated.Agent_Interested_Locations__c=location;
                contacttobeupdated.Referral_Agent__c='Yes';
                contacttobeupdated.Receive_Position_Notifications__c=receiveNotifications;
                update contacttobeupdated;
                
            }
            
            pr = new PageReference('/candidateportal/ReferralAgentSuccess');
        } 
        catch(Exception ex) 
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        
        return pr;
    }
}