({    
    doInit : function(component, event, helper) {
        var items = [];
        let selectItemsStruct=[];
        
        for (var i = 0; i < 15; i++) {
            var item = {
                "label": "Option " + i,
                "value": "opt" + i,
            };
            items.push(item);
        }
        for (var i = 0; i < 2; i++) {
            var item = 'opt' + i;
            selectItemsStruct.push(item);
        }
        selectItemsStruct.push('opt23');
        component.set("v.childAssetList", items);
        //"values" must be a subset of values from "options"
        component.set("v.selectedAssetList", selectItemsStruct);
		console.log(component.get("v.selectedAssetList"));
	},
    handleAssetRecordEvent : function(component, event, helper) {
        helper.handleAssetRecordEventHelper(component,event);
    },
    createContactAssets : function(component,event,helper){
        helper.validateContactAssetsHelper(component,event);
    }
})