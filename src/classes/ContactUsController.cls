public class ContactUsController
{
    public String question{get;set;}
    public pagereference submitcase()
    {
        pagereference p;
        try
        {
            //check if user has entered comments else throw error
            if(question==null || question=='')
            {
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,Constants.QUESTION_VALIDATION);
                apexpages.addmessage(msg);
            } 
            else 
            {
                Case newCase=new Case();
                //fetching the contactid of the logged in user
                String contactid=[select contactid from user where id=:userinfo.getuserid()].contactid;
                if(contactId!=null)
                newcase.contactid=contactId;
                newcase.description=question;
                //assigning some part of the description to case subject
                if(question.length()>10)
                newcase.subject=question.substring(0,10);
                insert newcase;
                //redirecting to portal home page
                p = new pagereference(constants.PORTAL_HOMEPAGE);
            }
            return p;
        }
        catch(Exception e)
        {
            System.debug(e);
            return null;
        }
    }
}