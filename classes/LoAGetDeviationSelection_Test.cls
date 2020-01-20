/**
 * Created by jens.becker on 09.05.18.
 */


@isTest
public with sharing class LoAGetDeviationSelection_Test {
    @testSetup
    static void setupTestData()
    {
        //user creation
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg321.com');
        insert u1;

        User u2 = new User(Alias = 'standt2', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg321.com');
        insert u2;

        User u3 = new User(Alias = 'standt3', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3@testorg321.com');
        insert u3;

        // add accounts
        List<Account> accList = new List<Account>();
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;

        // For each account, add opportuntiy
        List<Opportunity> oppsList = new List<Opportunity>();

        for (Account acct:accList) {
            oppsList.add(new Opportunity(Name=acct.Name + ' Opportunity ', StageName='Qualifying',
                    CloseDate=System.today().addMonths(1), AccountId=acct.Id));
        }
        insert oppsList;

        //create a quote List
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(Opportunity oppty : oppsList){
            quoteList.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c=oppty.Id, SBQQ__Account__c=oppty.AccountId));
        }
        insert quoteList;

        //create LOA Risk Report
        /**List<LOAReport__c> loaReportList = new List<LOAReport__c>();
        for(SBQQ__Quote__c quote : quoteList){
            loaReportList.add(new LOAReport__c(QuoteId__c=quote.Id, Name=quote.Name + ' Report'));
        }
        insert loaReportList;*/


        TriggerHandler.resetAllHasRun();
    }

    static testMethod void testLoAGetDeviationSelection_getQuestionnairesSObjects()
    {
        Test.startTest();

        List<SBQQ__Quote__c> quoteList = [Select id, Name from SBQQ__Quote__c LIMIT 1];
            List<LOABusinessRule__c> listQuestionnairesSObjects = LoAGetDeviationSelection.getQuestionnairesSObjects('' , 'Legal','');

            Map<String,List<String>> tmp1 = LoAGetDeviationSelection.getLevel1Options();

                List<LOADeviation__c> devs = new List<LOADeviation__c>();
        for(LOABusinessRule__c rule : listQuestionnairesSObjects){

            if(!rule.deviations__r.isEmpty()){
                devs = rule.deviations__r;
            }
        }

        Map<String,Object> tmp = new Map<String,Object>();
        LoAGetDeviationSelection.createApprovalsTopicsFromMap( tmp, '',  quoteList[0].id, '',  'Legal', devs);
        Test.stopTest();
    }
}