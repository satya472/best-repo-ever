({
	likeDislike : function(component,event) {
    	var bestPracticeId= component.get("v.simpleLesson.LessonLearnedId__c");
		var action = component.get("c.getBestPractice");   
        var voteTypeClick= component.get("v.voteType");
        	action.setParams({
            	"recId" : bestPracticeId,
                "voteType" : voteTypeClick
        });
                
        action.setCallback(this, function(response){
            var msg = response.getReturnValue();
            var returnMessage;
            var title;
            var popupType='notification';
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(msg=='AlreadyVotedMsg'){
                    title='Notification';
					returnMessage='You have already voted!';
                }else if(msg=='SuccessMsg'){
                    title='Success';
					returnMessage='Your vote is registered. Thanks for the voting.';
                    popupType='success';
                    
                    component.set("v.showSimpleIcon",false);
                    if(voteTypeClick==="Up"){
        				component.set("v.showLike",true);                 			
                    }else{
                    	component.set("v.showDisLike",true);                 		               
                    }
                    
                }else{
                    title='Notification';
                    returnMessage='There is some issue. Plese contact your administrator.';
                    popupType='error';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: title,
                    message: returnMessage,
                    type: popupType
                });
            	toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else{
            	console.log(' Some Error. ');   
            }
        });
        $A.enqueueAction(action);
	},
    
    getUserChoiceValue : function(component,event){
        var bestPracticeId= component.get("v.simpleLesson.LessonLearnedId__c");

        var action = component.get("c.getUserChioce");           
        action.setParams({
            	"recId" : bestPracticeId,               
        });
        
        action.setCallback(this, function(response){
            var msg= response.getReturnValue();            
            if(msg==="Like"){                     			
                component.set("v.showLike",true); 
                component.set("v.showSimpleIcon",false); 
            }else if(msg==="DisLike"){                
                component.set("v.showDisLike",true);               	                  
                component.set("v.showSimpleIcon",false); 
            }
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})