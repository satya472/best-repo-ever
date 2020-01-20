/*
*Author: G.Naveen Kumar
*Date:1-Sep-18
*Description: Test class for MeetingReportRecipients_Cont
*/
@IsTest
public with sharing class MeetingReportRecipients_ContTest {
   @testSetup
    static void setupTestData() 
	{   
		//user creation
        Id pId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pId, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg321.com');       
        insert u1;        
        User u2 = new User(Alias = 'standt2', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pId, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg321.com');
        insert u2;
        
		//CONTACT creation
        Contact c1=new Contact(FirstName='firstname',LastName = 'lname1',Email = 'email321@gmail.com',Phone = '9743800309'); 
        insert c1;         
        Contact c2=new Contact(FirstName='secondname',LastName = 'lname2',Email = 'email123@gmail.com',Phone = '9743800309'); 
        insert c2; 
        Contact c3=new Contact(FirstName='thirdname',LastName = 'lname3',Email = 'email3214@gmail.com',Phone = '9743700309'); 
        insert c3;
	
        
		// add accounts
        Account act= new Account( Name='Test Account', Type='Site');
        insert act;         
		
        Account act2= new Account( Name='Child Test Account', Type='Site');
        insert act2; 
		
		AccountTeamMember atm = new AccountTeamMember(AccountId = act.id, UserId = u1.id);
		insert atm;
        
      
		MeetingReport__c testMeetReport = new MeetingReport__c(AccountId__c = act.id);
        insert testMeetReport;
		
		MeetingAttendee__c maRec = new MeetingAttendee__c(MeetingReportId__c = testMeetReport.id,ContactId__c = c1.id);
		insert maRec;
		
		
    }
	
	public static testmethod void getTest()
	{
	    List<MeetingReport__c> readRec = [Select id,Name,AccountId__c FROM MeetingReport__c];
		system.assert(readRec.size() > 0);
        List<MeetingAttendee__c> maList = [Select id,Name FROM MeetingAttendee__c];
        system.assert(readRec.size() > 0);
		List<sObject> meetAtten =  MeetingReportRecipients_Cont.getTableRecords('MeetingAttendee__c','Attendees','["FirstName__c","LastName__c","Email__c"]',readRec[0]);
        
		List<sObject> atmUsers = MeetingReportRecipients_Cont.getTableRecords('User','actTeam','["LastName","FirstName","Email"]',readRec[0]);
		List<sObject> allSfdcUsers = MeetingReportRecipients_Cont.getTableRecords('User','allSfdcUsers','["LastName","FirstName","Email"]',readRec[0]);
		
		List<sObject> actContacts = MeetingReportRecipients_Cont.getTableRecords('Contact','actContatcs','["AccountId","Account.Name","FirstName"]',readRec[0]);
		List<sObject> allContacts = MeetingReportRecipients_Cont.getTableRecords('Contact','allContacts','["AccountId","Account.Name","FirstName"]',readRec[0]);
		
		String sScope = MeetingReportRecipients_Cont.getSearchScope();
        string obj = MeetingReportRecipients_Cont.getSObjectName('Attendees');
        string obj2 = MeetingReportRecipients_Cont.getSObjectName('allSfdcUsers');
        string obj3 = MeetingReportRecipients_Cont.getSObjectName('actContatcs');
        
        string fs1 = MeetingReportRecipients_Cont.getFieldSetName('Attendees');
        string fs2 = MeetingReportRecipients_Cont.getFieldSetName('allSfdcUsers');
        string fs33 = MeetingReportRecipients_Cont.getFieldSetName('actContatcs');
		
        string inputString = '[{"attributes":{"type":"MeetingAttendee__c","url":"/services/data/v43.0/sobjects/MeetingAttendee__c/'+maList[0].Id+'"},';
        inputString = inputString+ '"Id":"'+maList[0].Id+'","FirstName__c":"Test"}]';
        Object[] values = (Object[])System.JSON.deserializeUntyped(inputString);
        MeetingReportRecipients_Cont.createMeetingRecipientsRecords('Attendees',readRec[0].id,values);
        List<MeetingReport__c> mrList = [Select id,Name from MeetingReport__c];
        system.assert(mrList.size()>0);
        
	}
}