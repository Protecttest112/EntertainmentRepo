public class sampleCon {
    String country = null;
         
    public sampleCon () {
        Account a = [select Id,datetimefield__c from Account where Id='001i000001yr8uT'];
        country =a.datetimefield__c;
    }
                
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('US','US')); 
        options.add(new SelectOption('CANADA','Canada')); 
        options.add(new SelectOption('MEXICO','Mexico')); return options; 
    }
                   
    public String getCountry() {
        return country;
    }
                    
    public void setCountry(String country) { this.country = country; }
}