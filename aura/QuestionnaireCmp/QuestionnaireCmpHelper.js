/*
 * created by selalaoui@salesforce.com + jens.becker
 * */
({

    //get the list of the questions to display according to the questionnaire Id
    getQuestionObjects :function(component,event,helper){
        
        var self = this;
        var action = component.get("c.getQuestions");
        component.set("v.PMReport_Id", component.get("v.recordId"));
        action.setParams({
                questionnaireId : component.get("v.Questionnaire").Id,
                loAProjectId    : component.get("v.recordId")
            }
        );

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                component.set("v.questionObjects",rtnValue.questionsList);
                if(!$A.util.isEmpty(rtnValue)){
                 component.set("v.loaMap",rtnValue.questionnaireLOAClassMap);
                 component.set("v.thirdPartyRecordTypeMap",rtnValue.thirdPartyRecordTypeMap);
                }else{
                    component.set("v.loaMap",{});
                    component.set("v.thirdPartyRecordTypeMap",{});
                }
            }else{
                 var errors = response.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(component,event,helper,'Error',errMsg,'error');
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);

    },


    //get the list of the questions to display according to the questionnaire Id
    getQuestionObjectStructure :function(component,event,helper){

        var self = this;
        var action = component.get("c.getQuestionStructure");
        component.set("v.PMReport_Id", component.get("v.recordId"));
        action.setParams({
                questionnaireId : component.get("v.Questionnaire").Id,
                loAProjectId    : component.get("v.recordId")
            }
        );

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                var length = rtnValue.length;
                /*
                for (let i = 0; i < length; i++) {
                   if( rtnValue[i].questionnaire.Parent_Questionnaire__c === 'a3V0E000000DAMfUAO'){
                       //rtnValue[i].questionnaire.Parent_Questionnaire__c = '';
                   }
                }
                */

                //var tree = this.getNestedChildren(rtnValue, 'a3V0E000000DAMfUAO');
                //var tree = this.getTreeFromFlat(rtnValue,'a3V0E000000DAMfUAO');
                //console.log(tree);


                //component.set("v.isLoading",false);
                /*
                if(!$A.util.isEmpty(rtnValue)){
                    component.set("v.loaMap",rtnValue.questionnaireLOAClassMap);
                    component.set("v.thirdPartyRecordTypeMap",rtnValue.thirdPartyRecordTypeMap);
                }else{
                    component.set("v.loaMap",{});
                    component.set("v.thirdPartyRecordTypeMap",{});
                }
                */
            }else{
                var errors = response.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(component,event,helper,'Error',errMsg,'error');
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);

    },

    getThirdPartyRecords : function(component,event,helper){

        var self = this;
        var action = component.get("c.getThirdPartyRecords");
        component.set("v.PMReport_Id", component.get("v.recordId"));
        action.setParams({
                loAProjectId    : component.get("v.recordId")
            }
        );

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                component.set("v.BusinessPartner",rtnValue);
            }else{
                var errors = response.getError();
                var errMsg = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    errMsg = errors[0].message;
                }
                helper.showToast(component,event,helper,'Error',errMsg,'error');
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(action);
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
    },

    getNestedChildren :  function (models, parentId) {
        var nestedTreeStructure = [];
        var length = models.length;

        for (let i = 0; i < length; i++) {
            var model = models[i];
            //console.log('Model ' +i+' '+ model.questionnaire.Id);

            //console.log((model.questionnaire.Id === parentId )+ ' Parent ' + model.questionnaire.Id + ' : ' +  model.questionnaire.Parent_Questionnaire__c);
            if (model.questionnaire.Parent_Questionnaire__c == parentId) {

                var _children = this.getNestedChildren(models, model.questionnaire.ParentId__c);
                console.log('looking for kids withParent Id ' + model.questionnaire.ParentId__c);
                if (_children.length > 0) {
                    console.log('we found some ' +_children.length);
                    model._children = _children;
                }

                nestedTreeStructure.push(model);
            }
        }

        return nestedTreeStructure;
    },

    getTreeFromFlat : function ( dataResult, MasterQ ){

        var data = dataResult,
            parents = { 'a3V0E000000DAMfUAO': { items: [] }};
            //data.forEach(questionnaire => { console.log(questionnaire.questionnaire.Id)});
            data.forEach(q => parents[q.questionnaire.Id] = { items: [] , questionnaire: q.questionnaire });
            data.forEach(q => parents[q.questionnaire.ParentId__c].items.push(parents[q.questionnaire.Id]));
            //component.set("v.data", parents[undefined].items);

        return parents['a3V0E000000DAMfUAO'].items;
    }

})