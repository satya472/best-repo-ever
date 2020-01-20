/*
* Author : Phaniram Upalapati
* Description : Test Class for DisplayHierarchy_Cont.
*/
@isTest
public class DisplayHierarchy_ContTest {
    
    @testsetup
    public static void testData(){
        
        Id plantId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        Id trainId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
        
        Account acc = new Account( Name='Test AccountHierarchy');
        insert acc;
        
        Account acc1 = new Account(Name='Test AccountHierarchyChild',parentId = acc.Id);
        insert acc1;
        
        List<Asset> assetList = new List<Asset>();
        Asset assetEquipRec1 =  new Asset(Name = 'Test AssetHierarchy1', AccountId = acc.Id,RecordTypeId= plantId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test AssetHierarchy2', AccountId = acc1.Id,RecordTypeId= plantId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2);
        insert assetList;
        
        assetList = new List<Asset>();
        Asset assetEquipRec3 =  new Asset(Name = 'Test AssetHierarchy3', AccountId = acc.Id,parentId=assetEquipRec1.Id,RecordTypeId= trainId,OperatingStatus__c='Active');
        insert assetEquipRec3;
        Asset assetEquipRec4 =  new Asset(Name = 'Test AssetHierarchy4', AccountId = acc.Id,parentId=assetEquipRec3.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        insert assetEquipRec4;
        
        
    }
    
    /* Method to test whether the class returning the Asset and Account hierarchy details properly or not */
    public static testMethod void testHierarchy(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User u1 = new User(Alias = 'DispHie', Email='TestDisplayHierarchy@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='hierarchy', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestDisplayHierarchy@orgTest.com');
        
        Asset assRec = [Select Id,Name,RootAssetId from Asset Where Name='Test AssetHierarchy1' LIMIT 1];
        Asset assRec2 = [Select Id,Name,RootAssetId from Asset Where Name='Test AssetHierarchy2' LIMIT 1];
        Asset assRec3 = [Select Id,Name,RootAssetId from Asset Where Name='Test AssetHierarchy3' LIMIT 1];
        
        Test.startTest();
        
        system.runAs(u1) {

            List<DisplayHierarchy_Cont.RecordItems> recordList = DisplayHierarchy_Cont.getHierarchyDetails(assRec.Id,'Asset');
            
            //Items count must match 1 i.e. 1 Asset(Top Level). Directly linked records only
            //Will be displayed i.e. no sibling records
            system.assertEquals(1, recordList[0].items.size());
            
            system.assertEquals(1, recordList[0].items[0].items.size());
            
            //Asset Records Under Child Account
            recordList = DisplayHierarchy_Cont.getHierarchyDetails(assRec2.Id,'Asset');
            
            //Items count must match 1 i.e. 1 child Account. And under the Account 1 Asset record
            //Account1->Account2->Asset
            system.assertEquals(1, recordList[0].items.size());
            
            recordList = DisplayHierarchy_Cont.getHierarchyDetails(assRec3.Id,'Asset');
            
            //Parent Account->1 record(1Asset)->(1 Asset))
            system.assertEquals(1, recordList[0].items[0].items.size());

        }      
        Test.stopTest();
    }
    
    /* Method to test Negative scenario */
    public static testMethod void testNegativeHierarchy(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User u1 = new User(Alias = 'DispHie1', Email='TestDisplayHierarchy1@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='hierarchy1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestDisplayHierarch1y@orgTest.com');
        
        Asset assRec = [Select Id,Name,RootAssetId from Asset Where Name='Test AssetHierarchy1' LIMIT 1];
        
        Test.startTest();
        
        system.runAs(u1){
            
            List<DisplayHierarchy_Cont.RecordItems> recordList = DisplayHierarchy_Cont.getHierarchyDetails(assRec.Id,'Contact');
        
            //If the Object name is other than Asset or Account then the class return Null value
            system.assertEquals(null, recordList);
            
        }

        Test.stopTest();
    }
    
}