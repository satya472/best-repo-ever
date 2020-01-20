/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 15-September-2018
* Description: MeetingReportAttendeeControllerTest called from MeetingReportAttendeeController
*/

@isTest
public class MeetingReportAttendeeControllerTest {
    
    @testSetup
    static void setupTestData(){
        Contact c1=new Contact(FirstName='firstname',LastName = 'lname1',Email = 'email321@gmail.com',Phone = '9743800309'); 
        insert c1; 
        
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
        List<Contact> contactLst = new List<Contact>([Select Id, Name from Contact]);
        Map<Id, Account> accIdMap = new Map<Id, Account>([Select Id, Name from Account where Name IN ('Test Account')]); 
        List<Opportunity> oppList =  ([SELECT ID, AccountId FROM Opportunity WHERE AccountId IN :accIdMap.keySet()]);
        Id accountId;
        for (Id accId : accIdMap.keySet()) {
                accountId = accId;
                break;       
        }
        
        MeetingReport__c record = new MeetingReport__c(AccountId__c = accountId);
        insert record;
        
        MeetingReportAttendeeController.getSearchScope();
        
        String searchScope = 'accountTeam';
        String fieldSetName = MeetingReportAttendeeController.getFieldSetName(searchScope);
        String sObjectName = MeetingReportAttendeeController.getSObjectName(searchScope);
        String fieldNameJson = '["FirstName","LastName","Email","UserRoleId","UserRole.Name"]';
        MeetingReportAttendeeController.getRecords(sObjectName, searchScope, fieldNameJson, record);
        
        searchScope = 'accountContacts';
        fieldSetName = MeetingReportAttendeeController.getFieldSetName(searchScope);
        sObjectName = MeetingReportAttendeeController.getSObjectName(searchScope);
        fieldNameJson = '["AccountId","Account.Name","FirstName","LastName","Title","Email","Department","OwnerId","Owner.Name"]';
        MeetingReportAttendeeController.getRecords(sObjectName, searchScope, fieldNameJson, record);        
        
        searchScope = 'allContacts';
        fieldSetName = MeetingReportAttendeeController.getFieldSetName(searchScope);
        sObjectName = MeetingReportAttendeeController.getSObjectName(searchScope);
        fieldNameJson = '["AccountId","Account.Name","FirstName","LastName","Title","Email","Department","OwnerId","Owner.Name"]';
        MeetingReportAttendeeController.getRecords(sObjectName, searchScope, fieldNameJson, record);
        
        //create records       
        String addRecordList = '[{"attributes":{"type":"Contact","url":"/services/data/v43.0/sobjects/Contact/'+contactLst.get(0).Id;
        addRecordList = addRecordList +'"},"Id":"'+contactLst.get(0).Id+'"}]';
        Object[] contactList = (Object[])System.JSON.deserializeUntyped(addRecordList);
        MeetingReportAttendeeController.createMeetingReportAttendee(searchScope, record.Id, contactList);
        List<MeetingAttendee__c> attendeeList = [Select id,Name from MeetingAttendee__c];
        system.assert(attendeeList .size()>0);
        
        Test.stopTest();          
    }

}