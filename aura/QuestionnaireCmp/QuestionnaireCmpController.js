/*
 * created by selalaoui@salesforce.com + jens.becker
 * */
({
    /*
     * used to handle modal closure
     */
    close : function(component, event, helper){	
        
        $A.get('e.force:refreshView').fire(); 
        component.set("v.isdisplayQuestionnaire",false);
    },
  
   
    doInit : function(component, event, helper){
        
       //display spinner
       component.set("v.isLoading",true);
       //get Questions to display
        helper.getThirdPartyRecords(component,event,helper);
        helper.getQuestionObjectStructure(component,event,helper);
       helper.getQuestionObjects(component,event, helper);

    },
    
    //action to send the questionnaire answers
    confirm: function(component, event, helper){
        
        console.log(JSON.stringify(component.get("v.AnswerQuestionsRelation")));
    }
 
})