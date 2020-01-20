({
    getReportResponse : function(component, event, helper) {
        //Apex method call
        let action = component.get("c.getReportResponse");
		let report = component.get("v.reportName");
        if($A.util.isEmpty(report)){
            return;
        }
        let filter = component.get("v.filterString");
        //Passing ReportApi Name, Current Record Id and filters as parameters for the report Execution.
        action.setParams({
            "reportAPIName": report,
            "recordId" : component.get("v.useCurrentRecord")?component.get("v.recordId"):'',
            "filterParam" : filter
        });

        action.setCallback(this, function(resp){

            let toastEvent = $A.get("e.force:showToast");
            if(resp.getState() ==='SUCCESS'){
               //Getting reportResponse Object as return value containing report Type and Report Rows data
               var reportResponseObj = JSON.parse(resp.getReturnValue());
               if($A.util.isEmpty(reportResponseObj.reportType)){
                    toastEvent.setParams({
                        "title": "Report API Name Issue",
                        "message" : "Report Does not Exists With the Given API Name",
                        "duration": 500
                    });
                    toastEvent.fire();
                    return;
               }
               
               component.set("v.tabResp", reportResponseObj.tabResp);
               component.set("v.sumResp", reportResponseObj.sumResp);
               component.set("v.reportResponse", reportResponseObj);
            }else{
                let errors = resp.getError();
                if (errors[0] && errors[0].message) {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Unknown Error. Please Check with Administrator.'
                    });
                    toastEvent.fire();
                }    
            }
            
        });
         $A.enqueueAction(action);
    },
    toggleSpinner : function(component){
        let spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
    
})