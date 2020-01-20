/*
* Author : Phaniram Upalapati
* Description : Test Class for CustomerSegmentation_Cont
*/
@isTest
public class CustomerSegmentation_ContTest {
    
    @testsetup
    public static void testData(){
        
        Id plantId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        Id trainId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
        
        List<Product2> prodLst = new List<Product2>();
        for(Integer i=0;i<10;i++){
         Product2 prod = new Product2();
         prod.Name = 'TestSeg Prod'+i;
         prod.IsActive = true;
         prod.CurrencyIsoCode = 'USD';
            
         prodLst.add(prod);
        }

        insert prodLst;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        Pricebook2 newPriceBook = new Pricebook2(Name='Seg PriceBook', isActive=True);
        insert newPriceBook;

       // PriceBook2 priceBook = [Select Id,Name from PriceBook2 Where Name= 'Standard Price Book' LIMIT 1];
        List<PriceBookEntry> pbeLst = new List<PriceBookEntry>();
        List<PriceBookEntry> standardpbeLst = new List<PriceBookEntry>();
        for(Integer i=0;i<prodLst.size();i++){
            PriceBookEntry pbe = new PricebookEntry();
            pbe.Product2Id = prodLst[i].Id;
            pbe.PriceBook2Id = newPriceBook.Id;
            pbe.UnitPrice = 10;
            pbe.isActive = true;
            pbe.CurrencyIsoCode = 'USD';
            pbe.UseStandardPrice = false;
            pbeLst.add(pbe);
            
            //Standard PricebookEntry
            PriceBookEntry stdpbe = new PricebookEntry();
            stdpbe.Product2Id = prodLst[i].Id;
            stdpbe.PriceBook2Id = standardPricebook.Id;
            stdpbe.UnitPrice = 10;
            stdpbe.isActive = true;
            stdpbe.CurrencyIsoCode = 'USD';
            stdpbe.UseStandardPrice = false;
            
            standardpbeLst.add(stdpbe);
            
        }
        
        insert standardpbeLst;
        insert pbeLst;
        
        Account acc = new Account( Name='Test CustSegmentation',currencyIsoCode='USD',Price_Book__c = newPriceBook.Id);
        insert acc;
        
        List<Asset> assetList = new List<Asset>();
        Asset assetEquipRec1 =  new Asset(Name = 'Test Segmentation1', AccountId = acc.Id,RecordTypeId= plantId,OperatingStatus__c='Active');
        insert assetEquipRec1;
        Asset assetEquipRec2 =  new Asset(Name = 'Test Segmentation2', AccountId = acc.Id,RecordTypeId= trainId,parentId = assetEquipRec1.Id ,OperatingStatus__c='Active');
        insert assetEquipRec2;

    }

