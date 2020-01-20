({
	doInit : function(component, event, helper) {
		  let action = component.get("c.fetchCustomMetadataRecords");
        //Passing parameters to the apex controller
        action.setParams({
            metaDataName : component.get("v.metaDataName"),
            objectName : 'DisplayRelatedList__mdt',
            fields : 'CardTitle__c,ChildObjectAPIName__c,CreateNewRecord__c,DisplayRecordsLimit__c,EditMode__c,FieldSetName__c,FilterBy__c,FilterTargetObjectRecordsBy__c,'+
                     'ParentFieldAPINameOfCurrentRecord__c,ParentFieldAPINameOnChildObject__c,RelatedListFieldId__c,RowsSelectable__c,SortByFieldAPIName__c,SortDirection__c'
        });

        action.setCallback(this,function(response){
        let state = response.getState();
        if(component.isValid() && state == 'SUCCESS'){
            let rtnValue = response.getReturnValue();
            if(!$A.util.isEmpty(rtnValue)){
                component.set("v.metaDataDetails",rtnValue[0]);
            }else{
                component.set("v.errorMsg",'No Records Found.Please Enter Proper metaDataName');
            }
        }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsg","Error in Fetching Details: "+errors[0].message);
                    }
                } else {
                   component.set("v.errorMsg", "Error in Fetching Details: Unknown Error");
                }
            
            }else{
                component.set("v.errorMsg",'Error in Loading the Data Please check With the Administrator');
            }
       });
       $A.enqueueAction(action);
	},
     navigateToSObject: function (component, event) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
        });
        
        navEvt.fire();
    },
})