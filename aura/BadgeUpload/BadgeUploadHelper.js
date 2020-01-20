({
    
    deleteFile: function(component,updateRecWith){
        let resultsToast = $A.get("e.force:showToast");
       try{
                //If there is any Document exists previously we are deleting the same as it is no more needed
                if(!$A.util.isEmpty(component.get("v.documentId"))){ 
                    component.find("deleteDocRecord").deleteRecord($A.getCallback((result) => {
                        if (result.state !== "SUCCESS") {
                            resultsToast.setParams({
                                "title": "Error",
                                "message": "There was an error in Deleting the Old Document record: " + JSON.stringify(result.error)
                            });
                            resultsToast.fire();
                        } 
                        
                         component.set("v.uploadedImage",'');
                         component.set("v.documentId",updateRecWith);
                           if($A.util.isEmpty(updateRecWith)){
                               component.set("v.documentId",'');
                           }else{
                               component.find("deleteDocRecord").reloadRecord(true);
                           }
           
                         component.set("v.spinner",false);
                         
                    }));
                }
            }catch(ex){
                resultsToast.setParams({
                                "title": "Error",
                                "message": "There was an error in Deleting the Old Document record. Please Delete the record from the Files Related List. "
                 });
                 resultsToast.fire();
            }  
    },
    UpdateExistinRec : function(component,updateRecWith) {

        let fieldApiName = component.get("v.fieldName");
        if(!$A.util.isEmpty(fieldApiName)){
            let rec = component.get("v.record");
            let resultsToast = $A.get("e.force:showToast");
            rec[fieldApiName] = updateRecWith;
            component.set("v.record", rec);       
            
             try{ 
                component.set("v.spinner",true);
                //Updating the record with the latest DocumentId to the field on the record.
                component.find("editRecord").saveRecord($A.getCallback(function(result) {
                    if (result.state !== "SUCCESS") {
                        resultsToast.setParams({
                            "title": "Error",
                            "message": "There was an error saving the record: " + JSON.stringify(result.error)
                        });
                        resultsToast.fire();
                    } 
                    
                    component.set("v.uploadedImage",'');
                    
                }));
            }catch(e){
                resultsToast.setParams({
                                "title": "Error",
                                "message": "Error in Updating the New File Id into the Current record. Please try once again. "
                 });
                 resultsToast.fire();
            }

        }       
    },

})