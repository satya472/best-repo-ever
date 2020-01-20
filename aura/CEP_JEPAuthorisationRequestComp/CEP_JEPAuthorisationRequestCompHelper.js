({
    submitDetailsHelper : function(component,event) {
        let sendMailAction=component.get("c.sendMailMethod");
        sendMailAction.setParams({
            'fName' : component.get("v.firstName"),
            'lName' : component.get("v.lastName"),
            'emailId' : component.get("v.customerEmail"),
            'accName' : component.get("v.accRequest"),
            'plantRequest' : component.get("v.plantRequest"),
            'equipRequest' : component.get("v.equipRequest")            
        });
        component.set("v.spinner",true);
        sendMailAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.mailSentStatus", true);
                component.set("v.spinner",false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Sending mail INCOMPLETE: '+response.ReturnValue());
                component.set("v.spinner",false);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message);
                            component.set("v.spinner",false);
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.spinner",false);
                    }
                }
        });
        $A.enqueueAction(sendMailAction);		
    },
    
    closeMessageHelper : function(component,event){
        component.set("v.firstName", null);
        component.set("v.lastName", null);
        component.set("v.accRequest", null);
        component.set("v.plantRequest", null);
        component.set("v.equipRequest", null);
        component.set("v.customerEmail", null);
        component.set("v.mailSentStatus", false);
    },
})