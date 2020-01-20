({
    doInit : function(component, event, helper) {
        //Showing spinner
        helper.toggleSpinner(component);
        
        // Retrieve reports for search autocomplete during component initialization
        helper.getReportResponse(component, event, helper);
        
        //Hiding Spinner
        helper.toggleSpinner(component);
    },
    
})