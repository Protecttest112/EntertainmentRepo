({
    validateform  : function(component) {
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
        }else{
            nameCmp.set("v.errors",null);
        }
        if($A.util.isEmpty(QtyIdVal)){
            isvalidInput= false;
            QtyId.set("v.errors",[{message:"Campaign Quantity can't be blank."}]);
        }else{
            QtyId.set("v.errors",null);
        }
        if($A.util.isEmpty(PriceIdVal)){
            isvalidInput= false;
            priceId.set("v.errors",[{message:"Campaign Price can't be blank."}]);
        }else{
            priceId.set("v.errors",null);
        }
   return (isvalidInput);    
},
 createItem  : function(component,item) {
    var action = component.get("c.saveItem"); 
    action.setParams ({
        "item":item
    });
    action.setCallback(this,function(response){
        var state = response.getState();
        if(component.isValid() && state =='SUCCESS'){
            var updateList = component.get("v.items");
            var response = response.getReturnValue();
            updateList.push(response);
            component.set("v.items",updateList);
        }
    });
    $A.enqueueAction(action);
}
})