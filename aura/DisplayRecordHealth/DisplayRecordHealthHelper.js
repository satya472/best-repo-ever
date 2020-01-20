({
    fetchDetails : function(component) {
        
        component.set("v.healthSpinner",true);
        
        let action = component.get("c.getRecordHealthDetails");
        //Passing parameters to the apex controller
        action.setParams({
            recordId : component.get("v.recordId"),
            objName : component.get("v.sObjectName")
        });
        
        //Fetching columns and its related data for the fields mentioned in fieldset
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                console.log('@@'+rtnValue);
                component.set("v.healthList",rtnValue);
                this.createProgressStep(component);
                
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Health Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Fetching Health Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            
            component.set("v.healthSpinner",false);
        });
        
        
        $A.enqueueAction(action);
        
    },
    createProgressStep : function(component){
        
        component.set("v.healthSpinner",true);
        component.set("v.Prog",false);
        component.set("v.goodProg",false);
        component.set("v.greatProg",false);
        component.set("v.currentStep",'');
        let healthLst = component.get("v.healthList");
        
        component.set("v.totalCount",healthLst.length);
        let totalCount = component.get("v.totalCount");
        console.log('^^'+totalCount);
        let actualVal = 0;
        // Add the completed steps
        for (let index in healthLst) 
        {
            let step = healthLst[index];
            if(step.completed)
            {
                actualVal++;                
            }
            
        }
        
        component.set("v.actualCount",actualVal);
        console.log('actualVal'+actualVal);
        let totalDegree;
        if(actualVal==0)
        {
            totalDegree =(actualVal+0.4/totalCount)*360; 
        }
        else 
        {
            totalDegree =(actualVal/totalCount)*360;
        }
        
        component.set("v.value",totalDegree);
        let countPercent = (actualVal/totalCount)*100;
        console.log('^^'+totalDegree);
        console.log('^^'+countPercent);
        
        //For displaying conditional text and giving color depending on percentage completion
        
        if(countPercent <= 50)
        { 
            if(countPercent <= 25)
            {
                component.set("v.theme",'red');
                component.set("v.Prog",true);
            }
            else
            {
                component.set("v.theme",'orange');
                component.set("v.goodProg",true);
            }
        } 
        else
        {
            component.set("v.theme",'green');
            component.set("v.greatProg",true);  
        }
        component.set("v.healthSpinner",false);
        
    }
})