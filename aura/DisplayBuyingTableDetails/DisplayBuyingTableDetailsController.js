({
	readData : function(component, event, helper) {
        $A.createComponent("c:DisplayVisualCard",{"member" : component.get("v.recordFields")}, function(
				result, status, statusMessagesList){
				 component.set('v.childBody',result);
        });
	}
})