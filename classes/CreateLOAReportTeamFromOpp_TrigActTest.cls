/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 29-March-2018
* Description: CreateLOAReportTeamFromOpp_TrigAct_Test class
*/

@isTest
public class CreateLOAReportTeamFromOpp_TrigActTest {
    
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
        
        // add accounts
        List<Account> accList = new List<Account>();
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;
        
        // For each account, add account team member and opportuntiy
        List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
        List<Opportunity> oppsList = new List<Opportunity>();
        
        for (Account acct:accList) {            
            accTeamMemberList.add(new AccountTeamMember(AccountId=acct.Id, AccountAccessLevel = 'Read', 
                                 CaseAccessLevel = 'Read', ContactAccessLevel = 'Read',UserId = u1.Id ,
                                 OpportunityAccessLevel = 'Read', TeamMemberRole = 'Commercial') ); 
            accTeamMemberList.add(new AccountTeamMember(AccountId=acct.Id, AccountAccessLevel = 'All', 
                                 CaseAccessLevel = 'All', ContactAccessLevel = 'Edit',UserId = u2.Id ,
                                 OpportunityAccessLevel = 'All', TeamMemberRole = 'Offshore Field Sales manager') ); 
            oppsList.add(new Opportunity(Name=acct.Name + ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=acct.Id)); 
        }
        insert accTeamMemberList;     
        insert oppsList; 
        
        //create a quote List
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(Opportunity oppty : oppsList){           
            quoteList.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c=oppty.Id, SBQQ__Account__c=oppty.AccountId)); 
        }
        insert quoteList;         
        TriggerHandler.resetAllHasRun();
    }
    
    // Commented by Ankur on 15th Oct 2018 as test method is failing while deployment.
    static testMethod void testLOAReportTeamInsert()
    {
        Test.startTest();                   
        Set<Id> accIdList = new Map<Id, Account>([Select Id, Name from Account where Name IN ('Test Account')]).keySet(); 
        
        Set<Id> opportunityIdSet = new Map<Id, Opportunity>([SELECT ID, AccountId FROM Opportunity WHERE AccountId IN :accIdList]).keySet();  
        
        List<OpportunityTeamMember> oppTeamMemberList = [SELECT ID, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIdSet];
        
        List<SBQQ__Quote__c> quoteList = [SELECT ID, Name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :opportunityIdSet];        
        
        List<LOAReport__c> loaReportList = new List<LOAReport__c>();
        for(SBQQ__Quote__c quote : quoteList){           
            loaReportList.add(new LOAReport__c(QuoteId__c=quote.Id, Name=quote.Name + ' Report')); 
        }
        insert loaReportList;
        
        Set<Id> loaReportIdList = new Set<Id>();
        for(LOAReport__c loaReport : loaReportList){  
            loaReportIdList.add(loaReport.Id);
        }
        
        List<LOAReportTeam__c> loaReportTeamList = [SELECT ID, LOAReportId__c FROM LOAReportTeam__c WHERE LOAReportId__c IN :loaReportIdList];
        
        system.assertEquals( oppTeamMemberList.size(), loaReportTeamList.size());
        Test.stopTest();
    }
}