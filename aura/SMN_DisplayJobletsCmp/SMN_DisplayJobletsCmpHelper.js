({
	 getData : function(component,helper) {
        
        var action = component.get("c.getListTodisplay");
         
        action.setParams({
            "recordId": component.get("v.recordId"),
            "currentRecord":component.get("v.currentRecord"),
            "fieldSetName" : component.get("v.fieldSetName"),
            "fieldSetNameWorkPackage":component.get("v.fieldSetNameWorkPackage"),
            "recordObject":component.get("v.sObjectName"),
            "parentChildRelatedField":component.get("v.parentChildRelatedFieldAPI"),
            "childObjectName":component.get("v.contextRelatedRecordName")=='-Select-'?'':component.get("v.contextRelatedRecordName")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS"){  
                var result=a.getReturnValue();
                
                //fill the table data (worklet list) + table columns (from fieldset chosen)
                component.set("v.data",result.workletTableWrapper.tableRecord);
                                             
                var tableColumn=result.workletTableWrapper.tableColumn;
                var columns = [
                    {label: '', type: 'button',initialWidth: 3,typeAttributes:
                     { label: { fieldName: 'viewLabel'}, variant:"base",title: 'Click to View', name: 'view_details', iconName: 'utility:zoomin'}}
                    
                ];
                
                for(var i=0;i<1;i++){
                    columns.push(tableColumn[i]);
                }
                
                var columnsAction = 
                    {label: 'Status', type: 'button',typeAttributes:
                     { label: { fieldName: 'Status__c'}, title: 'Click to View', name: 'edit_status', iconName: 'utility:edit',disabled: {fieldName: 'actionDisabled'},class: 'btn_status'}}
                    
                ;
                
                columns.push(columnsAction);
                
                 for(var i=1;i<tableColumn.length;i++){
                    columns.push(tableColumn[i]);
                }
                
                component.set("v.columns", columns);
                
                //fill work package table info
                component.set("v.workPackageColumns",result.workPackageTableWrapper.tableColumn);
                component.set("v.workPackageData",result.workPackageTableWrapper.tableRecord);
                            
                //hide spinner
                component.set("v.isLoading",false);
                
            }else {
                var errors = a.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(component,event,helper,'Error',errMsg,'error');
                component.set("v.isLoading",false);
            }
            
            
        });
        
        $A.enqueueAction(action);
    },
    
    
     sortData: function (cmp, fieldName, sortDirection) {
       
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
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
    
    showRowDetails: function(component,row,helper) {
        
        component.set('v.worklet',row);
        component.set('v.openWorkletModal',true);
    },
    
    updateWorkletStatusHelper: function(cmp,row,status,helper) {
        var action = cmp.get("c.updateWorkletStatus");
        action.setParams({
            "workletId": row.Id,
            "newStatus":status
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS"){  
                helper.showToast(cmp,event,helper,'Success','Worklet status updated successfully!','success');
                
            }else {
                var errors = a.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(cmp,event,helper,'Error',errMsg,'error');
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    editRowStatus: function(cmp,row,helper) {
       
        var data = cmp.get('v.data');
        
        for(var i=0; i<data.length;i++){
            if(data[i].Id==row.Id){
                if(data[i].Status__c=='Open'){                   
                    data[i].Status__c = 'In Progress';   
                    
                }else if(data[i].Status__c=='In Progress'){
                    data[i].Status__c = 'Complete';
                    
                }
                else if(data[i].Status__c=='Complete'){
                    data[i].Status__c = 'Open';
                    
                }
                
                helper.updateWorkletStatusHelper(cmp,row,data[i].Status__c,helper);
                
                
                
            }
            
        }
              
        cmp.set('v.data',data);
    }
})