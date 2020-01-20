({
	navigateToSObject : function(component, event, helper) {
		var sObjId = component.get("v.sObjectId");          
        var navToSObjEvt = $A.get("e.force:navigateToSObject");
        navToSObjEvt.setParams({
            recordId: sObjId,
            slideDevName: "detail"
        });
        navToSObjEvt.fire();
      
    /*     $A.createComponent(
             "force:recordView",
            {
                "recordId": sObjId
            },
            function(fieldComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.viewBody");
                    body.push(fieldComponent);
                    component.set("v.viewBody", body);
                }
            });   */
        
    },
})