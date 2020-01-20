({
    setAttributeFields : function(component, event){
        var action = component.get("c.getFieldSetData");
        action.setParams({
            sObjectName: "Buying_Center_Member__c",
            fieldSetName: "BuyingCenterMemberAttributes"
        });
                
        action.setCallback(this, function(response) {
            var fieldSetObj = response.getReturnValue();
            component.set("v.attributeFields", fieldSetObj);
        });
        $A.enqueueAction(action);
    },
    
    setStatusBar : function(component, event, mem){
        component.set("v.coverage","100");      
        if(mem.Status__c == 'Pro'){
            $A.util.addClass(component.find("coverageBar"),'slds-progress-bar__value_success');
        }else if(mem.Status__c == 'Anti'){
            $A.util.addClass(component.find("coverageBar"),'lowInteraction');
        }else if(mem.Status__c == 'Unknown'){
            $A.util.addClass(component.find("coverageBar"),'unknownInteraction');
        }else{
            component.set("v.coverage","0"); 
        }
    },
    
    displayIcons : function(component, event, helper) {
        let mem = component.get("v.member");
        if(!$A.util.isEmpty(mem.Buying_Role__c)){
            if(mem.Buying_Role__c == '1'){
                component.set("v.role",'U');
            }else if(mem.Buying_Role__c == '2'){
                component.set("v.role",'E');
            }else if(mem.Buying_Role__c == '3'){
                component.set("v.role",'D');
            }else if(mem.Buying_Role__c == '4'){
                component.set("v.role",'A');
            }else if(mem.Buying_Role__c == 'Multiple Roles'){
                component.set("v.role",'--');
            }
        }
        if(!$A.util.isEmpty(mem.Adaptability__c)){
            if(mem.Adaptability__c == 'Unknown' || mem.Adaptability__c == '0'){
                component.set("v.adaptability",'?');
            }else if(mem.Adaptability__c == '1'){
                component.set("v.adaptability",'C');
            }else if(mem.Adaptability__c == '2'){
                component.set("v.adaptability",'P');
            }else if(mem.Adaptability__c == '3'){
                component.set("v.adaptability",'V');
            }else if(mem.Adaptability__c == '4'){
                component.set("v.adaptability",'I');
            }
        }
        if(!$A.util.isEmpty(mem.Our_Status__c)){
            if(mem.Our_Status__c == 'Unknown'){
                component.set("v.status",'?');
            }else if(mem.Our_Status__c == '0'){
                component.set("v.status",'X');
            }else if(mem.Our_Status__c == '1'){
                component.set("v.status",'-');
            }else if(mem.Our_Status__c == '2'){
                component.set("v.status","'=");
            }else if(mem.Our_Status__c == '3'){
                component.set("v.status",'+');
            }else if(mem.Our_Status__c == '4'){
                component.set("v.status",'#');
            }
        }
        
        component.set("v.coverage",mem.Contact_Coverage__c);
        if(mem.Contact_Coverage__c <= 30){
            $A.util.addClass(component.find("coverageBar"),'lowInteraction');
        }else if(mem.Contact_Coverage__c > 30 && mem.Contact_Coverage__c <= 70){
            $A.util.addClass(component.find("coverageBar"),'mediumInteraction');
        }else{
            $A.util.addClass(component.find("coverageBar"),'slds-progress-bar__value_success');
        }
    },
    
    showToast : function(title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})