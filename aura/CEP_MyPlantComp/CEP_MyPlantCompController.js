({
	doInit : function(component, event, helper) {
		
		if(!$A.util.isEmpty(component.get("v.accountId"))){
           		 helper.fetchAssetDetails(component,event,helper);
		}
	},
	expandAndCollapse : function(component, event, helper){
		component.set("v.hidePlants",!component.get("v.hidePlants"));
	}
})