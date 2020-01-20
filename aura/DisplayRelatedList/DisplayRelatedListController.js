({
    init : function(component, event, helper) {
        //Checking whether user provided input for ParentObjectField
        let parentId = component.get("v.ParentObjectIdField");
        
        //Checkign Whether parent Id Valued Exists or not
        if($A.util.isEmpty(parentId)){
            
            helper.getLightningTableData(component); 
        } else
        {
            helper.getQueryFromId(component);
        } 
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
    getSelectedName: function (component, event) {
        
        var selectedRows = event.getParam('selectedRows');
        for (var i = 0; i < selectedRows.length; i++){
            console.log(selectedRows[i].Id);
        }        
    },
    
    navigateToSObject: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": selectedRows[0].Id,
        });
        
        navEvt.fire();
    },
    
    editRecord : function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.showPopup",true);
        if(selectedRows.length != 0){
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": selectedRows[0].Id,
            });
            editRecordEvent.fire();
        }
        component.set("v.showPopup",false);
    },
    createRecord : function(component, event,helper) {        
        if(!$A.util.isEmpty( component.get("v.RecordType"))){
          let recTypeId = '';
          component.get("v.recordTypeLst").forEach(function(rec){
              if(rec.DeveloperName == component.get("v.RecordType")){
                recTypeId = rec.Id;
              }
          });

          helper.newRecord(component,recTypeId);
        }else if(!$A.util.isEmpty(component.get("v.recordTypeLst"))){
            component.set("v.showRecordTypeSelection",true);
        }else{
            helper.newRecord(component,'');
        }
    },
    showAll : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");  
        evt.setParams({
            componentDef:"c:DisplayFullRelatedList",
            componentAttributes: {
                recordsList: component.get("v.fullListData"),
                objectApiName: component.get("v.object"),
                fieldsList: component.get("v.mycolumn"),
                iconName:component.get("v.iconName"),
                parentId : $A.util.isEmpty(component.get("v.ParentObjectId"))?component.get("v.recordId"):component.get("v.ParentObjectId")
            }
        });
        evt.fire();
    },
    
    editMode : function(component, event, helper) {
        helper.showPopup(component);
    },
    cancelPopup: function(component, event, helper){
        helper.cancel(component);
    },
    filterRecords : function(component, event, helper){
        component.set("v.relatedSpinner",true);; 
        let dataRec = component.get("v.fullListData");
        var splitFilters = component.get("v.filterBy").split(",");  
        var filters = [];
        for (var i in splitFilters) {  
            let elementVal = document.getElementById(splitFilters[i]).value;
            if(elementVal == 'All'){
                continue;
            }
            filters[filters.length] = splitFilters[i]+','+elementVal; 
        } 
        let filterLst = [];
        if($A.util.isEmpty(filters)){
            filterLst = dataRec;
        }else{
            
            filterLst = dataRec.filter(function(rec){
                let filterSatisfied = false;
                filters.every(function(fList){
                    let fSplit = fList.split(',')
                    if(rec[fSplit[0]] == fSplit[1]){
                        filterSatisfied = true;
                        return true;
                    }else{
                        filterSatisfied = false;
                        return false;
                    }
                    
                });
                return filterSatisfied;
            });
        }
        component.set("v.mydata",filterLst);
        component.set("v.relatedSpinner",false);
    },
    close : function(component,event,helper){
          component.set("v.showRecordTypeSelection",false);
    },
    radioChange : function(component,event,helper){
      component.set("v.currentRecordTypeId",event.getSource().get("v.value"));
    },
    handleNext: function(component,event,helper){
        helper.newRecord(component,component.get("v.currentRecordTypeId"));
        component.set("v.showRecordTypeSelection",false);
    },
    
})