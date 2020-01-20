/*
 * Author : Phaniram Upalapati
 * Description : Test Class for CustomMetadataFetch_Cont
 */
@IsTest
public class CustomMetadataFetch_ContTest {

    public static testMethod void testingMetadataFetch(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User u1 = new User(Alias = 'metaFe', Email='metaDataFetch@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='Fetching', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='metaDataFetch@orgTest.com');
        
        Test.startTest();
        
        system.runAs(u1){
            
            List<sObject> metadataRec = CustomMetadataFetch_Cont.fetchCustomMetadataRecords('AssetPlantsOnAccount','DisplayRelatedList__mdt' , 'CardTitle__c,ChildObjectAPIName__c,FieldSetName__c');
            
            system.assertEquals(1, metadataRec.size());
            
            //Negative Scenario
            metadataRec = CustomMetadataFetch_Cont.fetchCustomMetadataRecords('AssetPlantsOnAccountTest','DisplayRelatedList__mdt' , 'CardTitle__c,ChildObjectAPIName__c,FieldSetName__c');
            
            //0 Records must be fetched
            system.assertEquals(0, metadataRec.size());
        }

        Test.stopTest();

    }
}