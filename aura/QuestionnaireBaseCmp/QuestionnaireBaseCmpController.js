/*
 * created by selalaoui@salesforce.com 
 * */
({
	doInit : function(component, event, helper) {
        component.set("v.isLoading",true);
	},
    questionnairesHelper : function(component, event, helper) {
        
         let changeType = event.getParams().changeType;
         if (changeType === "LOADED") { 
            //get the questionnaires to display
            helper.getQuestionnairesHelper(component, event, helper);
         }
         else if (changeType === "CHANGED") { 
          /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
          component.find("questionnaireLoader").reloadRecord();
         }else{
             component.set("v.isLoading",false);
         }
    },    
    handleClick:function(component, event, helper){
        
        //handle the click on the questionnaire to get the id and display the questionnaire modal
        var idx = event.getSource().get("v.name");
        var nme = event.getSource().get("v.value");
        var questionnaires = component.get("v.Questionnaires");
        var qTypeString = '';
        let questionnaireRec;
        for(var i=0;i<questionnaires.length;i++){
            console.log(questionnaires[i].Id);
            console.log(idx);
            if(questionnaires[i].Id == idx){
                qTypeString = questionnaires[i].QuestionnaireType__c;
                questionnaireRec = questionnaires[i];
            }
        }

        component.set("v.RiskClassRecordId",'');
        component.set("v.Questionnaire",questionnaireRec);
        component.set("v.isdisplayQuestionnaire",true);
        component.set("v.isLoading",false);
        
    }
})