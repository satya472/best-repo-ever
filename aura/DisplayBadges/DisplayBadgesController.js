({
	doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        let sObjName = component.get("v.sObjectName");
        let action = component.get("c.getBadgeDetails");
        //Passing parameters to the apex controller
        action.setParams({
            recordId : component.get("v.recordId"),
            objName : sObjName
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                
                if(rtnValue.length == 0){
                    component.set("v.msg",'No Badges to Display');
                }else{
                    component.set("v.imageLst",rtnValue);
                }
                
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
            
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	}
})