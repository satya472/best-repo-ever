/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 29-March-2018
* Description: CreateOpportunityTeamFromAccount_TrigAct_Test class
*/

@isTest
public class CreateOppTeamFromAccount_TrigActTest {
    
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
        
        // For each account, add account team member
        List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
        for (Account acct:accList) {            
            accTeamMemberList.add(new AccountTeamMember(AccountId=acct.Id, AccountAccessLevel = 'Read', 
                                 CaseAccessLevel = 'Read', ContactAccessLevel = 'Read',UserId = u1.Id ,
                                 OpportunityAccessLevel = 'Read', TeamMemberRole = 'Commercial') ); 
            accTeamMemberList.add(new AccountTeamMember(AccountId=acct.Id, AccountAccessLevel = 'All', 
                                 CaseAccessLevel = 'All', ContactAccessLevel = 'Edit',UserId = u2.Id ,
                                 OpportunityAccessLevel = 'All', TeamMemberRole = 'Offshore Field Sales manager') ); 
        }
        insert accTeamMemberList;       
        TriggerHandler.resetAllHasRun();
    }
    
    // Commented by Ankur on 15th Oct 2018 as test method is failing while deployment.
    static testMethod void testOpportunityInsertOnAccount()
    {
        Test.startTest();                   
        Map<Id, Account> accIdMap = new Map<Id, Account>([Select Id, Name from Account where Name IN ('Test Account')]); 
        List<AccountTeamMember> accTeamMemberList = [SELECT ID, AccountId FROM AccountTeamMember WHERE AccountId IN :accIdMap.keySet()];
        
        List<Opportunity> oppsList = new List<Opportunity>();        
        for (Id acctId : accIdMap.keySet()) {            
            oppsList.add(new Opportunity(Name= accIdMap.get(acctId).Name+ ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=acctId)); 
        }        
        insert oppsList;               
        
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Opportunity oppty : oppsList){
            opportunityIdSet.add(oppty.Id);
        }
        List<OpportunityTeamMember> oppTeamMemberList = [SELECT ID, OpportunityId FROM OpportunityTeamMember 
                                                        WHERE OpportunityId IN :opportunityIdSet];
        system.assertEquals(accTeamMemberList.size(), oppTeamMemberList.size());
        Test.stopTest();
    }
}