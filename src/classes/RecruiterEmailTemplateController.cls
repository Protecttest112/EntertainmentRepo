public class RecruiterEmailTemplateController
{

    public Id recruiterId {get;set;}
    //fetching the referral records for the recruiter which are not reviewed
    public List<Referral__c> getReferrals()
    {
        List<Referral__c> referrals;
        referrals = [SELECT Referred_Candidate__r.Name,Application__c,Requisition__r.Requisition_Title__c,Referral_Name__c,Name,Application__r.Name,Referred_Candidate__c,Reviewed_by_Recruiter__c,Requisition__c,createdbyId,lastmodifiedbyId  FROM Referral__c WHERE 
                    Requisition__r.recruiter__c =: recruiterId and Requisition__r.Requisition_Status__c!='Cancelled'
                    and Application__r.Submitted_date__c=null and Reviewed_By_Recruiter__c=false and (application__r.status__c!='Candidate Withdrew' OR application__r.status__c!='Declined')];

        return referrals;
    }

}