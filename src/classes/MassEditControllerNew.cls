public class MassEditControllerNew{

    public MassEditControllerNew(ApexPages.StandardController controller) {

    }

public LIST<Account>a1{get;set;}
    public MassEditControllerNew(ApexPages.StandardSetController controller) {
    a1 = new LIST<Account>();
    a1 = [select Id,Name,Rating,Phone,Owner.Name from Account where phone !=null LIMIT 10];
    }


public MassEditControllerNew(){
}
}