({
    doInit : function(component, event, helper) 
    {
        helper.callAction( component, 'c.getCompData', {
            'priceExpId' : component.get('v.recordId')
        }, function( responseData ) {
            component.set('v.PriceExperienceList', responseData);            
        });
    },
    Save: function(component, event, helper) {
        // Check required fields(Name) first in helper method which is return true/false
                   
            var action = component.get("c.UpsertPriceExperience");
            var priceList = JSON.stringify(component.get('v.PriceExperienceList'));
            action.setParams({
                priceExpWrapperJason: priceList
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.PriceExperienceList", []);
                    var storeResponse = response.getReturnValue();
                    // set  list with return value from server.
                    component.set("v.PriceExperienceList", storeResponse);
                    // Hide the save and cancel buttons by setting the 'showSaveCancelBtn' false 
                    component.set("v.showSaveCancelBtn",false);
                }
                else{
                    console.log("failed  ::: " + response.getError()[0].message);                    
                }
            });
            $A.enqueueAction(action);
    },    
    cancel : function(component,event,helper){
        component.set("v.showSaveCancelBtn",false);
    } 
})