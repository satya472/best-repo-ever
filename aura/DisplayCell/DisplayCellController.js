({
    doInit : function(component, event, helper) {
        var record = component.get("v.record");
        var field = component.get("v.field");
        
        component.set("v.cellValue", record[field.name]);
        if(field.type == 'REFERENCE' && record[field.name] != undefined){
            component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.name.indexOf('__c') == -1) {
                relationShipName = field.name.substring(0, field.name.indexOf('Id'));
            }
            else {
                relationShipName = field.name.substring(0, field.name.indexOf('__c')) + '__r';
            }
            component.set("v.cellLabel", record[relationShipName].Name);
        }//check if its is Attribute field
        else if(field.isAttribute == 'true'){
            if(field.type == 'PICKLIST'){
                component.set("v.isPicklistField", true);
                component.set("v.cellLabel",field.label);            
            }else{
                component.set("v.isInputField", true);
                component.set("v.cellLabel",field.label);  
            }
        }
             
    },
    
    dosomething: function(component, event, helper) {
        var x = component.get("v.selectedValue");
        if(x==null){
            x = component.find("inputBoxText").get("v.value");
        }
        var rec = component.get("v.record");
        rec[component.get("v.cellLabel")] = x;
        component.set("v.record", rec);
    }
})