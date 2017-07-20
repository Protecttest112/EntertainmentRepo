public class ReferralFormController
{
    public Referral__c referral{get;set;}
    public Attachment attach{get;set;}
    public string ReqId;
    public Requisition__c req {get; set;}
    public String question{get;set;}
    public Boolean agreed {get; set;}
    
    public  ReferralFormController()
    {
        referral=new Referral__c();
        attach = new Attachment();
        ReqId=ApexPages.currentPage().getParameters().get('id');
        System.debug(ReqId);
        
        //fetch requisition details
        if(ReqId!=null)
        req=[Select id,name,Requisition_Title__c,Recruiter__c from requisition__c where id=:ReqId];

    }
    public pagereference SubmitReferral()
    {
        Pagereference pg;
        Boolean isValid = true;
        
        if(String.IsBlank(referral.Name)) {           
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please enter Referral Name.');
            apexpages.addmessage(msg);
            isValid = false;
        }
        
        if(String.IsBlank(referral.Contact_Email__c)) {           
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please enter Contact Email.');
            apexpages.addmessage(msg);
            isValid = false;
        }
        
        if(agreed  == null || agreed == false) {           
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please agree to terms & conditions.');
            apexpages.addmessage(msg);
            isValid = false;
        }
        
        if(String.IsBlank(referral.Referrer_Comments__c)) {           
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please enter Reason for recommending this candidate.');
            apexpages.addmessage(msg);
            isValid = false;
        }
        
        if(attach.body == null) {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select a valid Referral Resume.');
            apexpages.addmessage(msg);
            isValid = false;
        }
        
        if(isValid) {          
            referral.Requisition__c=reqId;
            try
            {
            //fetching the contact associated to logged in user
            String contactid=[select contactid from user where id=:userinfo.getuserid()].contactid;
            if(contactId!=null)
            referral.Referrer__c=contactId;
            referral.Active__c=true;
            //referral.Referred__c='Yes';
            //check if there is a existing contact with the email
            
            checkforExistingContact(referral.Contact_Email__c);
            
            //if there is no candidate with the email, then pass the resume to resumeparser
            if(referral.Referred_Candidate__c==null)
            {
                
                String newEmail=ParseResume(attach.body);
                if(newEmail!=null && newEmail!=referral.Contact_email__c)
                checkforExistingContact(newEmail);
                
            }
            //if there is no contact after this, create a new contact
            if(referral.Referred_Candidate__c==null)
            {
                CreateNewContact();
            }
            
            
            
            
            if(referral.application__c==null)
            createApplication();
            
            
            insert referral;
            if(attach!=null)
            {
                attach.parentid=referral.id;
                insert attach;
            }
            pg = new Pagereference('/apex/ReferralSuccess?id='+reqId);
            return pg;
        }
        catch(Exception e)
        {
            System.debug(e);
            
        }
        }
        return null;
        
    }
    public void createApplication()
    {
        try
        {
            RequisitionCandidate__c application=new RequisitionCandidate__c();
            application.Candidate__c = Referral.Referred_Candidate__c;
            application.Requisition__c=ReqId;
            application.Status__c = 'Under Consideration';
            application.Recruiter__c=req.Recruiter__c;
            application.Sourcing_General__c='Referral';
            application.Sourcing_Specific__c='Candidate / Non-employee';
            
            List<recordtype> recordtypes=[select id from recordtype where developerName='Preferred_CSW'];
            if(recordtypes.size()>0)            
            application.recordtypeId=recordtypes[0].id;
            insert application;
            referral.application__c=application.id;
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }
    public void createNewContact()
    {
        try
        {
            Account newAcc=new Account();
            newAcc.Name=referral.name;
            insert newAcc;
            
            contact cont=new contact();
            cont.LastName=referral.name;
            cont.email=referral.contact_email__c;
            cont.Referred_Candidate__c='Yes';
            insert cont;
            referral.Referred_Candidate__c=cont.id;
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }
    public void checkforExistingContact(String contactEmail)
    {
        try
        {
            List<Contact> contlist=[select id,email from contact where email=:contactEmail limit 1];
            if(contlist.size()>0)
            {
                referral.Referred_Candidate__c=contlist[0].id;
                
            }
            List<RequisitionCandidate__c> applist=[select id,createddate from RequisitionCandidate__c where Candidate__r.email=:contactEmail order by createddate desc limit 1];
            if(applist.size()>0) 
            {
                Date todaysDate=system.today();
                if(applist[0].createddate+180<todaysDate){
                referral.Active__c=false;
                referral.application__c=applist[0].id;
                }
                
            }
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }
    public string ParseResume(Blob resume)
    {
        return null;
    }
   /* public pagereference submitcase()
    {
        pagereference p;
        try
        {
            if(question==null || question=='')
            {
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please enter valid question or problem to submit.');
                apexpages.addmessage(msg);
            } 
            else 
            {
                Case newCase=new Case();
                String contactid=[select contactid from user where id=:userinfo.getuserid()].contactid;
                if(contactId!=null)
                newcase.contactid=contactId;
                newcase.description=question;
                if(question.length()>10)
                newcase.subject=question.substring(0,10);
                insert newcase;
                
                p = new pagereference('/candidateportal');
            }
            return p;
        }
        catch(Exception e)
        {
            System.debug(e);
            return null;
        }
    }*/
    
}