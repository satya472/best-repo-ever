({
    paginationClick: function(component, event, helper) {
        let btnLabel = event.getSource().get("v.value");
        if(btnLabel == 'First'){
            component.set("v.currentPageNumber", 1);
        }else if(btnLabel == 'Prev'){
            component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
        }else if(btnLabel == 'Next'){
            component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
        }else{
            component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
        }
        component.getEvent('pageChange').fire();
    },
})