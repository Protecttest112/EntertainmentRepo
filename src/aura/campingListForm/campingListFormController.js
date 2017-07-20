({
	submitForm : function(component, event, helper) {
        var campaignVal = component.get("v.newitem");
        helper.createItem(component,campaignVal);
        }
})