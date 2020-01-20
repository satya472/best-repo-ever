({
    showorhide : function(component) {
    	$A.util.toggleClass(component.find("flowData"),"slds-hide");
        $A.util.toggleClass(component.find("experience").set("v.variant","neutral"));
	},
    
    initiateFlow : function(component, flowname){
        // Find the component whose aura:id is "flowData"
        var opportunityIdVal= component.get("v.recordId");       
        var inputVariables = [ // Load input variables data to send to flow
                  {
                    name : 'recordId',
                    type : 'String',
                    value : opportunityIdVal
                  }];
        var flow = component.find("flowData");
        flow.startFlow(flowname,inputVariables);
    }
    
    
})