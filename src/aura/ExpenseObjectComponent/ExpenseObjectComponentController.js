({
	clickReimbursed : function(component, event, helper) {
		var expense = component.get("v.expense");
        var updateEvent = component.getEvent("updateExpense");
        updateEvent.setparams({"expense":expense});
        updateEvent.fire();
	}
})
({
	expensesItemUpdate : function(component, event, helper) {
		var expense = component.get("v.expense");
        var updateEvent = component.getEvent("updateExpense");
        updateEvent.setparams({"expense":expense});
        updateEvent.fire();
	}
})