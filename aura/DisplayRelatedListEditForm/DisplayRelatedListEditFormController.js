({
    recUpdated : function(component, event, helper) {
       let spinner = component.find("mySpinner");
       $A.util.toggleClass(spinner, "slds-hide"); 
       $A.get('e.force:refreshView').fire();
    },
    formSubmit : function(component, event, helper) {
       let spinner = component.find("mySpinner");
       $A.util.toggleClass(spinner, "slds-hide"); 
    },
    errorReturned :  function(component, event, helper) {
       let spinner = component.find("mySpinner");
       $A.util.toggleClass(spinner, "slds-hide"); 
    },
})