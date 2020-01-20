/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 15-August-2018
* Description: GenericRecordSelectorController called from GenericRecordSelectorComponent
*/
@isTest
public class GenericRecordSelectorControllerTest {
    
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
    
    static testMethod void testDisplayGenericTable(){
        Test.startTest();  
        List<Account> accList = new List<Account>([Select Id, Name from Account where Name IN ('Test Account')]);
        List<Contact> contactLst = new List<Contact>([Select Id, Name from Contact]);
        List<Opportunity> oppList = new List<Opportunity>([SELECT ID, AccountId FROM Opportunity]); 
        sobject record  = oppList.get(0);
        
        MeetingReport__c meetingReportRecord = new MeetingReport__c(AccountId__c = accList.get(0).Id);
        insert meetingReportRecord;
        
        //BUYING CENTER TABLE
        String controllerName = 'BuyingCenterController';
        String modalName = 'SCM';
        String fieldNameJson = '["FirstName","LastName","AccountId","Account.Name","Title","Email","Phone"]';
        
        //GET SEARCH SCOPE
        GenericRecordSelectorController.getSearchScope(controllerName, modalName);        
        
        //GET TABLE COLUMNS
        GenericRecordSelectorController.getFieldSetDataJSON(controllerName, modalName); 
        
        //GET TABLE DATA
        String searchScope = 'otmContacts';
        GenericRecordSelectorController.getTableRows(controllerName, modalName, searchScope, fieldNameJson, record);
        searchScope = 'allSFUsers';        
        GenericRecordSelectorController.getTableRows(controllerName, modalName, searchScope, fieldNameJson, record);
        searchScope = 'allContacts';        
        GenericRecordSelectorController.getTableRows(controllerName, modalName, searchScope, fieldNameJson, record); 
        
        //GET SEARCH SCOPE
        modalName = 'BCM';
        GenericRecordSelectorController.getSearchScope(controllerName, modalName);
        
        //GET TABLE COLUMNS
        GenericRecordSelectorController.getFieldSetDataJSON(controllerName, modalName);
        GenericRecordSelectorController.getTableRows(controllerName, modalName, searchScope, fieldNameJson, record);
        searchScope = 'accountContacts';        
        GenericRecordSelectorController.getTableRows(controllerName, modalName, searchScope, fieldNameJson, record);
        
        //GET ATTRIBUTE DATA
        GenericRecordSelectorController.getAttributeData(controllerName);
        
        //SAVE DATA
        String addRecordList = '[{"attributes":{"type":"Contact","url":"/services/data/v43.0/sobjects/Contact/0030E00000KUZPKQA5"},"Id":"0030E00000KUZPKQA5","FirstName":"Tony","LastName":"Stark","AccountId":"0010E00000JcZpfQAF","Account":{"attributes":{"type":"Account","url":"/services/data/v43.0/sobjects/Account/0010E00000JcZpfQAF"},"Name":"Stark Chemicals","Id":"0010E00000JcZpfQAF"},"check":true,"Category":"Decision Maker","Status":"Unknown","Role":"CEO"}]';
        GenericRecordSelectorController.createNewRecords(controllerName, modalName, searchScope,'[{}]', record.Id);
        GenericRecordSelectorController.createNewRecords(controllerName, modalName, searchScope,addRecordList, record.Id);   
        
        //MEETING REPORT
        //GET SEARCH SCOPE
        GenericRecordSelectorController.getSearchScope('MeetingReportRelatedEvents_Cont', modalName);
        GenericRecordSelectorController.getSearchScope('MeetingReportRecipients_Cont', modalName);
        GenericRecordSelectorController.getSearchScope('MeetingReportOpportunityController', '');        
        GenericRecordSelectorController.getSearchScope('MeetingReportAttendeeController', '');
        
        //GET TABLE COLUMNS
        GenericRecordSelectorController.getFieldSetDataJSON('MeetingReportRelatedEvents_Cont', modalName);        
        GenericRecordSelectorController.getFieldSetDataJSON('MeetingReportRecipients_Cont', modalName);        
        GenericRecordSelectorController.getFieldSetDataJSON('MeetingReportOpportunityController', '');        
        GenericRecordSelectorController.getFieldSetDataJSON('MeetingReportAttendeeController', 'allContacts');   
        
        //GET TABLE DATA
        searchScope = 'allContacts';       
        GenericRecordSelectorController.getTableRows('MeetingReportOpportunityController', modalName, searchScope, fieldNameJson, meetingReportRecord); 
        GenericRecordSelectorController.getTableRows('MeetingReportAttendeeController', modalName, searchScope, fieldNameJson, meetingReportRecord); 
        
        //GET ATTRIBUTE DATA
        GenericRecordSelectorController.getAttributeData('MeetingReportRelatedEvents_Cont');
        
        //SAVE DATA
        addRecordList = '[{"attributes":{"type":"Contact","url":"/services/data/v43.0/sobjects/Contact/'+contactLst.get(0).Id;
        addRecordList = addRecordList +'"},"Id":"'+contactLst.get(0).Id+'"}]';
        GenericRecordSelectorController.createNewRecords('MeetingReportAttendeeController', '', searchScope, addRecordList, meetingReportRecord.Id);   
        List<MeetingAttendee__c> attendeeList = [Select id,Name from MeetingAttendee__c];
        system.assert(attendeeList .size()>0);
        
        addRecordList = '[{"attributes":{"type":"Opportunity","url":"/services/data/v43.0/sobjects/Opportunity/'+oppList.get(0).Id;
        addRecordList = addRecordList +'"},"Id":"'+oppList.get(0).Id+'"}]';   
        GenericRecordSelectorController.createNewRecords('MeetingReportOpportunityController', '', searchScope, addRecordList, meetingReportRecord.Id);   
        List<MeetingOpportunities__c> meetingoppList = [Select id,Name from MeetingOpportunities__c];
        system.assert(meetingoppList.size()>0);
        Test.stopTest();          
    }
    
}