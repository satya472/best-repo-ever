/*
 * Author : Jens Becker
 * Description : Controller For capturing Pricing experiences on opportunities.
 * Associated To : PriceExperienceCapture
 * Test Class : ...
*/

public with sharing class PriceExperienceCapture {

    /*
    * Description : Methods fetches the related Competitors from the opportunity record of the reports
    * Input Param : opportunityId
    * Return Type: List<Sobject>
    */
    @AuraEnabled
    public static List<OpportunityCompetition__c> getOpportunityCompetitions(String opportunityId){
        system.debug('opportunityId: '+ opportunityId);
        List<OpportunityCompetition__c>  oppComp = new List<OpportunityCompetition__c>();
        oppComp = [SELECT id,  AccountName__c from OpportunityCompetition__c WHERE Opportunity__c=:opportunityId];
        system.debug(oppComp);
        return oppComp;
    }

}