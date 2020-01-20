({
	doInit : function(component, event, helper) {
		let attrRec = component.get("v.attributeRec");
        if(!$A.util.isEmpty(attrRec.segAtt.Values__c)){
            //Spilitting the values so that slider can be displayed
            component.set("v.sliderValues",attrRec.segAtt.Values__c.split(';'));
            //If there is no Current Value i.e. new records then we are marking the first value as current value
            if($A.util.isEmpty(attrRec.currentValue)){
                component.set("v.currentStep",component.get("v.sliderValues")[0]);
                component.set("v.attributeRec.currentValue",component.get("v.sliderValues")[0]);
            }else{
                component.set("v.currentStep",attrRec.currentValue);
            }
            
        }
	},
    progressStep : function(component, event, helper){
        let selVal = event.getSource().get('v.value');
        component.set("v.currentStep",selVal);
        component.set("v.attributeRec.currentValue",selVal);       
    }
})