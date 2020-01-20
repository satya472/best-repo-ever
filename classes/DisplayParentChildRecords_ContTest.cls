/*
* Author : Rupinder Kaur
* Description : Test Class for DisplayParentChildRecords.
*/
@isTest
public class DisplayParentChildRecords_ContTest {
    
    @testsetup
    public static void testData(){
        
        Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        
        Account acc = new Account( Name='Test ParentChild',Type='Site');
        insert acc;
        
        Account acc1 = new Account(Name='Test ParentChildRecord',parentId = acc.Id,Type='Site');
        insert acc1;
        
        List<Asset> assetList = new List<Asset>();
        Asset assetRec1 =  new Asset(Name = 'Test AssetParentChild1', AccountId = acc.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetRec2 =  new Asset(Name = 'Test AssetParentChild2', AccountId = acc1.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetRec3 =  new Asset(Name = 'Test AssetParentChild3', AccountId = acc.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        Asset assetRec4 =  new Asset(Name = 'Test AssetParentChild4', AccountId = acc.Id,RecordTypeId= equipId,OperatingStatus__c='Active');
        assetList.add(assetRec1);
        assetList.add(assetRec2);
        assetList.add(assetRec3);
        assetList.add(assetRec4);
        insert assetList;
        
    }
    
    /* Method to test whether the class returning the parent and child records properly or not */
    public static testMethod void testParentChildRecord(){
        
        Test.startTest();
        List<DisplayParentChildRecords_Cont.ParentChildWrapper> records=  DisplayParentChildRecords_Cont.getParentChildRecordDetails('Account', 'Asset','Type=\'Site\'',
                                                                                                                                     'RecordType.DeveloperName = \'Equipment\'' , 'AccountId' , '');
        system.assertEquals(2, records.size());
        
        try{
            records=  DisplayParentChildRecords_Cont.getParentChildRecordDetails('Account', 'Asset','Type=\'Site1\'','RecordType.DeveloperName = \'Equipment\'' , 'AccountId' , '');
        }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
        }
         
        Test.stopTest();
        
    }
    /* Method to test Negative scenario */
    public static testMethod void testNegativeParentChild(){
        
        Test.startTest();
        try{
            List<DisplayParentChildRecords_Cont.ParentChildWrapper> records=  DisplayParentChildRecords_Cont.getParentChildRecordDetails('Account', '','Type=\'Site\'','RecordType.DeveloperName = \'Equipment\'' , 'AccountId' , '');
            system.assertEquals(null, records);
        }
        catch (AuraHandledException e) {
            System.debug(e.getMessage());
        }
        
        
        Test.stopTest();
    }
    
}