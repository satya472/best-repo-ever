({
    doInit : function(component, event, helper) { 

        component.set("v.spin",true);

        if(component.get("v.varLessonId") == null){
            component.set("v.varLessonId", component.get("v.recordId"));
        }
        
        var action= component.get("c.getCurrentRecordStatus");
        action.setParams({            
            intelligenceId:component.get("v.varLessonId"),
            controllerName:component.get("v.varControllerName")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var arrayOfLevel1 = [];
                var arrayOfLevel2 = [];
                var arrayOfLevel3 = [];
                var jsonResponse = response.getReturnValue();  
                if(jsonResponse.length == 0){
                    if(component.get("v.varControllerName") === $A.get("$Label.c.TreeMapOpportunityCompHelper")){
                        component.set("v.ErrorMessage",$A.get("$Label.c.TreeMapOpportunityCompErrorMessage"));
                    }else if(component.get("v.varControllerName") === $A.get("$Label.c.TreeMapAccountHelper")){
                        component.set("v.ErrorMessage",$A.get("$Label.c.TreeMapAccountErrorMessage"));
                    }else if(component.get("v.varControllerName") === $A.get("$Label.c.TreeMapAssetHelper")){
                        component.set("v.ErrorMessage",$A.get("$Label.c.TreeMapAssetErrorMessage"));
                    }
                }else{
                    for (var key in jsonResponse ) {
                        var item = jsonResponse[key];
                        var newKey = "layoutSize";                                           
                        if(item.level === 1){
                            item[newKey] = "1"; 
                            arrayOfLevel1.push(item);
                        }else if(item.level === 2){
                            item[newKey] = "0"; 
                            arrayOfLevel2.push(item);
                        }else if(item.level === 3){
                            item[newKey] = "1"; 
                            arrayOfLevel3.push(item);
                        }
                    } 

                    //create parent Map
                    var parentMap = new Object();
                    for (var parentObj in arrayOfLevel2){
                        parentMap[arrayOfLevel2[parentObj].id] = arrayOfLevel2[parentObj];                        
                    }
                    
                    //get the parent-child records relationship for the parent size
                    for (var childObj in arrayOfLevel3){
                        var childRecord = arrayOfLevel3[childObj];
                        if(childRecord.parentId != null && parentMap[childRecord.parentId]!= null){
                            var parentRecord = parentMap[childRecord.parentId];
                        	parentRecord.layoutSize = Number(parentRecord.layoutSize) + 1;
                        	parentMap[childRecord.parentId] = parentRecord;    	
                        }
                    }
                    
                    //if no records exist then default size =1
                    arrayOfLevel2 = []; 
                    for (var parentObj in parentMap){
                        if (parentMap[parentObj].layoutSize === 0){
                            parentMap[parentObj].layoutSize = 1;
                        }
                        arrayOfLevel2.push(parentMap[parentObj]);
                    }
                    component.set("v.jsonResponseLevel1",arrayOfLevel1);
                    component.set("v.jsonResponseLevel2",arrayOfLevel2);
                    component.set("v.jsonResponseLevel3",arrayOfLevel3);
                }     
            }

            component.set("v.spin",false);
        });
        
        $A.enqueueAction(action);        
    },
    
    onSelectCreate : function(component, event, helper){ 
        component.set("v.spin",true);
        var selectedItem = event.getSource().get("v.value");  
        var action= component.get("c.createExperienceRelation");
        action.setParams({            
            accId:selectedItem.id,
            intelligenceId:component.get("v.varLessonId"),
            controllerName:component.get("v.varControllerName")            
        });

        action.setCallback(this, (response) => {
            if(response.getState() == 'SUCCESS'){ 
                $A.get('e.force:refreshView').fire(); 
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Updating Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Updating Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.spin",false);
        });        
        $A.enqueueAction(action);   
    },
    
    onSelectDelete : function(component, event, helper){ 
        component.set("v.spin",true);
        var selectedItem = event.getSource().get("v.value");               
        var action= component.get("c.deleteExperienceRelation");
        action.setParams({            
            accId:selectedItem.id,
            intelligenceId:component.get("v.varLessonId"),
            controllerName:component.get("v.varControllerName")  
        });
        action.setCallback(this, (response) => {
            if(response.getState() == 'SUCCESS'){
                $A.get('e.force:refreshView').fire(); 
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in deleting Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Deleting Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.spin",false);
        });        
        $A.enqueueAction(action);
    },
    
})