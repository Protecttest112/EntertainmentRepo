public with sharing class UserLookupController {
    public String fieldTypeForSelectedField {get;set;}
    public List<PhoneNumberDetail> ListOfLookupsElement {get;set;}
    public String objectName {get;set;}
    public String fieldName {get;set;}
    public String searchByName {get;set;}
    public String searchByPhone {get;set;}
    public Boolean isChecked {get;set;}
    public String phoneNumberPassToTextBox {get;set;}
    public String phoneNamePassToHdn {get;set;}
    public Boolean isAllSelectCheckBox {get;set;}

    /*Controller*/
    public UserLookupController() {
            ListOfLookupsElement = new List<PhoneNumberDetail>();
            //objectName = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('oN'));
            //fieldName = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('fN'));
            isAllSelectCheckBox = false;
            searchByPhone = '';
            searchByName = '';
            phoneNumberPassToTextBox = '';
            phoneNamePassToHdn = '';
            getListOfLookupsElement();
        }

    /*to get List of lookup element*/
    public void getListOfLookupsElement() {
            Boolean isCountryCodeAlreadyExist;
            try {
                ListOfLookupsElement = new List<PhoneNumberDetail>();
                String query = 'SELECT FirstName, LastName, Username FROM User';
                List <User> s = Database.query(query); 
                for (User sObj: s) {
                    ListOfLookupsElement.add(new PhoneNumberDetail(String.valueOf(sObj.get('LastName')), String.valueOf(sObj.get('Username')), String.valueOf(sObj.Lastname), false, isCountryCodeAlreadyExist));
                }
            } catch (Exception ex) {
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Parameter is not defined, Please contact your Administrator!'));
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            }
        }

    /*Search event*/
    public void onSearch() {
            phoneNumberPassToTextBox = '';
            phoneNamePassToHdn = '';
            isAllSelectCheckBox = false;
            ListOfLookupsElement = new List<PhoneNumberDetail>();
            String byName = '\'%' + String.escapeSingleQuotes(searchByName) + '%\'';
            String byPhone = '\'%' + String.escapeSingleQuotes(searchByPhone) + '%\'';
            String CountryCode = null;
            Boolean isCountryCodeAlreadyExist;
            try {
                String query = 'SELECT FirstName, LastName, Username FROM User WHERE name Like ' + byName ;
                List<User> s = Database.query(query);   
                for (User sObj: s) {
                    ListOfLookupsElement.add(new PhoneNumberDetail(String.valueOf(sObj.get('Name')), String.valueOf(sObj.get('UserName')), String.valueOf(sObj.Lastname), false, isCountryCodeAlreadyExist));
                }
            } catch (Exception ex) {
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Illegal Search parameter!'));
            }
        }

    /*Event for check box checked*/
    public void onCheck() {
            phoneNumberPassToTextBox = '';
            phoneNamePassToHdn = '';
            String CountryCode = '';
            for (PhoneNumberDetail pn: ListOfLookupsElement) {
                if (pn.isChecked) {
                    phoneNumberPassToTextBox += pn.sObjectNameField + ',';
                }
            }
            System.debug('phoneNumberPassToTextBox : '+phoneNumberPassToTextBox);
        }

    /*Event for all select in single check*/
    public void onSelectAll() {
            phoneNumberPassToTextBox = '';
            phoneNamePassToHdn = '';
            String CountryCode = '';
            for(PhoneNumberDetail pn: ListOfLookupsElement) {
                if(isAllSelectCheckBox) {
                    pn.isChecked = true;
                } else {
                    pn.isChecked = false;
                }
                if(pn.isChecked) {
                    phoneNumberPassToTextBox += pn.sObjectNameField + ',';
                }
            }
        }

    /*P2l Detail wrapper*/
    public class PhoneNumberDetail {
        public Boolean isChecked {get;set;}
        public String sObjectNameField {get;set;}
        public String sObjectPhone {get; set;}
        public String countryCode {get;set;}
        public Boolean isCountryCodeExist {get;set;}
        public PhoneNumberDetail(String sObjectNameField, String countryCode, String sObjectPhone, Boolean isChecked, Boolean isCountryCodeExist) {
            this.sObjectNameField = sObjectNameField;
            this.sObjectPhone = sObjectPhone;
            this.countryCode = countryCode;
            this.isChecked = isChecked;
            this.isCountryCodeExist = isCountryCodeExist;
        }
    }
}