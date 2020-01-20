({   
    doInit:function(component, event, helper) { 
        component.set("v.Spinner", true);
        
        //initialize the jsplumb plugin
        jsPlumb.ready(function() {
            jsPlumb.setContainer("diagramContainer");
        });        
        
        //clear the variables
        helper.clearVariables(component, event, helper);
        
        //get the related record Id 
        if(component.get("v.objectAPI") != "Opportunity"){           
            helper.getOpportunityId(component, event, helper);
        }else{
            component.set("v.opportunityId",component.get("v.recordId"));
            helper.getTableMembers(component, event, helper);
        }   
        component.find("forceRecord").reloadRecord();
    },
    
    changeStyle : function(component, event, helper) {
        //clicked item should be otm or bcm
        if(event.currentTarget.getAttribute('data-type') != null){  
            var resetFlag = true;
            var elements = document.getElementsByClassName("selectedDiv");             
            if(elements.length == 2){
                //check if the member is already selected
                var containerId = event.currentTarget.getAttribute("id");                
                for(var x=0; x < elements.length; x++){
                    if(containerId == elements[x].id){
                        $A.util.toggleClass(event.currentTarget, 'selectedDiv'); 
                        resetFlag = false;
                        break;
                    }
                }
                //change the class for all the members selected
                if(resetFlag){
                    while (elements.length) {
                        elements[0].classList.toggle('selectedDiv');                        
                    } 
                }
            }//new member selected
            if(resetFlag){
                $A.util.toggleClass(event.currentTarget, 'selectedDiv');     
            }
        }
    },
    
    connectMembers: function(component, event, helper) {
        var methodname = "c.createBuyingCenterRelation";
        helper.getMemberIds(methodname, component, event, helper);    
    },
    
    disconnectMembers: function(component, event, helper) {   
        var methodname = "c.deleteBuyingCenterRelation";
        helper.getMemberIds(methodname, component, event, helper);           
    },
    
    openBCMModal: function(component, event, helper) {
        component.set("v.addMemberType", "BCM"); 
        component.set("v.fieldSetName", "BuyingCenterContactFields");
        component.set("v.ModalTitle","Add New Buying Center Member");     
        component.set("v.isOpen", true);       
    },
    
    openSCMModal: function(component, event, helper) {
        component.set("v.addMemberType", "SCM"); 
        component.set("v.fieldSetName", "SellingCenterContactFields");        
        component.set("v.ModalTitle","Add New Selling Center Member");      
        component.set("v.isOpen", true);   
    },
    
    closeBCMModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    closeModal: function(component, event, helper) {
        // for Hide/Close Modal,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
    },
    
    
    moveMemberUp: function(component, event, helper){
        var swapMemberList = [];
        //get the member record
        var currentMember = event.getSource().get("v.value");        
        //if the member has a position
        if(currentMember.Position__c != undefined){
            if(currentMember.Position__c != 1){
                //prev member
                var prevMember;
                if(currentMember.Type__c === 'Buying Center')
                    prevMember = component.get("v.positionBCMMap").get(currentMember.Position__c-1);
                else
                    prevMember = component.get("v.positionSCMMap").get(currentMember.Position__c-1);               
                if(prevMember != undefined){
                    prevMember.Position__c = currentMember.Position__c;
                    swapMemberList.push(prevMember);
                }
                //current member
                currentMember.Position__c = currentMember.Position__c - 1;
                swapMemberList.push(currentMember);   
                helper.swapMembers(component, event, swapMemberList); 
            }
        }else{
            var size = (currentMember.Type__c == 'Buying Center') ? component.get("v.positionBCMMap").size : 
            component.get("v.positionSCMMap").size;
            currentMember.Position__c = size + 1;
            swapMemberList.push(currentMember);
            helper.swapMembers(component, event, swapMemberList); 
        }                          
    },
    
    moveMemberDown: function(component, event, helper){
        var swapMemberList = [];
        //get the member record
        var currentMember = event.getSource().get("v.value");
        //if the member has a position
        if(currentMember.Position__c != undefined){
            var size = (currentMember.Type__c == 'Buying Center') ? component.get("v.positionBCMMap").size : 
            component.get("v.positionSCMMap").size;
            if(currentMember.Position__c < size){
                //next member
                var nextMember;
                if(currentMember.Type__c === 'Buying Center')
                    nextMember = component.get("v.positionBCMMap").get(currentMember.Position__c+1);
                else
                    nextMember = component.get("v.positionSCMMap").get(currentMember.Position__c+1); 
                if(nextMember != undefined){
                    nextMember.Position__c = currentMember.Position__c;
                    swapMemberList.push(nextMember);
                }
                //current member
                currentMember.Position__c = currentMember.Position__c + 1;
                swapMemberList.push(currentMember);   
                helper.swapMembers(component, event, swapMemberList); 
            }
        }else{
            var size = (currentMember.Type__c == 'Buying Center') ? component.get("v.positionBCMMap").size : 
            component.get("v.positionSCMMap").size;
            currentMember.Position__c = size + 1;
            swapMemberList.push(currentMember);
            helper.swapMembers(component, event, swapMemberList); 
        }
        
    }
})