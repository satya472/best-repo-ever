/* 
@Author: Ankur Gupta
@Created Date: 10 April 2018
@Description: It is used to call the specific class given by user.
@Last Updated By: Ankur Gupta
@Last Update Date: 16 April 2018
@Last Updated Reason: Added tree map components.
*/
public class TreeMapController{ 
    
    /*
    @Method Name: getCurrentRecordStatus
    @Method Desc: It will return a list of wrapper records which contains true/false value for a record if it is selected/deselected
    @Input parameter type: (string intelligenceId, string controllerName) , controllerName - It will provide by user to call a specific class
    @Return type: list<TreeMapController.TreeMapGenericWrapper>
    */
    @AuraEnabled
    public static list<TreeMapGenericWrapper> getCurrentRecordStatus(string intelligenceId, string controllerName){
        
        list<TreeMapController.TreeMapGenericWrapper> currentRecordWrapperList= new list<TreeMapController.TreeMapGenericWrapper>();
        if(controllerName==System.Label.TreeMapOpportunityCompHelper){ // Call opportunity competitor helper
        	currentRecordWrapperList= TreeMapOpportunityCompHelper.getOpportunityCompetition(intelligenceId);		
        }else if(controllerName==System.Label.TreeMapAccountHelper){ // Call Account helper
        	currentRecordWrapperList= TreeMapAccountHelper.getAccountHierarchy(intelligenceId);
        }else if(controllerName==System.Label.TreeMapAssetHelper){ // Call tree asset helper
        	currentRecordWrapperList= TreeMapAssetHelper.getAllAssetsOfOpportunity(intelligenceId);
        }
        return currentRecordWrapperList;
    }
    
     /*
    @Method Name: createExperienceRelation
    @Method Desc: This method will create experience relation record by calling user's given controller methods. 
    @Input parameter type: (string accId, string intelligenceId, string controllerName) , controllerName - It will provide by user to call a specific class
    @Return type: string - success/failure message to user
    */
    @AuraEnabled
    public static string createExperienceRelation(string accId, string intelligenceId, string controllerName){
        
        string dmlMessage='';
        
        if(controllerName==System.Label.TreeMapOpportunityCompHelper){
        	dmlMessage=	TreeMapOpportunityCompHelper.createOppCompExperienceRelation(accId,intelligenceId);
        }else if(controllerName==System.Label.TreeMapAccountHelper){
        	dmlMessage= TreeMapAccountHelper.createAccountExperienceRelation(accId,intelligenceId);
        }else if(controllerName==System.Label.TreeMapAssetHelper){
        	dmlMessage= TreeMapAssetHelper.createAssetExperienceRelation(accId,intelligenceId);
        }
        
        return dmlMessage;
    }
    
     /*
    @Method Name: deleteExperienceRelation
    @Method Desc: This method will delete experience relation record by calling user's given controller methods. 
    @Input parameter type: (string accId, string intelligenceId, string controllerName) , controllerName - It will provide by user to call a specific class
    @Return type: string - success/failure message to user
    */
    @AuraEnabled
    public static string deleteExperienceRelation(string accId, string intelligenceId, string controllerName){
        
        string dmlMessage='';
        
        if(controllerName==System.Label.TreeMapOpportunityCompHelper){
        	dmlMessage=	TreeMapOpportunityCompHelper.deleteOppCompExperienceRelation(accId,intelligenceId);
        }else if(controllerName==System.Label.TreeMapAccountHelper){
        	dmlMessage= TreeMapAccountHelper.deleteAccountExperienceRelation(accId,intelligenceId);
        }else if(controllerName==System.Label.TreeMapAssetHelper){
        	dmlMessage= TreeMapAssetHelper.deleteAssetExperienceRelation(accId,intelligenceId);
        }
        
        return dmlMessage;
        
    }

    /*
     * Author: Phaniram Upalapati
     * Description: Method used to return the Quote Line items related to the Primary quote of the Opportunity
     * Input Params: String - Record id
                     String - Object Name
     * Return Type : List of Quote Line Items
     */
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuoteLineItems(String currentRecordId, String objectName){

           Opportunity opp = [Select Id,Name,SBQQ__PrimaryQuote__c from Opportunity Where Id =:currentRecordId LIMIT 1];

           if(string.isBlank(opp.SBQQ__PrimaryQuote__c)){
               return null;
           }

           return [Select Id,Name,SBQQ__ProductName__c,SBQQ__NetPrice__c,Service_Asset__r.Name  from SBQQ__QuoteLine__c Where SBQQ__Quote__c = :opp.SBQQ__PrimaryQuote__c];
      
    }

    /*
     * Author: Phaniram Upalapati
     * Description: Method used to return the Quote Line items related to the Primary quote of the Opportunity
     * Input Params: String - recordId - Created Intelligence record Id
                     String - quoteLineId - Selected SBQQ QuoteLine item Id
     * Return Type : void
     */
    @AuraEnabled
    public static void updateIntelligenceRecord(String recordId, String quoteLineId){

         try{
              Intelligence__c cIntelligence = new Intelligence__c();
              cIntelligence.Id= recordId;
              cIntelligence.QuoteLineId__c = quoteLineId;

              update cIntelligence;

         }catch(Exception ex){
            throw new AurahandledException(ex.getMessage());
         }
      
    }
	
	// Wrapper class to create tree components with the below parameters 
    public class TreeMapGenericWrapper{      
        @AuraEnabled public string id{get;set;}        
        @AuraEnabled public string label{get;set;}
        @AuraEnabled public integer level{get;set;}
        @AuraEnabled public string parentId{get;set;}
        @AuraEnabled public boolean isSelected{get;set;}
    }
    
}