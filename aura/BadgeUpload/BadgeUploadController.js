({
    doInit : function(component,event,helper){
        component.set("v.spinner",true);
        let arr = [];
        arr.push(component.get("v.fieldName"));     
        component.set("v.fieldsArray",arr);
    },
    dataLoaded : function(component,event,helper){
        let eventParam = event.getParams();
        if(eventParam.changeType === "CHANGED") { 
            if(!$A.util.isEmpty(component.get("v.documentId")) && component.get("v.documentId") != component.get("v.record")[component.get("v.fieldName")]){
                helper.deleteFile(component,component.get("v.record")[component.get("v.fieldName")]);
            }else if($A.util.isEmpty(component.get("v.documentId")) && component.get("v.documentId") != component.get("v.record")[component.get("v.fieldName")]){
                //If there is no documentId previously and a new record is uploaded
                component.set("v.documentId",component.get("v.record")[component.get("v.fieldName")]);
            }           
        }
        if(eventParam.changeType === "LOADED") {
            if(!$A.util.isEmpty(component.get("v.fieldName"))){
                component.set("v.documentId",component.get("v.record")[component.get("v.fieldName")]);
                if($A.util.isEmpty(component.get("v.documentId"))){
                    component.set("v.spinner",false); 
                }
            }
        }    
    },
    documentRecordData : function(component,event,helper){
        if(!$A.util.isEmpty(component.get("v.documentRecord")['LatestPublishedVersionId'])){
            component.set("v.uploadedImage",$A.get('$Label.c.DisplayUploadedImageURL')+component.get("v.documentRecord")['LatestPublishedVersionId']);
            component.set("v.spinner",false); 
        }
    },
    onRender : function(component, event, helper) {
        component.find("lightningFileUpload").set("v.multiple", false);
    },
    handleUploadFinished: function (component, event,helper) {
        component.set("v.spinner",true);
        // Get the list of uploaded files
        let uploadedFiles = event.getParam("files");
        //Calling the method Where updation of current record with the new DocumentId
        helper.UpdateExistinRec(component,uploadedFiles[0].documentId);    
    },
    deleteImageFile: function(component,event,helper){
        component.set("v.spinner",true);
        //Updating the Existing record with empty documentId
        helper.UpdateExistinRec(component,'');
    },
})