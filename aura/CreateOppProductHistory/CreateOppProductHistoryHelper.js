({
	getHistoryTableData : function(component) {
        let objName = component.get("v.sObjectName");
        let recordId = component.get("v.recordId");
        let action = component.get("c.getSourceRecords");
        //Passing parameters to the apex controller
        action.setParams({
            ObjectName : objName,
            recordId:component.get("v.recordId")
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
                    else if(rec.type == 'currency'){
                        rec.cellAttributes = {alignment: 'left'};
                    }
                    
                });
                
                //We don't need the name field as it is displayed as url Name
                //so we are removing it from the list
                if(nameExists)
                {
                    rtnValue.tableColumn.splice(nameIndex,1);
                }
                rtnValue.historyRecords.forEach(function(rec,index){
                    rec.editId = rec.Id;
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

                component.set("v.mycolumn",rtnValue.tableColumn);
                component.set("v.mydata",rtnValue.historyRecords);
                component.set("v.recList",rtnValue.historyRecords);
                component.set("v.optionsLst",rtnValue.fieldByPickList);
                component.set("v.compFilters",rtnValue.filters);
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
 
    updateOppProdHistoryRecords : function(component)
    {
        
       // let sourceList = component.get("v.selectedLst");
        let statusFilter = component.get("v.statusFilter");
        let wonLossFilter = component.get("v.wonLossFilter");
        let action = component.get("c.updateOpportunityProductHistoryRecords");
        
        //Passing parameters to the apex controller
        action.setParams({
            sourceRecordList : JSON.stringify(component.get("v.selectedLst")),
            stageValue : statusFilter,
            wonLossValue : wonLossFilter
        });
        
        let _self = this;
        
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
                    "message": "Record updated successfully"
                });	
               // $A.get("e.force:closeQuickAction").fire() ;
                toastEvent.fire();
                component.set("v.recCreateSpinner",false);
                component.set("v.selectedLst",'');
                component.set("v.mydata",'');
               _self.getHistoryTableData(component); 
            }else if (state === 'ERROR'){
                let errors = response.getError();
                $A.get("e.force:closeQuickAction").fire() ;
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error Updating of Records: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error Updating of Records: Unknown Error"
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