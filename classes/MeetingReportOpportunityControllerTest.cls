/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 15-September-2018
* Description: MeetingReportOpportunityControllerTest called from MeetingReportOpportunityController
*/

@isTest
public class MeetingReportOpportunityControllerTest {
    
    @testSetup
    static void setupTestData(){
        // add accounts
        List<Account> accList = new List<Account>();
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;
        
        List<Opportunity> oppsList = new List<Opportunity>();     
        for (Account acct : accList) { 
            oppsList.add(new Opportunity(Name= acct.Name+ ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=acct.Id)); 
        }
        insert oppsList;                
    }
    
    static testMethod void testMeetingReportAttendeeController(){
        Test.startTest();  
        Map<Id, Account> accIdMap = new Map<Id, Account>([Select Id, Name from Account where Name IN ('Test Account')]); 
        List<Opportunity> oppList =  ([SELECT ID, AccountId FROM Opportunity WHERE AccountId IN :accIdMap.keySet()]);
        Id accountId;
        for (Id accId : accIdMap.keySet()) {
                accountId = accId;
                break;       
        }
        
        MeetingReport__c record = new MeetingReport__c(AccountId__c = accountId);
        insert record;
        
        MeetingReportOpportunityController.getSearchScope();
        
        String fieldSetName = MeetingReportOpportunityController.getFieldSetName();
        String sObjectName = MeetingReportOpportunityController.getSObjectName();
        String fieldNameJson = '["AccountId","Account.Name","Name","Stage","Amount","OwnerId","Owner.Name"]';

        String searchScope = 'accountOpportunities';
        MeetingReportOpportunityController.getRecords(sObjectName, searchScope, fieldNameJson, record);
        
        searchScope = 'allOpportunities';
        MeetingReportOpportunityController.getRecords(sObjectName, searchScope, fieldNameJson, record);        
        
        //create records       
        String addRecordList = '[{"attributes":{"type":"Opportunity","url":"/services/data/v43.0/sobjects/Opportunity/'+oppList.get(0).Id;
        addRecordList = addRecordList +'"},"Id":"'+oppList.get(0).Id+'"}]';   
        Object[] oppCreateList = (Object[])System.JSON.deserializeUntyped(addRecordList);
        MeetingReportOpportunityController.createMeetingReportOpp(searchScope, record.Id, oppCreateList);
        List<MeetingOpportunities__c> meetingoppList = [Select id,Name from MeetingOpportunities__c];
        system.assert(meetingoppList.size()>0);
        
        Test.stopTest();          
    }

}