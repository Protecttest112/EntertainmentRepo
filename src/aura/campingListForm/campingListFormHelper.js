({
	createItem : function(component,value) {
		var evnt = component.getEvent("addItem");
        evnt.setParams({"item":value});
        evnt.fire();
        component.set("v.newitem",{ 'sobjectType': 'Camping_Item__c',
                                                                   'Name': '',
                                                                   'Price__c': 0,
                                                                   'Quantity__c': 0,
                                                                   'Packed__c': '' });
	}
})