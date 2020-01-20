/* 
@Author: Ankur Gupta
@Created Date: 10 April 2018
@Description: It is used to capture the votes given by user on Best Practice object.
@Last Updated By: Ankur Gupta
@Last Update Date: 16 April 2018
@Last Updated Reason: To update the Show/Hide feature of vote.
*/
public with sharing class VoteLessonLearnedController{
    
    /*
    @Method Name: getUserChoice
    @Method Desc: It will return the user choice value if user is already voted otherwise it will give command to show both buttons on page.
    @Input parameter type: (string recId)
    @Return type: string
    */
    @AuraEnabled
    public static string getUserChioce(string recId){
        
        try{
            LessonsLearned__c bestPracticeObj= [select id, name, UserChoice__c, MainCategory__c,SubCategories__c, DownVotes__c, Details__c, UpVotes__c, Stage__c, WhatActionsCanBeTaken__c from LessonsLearned__c where id=:recId ];
            string userId= UserInfo.getUserId();
            
            // If user choice is not available then return "Show" 
            if(bestPracticeObj.UserChoice__c==null || !bestPracticeObj.UserChoice__c.contains(userId)){
                return 'Show';
            }else{
                // ****** START ******* User is already voted and start to get the user choice  
                string UserChoiceStr= bestPracticeObj.UserChoice__c;
                integer firstIndex= UserChoiceStr.indexOf(userId);
                string subString= UserChoiceStr.substring(firstIndex,firstIndex+22);
                string []splitSubString= subString.split('_');
                system.debug(' subString ' + subString +  ' splitSubString '+ splitSubString[0]);
                string userChoiceValue= splitSubString[1];
                // ******* END ******** 
                if(userChoiceValue.contains('Up')){
                    return 'Like';
                }else{
                    return 'DisLike';
                }
            }
        }catch(exception ex){
            return ex.getMessage(); // return error message to user.
        }
        
    }
    
    /*
    @Method Name: getBestPractice
    @Method Desc: Update the user choice in database on Best Practice record.
    @Input parameter type: (string recId, string voteType)
    @Return Type: string
    */
    @AuraEnabled
    public static string getBestPractice(string recId, string voteType){
    
        LessonsLearned__c bestPracticeObj= [select id, name, UserChoice__c, MainCategory__c,SubCategories__c, DownVotes__c, Details__c, UpVotes__c, Stage__c, WhatActionsCanBeTaken__c from LessonsLearned__c where id=:recId ];
        string userId= UserInfo.getUserId();        
        string uniqueIdentifier= userId + '_' + voteType +';';
        
        // If voting is done for the first time of lesson lessoned record.
        if(bestPracticeObj.UserChoice__c==null){
            bestPracticeObj.UserChoice__c= uniqueIdentifier; 
            if(voteType=='Up'){
                bestPracticeObj.UpVotes__c= 1;
                bestPracticeObj.DownVotes__c= 0;
            }else{
                bestPracticeObj.DownVotes__c= 1;
                bestPracticeObj.UpVotes__c= 0;
            }
        // Updating the Up Votes and Down votes values on best prcctice record.   
        }else if(!bestPracticeObj.UserChoice__c.contains(userId)){
            bestPracticeObj.UserChoice__c= bestPracticeObj.UserChoice__c + uniqueIdentifier; 
            if(voteType=='Up'){
                bestPracticeObj.UpVotes__c= bestPracticeObj.UpVotes__c + 1;
            }else{
                bestPracticeObj.DownVotes__c= bestPracticeObj.DownVotes__c + 1;
            } 
        }else{
            return 'AlreadyVotedMsg'; // User is already voted.
        }
        try{
            update bestPracticeObj;
        }catch(exception ex){
            return ex.getMessage();
        }
        return 'SuccessMsg'; // return success message to user.
    }
    
}