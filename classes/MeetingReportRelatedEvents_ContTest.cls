/*
*Author: G.Naveen Kumar
*Date:9-Sep-18
*Description: Test class for MeetingReportRelatedEvents_Cont
*/
@IsTest
public with sharing class MeetingReportRelatedEvents_ContTest {
   @testSetup
    static void setupTestData() 
	{      
        // add accounts
        
        
        Account act= new Account( Name='Test Account', Type='Site');
        insert act;         
		
         Account act2= new Account( Name='Child Test Account', Type='Site');
        insert act2; 
        
        string equipAssetMainId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        string equipAssetOppId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        
        Asset assetObj= new Asset();
        assetObj.name= 'test Plant Asset';
        assetObj.AccountId= act.Id;
        assetObj.recordtypeId= equipAssetMainId;
		assetObj.Frame__c = 'Test Frame';
        insert assetObj;
        
        Asset equipAsset = new Asset();
        equipAsset.name= 'test Train Asset';
        equipAsset.AccountId= act2.Id;
        equipAsset.recordtypeId= equipAssetOppId;
		equipAsset.Frame__c = 'Test Frame';
        insert equipAsset;
        
		
		Event__c testEvent = new Event__c(Name = 'Test Event',AssetId__c = assetObj.id,EventType__c = 'Controls');
		insert testEvent;
		
		MeetingReport__c testMeetReport = new MeetingReport__c(AccountId__c = act.id);
        insert testMeetReport;
    }
	
	public static testmethod void getTest()
	{
	    List<MeetingReport__c> readRec = [Select id,Name,AccountId__c FROM MeetingReport__c];
		List<Event__c> eventList = [Select Id,Name,AssetId__c FROM Event__c];
		system.assert(readRec.size() > 0);
		List<sObject> actEvents = MeetingReportRelatedEvents_Cont.getEventRecords('Event__c','accRelEvents','["Name","AssetId__c","AssetId__r.Name"]',readRec[0]);
        List<sObject> allEvents = MeetingReportRelatedEvents_Cont.getEventRecords('Event__c','allEvents','["Name","AssetId__c","AssetId__r.Name"]',readRec[0]);
		String sScope = MeetingReportRelatedEvents_Cont.getSearchScope();
        
        string addRecordList = '[{"attributes":{"type":"Event__c","url":"/services/data/v43.0/sobjects/Event__c/'+eventList[0].Id;
        addRecordList = addRecordList +'"},"Id":"'+eventList[0].Id+'"';
        addRecordList = addRecordList+',"AssetId__r":{"attributes":{"type":"Asset","url":"/services/data/v43.0/sobjects/Asset/'+eventList[0].AssetId__c+'"';
        addRecordList = addRecordList+'}}}]';
        system.debug(' addRecordList string:  '+addRecordList);
        Object[] values = (Object[])System.JSON.deserializeUntyped(addRecordList);   
        system.debug(' test class values '+values);
		MeetingReportRelatedEvents_Cont.createMeetingEventRecords(readRec[0].Id,values);
        List<MeetingEvent__c> eveList = [Select id,Name from MeetingEvent__c ];
        system.assert(eveList.size()>0);
	}
}