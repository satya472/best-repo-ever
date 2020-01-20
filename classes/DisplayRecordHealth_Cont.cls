/*
* Author : Phaniram Upalapati
* Description : Controller for fetching health details of a record
* Associated To : DisplayRecordHealth
* Test Class : DisplayRecordHealth_ContTest
*/
public class DisplayRecordHealth_Cont {
    
    /*
* Description : Methods fetches the details of the fields and Records
Details for the mentioned Object.
* Input Param:  recordId - recordId of the Current record
*               objName - Object Name on which the component placed
* Return Type: List<HealthWrapper> - List of Wrapper class Containing details of the records
*/
    @AuraEnabled
    public static List<HealthWrapper> getRecordHealthDetails(Id recordId,String objName){
        
        List<HealthWrapper> healthList = new List<HealthWrapper>();
        List<HealthWrapper> actualHealthList = new List<HealthWrapper>();
        
        if(objName.equalsIgnoreCase('Opportunity')){ 
            
            Opportunity oppRec= [Select Id,Name,Description,NextStep from Opportunity Where Id = :recordId];
            
            List<Buying_Center_Member__c> bcm = [Select Id,Name,Opportunity__c from Buying_Center_Member__c Where Opportunity__c = :recordId];
            
            List<Intelligence__c> intelligenceRecs = [Select Id,Name from Intelligence__c Where Opportunity__c = :recordId];

            List<ContentDocumentLink> relatedFiles = [SELECT ID FROM ContentDocumentLink WHERE  LinkedEntityId = :recordId];
            
            List<FeedComment> chatterPostsLst = [SELECT Id, ParentId, RelatedRecordId FROM FeedComment WHERE ParentId = :recordId];
            
            List<Task> taskLst = [SELECT Id FROM Task Where WhatId = :recordId];
            List<Event> eventLst = [SELECT Id FROM Event Where WhatId = :recordId];
            
            //Checks for the conditions and prepares the healthList based on that            
                healthList.add(new HealthWrapper(!String.isBlank(oppRec.Description),Label.OpportunityDescriptionInformation));
                healthList.add(new HealthWrapper(!String.isBlank(oppRec.NextStep),Label.OpportunityNextStepInformation));
                healthList.add(new HealthWrapper(intelligenceRecs.size() > 0,Label.OpportunityLessonsLearnedInformation));
                healthList.add(new HealthWrapper(bcm.size() > 0,Label.OpportunityBuyingCenterInformation));
                healthList.add(new HealthWrapper(relatedFiles.size() > 0,Label.OpportunityGoWinPlanInformation));
                healthList.add(new HealthWrapper((taskLst.size()>0 || eventLst.size() > 0 || chatterPostsLst.size() > 0),Label.OpportunityActivityChatterInformation));
            system.debug('Count'+healthList.size());
        }    
        return healthList;
        
    }
    
    
    
    /*
* ClassName: HealthWrapper
* Description : Wrapper class for storing the details of the Health indicators,Status and Informations
*/
    public Class HealthWrapper{
        @AuraEnabled
        public boolean completed{set;get;}
        
        @auraEnabled
        public String information{set;get;}
        
        public HealthWrapper(Boolean completed, String information){
            this.completed = completed;
            this.information = information;
        }
    }
    
}