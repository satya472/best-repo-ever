({
	doInit : function(component, event, helper) {
        //display spinner
        component.set("v.isLoading",true);
        
        let relatedRecord = component.get("v.contextRelatedRecordName")=='-Select-'?'':component.get("v.contextRelatedRecordName");
        if(!$A.util.isEmpty(relatedRecord)){
            if($A.util.isEmpty(component.get("v.parentChildRelatedFieldAPI"))){
                   // helper.showToast(component,event,helper,'Error','Please provide Data in both the Context Related Fields or Clear Both the Values','error');
                   throw new Error('Please provide Parent Child related Field API Name');
            }
        }
        
        //get data for worklets + workPackage
        helper.getData(component,helper);        
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
    
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                helper.showRowDetails(component,row);
                break;
            case 'edit_status':
                helper.editRowStatus(component, row,helper);
                break;
            default:
                helper.showRowDetails(component,row);
                break;
        }
    },
    
    openWorkpackagesListModal: function (component, event, helper) {
        component.set("v.openWorkPackageModal",true);
    }
    
   
})