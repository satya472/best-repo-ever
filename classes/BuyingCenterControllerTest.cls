/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 4-June-2018
* Description: BuyingCenterControllerTest class
*/

@isTest
public class BuyingCenterControllerTest {
    
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
        
        Contact c1=new Contact(FirstName='firstname',LastName = 'lname1',Email = 'email321@gmail.com',Phone = '9743800309'); 
        insert c1;         
        Contact c2=new Contact(FirstName='secondname',LastName = 'lname2',Email = 'email123@gmail.com',Phone = '9743800309'); 
        insert c2; 
        Contact c3=new Contact(FirstName='thirdname',LastName = 'lname3',Email = 'email3214@gmail.com',Phone = '9743700309'); 
        insert c3;
        
        // add accounts
        List<Account> accList = new List<Account>();
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;
        
        //add opportunity
        List<Opportunity> oppsList = new List<Opportunity>();        
        for (Account acct : accList) {            
            oppsList.add(new Opportunity(Name= acct.Name+ ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=acct.Id)); 
        }        
        insert oppsList;     
    }
    
    static testMethod void testCreateBuyingCenterMembers(){
        Test.startTest();   
        Map<Id, Contact> contactIdMap = new Map<Id, Contact>([Select Id, Name from Contact]);
        List<Id> contactIdList = new List<Id>(contactIdMap.keySet());
        
        Map<Id, User> userIdMap = new Map<Id, User>([Select Id, Name from User]);
        List<Id> userIdList = new List<Id>(userIdMap.keySet());        
        
        Map<Id, Account> accIdMap = new Map<Id, Account>([Select Id, Name from Account where Name IN ('Test Account')]); 
        List<Opportunity> oppList =  ([SELECT ID, AccountId FROM Opportunity WHERE AccountId IN :accIdMap.keySet()]);        
      	Id opptyId = oppList.get(0).Id;
        
        //check for screen:
        BuyingCenterController.getOpportunityId('Opportunity', 'Id',opptyId );
            
        //create BCM 
        List<Buying_Center_Member__c> bcmList = new List<Buying_Center_Member__c>();
        Integer count = 1;
        for (Id conId:contactIdList) { 
            Buying_Center_Member__c newBCM = new Buying_Center_Member__c();
            newBCM.Contact__c = conId;
            newBCM.Category__c = 'Decision Maker';  
            newBCM.Status__c = 'Pro';  
            newBCM.Type__c = 'Buying Center'; 
            newBCM.Position__c = count;
            newBCM.Opportunity__c = opptyId;
            bcmList.add(newBCM);
            count++;
        }
        
        //create SCM 
        count = 1;
        for (Id userId:userIdList) { 
            Buying_Center_Member__c newSCM = new Buying_Center_Member__c();
            newSCM.User__c = userId;
            newSCM.Category__c = 'Influencer';  
            newSCM.Status__c = 'Anti';  
            newSCM.Type__c = 'Selling Center'; 
            newSCM.Position__c = count;
            newSCM.Opportunity__c = opptyId;
            bcmList.add(newSCM);
            count++;
        }
        
        //create buying center member
		insert bcmList;
        
        Set<Id> oppTeamMemberList = new Map<Id, OpportunityTeamMember>([SELECT ID, OpportunityId FROM OpportunityTeamMember 
                                                                        WHERE OpportunityId =:opptyId]).keySet();
        Map<Id, Buying_Center_Member__c> memberMap = new Map<Id, Buying_Center_Member__c>([SELECT ID, Opportunity__c, Type__c FROM Buying_Center_Member__c 
                                                                               WHERE Opportunity__c =:opptyId]); 
               
        string scm = null;       
        string bcm= null;
        for (Id memberId : memberMap.keySet() ) {
            if(memberMap.get(memberId).Type__c == 'Buying Center'){
            	bcm= memberId;
                break;       
            }
        }
        
        for (Id memberId : memberMap.keySet() ) {
            if(memberMap.get(memberId).Type__c != 'Buying Center'){
                scm= memberId;
                break;
            }            
        }
        
        //get the attributes from fieldset
        String sObjectName = 'Buying_Center_Member__c';
        String fieldSetName = 'BuyingCenterMemberAttributes';
        BuyingCenterController.getFieldSetData(sObjectName,fieldSetName); 
        //negative
        BuyingCenterController.getFieldSetData('',''); 
        
        List<Buying_Center_Relation__c> bcRelationListResult = [SELECT Id, Name, BuyingCenterMember__c, SellingCenterMember__c
                                                                FROM Buying_Center_Relation__c 
                                                                WHERE BuyingCenterMember__c IN:memberMap.keySet() 
                                                                AND SellingCenterMember__c IN:memberMap.keySet()];                                                 
        
        List<Buying_Center_Relation__c> bcRelationCreateList = BuyingCenterController.createBuyingCenterRelation(opptyId, scm, bcm);          
        //system.assertEquals( bcRelationCreateList.size(), bcRelationListResult.size());
  
        List<Buying_Center_Relation__c> bcRelationDeleteList = BuyingCenterController.deleteBuyingCenterRelation(opptyId, scm, bcm);            
        //system.assertEquals( bcRelationDeleteList.size(), bcRelationListResult.size());

       BuyingCenterController.deleteBuyingCentreMembers(bcm);    

        count = 10;
        List<Buying_Center_Member__c> updateMemberList = new List<Buying_Center_Member__c>();
        for (Id memberId : memberMap.keySet() ) {
            memberMap.get(memberId).Position__c = count;
            updateMemberList.add(memberMap.get(memberId));
        }
        
        BuyingCenterController.updateBuyingCenterMember(updateMemberList);      
        Test.stopTest();    
    }    
}