({
    clickReimbursed: function(component, event, helper) {
        var expense = component.get("v.expense");
        var updateEvent = component.getEvent("updateExpense");
        alert(JSON.stringify(expense));
        updateEvent.setParams({ "expense": expense });
        updateEvent.fire();
    }
})