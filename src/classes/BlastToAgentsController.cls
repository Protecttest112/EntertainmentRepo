public class BlastToAgentsController
{
    public Requisition__c Req{get;set;}
    public string ReqId;
    public Integer noOfContacts{get;set;}
    public boolean displayresults{get;set;}
    public void Process()
    {
         ReqId=ApexPages.currentPage().getParameters().get('id');
         if(ReqId!=null)
         {
             fetchRequisition();
             fetchContacts();
         }
    }
    //fetching the requisition details based on the requisition id passed
    public void fetchRequisition()
    {
        Req=[Select Job_Function__c,skill__c,Last_Agent_Blast_Count__c,Last_Agent_Blast_Date__c,
             Location_City__c,Location_State__c,Location_Zip__c from Requisition__c where id=:ReqId];       
        
    }
    //fetching the contacts for referral agents and sending them email
    public Pagereference fetchContacts()
    {
        Set<Id> matchedContacts=new Set<Id>();
        
        //creating location group, to match the contact
        String reqlocation=req.Location_City__c+','+req.Location_State__c+','+req.Location_Zip__c;
        
        //creating the job function and skill combination to match the contact data
        String jobSkills=req.Job_Function__c+':'+req.Skill__c;
        try
        {
            List<contact> contlist=[Select id,email,Agent_Interested_Categories__c,Receive_Position_Notifications__c,Agent_Interested_Locations__c,Referral_Agent__c
                                     from contact where Referral_Agent__c='Yes' and Receive_Position_Notifications__c=true];
                                     
             for(contact c:contlist)
             {
                 //getting all interested locations from contact
                 List<String> locations=c.Agent_Interested_Locations__c.split(';');
                 //getting all interested categories from contact
                 List<String> categorySubCategories=c.Agent_Interested_Categories__c.split(';');
                 Set<String> uniqueLocations=new set<string>();
                 uniqueLocations.addAll(locations);
                 
                 Set<String> uniqueCategories=new Set<String>();
                 uniqueCategories.AddAll(categorySubCategories);
                 //check to see if the location and category match with requisition, if matched email will be sent to those contacts
                 if(uniqueLocations.contains(reqlocation) && uniqueCategories.contains(jobSkills))
                 {
                     matchedContacts.add(c.id);
                 }
                 
             } 
             //when some contacts exist to send email, displaying the results to recruiter
             if(matchedContacts.size()>0){
             noOfContacts = matchedContacts.size();
             displayresults=true;
             //sending email to contacts
             SendEmailtoContacts(matchedContacts);
             
             //updating the requistion fields with details
             req.Last_Agent_Blast_Count__c=matchedContacts.size();
             req.Last_Agent_Blast_Date__c=system.today();
             update req;
             
             }
         }
         catch(Exception e)
         {
             System.debug(e);
         }
         return null;
                              
                                 
    }
    public void SendEmailtoContacts(Set<Id> contactIds)
    {
        //fetching the email template
        try
        {
            EmailTemplate template=[Select id from EmailTemplate where developername=:Constants.REFERRAL_AGENT_EMAIL_BLAST];
            for(Id contId:contactIds)
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();     
               //Setting the Template and Target Ids
                 email.setTargetObjectId(contId);
                 email.setwhatId(Req.Id);
                 email.setTemplateId(template.id); 
               //Sending the Mail
                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
             }
         }
         catch(Exception e)
         {
             system.debug(e);
         }
    }
}