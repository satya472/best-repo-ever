({	
    handleLessonLearned : function(component, event, helper) {
		var bestPracticeId= component.get("v.simpleLesson.LessonLearnedId__c");
        
        if(bestPracticeId != null){
        	helper.getUserChoiceValue(component, event);
        }
    },

	like : function(component, event, helper) {	
        
        var bestPracticeId= component.get("v.simpleLesson.LessonLearnedId__c");  
        component.set("v.voteType","Up");  
        if(bestPracticeId ===null){
			var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                    title: "Warning",
                    message: "Experience is not yet promoted to Lesson Learned!",
                    type: "error"
                });
            toastEvent.fire();
        }else{
        	helper.likeDislike(component,event);               
        }
	},
    
    disLike : function(component, event, helper) {
        var bestPracticeId= component.get("v.simpleLesson.LessonLearnedId__c");  
        component.set("v.voteType","Down");
    	if(bestPracticeId ===null){
			var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                    title: "Warning",
                    message: "Experience is not yet promoted to Lesson Learned!",
                    type: "error"
                });
            toastEvent.fire();
        }else{
        	helper.likeDislike(component,event);               
        }    
	}
})