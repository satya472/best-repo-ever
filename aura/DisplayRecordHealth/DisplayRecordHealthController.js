({
    doInit : function(component, event, helper) {
        component.set("v.healthList",'');
        helper.fetchDetails(component);
    },
    expand : function(component, event, helper) {
        let show = component.get("v.showDetails");
        component.set("v.showDetails",!show);
    },
})