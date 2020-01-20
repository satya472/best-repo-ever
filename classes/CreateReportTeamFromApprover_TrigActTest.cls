/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 11-April-2018
* Description: CreateLOAReportTeamFromApprovers_Test class
*/

@isTest
public class CreateReportTeamFromApprover_TrigActTest {
	
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
        
        LOABusinessRule__c businessRule = new LOABusinessRule__c();
        businessRule.Name = 'TestRelatedList BusinessRule';
        businessRule.LOAClassification__c = 'Financial';
        insert businessRule;
        
        LOAApprovalGate__c approvalGate = new LOAApprovalGate__c();
        approvalGate.Name = 'TestData LOAApprovalGate';
        approvalGate.LevelOfAuthority__c = 'BR1 Division';
        insert approvalGate;
        
        LOAApprover__c approver = new LOAApprover__c();
        approver.ApproverType__c = 'Financial';
        approver.Name = 'TestRelatedList Approver';
        approver.LOAApprovalGateId__c = approvalGate.Id;
        approver.UserId__c = UserInfo.getUserId();
        insert approver;
        
        List<LOADeviation__c> deviationlst = new List<LOADeviation__c>();
        LOADeviation__c deviation;
        for(Integer i=0;i<10;i++){
            deviation = new LOADeviation__c();
            deviation.Name = 'TestRelatedList Deviation'+i;
            deviation.LOABusinessRuleId__c = businessRule.Id;
            deviation.LOAApprovalGateId__c = approvalGate.Id;
            deviation.StartDate__c = system.today();
            deviationlst.add(deviation);
        }
        insert deviationlst;
      
        TriggerHandler.resetAllHasRun();
    }
    
    static testMethod void testLOAReportTeamInsert()
    {
        Test.startTest();        	        
        Set<Id> accIdList = new Map<Id, Account>([Select Id, Name from Account where Name IN ('Test Account')]).keySet(); 
        
        Set<Id> opportunityIdSet = new Map<Id, Opportunity>([SELECT ID, AccountId FROM Opportunity WHERE AccountId IN :accIdList]).keySet();

        List<Id> quoteIdList = new List<Id>(new Map<Id, SBQQ__Quote__c>([SELECT ID, SBQQ__Opportunity2__c FROM SBQQ__Quote__c 
                                                           WHERE SBQQ__Opportunity2__c IN :opportunityIdSet]).keySet());     
        
		List<Id> approvalGateList = new List<Id>(new Map<Id, LOAApprovalGate__c>([SELECT ID,Name FROM LOAApprovalGate__c]).keySet());
        
        Set<Id> approversList = new Map<Id, LOAApprover__c>([SELECT ID, Name, LOAApprovalGateId__c FROM LOAApprover__c 
                                                             WHERE LOAApprovalGateId__c IN :approvalGateList]).keySet();
        
        List<Id> deviationlst = new List<Id>(new Map<Id, LOADeviation__c>([SELECT ID,Name FROM LOADeviation__c]).keySet());
        
        //create the Approval Topic
        List<LOAApprovalTopics__c> approvalTopicList = new List<LOAApprovalTopics__c>();
        approvalTopicList.add(new LOAApprovalTopics__c(Name='Test LOA Approval Topic 1',QuoteId__c= quoteIdList.get(0),
                                                       ApprovalGateId__c = approvalGateList.get(0),Stage__c='Applicable',
                                                      LOADeviationIDTxT__c = deviationlst[0]));      
        insert approvalTopicList;
        
        //get the LOA Report Team
        List<Id> loaReportIdList = new List<Id>(new Map<Id, LOAReport__c>([SELECT ID,Name FROM LOAReport__c 
                                                                           WHERE QuoteId__c IN :quoteIdList]).keySet());
        List<LOAReportTeam__c> loaReportTeamList = [SELECT ID, ApprovalGate__c, Approver__c, InternalUpsertID__c, LOAReportId__c, UserId__c
                                                    FROM LOAReportTeam__c WHERE LOAReportId__c IN :loaReportIdList];
        
        system.assertEquals( approversList.size(), loaReportTeamList.size());
        Test.stopTest();
    }
}