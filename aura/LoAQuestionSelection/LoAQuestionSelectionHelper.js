/**
 * Created by jens.becker on 26.04.18.
 */
({
    
    
    getOpenDeviations : function (cmp,event,helper){
        
        cmp.set("v.spin",true);
        var loaRecordId = "";
        
        loaRecordId = cmp.get("v.recordId");
        var filterString = cmp.get("v.typeFilter");
        var levelFilterString = cmp.get("v.levelFilter");
        console.log('## levelFilterString '+levelFilterString + ' : '+filterString);
        
        
        let action = cmp.get("c.getQuestionnairesSObjects");
        action.setParams({
            lReportId : loaRecordId,
            filter : filterString,
            filterL1: levelFilterString
        });
        action.setCallback(this,function(response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                let rtnValue = response.getReturnValue();
                var stagesFromReport = rtnValue;
                //console.log(stagesFromReport);
                //$A.get('e.force:refreshView').fire();
                cmp.set("v.QuestionSelectionList", stagesFromReport);
                
                var deviations = cmp.get("v.deviationsOptions");
                
                for(var i = 0; i < stagesFromReport.length; i++ ){
                    var devs = stagesFromReport[i].Deviations__r;
                    //console.log('deviations',devs);
                    if(devs!=null) {
                        for (var j = 0; j < devs.length; j++) {
                            //console.log('deviations',devs[i]);
                            deviations[devs[j].Id] = devs[j];
                        }
                    }
                }
                
                //var deviationsOut = cmp.get("v.deviationsOptions");
                //console.log('deviations ',deviationsOut);
                
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
            
            cmp.set("v.spin",false);
        });
        $A.enqueueAction(action);
    },
    
    getOptions : function (component, event, helper) {
        
        component.set("v.spin",true);
        
        let typeOpt = component.get("v.typeFilter");
        let action = component.get("c.getLevel1Options");
        
        
        action.setCallback(this,function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let retVal = response.getReturnValue();
                //var retVal = retnValue;
                
                component.set("v.filterMap", retVal);
                
              /*  var optionList = retVal[typeOpt];
                var opts =[];
                
                opts.push({
                    class: "optionClass",
                    label: optionList[0],
                    value: optionList[0],
                    selected:"true"
                });
                for (var j = 1; j < optionList.length; j++) {
                    opts.push({
                        class: "optionClass",
                        label: optionList[j],
                        value: optionList[j]
                    });
                }
                
                
                component.set("v.optionsL1", opts);*/
                
                this.filterData(component,event, helper);
                
                
                //component.set("v.optionsL1", opts);
                //component.set("v.levelFilter",optionList[1]);
                //console.log('OptionToSet',optionList[1]);
                
                //component.find("filterSelect2").set("v.value",optionList[1]);
                
                
                
                //component.find("").set("v.value",opts[0].value);
                //console.log(opts[0].value);
                // component.find("v.levelFilter",  opts[0].value);
                
             //   component.find("filterSelect2").set("v.value",opts[0].value);
             //   this.getOpenDeviations(component,event,helper);
                
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
            
            component.set("v.spin",false);
        });
        $A.enqueueAction(action);
        
        
        /*
        var opts = [
            { value:"1. Price",label:"1. Price"},
            { value:"2. Payment",label:"2. Payment"},
            { value:"3. Siemens Provided Financial Securities",label:"3. Siemens Provided Financial Securities"},
            { value:"4. Taxes",label:"4. Taxes"},
            { value:"5. Permanent Establisment (PE) and Special Purpose Entities (SPE)",label:"5. Permanent Establisment (PE) and Special Purpose Entities (SPE)"},
            { value:"6. Insurance",label:"6. Insurance"},
            { value:"7. Security (GM SEC)",label:"7. Security (GM SEC)"},
            { value:"8. Customer Settlements and Concessions",label:"8. Customer Settlements and Concessions"},
            { value:"9. Contract Specifics",label:"9. Contract Specifics"},
            { value:"10. PS Technical Questionnaire",label:"10. PS Technical Questionnaire"},
            { value:"17. PS Specifics",label:"17. PS Specifics"},
            { value:"21. Contract Formation",label:"21. Contract Formation"},
            { value:"22. Siemens' Obligations/Scope of Work",label:"22. Siemens' Obligations/Scope of Work"},
            { value:"23. Change Management",label:"23. Change Management"},
            { value:"24. Siemens Schedule and Performance Obligations/Siemens Breach of Contract",label:"24. Siemens Schedule and Performance Obligations/Siemens Breach of Contract"},
            { value:"25. Customer Breach of Contract",label:"25. Customer Breach of Contract"},
            { value:"26. Warranties",label:"26. Warranties"},
            { value:"27. Risk Allocation",label:"27. Risk Allocation"},
            { value:"28. Liability and Indemnifications",label:"28. Liability and Indemnifications"},
            { value:"29. Contract Foundation",label:"29. Contract Foundation"},
            { value:"30. Other",label:"30. Other"},
            { value:"30. PS Technical Questionnaire",label:"30. PS Technical Questionnaire"}
        ];
        cmp.set("v.optionsL1", opts);
        */
        
    },
    filterData : function(component,event, helper){
        component.set("v.spin",true);
        let baseline = component.get("v.typeFilter");
        
        let levelMap = component.get("v.filterMap");
        
        var optionList = levelMap[baseline];
        var opts =[];
        
        opts.push({
            class: "optionClass",
            label: optionList[0],
            value: optionList[0],
            selected:"true"
        });
        for (var j = 1; j < optionList.length; j++) {
            opts.push({
                class: "optionClass",
                label: optionList[j],
                value: optionList[j]
            });
        }
        
        
        component.set("v.optionsL1", opts);
        
        component.find("filterSelect2").set("v.value",opts[0].value);
        this.getOpenDeviations(component,event,helper);

        component.set("v.spin",false);
    }
})