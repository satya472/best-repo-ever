({
    getAccountDetailsHelper : function(component,event) {
        
        let action = component.get("c.getAccountDetailsMethod");
        action.setParams({
            recordId : component.get("v.accountId")
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                component.set("v.accountRecord",response.getReturnValue());
            }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error in Fetching Details: "+errors[0].message);
                    }
                } else {
                    console.log("Error in Fetching Details: Unknown Error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    }
    
})