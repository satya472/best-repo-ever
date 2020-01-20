({
	dataLoad : function(component) {
        //Fetching the Segmentation Attribute details
        component.set("v.load",true);
        
		let action = component.get("c.getSegmentationAttributes");
        //Passing parameters to the apex controller
        action.setParams({
            categoryDevName : component.get("v.segCategory"),
            recordId : component.get("v.recordId")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                component.set("v.records",rtnValue);
                //Setting the Category Name to display as card Title so that End User will be able to identify then properly
                if(!$A.util.isEmpty(rtnValue)){
                    component.set("v.categoryName",rtnValue[0].segAtt.SegmentationCategory__r.MasterLabel);
                }
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "error",
                            "message": "Error in Fetching Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": "Error in Fetching Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.load",false);
        });
        $A.enqueueAction(action);
	},
    saveRecords: function(component){
        //Saving the Segmentation Attribute records
        component.set("v.load",true);
        let action = component.get("c.saveSegmentationAttributes");
        //Passing parameters to the apex controller
        action.setParams({
            recordList : JSON.stringify(component.get("v.records")),
            recordId : component.get("v.recordId")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "message": "Records Upserted SuccessFully!!"
                });
                toastEvent.fire();
                this.dataLoad(component);
            }else if (state === 'ERROR'){
                let errors = response.getError();
               
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "error",
                            "message": "Error in Saving Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": "Error in Saving Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.load",false);
        });
        $A.enqueueAction(action);
    }
    
})