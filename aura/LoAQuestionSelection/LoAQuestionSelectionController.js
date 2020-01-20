/**
 * Created by jens.becker on 26.04.18.
 */
({

    init: function (component,event,helper) {
        let loaRecordId = component.get("v.recordId");

        var optsType = [
            { value:"Financial",label:"Financial"},
            { value:"Legal",label:"Legal"},
            { value:"Technical",label:"Technical"}
        ];

        component.set("v.optionsType", optsType);
        helper.getOptions(component,event,helper);
        //helper.getOpenDeviations(component,event,helper);

    },

    handleRadioClick : function (component, event) {
        var approvalTopics = component.get("v.DeviationToApprovalTopics");
        //approvalTopics[event.getSource().get('v.name')]= event.getSource().get('v.value');

        var keyValue =event.getSource().get("v.name");

        if( event.getSource().get('v.value') ==="none"){
                delete approvalTopics[keyValue];
            }else{
                approvalTopics[event.getSource().get("v.name")] = event.getSource().get("v.value");
        }
    },

    typeChanged : function (component, event, helper)
    {
        // when the type of the questions is changed, the depended picklist should be updated and the first value(of the second list), should be set in the
        // attribute.
        // get the new values from the server
        //  helper.getOptions(component,event,helper);
            helper.filterData(component);
        
        // give the page time to set the values and then get the new questions according to the filters

    },

    levelChanged : function (component, event, helper)
    {
        // get the new questions according to the filters
           helper.getOpenDeviations(component,event,helper);
        /*
        window.setTimeout(
            $A.getCallback( function() {

                helper.getOpenDeviations(component,event,helper);
                $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide");
            })),20;
        */
    },

    saveClick : function (component,event)
    {
    var options = component.get("v.DeviationToApprovalTopics");

    var loaRecordId ="";
    var quoteId="";
    console.log('sObject is', component.get("v.sObjectName"));
    if(component.get("v.sObjectName") === "LOAReport__c"){
        loaRecordId = component.get("v.recordId");
        quoteId =component.get("v.recordFields.QuoteId__c");
    }else if(component.get("v.sObjectName")==="SBQQ__Quote__c")
    {
        quoteId = component.get("v.recordId");
    }

    let deviationMap = component.get("v.deviationsOptions");

    var devOptions = component.get("v.DeviationToApprovalTopicsList");

    for(var key in options) {
        //console.log('Options values are  ', key +':'+ options[key]);
        //devOptions.push(deviationMap[key].Id);
        devOptions.push(options[key]);
    }



    let action = component.get("c.createApprovalsTopicsFromMap");
    action.setParams({

        loaReportId : loaRecordId,
        quoteId : quoteId,
        collectionItems : options,
        options : devOptions
    });

    action.setCallback(this,function(response) {
        let state = response.getState();
        if (state == 'SUCCESS') {
            let rtnValue = response.getReturnValue();
            var returnValue = rtnValue;
            //console.log(stagesFromReport);
            //cmp.set("v.QuestionSelectionList", stagesFromReport);
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
    $A.get("e.force:closeQuickAction").fire()
}
})