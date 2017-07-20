({
	handlebtn1 : function(component, event, helper) {
		var evnt = event.getSource();
        var btnMessage = evnt.get("v.label");
		component.set("v.message",'Pressed Button 1');
    },
	handlebtn2 : function(component, event, helper) {
		var evnt1 = event.getSource();
        var btnmsg = evnt1.get("v.label");
        component.set("v.message",'Pressed Button 2');
	}
})