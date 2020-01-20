({
    clickExperience : function(component, event, helper) {
        component.find("experience").set("v.variant","brand");
        component.set("v.isOpen", true);
        helper.initiateFlow(component,"CreateExperience");
	},
    
    clickDismiss : function(component, event, helper) {
        component.find("dismiss").set("v.variant","brand");
        var action=component.get("c.updateSignificantChange");
            action.setParams({
            	"oppId":component.get("v.recordId")
        	});        	
        	action.setCallback(this,function(response){
                if(response.getState()==="SUCCESS"){                    
                    $A.get('e.force:refreshView').fire();
                }
                else{  
                    alert("Error:"+response.getError());
                }
            });
            $A.enqueueAction(action);
	},
    
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
      helper.showorhide(component);  
   },
    
    // init function here
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") { 
			component.set("v.isOpen", false);
            $A.util.toggleClass(component.find("experience").set("v.variant","neutral"));
        }
    }
})