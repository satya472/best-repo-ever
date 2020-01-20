@isTest
public class CEPAssetPlantToolsCont_Test {
    
    @TestSetup
    public static void testData(){
        
        Id plantId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        
        Account acc = new Account( Name='Test AccountHierarchy');
        insert acc;
        
            
        List<Asset> assetList = new List<Asset>();
        for(Integer i =0;i<50;i++){
            Asset assetEquipRec1 =  new Asset(Name = 'Test Asset'+i, AccountId = acc.Id,RecordTypeId= plantId,OperatingStatus__c='Active');
            assetList.add(assetEquipRec1);
        }
        
        assetList[0].ControlSystemType__c = 'SPPA-T3000';
        
        insert assetList;

        List<Asset> assetList1 = new List<Asset>();

        for(Integer i =0;i<50;i++){
            Asset assetEquipRec2 =  new Asset(Name = 'Test AssetHierarchy4', AccountId = acc.Id,parentId=assetList[i].Id,RecordTypeId= equipId,OperatingStatus__c='Active');
            assetList1.add(assetEquipRec2);
        }

        insert assetList1;

        Profile profile =[SELECT Id FROM Profile WHERE Profile.Name LIKE 'Cube%Community%User' LIMIT 1];
       
        
        Contact usrContact= new Contact(AccountId = acc.Id,lastName = 'Testing User');
        insert usrContact;

        User testUser = new User(Alias = 'newUser', Email='CommUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profile.Id, FederationIdentifier='CommUser@testorg.com',
        TimeZoneSidKey='America/Los_Angeles', UserName='CommUser@testorg.com');
        testUser.ContactId = usrContact.Id;
        testUser.IsActive = true;

        insert testUser;

        ContactAsset__c ca = new ContactAsset__c();
        ca.AssetId__c = assetList[0].Id;
        ca.ContactId__c = usrContact.Id;
        
        insert ca;

        List<CEP_AssetNotification__c> notiLst = new List<CEP_AssetNotification__c>();

        CEP_AssetNotification__c noti1 =  new CEP_AssetNotification__c();
        noti1.Name = 'Test Noti1';
        noti1.Asset__c = assetList[0].Id;
        noti1.Status__c = 'Publish';
        
         notiLst.add(noti1);

        CEP_AssetNotification__c noti2 =  new CEP_AssetNotification__c();
        noti2.Name = 'Test Noti2';
        noti2.Asset__c = assetList[1].Id;
        noti2.Status__c = 'Publish';

        notiLst.add(noti2);
        
        CEP_AssetNotification__c noti3 =  new CEP_AssetNotification__c();
        noti3.Name = 'Test Noti3';
        noti3.AssetType__c = 'SPPA-T3000';
        noti3.Status__c = 'Publish';

        notiLst.add(noti3);

        insert notiLst;
        
    }

    public static testmethod void testAssetsAssigned(){

        User usr = [Select Id,ContactId,profile.Name from User Where Email = 'CommUser@testorg.com' LIMIT 1];
        
        System.runAs(usr){

            Test.startTest();

            CEPAssetPlantToolsCont.AssetGroupingClass agcLst = CEPAssetPlantToolsCont.getAssetDetails();
            
            List<CEP_AssetNotification__c> notilst = CEPAssetPlantToolsCont.getNotificationDetails();

            Test.stopTest();

            system.assertEquals(1, agcLst.assetList.size());
            system.assertEquals(2, notilst.size());

        }

    }
    
    public static testmethod void testdocumentsFetch(){
        
       Asset aa = [Select Id,name from Asset LIMIT 1];
        
       User usr = [Select Id,ContactId,profile.Name from User Where Email = 'CommUser@testorg.com' LIMIT 1];
        
        System.runAs(usr){

            Test.startTest();
            
              List<ContentDocumentLink> docLst = CEPAssetPlantToolsCont.getfilesInfo(aa.Id);
            
            Test.stopTest();
            
            system.assertEquals(0, docLst.size());
        }
       
        
    }
}