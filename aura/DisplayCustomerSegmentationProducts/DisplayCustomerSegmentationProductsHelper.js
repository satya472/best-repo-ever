({
    
    getRowActions: function(component, row, callBack) {
        //To display the row Actions dynamically based on Whether Product is blackListed or not
        let actions = [];
        if(row['blackListed']){
            actions.push({
                label: "Undo", 
                name: "Undo",
                iconName: 'utility:undo'
            });
        }else{
            actions.push({
                label: "BlackList", 
                name: "Add",
                iconName: 'utility:close'
            });
        }
        callBack(actions);
    },
	loadProductData : function(component) {
		 //Fetching the Segmentation Attribute details
        component.set("v.load",true);
		let action = component.get("c.getProducts");
        //Passing parameters to the apex controller
        action.setParams({
            categoryDevName : component.get("v.segCategory"),
            recordId : component.get("v.recordId")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                if(!$A.util.isEmpty(rtnValue)){
                    component.set("v.dataWrapper",rtnValue);
                    component.set("v.currencyCode",$A.util.isEmpty(rtnValue.recordsWrapper)?'USD':rtnValue.recordsWrapper[0].currencyCode);
                    component.set("v.assetList",rtnValue.assetPickList);
                    component.set("v.outageList",rtnValue.outagePickList);
                    component.set("v.opportunityRecordTypeId",rtnValue.recordTypeId);
                    component.set("v.fieldLst",rtnValue.opportunityFields);
                    component.find("assetVal").set("v.value",'All');
                    component.find("outageVal").set("v.value",'All');
                    this.filterData(component,rtnValue);
                    
                     // callback binding
                    let actions = this.getRowActions.bind(this, component);
                    component.set('v.dataColumns', [
                            {label: 'Product Name', fieldName: 'productLinkId', type: 'url',typeAttributes:{label:{fieldName : 'productName'},target:'_blank'}},
                            {label: 'Product Code', fieldName: 'productCode', type: 'text'},
                            {label: 'Budgetary Price', fieldName: 'price', type: 'currency',typeAttributes: { currencyCode: component.get("v.currencyCode") },cellAttributes:{alignment: 'left'}},
                            {label: 'Relevance', fieldName: 'productRelevance', type: 'percent',cellAttributes:{alignment: 'left'}},
                            {label: 'Train', fieldName: 'assetId', type: 'url',typeAttributes:{label:{fieldName : 'assetName'},target:'_blank'}},
                            {label: 'Black Listed', fieldName: 'blackListed', type: 'text' ,cellAttributes:
                             { iconName: { fieldName: 'icon' },alignment: 'center'  }} ,
                            {label: 'Reason', fieldName: 'blackListReason', type: 'text'},
                            {type: 'action', typeAttributes: { rowActions: actions }},
                        ]);
                }
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsg",errors[0].message);
                    }
                } else {
                    component.set("v.errorMsg",'Error in Fetching Details: Unknown Error');
                }
            }else{
                component.set("v.errorMsg",'Something went wrong, Please check with your admin');
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.load",false);
        });
        $A.enqueueAction(action);
	},
    saveData : function(component,selectedData,OpportunityRec){
        let action = component.get("c.createOpportunities");
        //Passing parameters to the apex controller
        action.setParams({
            selData : selectedData,
            accountId : component.get("v.dataWrapper").recordsWrapper[0].accountId,
            code : component.get("v.dataWrapper").recordsWrapper[0].currencyCode,
            oppInput : OpportunityRec
        });

        let _self= this;
        action.setCallback(this,function(response){
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                 toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "duration": 5000,
                            "message": 'Opportunity Created SuccessFully!!',
                            "messageTemplate" : 'Opportunity Record {0} Created SuccessFully!!',
                            "messageTemplateData": [{
                    				url: $A.get('$Label.c.Util_LtngURLFormat1')+rtnValue.Id+$A.get('$Label.c.Util_LtngURLFormat2'),
                   				    label: rtnValue.Name,
                           }],
                            "mode": "dismissible"
                });
                toastEvent.fire();
               
            }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "error",
                            "message": "Error in Saving Details: "+errors[0].message
                        });
                        toastEvent.fire();
                        component.set("v.errorMsg",errors[0].message);
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": "Error in Saving Details: Unknown Error"
                    });
                    toastEvent.fire();
                    component.set("v.errorMsg",'Error in Saving Details: Unknown Error');
                }
            }else{
                component.set("v.errorMsg",'Something went wrong, Please check with your admin');
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.createOpportunityPopup",false);
            component.set("v.recCreateSpinner",false);
            //Clearing the selected List
            component.set("v.selectedRowList",[]);
            component.set("v.ProductList",[]);
            _self.loadProductData(component);
        });
        $A.enqueueAction(action);
    },
    prodBlackListing: function(component,selectedData,blackList,reason){
        component.set("v.load",true);
         
        //Closing the popup if it is Opened
        component.set("v.reasonPopup",false);
        
        let action = component.get("c.blackListProducts");
        //Passing parameters to the apex controller
        action.setParams({
            selData : selectedData,
            addtoBlackList : blackList,
            recordId : component.get("v.recordId"),
            reason : reason
        });
        
        let _self = this;
        action.setCallback(this,function(response){
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state == 'SUCCESS'){
                 toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "message": response.getReturnValue()
                });
                toastEvent.fire();
               
            }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "error",
                            "message": "Error:"+errors[0].message
                        });
                        toastEvent.fire();
                        component.set("v.errorMsg",errors[0].message);
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": "Error: Unknown Error"
                    });
                    toastEvent.fire();
                    component.set("v.errorMsg",'Error: Unknown Error');
                }
            }else{
                component.set("v.errorMsg",'Something went wrong, Please check with your admin');
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.load",false);
            _self.loadProductData(component);
        });
        $A.enqueueAction(action);
    },
    filterData : function(component,wrapperRecords){
        if(wrapperRecords == null){
            return;
        }
        let assetValue = component.find("assetVal").get("v.value");
        let outageValue = component.find("outageVal").get("v.value");
        let showBlackListed = component.find("blackListToggle").get("v.checked");
        
        //Filtering the records based on Asset+OutageType+Blacklist Selection
        let fullFilterd = wrapperRecords.recordsWrapper.filter(rec =>{
            return assetValue == 'All'? rec:rec.assetName == assetValue?rec:'';
        }).filter( rec =>{
            return outageValue == 'All'? rec:rec.outageType == outageValue?rec:'';
        }).filter( rec =>{
            return showBlackListed? rec : !rec.blackListed?rec:'';
        });
        
        this.sortData(component,fullFilterd);
     
    },
    sortData: function(component, values){
        values.sort((v1,v2) => {return v1.productRelevance-v2.productRelevance});
        values.reverse();
        component.set("v.ProductList",values);
    }
})