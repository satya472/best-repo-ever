({		
    // Call the function on record load
    handleRecordUpdated : function(cmp, event, helper) {
    let bestPracticeId= cmp.get("v.simpleRecord.LessonLearnedId__c"); // get the best practice id 
    if(cmp.get("v.staticVar")==0 && bestPracticeId ===null){ // To avoid the recussion in components
        let flow = cmp.find("flowData"); // instance of flow variable to execute
      
        // Get the lesson learned values from the force:data variable
        let classification= cmp.get("v.simpleRecord.MainCategories__c	");                
        let nameChallenge= cmp.get("v.simpleRecord.Title__c");              
        let actionCanBeTaken= cmp.get("v.simpleRecord.Details__c");
        let bestPracticeId= cmp.get("v.simpleRecord.LessonLearnedId__c");
        let subcategory = cmp.get("v.simpleRecord.SubCategories__c");
        let remarks = cmp.get("v.simpleRecord.Remarks__c");
        let type = cmp.get("v.simpleRecord.Class__c");
        let competitorPrice = cmp.get("v.simpleRecord.CompetitorPrice__c");
        let intelligenceType = cmp.get("v.simpleRecord.IntelligenceType__c");
        let confidenceLevel = cmp.get("v.simpleRecord.ConfidenceLevel__c");

        // If action taken is null then simple push blank string into it.
        if(actionCanBeTaken===null){
            actionCanBeTaken='';                
        }
        if(remarks === null){
            remarks = '';
        }
        if(subcategory === null){
            subcategory = '';
        }
        if(confidenceLevel === null){
            confidenceLevel = '';
        }
        
        if($A.util.isEmpty(type)){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: "Please fill Class Field",
                type: "error"
            });
            toastEvent.fire();
        }
        
        if($A.util.isEmpty(nameChallenge)){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: "Please fill Title Field",
                type: "error"
            });
            toastEvent.fire();
        }
                   
        // Show messgae to user if classification fields are null
        if(classification ===null){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: "Please fill Main Category details.",
                type: "error"
            });
            toastEvent.fire(); 
        }else{
            var inputVariables = [ // Load input variables data to send to flow
              {
                name : 'nameString',
                type : 'String',
                value : nameChallenge
              },
              {
                name : 'recordId',
                type : 'String',
                value : cmp.get("v.recordId")
              },
             {
                name : 'actionCanBeTaken',
                type : 'String',
                value : actionCanBeTaken
              },
             {
                name : 'classification',
                type : 'String',
                value : classification
              },
              {
                name : 'subClassification',
                type : 'String',
                value : subcategory
              },
                {
                name : 'confidenceLevel',
                type : 'String',
                value : confidenceLevel
              },
                {
                name : 'intelligenceType',
                type : 'String',
                value : intelligenceType
              },
              {
                name : 'competitorPrice',
                type : 'Currency',
                value : competitorPrice
              },
              {
                name : 'class',
                type : 'String',
                value : type
              },
              {
                name : 'remarks',
                type : 'String',
                value : remarks
              },
         ];

            try{
                var incrementVar= cmp.get("v.staticVar");
                incrementVar= incrementVar + 1;
                cmp.set("v.staticVar",incrementVar);
                flow.startFlow("New_Lesson_Learned",inputVariables);   // Call flow 
            }catch(e){
                console.log('error '+ e);
            }                  
        }
    }else{ // if lesson learned is already pronoted to Best Practice then show notification to user        	
             $A.get("e.force:closeQuickAction").fire();
                
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
             title: "Notification",
             message: "Experience is already promoted to Lesson Learned!",
             type: "informational"
             });
             toastEvent.fire(); 
    }
},

// Handle status change function of flow
handleStatusChange : function (component, event,helper) {
    
    if(event.getParam("status") === "FINISHED_SCREEN") {
        $A.get("e.force:closeQuickAction").fire();
        var outputVariables = event.getParam("outputVariables"); // Get the newly created best practice id from flow
        var outputVar;
        for(var i = 0; i < outputVariables.length; i++) {
            outputVar = outputVariables[i];
            if(outputVar.name === "clonedRecordId"){       
                let someTest=  component.get("v.simpleRecord");
                someTest.LessonLearnedId__c= outputVar.value; // setting the best practice id to lesson learned record.
                component.set("v.simpleRecord",someTest); 
                
                component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
                     if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        console.log(' record is updated successfully. ');         
                     }                                         
                }));
                // Open best practice record in edit mode.
                var urlEvent = $A.get("e.force:editRecord");                    
                urlEvent.setParams({
                    "recordId": outputVar.value,
                    "isredirect": "false"
                });
                urlEvent.fire(); // Fire event
            }
        }
    }
}
})