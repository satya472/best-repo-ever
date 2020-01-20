({
    dataLoad : function(component) {
        
        component.set("v.relatedSpinner",true);        
        let action = component.get("c.getHierarchyDetails");
        //Passing parameters to the apex controller
        action.setParams({
            recordId : component.get("v.recordId"),
            objectName : component.get("v.sObjectName")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                component.set("v.items",rtnValue);
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Fetching Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.relatedSpinner",false);
        });
        $A.enqueueAction(action);
        
    }
})