    /*
     * Method to test the Segmentation Functionality
     */ 
    public static testmethod void testSegmentation(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User usr = new User(Alias = 'TestSeg', Email='TestSegmentation@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='hierarchy', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestSegmentation@orgTest.com');
        
        Account acc = [Select id,name from Account Where Name = 'Test CustSegmentation' LIMIT 1];
        Asset plantEquip = [Select Id,Name from Asset Where Name = 'Test Segmentation1' LIMIT 1];
        Asset trainEquip = [Select Id,Name from Asset Where Name = 'Test Segmentation2' LIMIT 1];
        List<Product2> prodLst = [Select Id,Name from Product2 Where Name LIKE 'TestSeg Prod%'];
        
        Test.startTest();
      
        system.runAs(usr){
        
            VisualEditor.DynamicPickListRows segCategory = new CustomerSegmentation_Cont().getValues();
            String categoryName = (String)((VisualEditor.DataRow)segCategory.get(0)).getValue();
            
           //Segmentation for Product related to Train Equipment
           List<CustomerSegmentation_Cont.SegmentationWrapper> segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,prodLst[6].Id);
        
            for(CustomerSegmentation_Cont.SegmentationWrapper segWrapper: segList){
              segWrapper.currentValue = 'Yes';
            }

           String succmsg = CustomerSegmentation_Cont.saveSegmentationAttributes(JSON.serialize(segList),prodLst[6].Id);
           system.assert(succmsg.equalsIgnoreCase('success'));
           try{
                CustomerSegmentation_Cont.DetailsWrapper wrap = CustomerSegmentation_Cont.getProducts(categoryName, trainEquip.Id);
            }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
            }
           //Asset Segmentation
           segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,plantEquip.Id);
        
           for(CustomerSegmentation_Cont.SegmentationWrapper segWrapper: segList){
              segWrapper.currentValue = 'Yes';
           }

           String msg = CustomerSegmentation_Cont.saveSegmentationAttributes(JSON.serialize(segList),plantEquip.Id);
        
           system.assert(msg.equalsIgnoreCase('success'));
                           
           segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,plantEquip.Id);
        
           system.assertEquals('Yes', segList[0].currentValue);
        
           segList[0].currentValue ='No';
        
           msg = CustomerSegmentation_Cont.saveSegmentationAttributes(JSON.serialize(segList),plantEquip.Id);
        
           system.assert(msg.equalsIgnoreCase('success'));
        
            //Segmentation for Product 1
            segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,prodLst[0].Id);
        
            for(CustomerSegmentation_Cont.SegmentationWrapper segWrapper: segList){
              segWrapper.currentValue = 'Yes';
            }

           msg = CustomerSegmentation_Cont.saveSegmentationAttributes(JSON.serialize(segList),prodLst[0].Id);
           system.assert(msg.equalsIgnoreCase('success'));
        
           //Segmentation for Product2
           segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,prodLst[1].Id);
        
            for(CustomerSegmentation_Cont.SegmentationWrapper segWrapper: segList){
              segWrapper.currentValue = 'Yes';
            }

           msg = CustomerSegmentation_Cont.saveSegmentationAttributes(JSON.serialize(segList),prodLst[1].Id);
           system.assert(msg.equalsIgnoreCase('success'));

           CustomerSegmentation_Cont.DetailsWrapper wrap = CustomerSegmentation_Cont.getProducts(categoryName, plantEquip.Id);
          
           List<CustomerSegmentation_Cont.ProductsWrapper> recLst =  new List<CustomerSegmentation_Cont.ProductsWrapper>();
           recLst.add(wrap.recordsWrapper[0]);
            
            Opportunity opp = new Opportunity(name='Tesclass oppName',CloseDate= (Date)system.now().addDays(30).date());
           
           CustomerSegmentation_Cont.createOpportunities(JSON.serialize(recLst),wrap.recordsWrapper[0].accountId,wrap.recordsWrapper[0].currencyCode,JSON.serialize(opp));
        
           List<Opportunity> opprec = [Select Id,Name from Opportunity Where Name = 'Tesclass oppName'];
        
           system.assertEquals(1, opprec.size());
        
           //Saving Segmentation for Train Equipment
           segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,trainEquip.Id);
        
           for(CustomerSegmentation_Cont.SegmentationWrapper segWrapper: segList){
              segWrapper.currentValue = 'Yes';
           }

           msg = CustomerSegmentation_Cont.saveSegmentationAttributes(JSON.serialize(segList),trainEquip.Id);
        
           system.assert(msg.equalsIgnoreCase('success'));
          
            wrap = CustomerSegmentation_Cont.getProducts(categoryName, trainEquip.Id);
             
            system.assertEquals(3, wrap.recordsWrapper.size());
            //Product relevance must be 1 i.e. 100% as all the details are marked as Yes in Both Product and Train Segmentation records.
            system.assertEquals(1, wrap.recordsWrapper[0].productRelevance);
        
           //BlackListing a Product
           wrap = CustomerSegmentation_Cont.getProducts(categoryName, plantEquip.Id);
          
           recLst =  new List<CustomerSegmentation_Cont.ProductsWrapper>();
           recLst.add(wrap.recordsWrapper[1]);
        
           msg = CustomerSegmentation_Cont.blackListProducts(JSON.serialize(recLst[0]),true,wrap.recordsWrapper[0].accountId,'Product Not Needed');

           system.assert(msg.contains('Black Listed successfully'));
        
           //undo blacklisting
           wrap = CustomerSegmentation_Cont.getProducts(categoryName, acc.Id);
                  
           recLst =  new List<CustomerSegmentation_Cont.ProductsWrapper>();
        
            for(Integer i=0;i<wrap.recordsWrapper.size();i++){
                if(wrap.recordsWrapper[i].blackListed){
                    recLst.add(wrap.recordsWrapper[i]);
                    break;
                }
            }
            
           msg = CustomerSegmentation_Cont.blackListProducts(JSON.serialize(recLst[0]),false,wrap.recordsWrapper[0].accountId,'');

           system.assert(msg.contains('removed from Black List successfully'));
        }        
        Test.stopTest();
    }    
    
    /*
     * Testing Negative Scenario i.e. providing wrong input
     */ 
    public static testmethod void testNegativeSegmentation(){
        Account acc = [Select id,name from Account Where Name = 'Test CustSegmentation' LIMIT 1];
        Opportunity opp = new Opportunity();
        opp.CloseDate = system.now().date().addDays(90);
        opp.Name = 'TestNeg Seg Opp';
        opp.StageName = 'Qualifying';
        opp.AccountId = acc.Id;
        
        Insert opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User usr = new User(Alias = 'TestSeg1', Email='TestSegmentation1@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='hierarchy', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestSegmentation1@orgTest.com');
        
        Test.startTest();
       
        system.runAs(usr){
            VisualEditor.DynamicPickListRows segCategory = new CustomerSegmentation_Cont().getValues();
            String categoryName = (String)((VisualEditor.DataRow)segCategory.get(0)).getValue();

            try{
                //When a recordId other than Account,Contact or Product is passed to segmentation
               List<CustomerSegmentation_Cont.SegmentationWrapper> segList = CustomerSegmentation_Cont.getSegmentationAttributes(categoryName,opp.Id);
            }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        
    }

}