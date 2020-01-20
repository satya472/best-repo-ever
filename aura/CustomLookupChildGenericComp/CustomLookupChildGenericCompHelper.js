({
	selectRecordHelper : function(component,event) {
        var getSelectRecord = component.get("v.oRecord");
        
        //Fire Component event to display the selected record
        var compEvent = component.getEvent("oSelectedRecordEvent");
        compEvent.setParams({"recordByEvent" : getSelectRecord });
        compEvent.fire();
        
        //Fire Application event to check ContactAsset records with the selected contact
        let selectedContAssetAppEvent=$A.get("e.c:ChildAssetRecordEvent");
        selectedContAssetAppEvent.setParams({
            "parentAssetIds"  : component.get("v.parentAssetIds"),
            "selectedContactId" : component.get("v.oRecord.Id")
        });
        selectedContAssetAppEvent.fire();
	}
})