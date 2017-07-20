public class customclass implements Comparable{
public date d1;

public void test1(){

List<Account> b = new List<Account>();

b=[SELECT Name,Phone,SLA__c,SLAExpirationDate__c from Account ];

system.debug ('asdsa'+b);
b.sort();
}

public Integer compareTo(Object compareTo){ 

    system.debug('^^^^'+compareTo);
        customclass compareToEmp = (customclass)compareTo; 
        if (d1== compareToEmp.d1) return 0; 
        if (d1> compareToEmp.d1) return 1; 
        return -1;          
        } 
}