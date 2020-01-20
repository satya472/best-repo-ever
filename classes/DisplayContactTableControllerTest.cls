/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 5-June-2018
* Description: DisplayContactTableController called from DisplayContactComponent
*/

@isTest
public class DisplayContactTableControllerTest {
    
    @testSetup
    static void setupTestData(){
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
        
        // add accounts
        List<Account> accList = new List<Account>();
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;
        
        List<Opportunity> oppsList = new List<Opportunity>();        
        List<Contact> contactList = new List<Contact>();
        
        for (Account acct : accList) { 
            oppsList.add(new Opportunity(Name= acct.Name+ ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=acct.Id)); 
            contactList.add(new Contact(FirstName='firstname',LastName = 'lname1',Email = 'email321@gmail.com',Phone = '9743800309',
                                        AccountId=acct.Id));        
            contactList.add(new Contact(FirstName='secondname',LastName = 'lname2',Email = 'email123@gmail.com',Phone = '9743800309',
                                        AccountId=acct.Id)); 
        }
        insert oppsList; 
        insert contactList;
        
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        for(Opportunity opp : oppsList){
            otmList.add(new OpportunityTeamMember(UserId=u1.Id, OpportunityId = opp.Id));
        }
        insert otmList;
    }
    
    static testMethod void testDisplayContactTable(){
        Test.startTest();  
       	Map<Id, User> userIdMap = new Map<Id, User>([Select Id, Name from User LIMIT 2]);
        List<Id> userIdList = new List<Id>(userIdMap.keySet());
            
        List<Account> accList = [Select Id, Name from Account where Name IN ('Test Account')]; 
        String parentRecordId = accList.get(0).Id;
        
        Map<Id, Contact> contactIdMap = new Map<Id, Contact>([Select Id, Name from Contact]);
        List<Id> contactIdList = new List<Id>(contactIdMap.keySet());        
        
        Set<Id> opportunityIdSet = new Map<Id, Opportunity>([SELECT ID, AccountId FROM Opportunity WHERE AccountId =:parentRecordId]).keySet();        
		String recordId;
        
        for (Id opptyId : opportunityIdSet) { 
            recordId = opptyId;
            break;
        }
        
        String sObjectName = 'Contact';
        String fieldSetName = 'BuyingCenterContactFields';                     
        String fieldNameJson = '["FirstName","LastName","AccountId","Account.Name","Title","Email","Phone"]';
        
        //get field set values and data
        DisplayContactTableController.getFieldSetData(sObjectName, fieldSetName);
        //Negative
        DisplayContactTableController.getFieldSetData('', '');

        //search key = blank
        String parentFieldName = 'AccountId';         
        String searchKey = '';
        DisplayContactTableController.getRecordsBCM(sObjectName, parentFieldName, parentRecordId, fieldNameJson, recordId, searchKey);
        
        //create BCM members
        List<Buying_Center_Member__c> bcmList = new List<Buying_Center_Member__c>();
        Buying_Center_Member__c newBCM = new Buying_Center_Member__c();
        newBCM.Contact__c = contactIdList.get(0);
        newBCM.Category__c = 'Decision Maker';  
        newBCM.Status__c = 'Pro';
        newBCM.Type__c = 'Buying Center';
        bcmList.add(newBCM);
        
        DisplayContactTableController.createBuyingCentreMembers(recordId, bcmList); 
        
        //search key = 'name'
        searchKey = 'name';
        DisplayContactTableController.getRecordsBCM(sObjectName, parentFieldName, parentRecordId, fieldNameJson, recordId, searchKey); 

		//search selling center
		fieldSetName = 'SellingCenterContactFields';                     
        fieldNameJson = '["FirstName","LastName","Title","Email","Phone"]';
        
        //get field set values and data
        DisplayContactTableController.getFieldSetData(sObjectName, fieldSetName);
        //Negative
        DisplayContactTableController.getFieldSetData('', '');

        //search key = blank
        parentFieldName = 'OpportunityId';         
        searchKey = '';
        DisplayContactTableController.getRecordsSCM(sObjectName, parentFieldName, fieldNameJson, recordId, searchKey);
        
        //create SCM members
        bcmList.clear();
        Buying_Center_Member__c newSCM = new Buying_Center_Member__c();
        newSCM.User__c = userIdList.get(0);
        newSCM.Category__c = 'Influencer';  
        newSCM.Status__c = 'Anti';
        newSCM.Type__c = 'Selling Center';
        bcmList.add(newSCM);
        
        //DisplayContactTableController.createBuyingCentreMembers(recordId, bcmList); 
        
        //search key = 'name'
        searchKey = 'name';
        DisplayContactTableController.getRecordsSCM(sObjectName, parentFieldName, fieldNameJson, recordId, searchKey); 
                
        //get the attributes:
        sObjectName = 'Buying_Center_Member__c';
        fieldSetName = 'BuyingCenterMemberAttributes';
        DisplayContactTableController.getAttributeData(sObjectName,fieldSetName);
        //NEGATIVE
        DisplayContactTableController.getAttributeData('','');
      
        List<Buying_Center_Member__c> resultList = [SELECT ID FROM Buying_Center_Member__c WHERE Opportunity__c =:recordId AND
                                                    (Contact__c IN:contactIdList OR User__c IN:userIdList)  ];
        //system.assertEquals(2, resultList.size());
        Test.stopTest();  
    }    
}