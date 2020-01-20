({
	doInit : function(component, event, helper) {

		component.set("v.imageName", $A.util.isEmpty(component.get("v.imageName"))?'SiemensLogo.gif':component.get("v.imageName"));
	}
})