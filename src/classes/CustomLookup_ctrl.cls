public with sharing class CustomLookup_ctrl {

    public String fieldTypeForSelectedField {get;set;}

    public list < PhoneNumberDetail > listOfLookupsElement {get;set;}

    public String objectName {get;set;}

    public String fieldName {get;set;}

    public String searchByName {get;set;}

    public String searchByPhone {get;set;}

    public boolean isChecked {get;set;}

    public String phoneNumberPassToTextBox {get;set;}

    public String phoneNamePassToHdn {get;set;}

    public boolean isAllSelectCheckBox {get;set;}

    /*Controller*/

    public CustomLookup_ctrl() {

            listOfLookupsElement = new list < PhoneNumberDetail > ();

            //objectName = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('oN'));

            //fieldName = String.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get('fN'));

            isAllSelectCheckBox = false;

            searchByPhone = '';

            searchByName = '';

            phoneNumberPassToTextBox = '';

            phoneNamePassToHdn = '';

            getlistOfLookupsElement();

        }

        /*to get list of lookup element*/

    public void getlistOfLookupsElement() {

            Boolean isCountryCodeAlreadyExist;

            try {

                listOfLookupsElement = new list < PhoneNumberDetail > ();

                String query = 'SELECT Name,ProductCode,Description FROM Product2';

                list < Product2 > s = Database.query(query); 

                for (Product2 sObj: s) {

                    listOfLookupsElement.add(new PhoneNumberDetail(String.valueOf(sObj.get('Name')), String.valueOf(sObj.get('ProductCode')), String.valueOf(sObj.Description), false, isCountryCodeAlreadyExist));

                }

            } catch (Exception ex) {

                apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Parameter is not defined, Please contact your Administrator!'));

            }

        }

        /*Search event*/

    public void onSearch() {

            phoneNumberPassToTextBox = '';

            phoneNamePassToHdn = '';

            isAllSelectCheckBox = false;

            listOfLookupsElement = new list < PhoneNumberDetail > ();

            String byName = '\'%' + String.escapeSingleQuotes(searchByName) + '%\'';

            String byPhone = '\'%' + String.escapeSingleQuotes(searchByPhone) + '%\'';

            String CountryCode = null;

            boolean isCountryCodeAlreadyExist;

            try {

                String query = 'SELECT  Name,ProductCode,Description FROM Product2 WHERE name Like ' + byName ;

                list < Product2 > s = Database.query(query);   

                for (Product2 sObj: s) {

                    listOfLookupsElement.add(new PhoneNumberDetail(String.valueOf(sObj.get('Name')), String.valueOf(sObj.get('ProductCode')), String.valueOf(sObj.Description), false, isCountryCodeAlreadyExist));

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

            for (PhoneNumberDetail pn: listOfLookupsElement) {

                if (pn.isChecked) {

                    phoneNumberPassToTextBox += pn.sObjectNameField + ',';

                }

            }

        }

        /*Event for all select in single check*/

    public void onSelectAll() {

            phoneNumberPassToTextBox = '';

            phoneNamePassToHdn = '';

            String CountryCode = '';

            for (PhoneNumberDetail pn: listOfLookupsElement) {

                if (isAllSelectCheckBox) {

                    pn.isChecked = true;

                } else {

                    pn.isChecked = false;

                }

                if (pn.isChecked) {

                    phoneNumberPassToTextBox += pn.sObjectNameField + ',';

                }

            }

        }

        /*P2l Detail wrapper*/

    public class PhoneNumberDetail {

        public boolean isChecked {get;set;}

        public String sObjectNameField {get;set;}

        public String sObjectPhone {get; set;}

        public String countryCode {get;set;}

        public boolean isCountryCodeExist {get;set;}

        public PhoneNumberDetail(string sObjectNameField, string countryCode, string sObjectPhone, boolean isChecked, boolean isCountryCodeExist) {

            this.sObjectNameField = sObjectNameField;

            this.sObjectPhone = sObjectPhone;

            this.countryCode = countryCode;

            this.isChecked = isChecked;

            this.isCountryCodeExist = isCountryCodeExist;

        }

    }

}