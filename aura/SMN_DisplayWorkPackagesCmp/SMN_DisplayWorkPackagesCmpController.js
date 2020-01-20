({
	/*
     * used to handle modal closure
     */
    close : function(component, event, helper){	
        
        component.set("v.openWorkPackageModal",false);
        
        
    },
    
    confirm: function(component, event, helper){	
       
        var obj =  component.get("v.selectedRowsList");        
        var updateAction = component.get("c.createWorklets");
        updateAction.setParams({ "selectedWorkPackages_str": JSON.stringify(obj),
                                 "recordId":component.get("v.recordId"),
                                 "currentRecord":component.get("v.currentRecord")
                               });
        updateAction.setCallback(this, function(a) {
            var state = a.getState();
            
            if (state === "SUCCESS"){ 
                //close modal
                component.set("v.openWorkPackageModal",false);
                
                //fire event to reload only worklets list without refreshing the whole page
                var cmpEvent = component.getEvent("reloadWorklets");                
                cmpEvent.fire();
                
                helper.showToast(component,event,helper,'Success','Worklets has been created successfully','success');
                
            }else {
                var errors = a.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(component,event,helper,'Error',errMsg,'error');
                
            }
            
        });
        $A.enqueueAction(updateAction);
        
    },
    
    updateColumnSorting: function (cmp, event, helper) {
        let fieldName = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        
        //On UI it will be displayed as Name but on click of Sort it happens on Id as the column belongs to Id
        //to sort on Name instead of Id we are check the fieldName and proceeding based on that
        helper.sortData(cmp, fieldName == 'Id'?'Name':fieldName, sortDirection);
        
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        
    },
    
    
    updateSelectedText : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');        
        component.set("v.selectedRowsList" ,selectedRows );
        
    },
    

    
})