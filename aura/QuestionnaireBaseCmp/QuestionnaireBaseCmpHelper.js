({
    //helper mothod to get the list of questionnaire according to the current LOA project stage
    getQuestionnairesHelper:function(component,event,helper){
        var action = component.get("c.getQuestionnaire");
        action.setParams({
                stageName : component.get("v.currentRecord.Stage__c"),
                projectIdString : component.get("v.currentRecord.Id")
            }
        );
        
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){

                let currRec = component.get("v.currentRecord");

                let rtnValue = response.getReturnValue();

                component.set("v.Questionnaires",rtnValue);
                
                
            }else{
                
                var errors = response.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(component,event,helper,'Error',errMsg,'error');
            }
            
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);
    },
    
    /*
    * Used to show toast
    */
    showToast : function(component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type 
        });
        toastEvent.fire();
    },
})