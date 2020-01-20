({
    loadData : function(component) {
        component.set("v.relatedSpinner",true);
        //Fetching the ChildRecord details
        let action = component.get("c.getParentChildRecordDetails");
        //Passing parameters to the apex controller
        action.setParams({
            parentObjName : component.get("v.parentObj"),
            childObjName : component.get("v.childObj"),
            parentFilter : component.get("v.parentFilter"),
            childFilter : component.get("v.childFilter"),
            fieldApiName : component.get("v.parentChildRelField"),
            childRecordFieldSet : component.get("v.fieldSetName")
        });
        
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                
                //Setting up the Id field with Url formatting and removing the name from the list 
                //So that link to the record will be displayed
                let columnId = {
                    'label' : 'Id',
                    'fieldName' : 'Id',
                    'type' : 'url',
                    'sortable' : false
                };

                rtnValue.forEach(function(recList){
                    recList.childRecordsDetails.tableColumn.unshift(columnId);
                    recList.childRecordsDetails.tableColumn.forEach(function(rec,index){
                        //We don't need the name field as it is displayed as url Name
                        //so we are removing it from the list
                        if(rec.fieldName == 'Name'){
                            recList.childRecordsDetails.tableColumn[0].label = rec.label;
                            recList.childRecordsDetails.tableColumn[0]['typeAttributes'] = { label: { fieldName: rec.fieldName } ,target: '_top'};
                            recList.childRecordsDetails.tableColumn.splice(index,1);
                        }
                    });
                    
                    recList.childRecordsDetails.tableRecord.forEach(function(rec,index){
                        rec.Id = $A.get('$Label.c.Util_CommunityRecordURL')+rec.Id;
                    });
                    
                });
                
                component.set("v.parentChildRec",rtnValue);
                
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
            
            component.set("v.relatedSpinner",false);
        });
        $A.enqueueAction(action);
    }
})