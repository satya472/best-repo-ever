public with sharing class OpportunityController {
	
    @AuraEnabled
    public static void updateSignificantChange(String oppId){
        Opportunity opp = [select Id, SignificantChangeDetected__c FROM Opportunity WHERE ID = :oppId LIMIT 1];
        opp.SignificantChangeDetected__c = False;
        update opp;
    }
}