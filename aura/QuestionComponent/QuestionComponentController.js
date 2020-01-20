/*
 * created by selalaoui@salesforce.com + jens.becker
 * */
({

    // get the answer and answer options to display
    init: function(component,event,helper){

        var questionObject = component.get("v.questionObject");
        var answerOptionRecords = questionObject.AnswerOptions;
        var answer = questionObject.AnswerGiven;
        var answerQuestionRelations = questionObject.RelatedQuestionsMap;

        if(questionObject.isHidden){
            component.set("v.ShowQuestion", false);
        }

        if(answer == null){
            // Prepare a new record from template
            component.find("answerRecord").getNewRecord(
                "RiskTopic__c", // sObject type (objectApiName)
                null,      // recordTypeId
                false,     // skip cache?
                $A.getCallback(function() {
                    var rec = component.get("v.AnswerRecord");
                    var error = component.get("v.recordError");
                    if(error || (rec === null)) {
                        console.log("Error initializing record template: " + error);
                        return;
                    }
                    //console.log("Record template initialized: " + rec.sobjectType);
                })
            );
        } else {
            component.set("v.AnswerRecord", answer);
        }


        var optionList = [];
        var optionMap = {};
        //console.log('AnswerAvailable + ' +answer);
        
        for(var option in answerOptionRecords) {
            var curOption = [];
            let labelText = '';
            //let brcLabel =;

            //console.log('util '+$A.util.isEmpty(answerOptionRecords[option].BRC_Label__c));
            if(!$A.util.isEmpty(answerOptionRecords[option].BRCLabel__c)){
                labelText = answerOptionRecords[option].BRCLabel__c+ ' ';
            }
            labelText += answerOptionRecords[option].OptionText__c;
            curOption['label'] =  labelText;
            curOption['value']  = answerOptionRecords[option].Id;
            curOption['helpText'] = answerOptionRecords[option].OptionHelpText__c;
            curOption['AddInfoText'] =answerOptionRecords[option].AddInfoHelpText__c;
            curOption['ShowInfoText'] =answerOptionRecords[option].ShowAddInfo__c;
            curOption['ProcessControlStatus'] =answerOptionRecords[option].ProcessControlStatus__c;
            optionList.push(curOption);
            optionMap[answerOptionRecords[option].Id]= answerOptionRecords[option];
        }
        //get the answers value
        if(questionObject.AnswerGiven != null) {
            if(optionMap[answer.AnsweroptionId__c].ShowAddInfo__c){
                var AddInfoText = optionMap[answer.AnsweroptionId__c].AddInfoHelpText__c;
                component.set("v.ShowAddInfo", true);
                component.set("v.AddInfoHelpText", AddInfoText);
            }
            
            component.set("v.fieldOnAnswerOption",optionMap[answer.AnsweroptionId__c].ThisAnswerOption__c);
        }
        if(answerQuestionRelations != null){
            component.set("v.answerSubQueMap", answerQuestionRelations);
            //console.log('AQR :' + answerQuestionRelations);
        }

        component.set("v.answerOptions", optionList);
        component.set("v.answersMap", optionMap);
    },
    

    //push the checkbox / radio answer in the question-answer list 
    handleSelect : function (component, event, helper) {
       component.set("v.spinner",true);
       helper.loaRiskRecordCheck(component, event, helper);
    },


    handleAnswerRecordChange :function(component,event,helper){
        var rec = component.get("v.AnswerRecord");
        rec.FlagthisQuestion__c = !rec.FlagthisQuestion__c;
        component.set("v.AnswerRecord",rec);
        helper.saveRecord(component,helper,'');
    },

    handleParentRecordChange : function(component, event,helper){
        var eventParams = event.getParams();
        for( var option in eventParams ){
            alert(option.valueOf());
        }
        component.find("12324").submit();

        var parentRecord = component.get("v.PMReport");

      //helper.savePmRecord(component,event,helper);
    },
    
    //push the text / number answer in the question-answer list 
    handleTextOrNumberAnswer : function (component, event,helper) {
        component.set("v.spinner",true);
        var answerQuestionsRelation = component.get("v.AnswerQuestionsRelation");
        for(var i=0;i<answerQuestionsRelation.length;i++){
            var answerMap=answerQuestionsRelation[i];
            if(answerMap['question'].Id==component.get("v.questionObject.QuestionRecord.Id")){
               answerQuestionsRelation.splice(i , 1);
            }
        }
        component.set("v.answerQuestionsRelation",answerQuestionsRelation);
        helper.pushAnswer(component, event,helper);
    },

    handleUpdate : function (component, event,helper) {
        
        component.set("v.spinner",true);

        var answer = component.get("v.AnswerRecordObject");
        component.find("answerRecord").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                helper.showToast(component,event,helper,'SUCCESS',"The record was saved.",'success');
                
                //Added by Phani
                //helper.subQuestionEventFire(component,helper,answer.Id);

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

    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        //console.log('We fire the updated event: '+ eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            //console.log('We fire the updated event');
            // get the fields that are changed for this record
            var changedFields = eventParams.changedFields;
            //console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            if(!$A.util.isEmpty(changedFields['AnsweroptionId__c'])){
            var oldOptionId = changedFields['AnsweroptionId__c']['oldValue'];
            var newOptionId = changedFields['AnsweroptionId__c']['value'];
            //console.log('oldOptionId: ' + JSON.stringify(oldOptionId));
            //console.log('newOptionId: ' + JSON.stringify(newOptionId));
            
                if(oldOptionId != newOptionId){

                    //console.log('We fire the updated event and send to subQuestionEventFire');
                    // record is changed so refresh the component (or other component logic)
                    // we fire the event now, in order to inform sub questions to show up
                    helper.subQuestionEventFire(component,helper,oldOptionId,newOptionId);
                }
            }
            
          
        } else if(eventParams.changeType === "LOADED") {
            //console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "REMOVED") {
            helper.showToast(component,event,helper,'Deleted',"The record was Deleted.",'');
        } else if(eventParams.changeType === "ERROR") {
            console.log('Error: ' + component.get("v.error"));
        }
    },
    displayQuestion : function(component,event,helper){
        var self = this;
        var showIdsLst = event.getParam('subQuestionIdstoShow');
        var hideIdsLst = event.getParam('subQuestionIdstoHide');

        var compId = component.get("v.questionObject")['QuestionRecord']['Id'];
        
		//handle Show
        if(!$A.util.isEmpty(showIdsLst) && showIdsLst.includes(compId)){
            component.set("v.ShowQuestion",true);
        }
        //handle hide
        if(!$A.util.isEmpty(hideIdsLst) && hideIdsLst.includes(compId)){
            component.set("v.ShowQuestion",false);
        }
        
    },
    addMitigation : function(component,event,helper){
        component.set("v.showMitigationPopup",true);        
    },

    addThirdParty : function(component,event,helper){
        let autolst =[];
        autolst.push('PMLoAProjectId__c-'+component.get("v.PMReportId"));
        component.set("v.autoPopulateList",autolst);
        let Ques = component.get("v.questionObject").QuestionRecord;
        component.set("v.thirdPartyRecordTypeId",component.get("v.thirdPartyRecordTypeMap")[Ques['RecordTypeFieldsetIdentifier__c']]);
        component.set("v.showAddThirdParty",true);
        
    },

    loadRecord : function(component, event, helper) {
       component.set("v.isLoading",false);
    },
    success : function(component, event, helper) {
        component.set("v.saved",true);
        helper.showToast(component,event,helper,'SUCCESS',"Mitigation Action Record Created Successfully!!",'success');
        component.set("v.isLoading",false);
        helper.close(component);
    },
    submit : function(component, event, helper) {
        component.set("v.isLoading",true);
        event.preventDefault(); 
        let fieldsData = event.getParam("fields");
        fieldsData['MitigationStatus__c'] = 'Open';
        fieldsData['PMLoAProjectId__c'] = component.get("v.PMReportId");
        fieldsData['RiskTopic__c'] = component.get("v.AnswerRecord").Id;
        
        component.find('recCreate').submit(fieldsData);
    },
    error : function(component, event, helper){
        component.set("v.isLoading",false);
    },
    close : function(component, event, helper) {
        helper.close(component);
    }
   
})