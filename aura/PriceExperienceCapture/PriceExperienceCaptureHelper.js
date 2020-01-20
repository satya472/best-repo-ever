/**
 * Created by jens.becker on 11.04.18.
 */
({
    getCompetitionRecords : function (cmp, event,helper ){

        var oppId = cmp.get("v.recordId");
        var action = cmp.get("c.getOpportunityCompetitions");
            console.log('OppId '+oppId);
            action.setParams({opportunityId : oppId});
            action.setCallback(this, function(response){

            let state = response.getState();
            if(state == 'SUCCESS')
            {
                let rtnValue = response.getReturnValue();
                var compRecs = JSON.parse(JSON.stringify(rtnValue));
                console.log(compRecs);
                cmp.set("v.CompetitionRecords",compRecs);

                //component.set("v.mydata",rtnValue.tableRecord);
                //component.set("v.mycolumn",rtnValue.tableColumn);
            }
            else if (state === 'ERROR')
            {
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors)
                {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Related List Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
                else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Fetching Related List Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }

        });
        $A.enqueueAction(action);


    }
})