public with sharing class mockupcontroller {
     public List<Contact> listofSubmissionContacts {get; set;}
    public wrappertable wrapperinstance {get;set;} 
    public List<wrappertable> userInput {get; set;}
      public String submissionContactID {get; set;}
    public String custname {get; set;}
     public String comments {get; set;}
     public Boolean isContactSearchDone {get; set;}
     public ContactSearchParamInput contactSearchInput {get; set;}
     public mockupcontroller(){
        contactSearchInput = new ContactSearchParamInput();
          userInput = new List<wrappertable>();
        for (integer i =0; i <5;i++){
            wrapperinstance = new wrappertable();
            wrapperinstance.productno='';
            wrapperinstance.lotno='';
            userInput.add(wrapperinstance);
        }
     }
    //Search based on given inputs
    //
    public void contactSearch(){

        if( String.isBlank(contactSearchInput.email)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter email Address to perform search'));
            return;
        }
        String query = 'SELECT Id, Name,FirstName,LastName, Email, Phone FROM Contact ';
        
        query += ' WHERE Id != NULL ';
        if(String.isNotBlank(contactSearchInput.email)){
            query += ' AND Email = \'' +String.escapeSingleQuotes(contactSearchInput.email)+'\' order by createddate desc limit 1';
        }
        system.debug('Query:-'+query);
        listofSubmissionContacts = new List<Contact>((List<Contact>)Database.query(query));
        if(listofSubmissionContacts.size() != 0)
          {
           contactSearchInput.FirstName = listofSubmissionContacts[0].FirstName ;
           contactSearchInput.LastName = listofSubmissionContacts[0].LastName ;
           contactSearchInput.PHone= listofSubmissionContacts[0].PHone;
          }
        else
          {
           contactSearchInput.FirstName = '';
           contactSearchInput.LastName = '';
           contactSearchInput.PHone = '';
          } 
           isContactSearchDone = true; 
    }
    
    /* reset the lender search modal */
    public void resetContactSearch(){
        contactSearchInput = new ContactSearchParamInput();
        listofSubmissionContacts = null;
    }
    
    //Update page contact info
    public void contactinfoupdated(){
      custname= listofSubmissionContacts[0].name;
    }
    
    //wrapper class for contact search
     public class ContactSearchParamInput{
        public String name {get; set;}
        public String firstname {get; set;}
        public String lastname {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
    }
    //wrapper class for table creation
    public class wrappertable{
        public string productno{get;set;}
        public string lotno{get;set;}
        public string qty{get;set;}
        public string unitprice{get;set;}
        public string extprice{get;set;}
        
    }
}