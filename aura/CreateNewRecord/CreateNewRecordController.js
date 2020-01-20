({
	doInit : function(component, event, helper) {

        component.set("v.editSpinner",true);
        
        let fieldsData = component.get("v.fields");
        
        if(!$A.util.isEmpty(fieldsData)){
            component.set("v.fieldsLst",fieldsData.split(','));
        }
        
        if($A.util.isEmpty(fieldsData) && $A.util.isEmpty(component.get("v.layoutType"))){
            component.set("v.editSpinner",false);
            throw new Error("Please provide List of fields API Name or LayoutType as inputs!!");
        }

    },
    load: function(component, event, helper){
        component.set("v.editSpinner",false);
    },
    success : function(component, event, helper) {
        component.set("v.newRecord",event.getParams());
        component.set("v.saved",true);
        component.set("v.msg",'Record Created Successfully!!');
        if(component.get("v.showToast")){
           let toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
                            "title": "Success!",
                            "type" : "success",
                            "duration": 5000,
                            "message": 'Record was created',
                            "messageTemplate" : 'Record {0} was created',
                            "messageTemplateData": [{
                    				url: $A.get('$Label.c.Util_LtngURLFormat1')+event.getParams().id+$A.get('$Label.c.Util_LtngURLFormat2'),
                   				    label: (event.getParam('fields')).Name.value,
                           }],
                            "mode": "dismissible"
                });
            toastEvent.fire();
        }
        if(component.get("v.closeModalPopup")){
            component.set("v.closeModalPopup",false);
        }
    
        if(component.get("v.closePopup")){
            $A.get("e.force:closeQuickAction").fire();
        }
        component.set("v.editSpinner",false);
    },
    submit : function(component, event, helper) {
        event.preventDefault();
        component.set("v.editSpinner",true);   
        let fieldsData = event.getParam("fields");
        if(!$A.util.isEmpty(component.get("v.autoPopulate"))){
            component.get("v.autoPopulate").forEach((autoPopRec) =>{
                let populateFields = autoPopRec.split('-');
                fieldsData[populateFields[0]] = populateFields[1];
            });
        }

        component.find('recCreate').submit(fieldsData);
    },
    error : function(component, event, helper) {
        component.set("v.editSpinner",false);
    }
    
})