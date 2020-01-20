/*
* Author - G. Naveen
* Apex covering 
* Test class for EquipmentRollupOnAccount_TriggerAct
*/

@isTest
public class EquipmentRollupOnAccount_TriggerAct_Test {
    
    private static final Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
    private static final Id trainId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
    private static List<Account> accList = new List<Account>();
    private static List<Contact> conList = new List<Contact>();
    
    @testSetup
    static void setupTestData() 
    {          
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        Account accNew = new Account( Name='Test Account1');
        accList.add(accNew);
        insert accList;
        Contact con = new Contact(LastName = 'Test',AccountId=acc.Id);
        conList.add(con);
        insert conList;
    } 
    // Test Method to test No. of equipments inserted related to account
    static testMethod void testEquipmentInsertOnAccount()
    {
        Test.startTest();
        List<Asset> assetList = new List<Asset>();
        Account acctEntity = [Select id,Name from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = acctEntity.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = acctEntity.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2); 
        insert assetList;
        system.assertEquals(2,assetList.Size());
        TriggerHandler.resetAllHasRun();
        
        Account readAcct = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        System.assertEquals(2,readAcct.NoOfRelatedEquipments__c);
        
        Test.stopTest();
    }
    // Test Method to test No. of equipments deleted related to account
    static testMethod void testEquipmentDeleteOnAccount()
    {
        Test.startTest();
        List<Asset> assetList = new List<Asset>();
        Account acctEntity = [Select id,Name from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = acctEntity.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = acctEntity.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2); 
        insert assetList;
        system.assertEquals(2,assetList.Size());
        TriggerHandler.resetAllHasRun();
        
        Account readAcct = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        System.assertEquals(2,readAcct.NoOfRelatedEquipments__c);
        Asset delRec = [Select id,Name from Asset where Name = 'Test Asset Equipment1'];
        delete delRec;
        List<Asset> equipList = [Select id, Name from Asset  where Name  like 'Test Asset Equipment%'];
        system.assertEquals(1,equipList.Size());
        Account accReadAgain = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        system.assertEquals(1,accReadAgain.NoOfRelatedEquipments__c);
         Test.stopTest();
        
    }
    // Test Method to test No. of equipments updated related to account
    static testMethod void testEquipmentUpdateOnAccount()
    {
        Test.startTest();
        List<Asset> assetList = new List<Asset>();
        Account acctEntity = [Select id,Name from Account Where Name = 'Test Account'];
        Account secondAcct = [Select id,Name from Account Where Name = 'Test Account1'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = acctEntity.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = secondAcct.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2); 
        insert assetList;
        system.assertEquals(2,assetList.Size());
        TriggerHandler.resetAllHasRun();
        
        
        Account accRec = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        system.assertEquals(1,accRec.NoOfRelatedEquipments__c);
        Account accTest2 = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account1'];
        system.assertEquals(1,accTest2.NoOfRelatedEquipments__c);
        Asset readRec = [Select id,Name from Asset Where Name = 'Test Asset Equipment2'];
        readRec.AccountId = accRec.Id;
        update readRec;
        Account accUpdate = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        system.assertEquals(2,accUpdate .NoOfRelatedEquipments__c);
                
        Test.stopTest();
    }
    
    
    
    
    
    
    
    
}