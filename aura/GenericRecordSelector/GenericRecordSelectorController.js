({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);    
        //clear search box
        component.set("v.searchKey","");
        component.find("searchBoxText").set("v.value","");
        
        helper.getSearchScope(component, event, helper);                
    },
    
    refreshScopeData : function(component, event, helper) {
        component.set("v.Spinner", true);    
        //clear search box
        component.set("v.searchKey","");
        component.find("searchBoxText").set("v.value","");        
        helper.getTableFieldSet(component, event, helper);   
        if(component.get("v.selectedValue") === 'allContacts')
            component.set("v.isCreateNewRec", true);
        else
            component.set("v.isCreateNewRec", false);
    },
    
    //For Search
    searchKeyChangeInput: function(component, event, helper) {
        var queryTerm = component.find('searchBoxText').get('v.value');  
        component.set("v.searchKey",queryTerm);        
        helper.getSearchTableData(component, event, helper);
    },
    
    //checkbox select
    checkboxSelect: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");  
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
    }, 
    
    //select all records
    selectAll: function(component, event, helper) {
        if(component.get("v.currentList.length") > 0){            
            let selectedHeaderCheck = event.getSource().get("v.value");
            let recordList = component.get("v.currentList");
            let selCount = component.get("v.selectedCount");
            for(let i in recordList){
                if(selectedHeaderCheck == true && !recordList[i].check){
                    recordList[i].check = true;
                    selCount++;
                }else{
                    if(recordList[i].check && selectedHeaderCheck == false){
                        recordList[i].check = false;
                        selCount--;
                    }
                }
            }
            component.set("v.currentList",recordList);
            component.set("v.selectedCount",selCount);
        }  
    },
    
    //create new record
    openNewRecordModal: function(component, event, helper) {
        component.set("v.createContact",true);
    },
    
    closeNewRecordModal: function(component, event, helper) {
        component.set("v.createContact", false);
        $A.get('e.force:refreshView').fire();
    },
    
    createNewContactRec: function(component, event, helper) {
        component.set("v.createContact", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Contact Created."
        });
        toastEvent.fire();
    },
    
    handleSubmit: function(component, event, helper) {
        if(event.getParams().fields['AccountId'] == null){
            event.preventDefault();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Associate an Account with the Contact!"
            });
            toastEvent.fire();
        }
    },
    
    //For Pagination   
    handlePageChange : function(component,event,helper){
        helper.renderPage(component);
    },
    
    recordsPerPageChange : function(component,event,helper){
        component.set("v.currentPageNumber",1);
        helper.renderPage(component);
    },
    
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
        $A.get("e.force:closeQuickAction").fire() ;         
    },
    
    createSelectedMember: function(component, event, helper) {
        if(component.get("v.selectedCount") > 0){ 
            component.set("v.AddRecordList",[]);
            //check for the mandatory fields
            var mandatoryFieldsError = false;
            var fieldVals = [];
            for(var key in component.get("v.fieldSetValues")){
                if(component.get("v.fieldSetValues")[key].required == "true" && 
                   component.get("v.fieldSetValues")[key].isAttribute == "true")
                    fieldVals.push(component.get("v.fieldSetValues")[key]);
            }            
            
            let addRecordList = component.get("v.AddRecordList");
            for(let i in component.get("v.tableRecords")){
                if(component.get("v.tableRecords")[i].check){                    
                    let selRec = component.get("v.tableRecords")[i];
                    //check if the mandatory fields are filled
                    for(var mandatoryField in fieldVals){                        
                        let isDataFilled = (selRec[fieldVals[mandatoryField].label] == undefined) ? 
                            selRec[fieldVals[mandatoryField].name] : selRec[fieldVals[mandatoryField].label] ;
                        if(isDataFilled == undefined || typeof isDataFilled == 'object'){
                            mandatoryFieldsError = true;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please enter the data for all fields!"
                            });
                            toastEvent.fire();
                            break;
                        }
                    }//send the data to the backend
                    if(!mandatoryFieldsError){
                        addRecordList.push(selRec);
                    }
                }
            }
            
            if(addRecordList.length > 0){
                component.set("v.AddRecordList", addRecordList);
                helper.createNewRecordsHelper(component, helper);
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select atleast one record!"
            });
            toastEvent.fire();
        }
    },
    
    sortByCol: function(component, event, helper) {
        var fieldType =  event.currentTarget.getAttribute('data-type');
        var fieldName =  event.currentTarget.getAttribute('data-name');
        helper.sortBy(component, fieldType, fieldName);
    },
})