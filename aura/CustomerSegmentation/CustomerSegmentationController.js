({
	doInit : function(component, event, helper) {
		helper.dataLoad(component);
	},
    saveData : function(component, event, helper){
        helper.saveRecords(component);
    }
})