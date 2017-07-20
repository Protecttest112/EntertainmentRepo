({
	doinit : function(component, event, helper) {
		var action = component.get("c.getExpenses");
        action.setCallback(this,function(response){
           var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){ 
            //    var expview = component.get("v.expenses");
             //   var expviewParse =response.getReturnValue();
              //  expview.concat(expviewParse);
             //   component.set("v.expenses",expview);
                component.set("v.expenses",response.getReturnValue());
            }else{
                console.log(state);
            }
        });
        $A.enqueueAction(action);
	},
    render : function(component, helper){
        helper.open(component, null, "new");
    }
})