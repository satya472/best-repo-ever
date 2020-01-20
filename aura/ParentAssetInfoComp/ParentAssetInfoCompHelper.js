({
    getParentAssetDetailsHelper : function(component,event) {
        var action = component.get("c.getParentAssetDetailsCEP");
        action.setParams({
            parentAccountId : component.get("v.accountId")
        });
        
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                this.displayParentAssetListStruct(component,response.getReturnValue());
            }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error in Fetching Details: "+errors[0].message);
                    }
                } else {
                    console.log("Error in Fetching Details: Unknown Error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    },
    
    displayParentAssetListStruct : function(component,assetList){
        let listStruct = [];
        let lookup = {};
        assetList.forEach(function(obj) {
            lookup[obj['Id']] = {
                'value' : obj['Id'],
                'label': obj['Name']
            };
        });
        assetList.forEach(function(obj) {
            listStruct.push(lookup[obj['Id']]);            
        });        
        component.set("v.plantList",listStruct);
    },
    
    handleAssetChangeHelper : function(component,event){
        var parentAssetIds=event.getParam('value');
        var appEvent = $A.get("e.c:ChildAssetRecordEvent");
        appEvent.setParams({
            "parentAssetIds"  : parentAssetIds,
            "selectedContactId" : null
        });
        appEvent.fire();
    }
    
})