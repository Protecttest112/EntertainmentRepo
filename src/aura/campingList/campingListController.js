/*({
    checkValue : function(component, event, helper) {
        var isvalidInput=true;
        var nameCmp = component.find("Name");
        var nameVal = nameCmp.get("v.value");
        var QtyId = component.find("QtyId");
        var QtyIdVal = QtyId.get("v.value");
        var priceId = component.find("PriceId");
        var PriceIdVal = priceId.get("v.value");
        
        if($A.util.isEmpty(nameVal)){
            isvalidInput= false;
            nameCmp.set("v.errors",[{message:"Campaign name can't be blank."}]);
        }
       else if($A.util.isEmpty(QtyIdVal)){
            isvalidInput= false;
            QtyId.set("v.errors",[{message:"Campaign Quantity can't be blank."}]);
        }
       else if($A.util.isEmpty(PriceIdVal)){
                isvalidInput= false;
                priceId.set("v.errors",[{message:"Campaign Price can't be blank."}]);
            }
           
        return (isvalidInput);
        if(isvalidInput){
            var newItem = component.get("v.newitem");
            var updatedItem = component.get("v.items");
            var jsoninput = JSON.parse(JSON.stringify(newItem));
            updatedItem.push(jsoninput);
            component.set("v.items",updatedItem);
            component.set("v.newitem",{'sobjectType': 'Camping_Item__c',
                                       'Name': 'Default',
                                       'Price__c': 0,                                   
                                       'Quantity__c': 0,
                                       'Packed__c': false });
        
         
        }
    }
}), */
({
    doInit: function(component, event, helper) {
        var action =component.get("c.getItems");
        action.setCallback(this,function(response){
            var status = response.getState();
            if(component.isValid() && status== 'SUCCESS'){
                var response= response.getReturnValue();
                component.set("v.items",response);
            }
        });
        $A.enqueueAction(action);
    },
    createItem : function(component, event, helper) {
        if(helper.validateform (component)){
            var newItem = component.get("v.newitem");
            helper.createItem(component,newItem);
        }
    },
    handleAddItem : function(component, event, helper) {
        alert('Event Received');
        var params = event.getParam("item");
        var action = component.get("c.saveItem");
        action.setParams({"item":params});
        action.setCallback(this,function(response){
            var state = response.getState();
            var pageitem = component.get("v.items");
            var resresult = response.getReturnValue();
            component.set("v.items",resresult);
        });
        $A.enqueueAction(action);
    }
})