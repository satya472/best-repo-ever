({
    handleAssetRecordEventHelper : function(component,event) {
        var parentAssetIds=event.getParam("parentAssetIds");
        var selectedContactId=event.getParam("selectedContactId");
        component.set("v.parentAssetIds",parentAssetIds);
        var getChildAssetDetailsAction=component.get("c.getChildAssetDetails");
        getChildAssetDetailsAction.setParams({
            "parentAssetIds" : parentAssetIds,
            "selectedContactId" : selectedContactId
        });
        getChildAssetDetailsAction.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                this.displayChildAssetListStruct(component,response.getReturnValue(),selectedContactId);
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
        $A.enqueueAction(getChildAssetDetailsAction);
    },
    
    displayChildAssetListStruct : function(component,childAssetList,selectedContactId){
        if(selectedContactId==null || selectedContactId==''){
            let listStruct = [];
            let lookup = {};
            childAssetList.forEach(function(obj) {
                lookup[obj['Id']]={
                    'value':obj['Id'],
                    'label':obj['Name']
                };
            });
            childAssetList.forEach(function(obj){
                listStruct.push(lookup[obj['Id']]);            
            });        
            component.set("v.childAssetList",listStruct);
            component.set("v.selectedAssetList",[]);
        }else{
            let assetContactSelectedList=[];
            childAssetList.forEach(function(obj){
                var assetContact = obj['Id'];
                assetContactSelectedList.push(assetContact);
            });
            component.set("v.selectedAssetList",assetContactSelectedList);
        }
    },
    
    validateContactAssetsHelper : function(component,event){
        var validItem=true;
        var selectedAssetListVal=(component.get("v.selectedAssetList"));        
        var selectedContactId=component.find('selectedSObjectRecord').get('v.selectedRecord.Id');
        if($A.util.isEmpty(selectedAssetListVal) || $A.util.isUndefined(selectedAssetListVal) || selectedAssetListVal==''){
            validItem = false;
        }
        if($A.util.isEmpty(selectedContactId) || $A.util.isUndefined(selectedContactId) || selectedContactId==''){
            validItem = false;
        }
        if(!validItem){
            alert('Please fill all required details marked with \'*\'');
            return false;
        }else{
            return confirm('Do you want to assign selected Assets to the select Contact?') ? this.createContactAssetHelper(component,selectedAssetListVal,selectedContactId):false;
        }
        
    },
    createContactAssetHelper : function(component,selectedAssetListVal,selectedContactId){
        var action=component.get("c.getInsertedContactAssets");
        action.setParams({
            "assetIds":selectedAssetListVal,
            "contactId":selectedContactId
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                if(response.getReturnValue().length>0){
                    alert('Assets have been assigned successfully.');
                }else{
                    alert('Assets assignment failed..!! Please contact your admin.');
                }
            }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error in Assigning Assets: "+errors[0].message);
                    }
                } else {
                    console.log("Error in Assigning Assets: Unknown Error.");
                }
            }else{
                console.log('Something went wrong, Please check with your admin.');
            }
        });
        $A.enqueueAction(action);
    }
})