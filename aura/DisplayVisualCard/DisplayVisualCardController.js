({
    doInit : function(component, event, helper) {
        var mem = component.get("v.member");
        if(mem.Contact__c != undefined)
            component.set("v.contactImageDocId",mem.Contact__r.Picture__c);   
        else
            component.set("v.picture",mem.User__r.FullPhotoUrl);
        
        //set member status
        helper.setStatusBar(component, event, mem);
        
        //if showIcons = true
        if(component.get("v.showIcons")){
            helper.displayIcons(component, event, helper);
        }
    },
    
    onLoad : function(component, event, helper) {
        //get attribute fields
        helper.setAttributeFields(component, event);
    },
    
    filesRecordData : function(component,event,helper){
        if(!$A.util.isEmpty(component.get("v.documentRecord"))){
            component.set("v.picture",$A.get('$Label.c.DisplayUploadedImageURL')+component.get("v.documentRecord")['LatestPublishedVersionId']);
        }    
    },
    
    confirmDeleteBCM : function(component, event, helper){     
        component.set("v.errorMessage", $A.get("$Label.c.ConfirmMemberDeletion"));
        component.set("v.delMemberId", event.currentTarget.getAttribute("id"));		
        component.set("v.isDelete", true);
    },
    
     cancelDeleteBCM : function(component, event, helper){     
		component.set("v.isDelete", false);
    },
    
    editBCM : function(component, event, helper){     
        var containerId = event.currentTarget.getAttribute("id");
        component.set("v.selectedBCM", containerId);        
        component.set("v.isEdit", true);  
    },
    
    deleteBCM : function(component, event, helper){     
        var containerId = component.get("v.delMemberId");
        var action= component.get("c.deleteBuyingCentreMembers");
        action.setParams({            
            recordId:containerId
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() === 'SUCCESS'){
                helper.showToast("Success!","The record has been deleted successfully."); 
                $A.get('e.force:refreshView').fire();
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }  
        });        
        $A.enqueueAction(action); 
    },
    
    onSuccess: function(component, event, helper) {
        // for Hide/Close Modal,set the "isEdit" attribute to "Fasle"  
        component.set("v.isEdit", false);
        $A.get('e.force:refreshView').fire();
    },
    
    closeEditModal: function(component, event, helper) {
        // for Hide/Close Modal,set the "isEdit" attribute to "Fasle"  
        component.set("v.isEdit", false);
    }
})