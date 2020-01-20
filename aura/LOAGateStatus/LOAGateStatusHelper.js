/**
 * Created by jens.becker on 17.04.18.
 */
({
    getStagesFromApprovalTopics : function (cmp,event,helper) {
        let loaRecordId = cmp.get("v.recordId");
        var loaRecordObject = cmp.get("v.loARecord");
        
        let action = cmp.get("c.getStages");
        action.setParams({
            loAReportId : loaRecordId,
            fieldName : "Name",
            parentSobjectId : loaRecordId,
            parentSObjectField : "LOA_Report__c",
            sObjectName : "LOAApproval_Gate_Step__c"
        });
        
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                var stagesFromReport = JSON.stringify(rtnValue);
                console.log('Stages: '+ stagesFromReport);
                console.log('Stages ohne: '+ rtnValue);
                //cmp.set("v.statusList" , rtnValue);
                
                var progressIndicator = cmp.find("ProgressLoa");
                var body = [];
                //create an initial step
                $A.createComponent(
                    "lightning:progressStep",
                    {
                        "label": "In Review",
                        "value": "In_Review"
                    },
                    function(newProgressStep, status, errorMessage) {
                        //Add the new step to the progress array
                        if (status === "SUCCESS") {
                            body.push(newProgressStep);
                        } else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        }else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
                
                // For each stage in activeStages...                
                for(let stage in rtnValue) {
                    var labelNaming;                    
                    labelNaming = rtnValue[stage];
                    
                    $A.createComponent(
                        "lightning:progressStep",
                        {
                            "label": labelNaming,
                            "value": rtnValue[stage]
                        },
                        function(newProgressStep1, status, errorMessage) {
                            //Add the new step to the progress array
                            if (status === "SUCCESS") {
                                body.push(newProgressStep1);
                            }else if (status === "INCOMPLETE") {
                                // Show offline error
                                console.log("No response from server or client is offline.")
                            }else if (status === "ERROR") {
                                // Show error message
                                console.log("Error: " + errorMessage);
                            }
                        }
                    );
                }
                
                //create an End step
                $A.createComponent(
                    "lightning:progressStep",
                    {
                        "label": "Approved",
                        "value": "Approved"
                    },
                    function(newProgressStep2, status, errorMessage) {
                        //Add the new step to the progress array
                        if (status === "SUCCESS") {
                            body.push(newProgressStep2);
                        }else if (status === "INCOMPLETE") {
                            // Show offline error
                            console.log("No response from server or client is offline.")
                        }else if (status === "ERROR") {
                            // Show error message
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
                progressIndicator.set("v.body", body);
            }
        });
        $A.enqueueAction(action);        
    }    
})