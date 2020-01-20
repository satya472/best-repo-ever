({
	doInit : function(component, event, helper) {
		let objName = component.get("v.sObjectName");
        if(objName == 'Account')
        {   
            component.set("v.segment",$A.get('$Label.c.CustomerBehaviors'));
        }
        else
        {
            component.set("v.segment",$A.get('$Label.c.TI_Driver'));
        }
	},
})