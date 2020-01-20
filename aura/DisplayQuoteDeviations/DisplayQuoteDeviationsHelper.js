({
    getLightningTableData : function(component) {
        component.set("v.recObject",component.get("v.sObjectName"));
        
        let sColumn = component.get("v.fieldSetName");
        let sObject = component.get("v.object");
        let currentRecId = component.get("v.recordId");
        let objName = component.get("v.sObjectName");
        let fieldName = component.get("v.TargetParentField");
        let fetchValue = component.get("v.fetchValue");
        let targetObject = component.get("v.TargetFieldId");
        let targetReportField = component.get("v.TargetReportField");
        let recId = component.get("v.recordId");//Record id of the object component sitting on
        //passing CurrentRecordId or Parent of Current Record as filter based on user inputs
        let additionalFilter = component.get("v.AdditionalFilter");
        let filterBy = component.get("v.filterBy");
        let action = component.get("c.getSourceRecords");
        let sourceQuery = component.get("v.QueryString");
        let recObject = component.get("v.recObject");
        
        
        //Passing parameters to the apex controller
        action.setParams({
            ObjectName : sObject,
            fieldSetName : sColumn,
            AdditionalFilter : additionalFilter,
            filterByField : filterBy,
            fieldMappingId : component.get("v.filterById"),
            fieldName:component.get("v.TargetParentField"),
            fieldValue :component.get("v.recordId"),
            targetObject:targetObject,
            sourceReportField:component.get("v.TargetReportField"),
            paramString:component.get("v.QueryString"),
            recordId:component.get("v.recordId"),
            recObject:component.get("v.recObject"),
            recordFields:component.get("v.RecordFilters")
            
        });
        
        //Fetching columns and its related data for the fields mentioned in fieldset
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                                //
                                //
                //Setting up the Id field with Url formatting and removing the name from the list 
                //So that link to the record will be displayed
                
                let columnId = {
                    'label' : 'Id',
                    'fieldName' : 'Id',
                    'type' : 'url',
                    'typeAttributes' : { label: { fieldName: 'Name' } ,target: '_top'},
                    'sortable' : true
                };
                
                let fields=[];                
                let nameExists = false;
                rtnValue.tableColumn.forEach(function(row)
				{
                    if(row.fieldName == 'Name')
                    {
                        nameExists = true;
                    }
                    fields.push(row.fieldName);
                });
                
                //Adding Id column only when Name field is present in the fieldSet
                if(nameExists){
                    rtnValue.tableColumn.unshift(columnId);
                }
                let nameIndex = 0;
                rtnValue.tableColumn.forEach(function(rec,index){
                    if(rec.fieldName == 'Name'){
                        rtnValue.tableColumn[0].label = rec.label;
                        nameIndex = index;
                    }
                    if(rec.type == 'reference'){
                        rec['type'] = 'url';
                        rec.typeAttributes = { label: { fieldName: rtnValue.referenceValMap[rec.fieldName]  } ,target: '_top' };
                    }
                });
                
                //We don't need the name field as it is displayed as url Name
                //so we are removing it from the list
                if(nameExists)
                {
                    rtnValue.tableColumn.splice(nameIndex,1);
                }
                
                rtnValue.nonExistingRecord.forEach(function(rec,index){
                    //rec.editId = rec.Id;
                    rec.Id = $A.get('$Label.c.Util_LtngURLFormat1')+rec.Id+$A.get('$Label.c.Util_LtngURLFormat2');    
                    if(!$A.util.isEmpty(rtnValue.referenceValMap))
                    {
                        //Looping through the referenceMap to update the values properly as required
                        Object.keys(rtnValue.referenceValMap).forEach(function(key,index) {
                            // key: the name of the object key
                            //Going inside the loop only if the reference has some value
                            if(!$A.util.isEmpty(rec[key])){
                                rec[key] = $A.get('$Label.c.Util_LtngURLFormat1')+rec[key]+$A.get('$Label.c.Util_LtngURLFormat2');
                                let data = rtnValue.referenceValMap[key].split('.');
                                rec[data[0]+'.'+data[1]] = rec[data[0]][data[1]];
                            }
                            
                        });
                    } 
                });

                                //
                component.set("v.mycolumn",rtnValue.tableColumn);
                component.set("v.mydata",rtnValue.nonExistingRecord);
                component.set("v.existList",rtnValue.existingRecord);
                component.set("v.nonExistingList",rtnValue.nonExistingRecord);
                component.set("v.optionsLst",rtnValue.fieldByPickList);
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
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    },
    
    createTargetRecords : function(component)
    {
        let sObject = component.get("v.TargetFieldId");
        let sourceList = component.get("v.selectedLst");
        let recId = component.get("v.recordId");
        let successMessage = component.get("v.SuccessMessage");
        //passing CurrentRecordId or Parent of Current Record as filter based on user inputs
        let filterById = component.get("v.filterById");
        let recFieldName = component.get("v.TargetReportField");
        sourceList.forEach(function(rec,index){
            var split = rec.Id.split("/");
            rec.Id = split[3];
        });
        let action = component.get("c.createTargetObjectRecords");
        
        //Passing parameters to the apex controller
        action.setParams({
            sourceRecordList : sourceList,
            fieldMappingId : filterById,
            targetObject : sObject,
            recValue:recId,
            recId:recFieldName
        });
        
        //Fetching columns and its related data for the fields mentioned in fieldset
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS')
            {
                console.log(' @@ SUCCESS : ');
                
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "SUCCESS",
                    "type":"Success",
                    "message": successMessage
                });	
                toastEvent.fire();
                component.set("v.selectedLst",'');
                this.getLightningTableData(component);
                
                
            }else if (state === 'ERROR'){
                let errors = response.getError();
                $A.get("e.force:closeQuickAction").fire() ;
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error Insertion of Records: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Insertion of Records: Unknown Error"
                    });
                    component.set("v.recCreateSpinner",false);
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    }
    
})