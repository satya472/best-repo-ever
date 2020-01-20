({
    autoPopulateHelper : function(component,helper){

        //Auto populating the fields  
        let autoLst = [];
	    if(component.get("v.sObjectName") == 'Opportunity'){
			autoLst.push('Opportunity__c-'+ component.get("v.recordId"));
		}else{
			autoLst.push('Opportunity__c-'+ component.get("v.recordData.Opportunity__c"));
        }
        
        //Status of New Intelligence Record
        autoLst.push('Status__c-Draft');

		component.set("v.autoPopList",autoLst);
	},
	fetchQuoteLineItems : function(component,helper){

        component.set("v.spin",true);

        let action = component.get("c.getQuoteLineItems");
        
        //Passing parameters to the apex controller
        action.setParams({
			currentRecordId : component.get("v.recordId"),
			objectName : component.get("v.sObjectName")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(component.isValid() && state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                component.set("v.quoteLineList",rtnValue);
    
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

            component.set("v.spin",false);
        });
        $A.enqueueAction(action);
    },
    updateIntelligenceRecord: function(component,helper){

        component.set("v.spin",true);

        // Updating the Intelligence record with the Selected SBQQ Quote Line Id 
        let action = component.get("c.updateIntelligenceRecord");
        
        //Passing parameters to the apex controller
        action.setParams({
			recordId : component.get("v.newIntelligenceRec").id,
			quoteLineId : component.get("v.selectedQuoteLine")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(component.isValid() && state == 'SUCCESS'){
                //Showing the TreeMap after Updating the Intelligence record with selecte SBQQ QuoteLine Id
                component.set("v.afterPrice",true);
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

            component.set("v.spin",false);
        });
        $A.enqueueAction(action);

    }
})