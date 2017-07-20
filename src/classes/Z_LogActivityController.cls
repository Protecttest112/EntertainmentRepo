public class Z_LogActivityController{ 
 public Boolean IsRecurrence {get; set;}
 public string RECURRENCETYPE{get;set;}
    public String timeinterval {get; set;}
    public String days {get;set;}
    public String whichday {get;set;}
    public String month {get; set;}
    public String dayofmonth {get;set;}
    public String monthlyinterval {get; set;}
    public String whichweek {get; set;}
    public String whichweekofthemonth {get; set;}
    public String whichdayoftheweek {get; set;}
    public String themonth {get; set;}
    public string RECURRENCETYPE1 {get;set;}
    public string RecurrenceDayOfWeekMask{get;set;}
    public string sun1{get;set;}
    public string RecurrenceDayOfMonth{get;set;}
    public string RECURRENCETYPE2{get;set;}
    public string RECURRENCETYPE3{get;set;}
    public String recId{get;set;}
    public Boolean isFollowUp{get;set;}
    public String actSubStr{get;set;}
    public String RecurrenceStartDateOnly {get; set;}   
     public String RecurrenceEndDateOnly {get; set;}
      public String strJSONGrid{get;set;}
    public Set<String> setParentAccountIds;
    public Map<String,Account> mapAccs;
   
    public Map<String,String> mapEvntAccActivity;



    public Z_LogActivityController(ApexPages.StandardController controller) {

    }
     public PageReference saveAndRedirect(){
        system.debug('f1:-'+sun1);
        system.debug('f2:-'+RecurrenceDayOfWeekMask);
        
        return null;
        }
   
  }