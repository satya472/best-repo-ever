/*
 * created by selalaoui@salesforce.com 
 * */
({
    
    //push answer to the global list that map every question to it answers for the current questionnaire
    pushAnswer: function (component, event,helper) {
        component.set("v.spinner",true);
        var answerMap = component.get("v.AnswerQuestionRelation");
        if((component.get("v.questionObject.QuestionRecord.AnswerType__c") == 'Multipicklist')||(component.get("v.questionObject.QuestionRecord.AnswerType__c") == 'Picklist')){
            answerMap['question']=component.get("v.questionObject.QuestionRecord");
            answerMap['answer']=component.get("v.answersGiven");
        }else{
            answerMap['question']=component.get("v.questionObject.QuestionRecord");
            answerMap['answer']=component.get("v.answersGivenText");
        }
        component.set("v.AnswerQuestionRelation",answerMap);
        
        var AnswerQuestionsRelation=component.get("v.AnswerQuestionsRelation");
        AnswerQuestionsRelation.push(answerMap);
        component.set("v.AnswerQuestionsRelation",AnswerQuestionsRelation);
        component.set("v.spinner",false);
    },

    saveRecord : function (component, helper,selectAnswerId){
        
         component.set("v.spinner",true);
        // answerRec = component.find("answerRecord");
        // get the previous
        let isNew = $A.util.isEmpty(component.get("v.AnswerRecord").Id);
        component.find("answerRecord").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                helper.showToast(component,event,helper,'SUCCESS',"The record was saved.",'success');
               
                if(isNew){
                    console.log('we fire again:'+saveResult.recordId);
                    component.set("v.recordId",saveResult.recordId);
                    component.find("answerRecord").reloadRecord();
                    helper.subQuestionEventFire(component,helper,'',selectAnswerId);
                }else{
                    component.set("v.recordId",component.get("v.AnswerRecord").Id);
                }
                
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
            component.set("v.spinner",false);
        });
    },
    
    loaRiskRecordCheck: function(component,event,helper){
               
        var self = this;

        var optionMap = component.get("v.answersMap");
        let riskMap = component.get("v.loaMap");

        var answerOptionSelected  = event.getSource().get("v.id") ;
        var questionSelected  = event.getSource().get("v.name") ;
        var riskClassId = component.get("v.RiskClassRecordId");
        var currentPMRecord = component.get("v.PMReportId");
        var rec = component.get("v.AnswerRecord");
        var questionRecord = component.get("v.questionObject");
        component.set("v.ShowAddInfo", false);

        rec.AnsweroptionId__c = answerOptionSelected;
        rec.PMLoADataId__c  = currentPMRecord;
        rec.QuestionId__c   = questionSelected;
        rec.AnswerText__c   = optionMap[answerOptionSelected].OptionText__c;
        rec.ProcessControlStatus__c=optionMap[answerOptionSelected].ProcessControlStatus__c;
        rec.Question__c     = questionRecord.QuestionRecord.Question__c;
        rec.ScoreValue__c  = optionMap[answerOptionSelected].Answervalue__c;
        rec.Cap__c          = questionRecord.QuestionRecord.AnswerValueCap__c;
        rec.Name            = questionRecord.QuestionRecord.Name;
        rec.AddInfoHelpText__c = optionMap[answerOptionSelected].AddInfoHelpText__c;
        rec.Status__c       = 'Answered';

        //If there is a LoaRiskClassification record for Questionnaire or not. If not We are creating one
        if($A.util.isEmpty(riskMap[questionRecord.QuestionRecord.QuestionnaireObjectId__r.Id])){
            let action = component.get("c.createLOARiskClassRecord");
            action.setParams({
                questionnaireName   : questionRecord.QuestionRecord.QuestionnaireObjectId__r.Name,
                RiskTypeString      : questionRecord.QuestionRecord.QuestionnaireObjectId__r.QuestionnaireType__c,
                PMLoaReportIdString : component.get("v.PMReportId"),
                QuestionnaireIdString : questionRecord.QuestionRecord.QuestionnaireObjectId__r.Id,
                topRiskClassification : component.get("v.questionnaireName"),

            });
    
            action.setCallback(this,function(response){
                let state = response.getState();
                if(state == 'SUCCESS'){
                    let rtnValue = response.getReturnValue();
                    component.set("v.RiskClassRecordId",rtnValue);
                    riskMap[questionRecord.QuestionRecord.QuestionnaireObjectId__r.Id] = rtnValue;
                    rec.RiskClassificationId__c =rtnValue;
                    
                    component.set("v.AnswerRecord",rec);
        
                    component.set("v.fieldOnAnswerOption",optionMap[answerOptionSelected].ThisAnswerOption__c);
            
            
                    if(optionMap[answerOptionSelected].ShowAddInfo__c){
                        var AddInfoText = optionMap[answerOptionSelected].AddInfoHelpText__c;
            
                        component.set("v.AddInfoHelpText", AddInfoText);
                        component.set("v.ShowAddInfo", true);
                    }
                    
                    component.set("v.loaMap",riskMap);

                    helper.saveRecord(component,helper,answerOptionSelected);
    
                }else{
    
                    var errors = response.getError();
                    var errMsg = 'Unknown error'; // Default error message
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        errMsg = errors[0].message;
                    }

                    helper.showToast(component,event,helper,'Error',errMsg,'error');

                    component.set("v.spinner",false);
                }
                
            });
            $A.enqueueAction(action);
        }else{
       
            rec.RiskClassificationId__c =riskMap[questionRecord.QuestionRecord.QuestionnaireObjectId__r.Id];
            component.set("v.AnswerRecord",rec);
            
            component.set("v.fieldOnAnswerOption",optionMap[answerOptionSelected].ThisAnswerOption__c);
    
    
            if(optionMap[answerOptionSelected].ShowAddInfo__c){
                var AddInfoText = optionMap[answerOptionSelected].AddInfoHelpText__c;
    
                component.set("v.AddInfoHelpText", AddInfoText);
                component.set("v.ShowAddInfo", true);
            }
            
            helper.saveRecord(component,helper,answerOptionSelected);
        }
    },
    savePmRecord : function (component,event,helper){
        
         component.set("v.spinner",true);
        
        component.find("PMReport").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                helper.showToast(component,event,helper,'SUCCESS',"The record was saved.",'success');
                               
                component.set("v.spinner",false);

                //Added by Phani
                helper.subQuestionEventFire(component,helper, selectAnswerId);

            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
            
             component.set("v.spinner",false);
        });
    },
    subQuestionEventFire : function(component,helper, oldAnswerId, newAnswerId){
        
         component.set("v.spinner",true);
        //Added by Phani complete function
        var self=this;
        var mappe = {};
        mappe = JSON.stringify(component.get("v.answerSubQueMap"));
        console.log('newAnswerId: '+JSON.stringify(component.get("v.answerSubQueMap")[newAnswerId]));
        console.log('oldAnswerId: '+JSON.stringify(component.get("v.answerSubQueMap")[oldAnswerId]));
        let evt = $A.get("e.c:DisplaySubQuestions");
        evt.setParams({
            subQuestionIdstoShow : $A.util.isEmpty(newAnswerId)?'':component.get("v.answerSubQueMap")[newAnswerId],
            subQuestionIdstoHide : $A.util.isEmpty(oldAnswerId)?'':component.get("v.answerSubQueMap")[oldAnswerId]
        }).fire();
        
        component.set("v.spinner",false);
    },
    close : function(component) {
        component.set("v.showMitigationPopup",false);
        component.set("v.showAddThirdParty",false);
    },
    /*
    * Used to show toast
    */
   showToast : function(component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type 
        });
        toastEvent.fire();
   }

})