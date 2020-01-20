({
	getCardTitle : function(component) {
        if(component.get("v.varControllerName") === "TreeMapOpportunityCompHelper"){
            component.set("v.CardTitle","Opportunity Competition");
        }else if(component.get("v.varControllerName") === "TreeMapAccountHelper"){
            component.set("v.CardTitle","Account");
        }else if(component.get("v.varControllerName") === "TreeMapAssetHelper"){
            component.set("v.CardTitle","Asset");
        }		
	}
})