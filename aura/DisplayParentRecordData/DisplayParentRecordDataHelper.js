({
	getLightningTableData : function(component) {
		let sColumn = component.get("v.fieldSetName");
        let sObject = component.get("v.object");
        let action = component.get("c.getFieldDetails");
        //Passing parameters to the apex controller
        action.setParams({
            ObjectName : sObject,
            fieldSetName : sColumn
        });
        
        //Fetching field details from the field sets and creating new
        //Lightning component for dispalying the data.
        action.setCallback(this,function(response){
        let state = response.getState();
        if(state == 'SUCCESS'){
            let rtnValue = response.getReturnValue();
            let fields = [];
            rtnValue.forEach(function(row){
                fields.push(row.fieldName);
            });
            component.set("v.fieldLst",fields);
            $A.createComponent(
             "c:DisplayFieldData",
            {
                "RecordId": component.get("v.parentRecordId"),
                "fieldDetails": component.get("v.fieldLst"),
                "objApiName": component.get("v.object"),
                "hyperLinkToRecord" : true
            },
            function(fieldComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.viewBody");
                    body.push(fieldComponent);
                    component.set("v.viewBody", body);
                }
                else if (status === "INCOMPLETE") {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                                "title": "Error!",
                                "message": "No response from server or client is offline."
                        });
                        toastEvent.fire();
                }
                else if (status === "ERROR") {
                     let toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                                "title": "Error!",
                                "message": errorMessage
                     });
                     toastEvent.fire();
                    component.set("v.errorMsg",'Error in Loading the Data Please check With the Administrator');
                }
            }
        );
            
        }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       toastEvent.setParams({
                                "title": "Error!",
                                "message": "Error in Fetching Related List Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                   toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Related List Details: Unknown Error"
                   });
                   toastEvent.fire();
                }
              
              component.set("v.errorMsg",'Error in Loading the Data Please check With the Administrator');
            
            }else{
                console.log('Something went wrong, Please check with your admin');
                component.set("v.errorMsg",'Error in Loading the Data Please check With the Administrator');
            }
       });
         $A.enqueueAction(action);
	},

    getQueryFromId : function(component) {

        //For fetching the details of parent record from the Current displayed record
	    let FieldName = component.get("v.ParentObjectRelation");
        let DetailId = component.get("v.recordId");
        let sObjectName = component.get("v.sObjectName");

        let action = component.get("c.getParentInformationFromRecord");
            action.setParams({
                sObjectName : sObjectName,
                fieldName : FieldName,
                detailId : DetailId
                }
            );
        
        let self = this;
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let retrnValue = response.getReturnValue();
                component.set("v.parentRecordId", retrnValue);
                if($A.util.isEmpty(retrnValue)){
                    component.set('v.errorMsg','Mapping Lookup Value does not Exist');
                }
                self.getLightningTableData(component);
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Parent Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                   toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Parent Details: Unknown Error"
                   });
                   toastEvent.fire();
                }
                
                component.set("v.errorMsg",'Error in Loading the Data Please check With the Administrator');
            }else{
                component.set("v.errorMsg",'Error in Loading the Data Please check With the Administrator');
            }
        });

        $A.enqueueAction(action);
    },
})