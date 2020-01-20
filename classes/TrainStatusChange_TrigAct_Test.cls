/*
* Author - G. Naveen
* Date: 18-March-2018
* Company: Accenture
* Test class for TrainStatusChange_TrigAct
*/
@isTest

public class TrainStatusChange_TrigAct_Test {
    private static final Id plantId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
    private static final Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
    private static final Id trainId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
    private static List<Account> accList = new List<Account>();
    private static List<Contact> conList = new List<Contact>();
    
    @testSetup
    static void setupTestData() 
    {          
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;
        Contact con = new Contact(LastName = 'Test',AccountId=acc.Id);
        conList.add(con);
        insert conList;
    } 
    // Test Method to test No. of equipments and trains related to train asset and plant asset
    static testMethod void testRelatedAssetCountInsert()
    {
        Test.startTest();
        List<Asset> assetList = new List<Asset>();
        List<Asset> trainList = new List<Asset>();
        Account acctEntity = [Select id,Name from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetTrainRec =  new Asset(Name = 'Test Asset', AccountId = acctEntity.Id,RecordTypeId= trainId ,ContactId = conEntity.Id);
        insert assetTrainRec ;
        Asset assetPlantRec = new Asset(Name='Plant Asset',AccountId = acctEntity.Id,RecordTypeId= plantId,ContactId = conEntity.Id);
        insert assetPlantRec;
        
        Asset assetTrainRec1 =  new Asset(Name = 'TrainAsset1', AccountId = acctEntity.Id,ContactId=conEntity.Id,ParentId=assetPlantRec.Id,RecordTypeId= trainId);
        Asset assetTrainRec2 =  new Asset(Name = 'TrainAsset2', AccountId = acctEntity.Id,ParentId=assetPlantRec.Id,ContactId=conEntity.Id,RecordTypeId= trainId);
        trainList.add(assetTrainRec1);
        trainList.add(assetTrainRec2); 
        insert trainList;
        
        TriggerHandler.resetAllHasRun();
        
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = acctEntity.Id,ParentId=assetTrainRec.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = acctEntity.Id,ParentId=assetTrainRec.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2); 
        insert assetList;
        Asset equipRec = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'Test Asset'];
        system.assertEquals(2,equipRec.NoOfRelatedEquipments__c);
        
