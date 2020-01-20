({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        //clear search box
        component.set("v.searchKey","");
        component.find("searchBoxText").set("v.value","");
        
        //if type is scm
        if(component.get("v.SCMContactSearchValue") === "allContacts"){
            component.set("v.sObjectName","Contact");
            component.set("v.fieldSetName", "BuyingCenterContactFields");   
        }
        helper.getTableFieldSet(component, event, helper);            
        component.set("v.selectedCount", 0);
    },
    
    searchKeyChangeInput: function(component, event, helper) {
        var searchEvent = $A.get("e.c:SearchKeyChange");
        searchEvent.setParams({"searchKey": event.target.value});
        searchEvent.fire();
    },
    
    searchKeyChange: function(component, event,helper) {        
        component.set("v.searchKey",  event.getParam("searchKey"));           
        helper.getSearchTableData(component, event, helper);
    },
    
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
    
    createSelectedMember: function(component, event, helper) {
        if(component.get("v.selectedCount") > 0){ 
            var mandatoryFieldsError = false;
            let bcmPosition = component.get("v.positionBCMMap");
            let scmPosition = component.get("v.positionSCMMap");
            
            let bcmList = component.get("v.createBCMList");
            for(let i in component.get("v.tableRecords")){
                if(component.get("v.tableRecords")[i].check){                    
                    let selRec = component.get("v.tableRecords")[i];
                    if(selRec.Category != undefined && selRec.Status != undefined && selRec.Role != undefined){
                        if(selRec.Category == 'Coach' && selRec.Status != 'Pro'){
                            mandatoryFieldsError = true;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please select the Status = PRO for Category = COACH"
                            });
                            toastEvent.fire();
                            break;
                        }else{
                            let bcm = component.get("v.newBCM");
                            //for BCM
                            if( component.get("v.addMemberType") === "BCM"){
                                bcm["Contact__c"] = selRec.Id;
                                bcm["Type__c"] = "Buying Center";
                                bcm["Position__c"] = bcmPosition + 1;
                                bcmPosition++ ;
                            }//for SCM
                            else{
                                if(component.get("v.sObjectName") === "Contact")
                                    bcm["Contact__c"] = selRec.Id;
                                else
                                    bcm["User__c"] = selRec.Id; 
                                bcm["Type__c"] = "Selling Center";
                                bcm["Position__c"] = scmPosition + 1;
                                scmPosition++ ;                                
                            }                       
                            bcm["Category__c"] = selRec.Category;
                            bcm["Status__c"] = selRec.Status;  
                            bcm["Buying_Role__c"] = selRec.Role;
                            bcmList.push(bcm);
                            component.set("v.newBCM", { 'sobjectType': 'Buying_Center_Member__c' });
                        }
                    }else{
                        mandatoryFieldsError = true;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please enter the data for all fields!"
                        });
                        toastEvent.fire();
                        break;
                    }
                }
            }
            
            if(!mandatoryFieldsError){
                var action= component.get("c.createBuyingCentreMembers");
                action.setParams({   
                    bcmList: bcmList,
                    oppId:component.get("v.primaryRecordId")            
                });
                action.setCallback(this, function(response){
                    if(component.isValid() && response.getState() === 'SUCCESS'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The Contact(s) have been added."
                        });
                        toastEvent.fire();
                    }
                });        
                $A.enqueueAction(action);  
                component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Select atleast one Contact!"
            });
            toastEvent.fire();
        }
        component.set("v.createBCMList","");
    },
    
    openNewContactModal: function(component, event, helper) {
        component.set("v.createContact",true);
    },
    
    closeNewContactModal: function(component, event, helper) {
        component.set("v.createContact", false);
        //$A.get('e.force:refreshView').fire();
    },
    
    createNeWContactRec: function(component, event, helper) {
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
    
    handlePageChange : function(component,event,helper){
        helper.renderPage(component);
    },
    
    recordsPerPageChange : function(component,event,helper){
        component.set("v.currentPageNumber",1);
        helper.renderPage(component);
    },
    
    
})