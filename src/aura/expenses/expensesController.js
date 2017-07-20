({
	clickCreateExpense : function(component, event, helper) {
		var isValid=true;
        var expname = component.find("expname");
        var expVal = expname.get("v.value");
        if($A.util.isEmpty(expVal)){
            isValid= false;
            expname.set("v.errors",[{message:"Expense name can't be blank."}]);
        }else{
            isValid= true;
            expname.set("v.errors","");
        }
        if(isValid){
            var expVals = component.get("v.newExpense");
            helper.createExpense(component,expVals)
        }
	}
})