        Asset plantRec = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'Plant Asset'];
        system.assertEquals(2,plantRec.NoOfRelatedTrains__c);
        Test.stopTest();
        
    }
    // Test Method to test Train asset status change on new Child Equipment insert
    //
    static testMethod void testTrainStatusInsert()
    {
        Test.startTest();
        Account accRec = [Select id,Name from Account where Name = 'Test Account'];
        Contact conRec = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetTrainRec =  new Asset(Name = 'Test Asset', AccountId = accRec.Id,RecordTypeId= trainId ,ContactId = conRec.Id);
        insert assetTrainRec;
        TriggerHandler.resetAllHasRun();
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        insert assetEquipRec1;
        List<Asset> entity = [Select id, Name, TrainStatus__c from Asset  where Name = 'Test Asset'];
        system.assertEquals(1,entity.Size());
        system.assertEquals('Active',entity[0].TrainStatus__c);
        Test.stopTest();
    } 
    // 
    // Test Method to test Train asset status change on Child Equipment's status change
    // 
    static testMethod void testTrainStatusUpdate()
    {
        Test.startTest();
        TriggerHandler handlerInstance = new TriggerHandler();
        List <Asset> assetList = new List<Asset>();
        Account accRec = [Select id,Name from Account where Name = 'Test Account'];
        Contact conRec = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetTrainRec =  new Asset(Name = 'Test Asset', AccountId = accRec.Id,RecordTypeId= trainId ,ContactId = conRec.Id);
        insert assetTrainRec;
        TriggerHandler.resetAllHasRun();
        handlerInstance.resetHasRun();
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2);
        insert assetList;
        TriggerHandler.resetAllHasRun();
        Asset entityRec = [Select id, Name,OperatingStatus__c from Asset  where Name = 'Test Asset Equipment1'];
        entityRec.OperatingStatus__c = 'Inactive';
        update entityRec;
        Asset entityRead = [Select id, Name,OperatingStatus__c from Asset  where Name = 'Test Asset Equipment1'];
        system.assertEquals('Inactive',entityRead.OperatingStatus__c);
        Asset readParent = [Select id, Name, TrainStatus__c from Asset  where Name = 'Test Asset'];
        system.assertEquals('Partially Active',readParent.TrainStatus__c);
        Test.stopTest();
    }
    
    static testMethod void testCountUpdateforEquipmentAsset()
    {
        Test.startTest();
        Account acctEntity = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        List<Asset> EquipList = new List<Asset>();
        Asset assetTrainRec = new Asset(Name='TrainAsset',AccountId = acctEntity.Id,RecordTypeId= trainId,ContactId = conEntity.Id);
        insert assetTrainRec;
        Asset assetTrainRec1 = new Asset(Name='TrainAsset1',AccountId = acctEntity.Id,RecordTypeId= trainId,ContactId = conEntity.Id);
        insert assetTrainRec1;
        Asset assetEquipRecNew =  new Asset(Name = 'EquipAssetnew', AccountId = acctEntity.Id,ContactId=conEntity.Id,ParentId=assetTrainRec1.Id,RecordTypeId= equipId);
        Asset assetEquipRec1 =  new Asset(Name = 'EquipAsset1', AccountId = acctEntity.Id,ContactId=conEntity.Id,ParentId=assetTrainRec.Id,RecordTypeId= equipId);
        Asset assetEquipRec2 =  new Asset(Name = 'EquipAsset2', AccountId = acctEntity.Id,ParentId=assetTrainRec.Id,ContactId=conEntity.Id,RecordTypeId= equipId);
        EquipList.add(assetEquipRecNew);
        EquipList.add(assetEquipRec1);
        EquipList.add(assetEquipRec2); 
        insert EquipList;
        system.assertEquals(3,EquipList.Size());
        
        TriggerHandler.resetAllHasRun();
        
        Asset equipRec = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'TrainAsset'];
        system.assertEquals(2,equipRec.NoOfRelatedEquipments__c);
        Asset equipRec1 = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'TrainAsset1'];
        system.assertEquals(1,equipRec1.NoOfRelatedEquipments__c);
        
        Asset readRec = [Select id,Name from Asset Where Name = 'EquipAssetnew'];
        readRec.ParentId = equipRec.Id;
        update readRec;
        Asset asUpdate = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'TrainAsset'];
        system.assertEquals(3,asUpdate.NoOfRelatedEquipments__c);
        Asset asUpdate1 = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'TrainAsset1'];
        system.assertEquals(0,asUpdate1.NoOfRelatedEquipments__c);
        
        
        Test.stopTest();
        
        
    }
    // 
    static testMethod void testCountUpdateforTrainAsset()
    {
        Test.startTest();
        Account acctEntity = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        List<Asset> trainList = new List<Asset>();
        Asset assetPlantRec = new Asset(Name='PlantAsset',AccountId = acctEntity.Id,RecordTypeId= plantId,ContactId = conEntity.Id);
        insert assetPlantRec;
        Asset assetPlantRec1 = new Asset(Name='PlantAsset1',AccountId = acctEntity.Id,RecordTypeId= plantId,ContactId = conEntity.Id);
        insert assetPlantRec1;
        Asset assetTrainRecNew =  new Asset(Name = 'TrainAssetnew', AccountId = acctEntity.Id,ContactId=conEntity.Id,ParentId=assetPlantRec1.Id,RecordTypeId= trainId);
        Asset assetTrainRec1 =  new Asset(Name = 'TrainAsset1', AccountId = acctEntity.Id,ContactId=conEntity.Id,ParentId=assetPlantRec.Id,RecordTypeId= trainId);
        Asset assetTrainRec2 =  new Asset(Name = 'TrainAsset2', AccountId = acctEntity.Id,ParentId=assetPlantRec.Id,ContactId=conEntity.Id,RecordTypeId= trainId);
        trainList.add(assetTrainRecNew);
        trainList.add(assetTrainRec1);
        trainList.add(assetTrainRec2); 
        insert trainList;
        system.assertEquals(3,trainList.Size());
        
        TriggerHandler.resetAllHasRun();
        
        Asset trRec = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'PlantAsset'];
        system.assertEquals(2,trRec.NoOfRelatedTrains__c);
        Asset trRec1 = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'PlantAsset1'];
        system.assertEquals(1,trRec1.NoOfRelatedTrains__c);
        
        Asset readRec = [Select id,Name from Asset Where Name = 'TrainAssetnew'];
        readRec.ParentId = trRec.Id;
        update readRec;
        Asset asUpdate = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'PlantAsset'];
        system.assertEquals(3,asUpdate.NoOfRelatedTrains__c);
        Asset asUpdate1 = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'PlantAsset1'];
        system.assertEquals(0,asUpdate1.NoOfRelatedTrains__c);
        
        
        Test.stopTest();
        
        
    }
    // For deleting equipment assets on train
    static testMethod void testEquipmentDeleteforAsset()
    {
        
        Test.startTest();
        List<Asset> assetList = new List<Asset>();
        List<Asset> trainList = new List<Asset>();
        Account acctEntity = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetTrainRec =  new Asset(Name = 'Test Asset', AccountId = acctEntity.Id,RecordTypeId= trainId ,ContactId = conEntity.Id);
        insert assetTrainRec ;
        
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = acctEntity.Id,ParentId=assetTrainRec.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = acctEntity.Id,ParentId=assetTrainRec.Id,ContactId=conEntity.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2); 
        insert assetList;
        TriggerHandler.resetAllHasRun();
        
        Asset accRec = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'Test Asset'];
        system.assertEquals(2,accRec.NoOfRelatedEquipments__c);
        Asset delRec = [Select id,Name from Asset where Name = 'Test Asset Equipment1'];
        delete delRec;
        List<Asset> equipList = [Select id, Name from Asset  where Name  like 'Test Asset Equipment%'];
        system.assertEquals(1,equipList.Size());
        Asset accReadAgain = [Select id,Name,NoOfRelatedEquipments__c  from Asset Where Name = 'Test Asset'];
        system.assertEquals(1,accReadAgain.NoOfRelatedEquipments__c);
        
        Test.stopTest();
        
        
    }
    
    // For deleting Train assets on plant
    static testMethod void testTrainDeleteforAsset()
    {
        Test.startTest();
        Account acctEntity = [Select id,Name,NoOfRelatedEquipments__c  from Account Where Name = 'Test Account'];
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        List<Asset> trainList = new List<Asset>();
        Asset assetPlantRec = new Asset(Name='PlantAsset',AccountId = acctEntity.Id,RecordTypeId= plantId,ContactId = conEntity.Id);
        insert assetPlantRec;
        Asset assetTrainRec1 =  new Asset(Name = 'TrainAsset1', AccountId = acctEntity.Id,ContactId=conEntity.Id,ParentId=assetPlantRec.Id,RecordTypeId= trainId);
        Asset assetTrainRec2 =  new Asset(Name = 'TrainAsset2', AccountId = acctEntity.Id,ParentId=assetPlantRec.Id,ContactId=conEntity.Id,RecordTypeId= trainId);
        trainList.add(assetTrainRec1);
        trainList.add(assetTrainRec2); 
        insert trainList;
        system.assertEquals(2,trainList.Size());
        TriggerHandler.resetAllHasRun();
        Asset trRec = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'PlantAsset'];
        system.assertEquals(2,trRec.NoOfRelatedTrains__c);
        Asset delRecc = [Select id,Name from Asset where Name = 'TrainAsset1'];
        delete delRecc;
        List<Asset> traList = [Select id, Name from Asset  where Name  like 'TrainAsset%'];
        system.assertEquals(1,traList.Size());
        Asset asetReadAgain = [Select id,Name,NoOfRelatedTrains__c  from Asset Where Name = 'PlantAsset'];
        system.assertEquals(1,asetReadAgain.NoOfRelatedTrains__c);
        Test.stopTest();
    }
    
    // Test Method to test Train asset status change to Inactive when Child Equipment's are Inactive
    //
    static testMethod void testTrainStatusInactive()
    {
        Test.startTest();
        TriggerHandler handlerInstance = new TriggerHandler();
        List <Asset> assetList = new List<Asset>();
        Account accRec = [Select id,Name from Account where Name = 'Test Account'];
        Contact conRec = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetTrainRec =  new Asset(Name = 'Test Asset', AccountId = accRec.Id,RecordTypeId= trainId ,ContactId = conRec.Id);
        insert assetTrainRec;
        handlerInstance.resetHasRun();
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2);
        insert assetList;
        TriggerHandler.resetAllHasRun();
        List<Asset> updateRecList = new List<Asset>();
        List<Asset> assetListRead = [Select id, Name from Asset  where Name  like 'Test Asset Equipment%'];
        system.assertEquals(2,assetListRead.Size());
        for(Asset entity: assetListRead)
        {
            Asset upRec = new Asset();
            upRec.Id = entity.Id;
            upRec.OperatingStatus__c = 'Inactive';
            updateRecList.add(upRec);
        }
        if(!updateRecList.isEmpty())
        {
            update updateRecList;
        }
        Asset readParent = [Select id, Name, TrainStatus__c from Asset  where Name = 'Test Asset'];
        system.assertEquals('Inactive',readParent.TrainStatus__c);
        Test.stopTest();
    }
    // 
    // Test Method to cover all handler methods.
    //
    static testMethod void testHandlersMethods()
    {           
        Test.startTest();
        TriggerHandler handlerInstance = new TriggerHandler();
        List <Asset> assetList = new List<Asset>();
        Account accRec = [Select id,Name from Account where Name = 'Test Account'];
        Contact conRec = [Select Id,Name from Contact where LastName = 'Test'];
        Asset assetTrainRec =  new Asset(Name = 'Test Asset', AccountId = accRec.Id,RecordTypeId= trainId ,ContactId = conRec.Id);
        insert assetTrainRec;
        TriggerHandler.resetAllHasRun();
        //handlerInstance.resetHasRun();
        Asset assetEquipRec1 =  new Asset(Name = 'Test Asset Equipment1', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetEquipRec2 =  new Asset(Name = 'Test Asset Equipment2', AccountId = accRec.Id,ParentId=assetTrainRec.Id,ContactId=conRec.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetEquipRec1);
        assetList.add(assetEquipRec2);
        insert assetList;
        TriggerHandler.resetAllHasRun();
        Asset  entity = [Select id, Name, TrainStatus__c from Asset  where Name = 'Test Asset'];
        delete Entity;
        List<Asset>  readEntity = [Select id, Name, TrainStatus__c from Asset  where Name = 'Test Asset'];
        system.assertEquals(0, readEntity.size());
        TriggerHandler.resetAllHasRun();
        undelete entity;
        List<Asset>  readEntityAgain = [Select id, Name, TrainStatus__c from Asset  where Name = 'Test Asset'];
        system.assertEquals(1, readEntityAgain.size());
        
        Test.stopTest();
    }
    
}