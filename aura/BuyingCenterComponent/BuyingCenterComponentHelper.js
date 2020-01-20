({   
    getOpportunityId : function(component, event, helper) {
        var action= component.get("c.getOpportunityId");
        action.setParams({      
            objectAPI:component.get("v.objectAPI"),
            fieldAPI:component.get("v.fieldAPI"),
            recordId:component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() === 'SUCCESS'){
                component.set("v.opportunityId", response.getReturnValue());
                
                //get the table members
                helper.getTableMembers(component, event, helper);
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }  
        });        
        $A.enqueueAction(action);  
        
    },
    
    getTableMembers : function(component, event, helper) { 
        var action= component.get("c.getBuyingCenterDetails");
        action.setParams({            
            recordId:component.get("v.opportunityId")
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() === 'SUCCESS'){
                var jsonResponse = response.getReturnValue(); 
                if(jsonResponse.length != 0){
                    component.set("v.BuyingCenterRelationList",jsonResponse.buyingCenterRelationList);                    
                    var allMemberList = jsonResponse.buyingCenterMemberList;
                    var buyingCenterWrapperArray = []; 
                    var scmList = [];
                    var bcmList= [];
                    
                    //seperate the list as Buying Center & Selling Center Members
                    for(var i = 0; i<allMemberList.length; i++){   
                        if(allMemberList[i] != undefined && allMemberList[i].Type__c === 'Selling Center'){
                            scmList.push(allMemberList[i]);
                        }else if(allMemberList[i] != undefined && allMemberList[i].Type__c === 'Buying Center'){
                            bcmList.push(allMemberList[i]);
                        }
                    }
                    
                    //put the BCM as per position
                    var positionBCMMap = new Map();
                    var bcmSortedArray = []; 
                    for(var counter = 1; counter<bcmList.length+1; counter++){
                        for(var i=0; i<bcmList.length; i++){
                            if(bcmList[i].Position__c != undefined && bcmList[i].Position__c == counter){                                	
                                positionBCMMap.set(bcmList[i].Position__c, bcmList[i]);
                                bcmSortedArray.push(bcmList[i]);
                                break;
                            }
                        }                        	
                    }//for all the bcm without position
                    for(var i=0; i<bcmList.length; i++){
                        if(bcmList[i].Position__c == undefined)
                            bcmSortedArray.push(bcmList[i]);
                    }                    
                    
                    //put the SCM as per position
                    var positionSCMMap = new Map();
                    var scmSortedArray = []; 
                    for(var counter = 1; counter<scmList.length+1; counter++){
                        for(var i=0; i<scmList.length; i++){
                            if(scmList[i].Position__c != undefined && scmList[i].Position__c == counter){                                	
                                positionSCMMap.set(scmList[i].Position__c, scmList[i]);
                                scmSortedArray.push(scmList[i]);
                                break;
                            }
                        }
                    }//for all the scm without position
                    for(var i=0; i<scmList.length; i++){
                        if(scmList[i].Position__c == undefined)
                            scmSortedArray.push(scmList[i]);
                    }
                    
                    var size = bcmList.length > scmList.length ? bcmList.length : scmList.length;
                    component.set("v.BuyingCenterListSize",size-1);                    
                    
                    var buyingCenter = {};
                    var counter;
                    for(counter = 0; counter<size; counter++){                        
                        buyingCenter = new Object();
                        var varBuyingCenterMember = null;
                        var varSellingCenterMember = null;
                        if(bcmSortedArray[counter]!= null)
                            varBuyingCenterMember = bcmSortedArray[counter];
                        if(scmSortedArray[counter]!= null)
                            varSellingCenterMember= scmSortedArray[counter];
                        buyingCenter = {buyingCenterMember:varBuyingCenterMember, sellingCenterMember:varSellingCenterMember};
                        buyingCenterWrapperArray.push(buyingCenter);
                    }
                    component.set("v.positionBCMMap",positionBCMMap);
                    component.set("v.positionSCMMap",positionSCMMap);
                    component.set("v.BuyingCenterDetailsList",buyingCenterWrapperArray);
                    
                    helper.initLinesPlugin(component, event, helper); 
                }    
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }  
            component.set("v.Spinner", false);
        });        
        $A.enqueueAction(action);    
    },
    
    initLinesPlugin : function(component, event, helper){
        var delay=15; 
        setTimeout(function() {
            helper.drawLines(component, event);
        }, delay);
    },
    
    drawLines : function(component, event) {
        jsPlumb.reset();
        var endpointOptions = { 
            isSource:true,
            isTarget:true,
            connector: ["Straight"],
            endpoint:"Dot"
        };
        
        var buyingCenterRelation = component.get("v.BuyingCenterRelationList");  
        console.log(JSON.stringify(buyingCenterRelation));
        
        for (let key in buyingCenterRelation ) {                
            let item = buyingCenterRelation[key]; 
            let endPoint1 = jsPlumb.addEndpoint(item.BuyingCenterMember__c, {anchors:['Right']}, endpointOptions);            
            let endPoint2 = jsPlumb.addEndpoint(item.SellingCenterMember__c, {anchors:['Left']}, endpointOptions);
            jsPlumb.connect({
                source:endPoint2,
                target:endPoint1                    
            });         
        }
    },
    
    showToast : function(title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    
    getMemberIds: function(methodname, component, event, helper){
        var elements = document.getElementsByClassName("selectedDiv");        
        var scmId;
        var bcmId;        
        for(var x=0; x < elements.length; x++){
            if(elements[x].getAttribute('data-type') == "scm"){
                scmId = elements[x].id;
            }else{
                bcmId = elements[x].id;
            }
        } 
        if(scmId != undefined && bcmId != undefined){            
            //create a BCM Relation
            var action= component.get(methodname);
            action.setParams({    
                recordId:component.get("v.opportunityId"),
                sellingCenterMemberId: scmId,
                buyingCenterMemberId: bcmId
            });
            action.setCallback(this, function(response){
                if(component.isValid() && response.getState() === 'SUCCESS'){
                    var jsonResponse = response.getReturnValue(); 
                    component.set("v.BuyingCenterRelationList",jsonResponse);    
                    helper.delayDrawLines(component, event, helper);                           
                }else if (response.getState() === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }  
            });        
            $A.enqueueAction(action);   
        }else{
            helper.showToast("Alert!","Please select ONE Buying Center Member and ONE Opportunity Team Member");
        }
        while (elements.length) {
            elements[0].classList.toggle('selectedDiv');                        
        } 
    },
    
    delayDrawLines : function(component, event, helper){
        var delay=25; 
        setTimeout(function() {
            helper.drawLines(component, event);
        }, delay);
    },
    
    clearVariables : function(component, event, helper){
        //empty the list
        component.set("v.BuyingCenterRelationList","");
        component.set("v.BuyingCenterDetailsList","");
        component.set("v.BuyingCenterListSize","");        
    },
    
    swapMembers : function(component, event, swapMemberList){
        var action= component.get("c.updateBuyingCenterMember");
        action.setParams({            
            centerMemberList:swapMemberList
        });
        
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } 
        });
        $A.enqueueAction(action);  
    }
})