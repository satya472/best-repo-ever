/*
 Created By : Naveen Kumar G
 Description: Test class for FetchOppCompetitor class
*/
@IsTest
public class CreateOppProductHistory_ContTest {
	@testSetup
    static void setupTestData() 
    {
        Account acct = new Account(name='Test Account');
        insert acct;
        
         //Product2 prod = new Product2(Name = 'Test Product',ProductCode = 'TEST',isActive = true);
		//insert prod;
        string equipAssetMainId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        Asset assetObj= new Asset();
        assetObj.name= 'test Plant Asset';
        assetObj.AccountId= acct.Id;
        assetObj.recordtypeId= equipAssetMainId;
		assetObj.Frame__c = 'Test Frame';
        insert assetObj;
         List<Product2> prodLst = new List<Product2>();
        for(Integer i=0;i<10;i++){
         Product2 prod = new Product2();
         prod.Name = 'TestSeg Prod'+i;
         prod.IsActive = true;
         prod.CurrencyIsoCode = 'USD';
            
         prodLst.add(prod);
        }

        insert prodLst;
        
        Pricebook2 custPricebook = new Pricebook2(
           Name = 'Custom Price Book',
            IsActive = true
        );
        insert custPricebook;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
		// PriceBook2 priceBook = [Select Id,Name from PriceBook2 Where Name= 'Standard Price Book' LIMIT 1];
        List<PriceBookEntry> pbeLst = new List<PriceBookEntry>();
        for(Integer i=0;i<prodLst.size();i++){
            PriceBookEntry pbe = new PricebookEntry();
            pbe.PriceBook2Id = standardPricebook.Id;
            pbe.Product2Id = prodLst[i].Id;
            pbe.UnitPrice = 10;
            pbe.isActive = true;
            pbe.CurrencyIsoCode = 'USD';
            pbe.UseStandardPrice = false;
            pbeLst.add(pbe);
        }
        
        insert pbeLst;
        PriceBookEntry pbeStd = new PricebookEntry();
			
        //pbeStd.PriceBook2Id = standardPricebook.Id;
        pbeStd.Product2Id = prodLst[0].Id;
        pbeStd.UnitPrice = 10;
        pbeStd.isActive = true;
        pbeStd.CurrencyIsoCode = 'USD';
        pbeStd.UseStandardPrice = false;
        pbeStd.PriceBook2Id = custPricebook.Id;
         insert pbeStd;
		 opportunity opp = new Opportunity(Name= 'Opportunity',StageName='Qualifying',CloseDate=System.today().addMonths(1), AccountId=acct.Id,Pricebook2Id =custPricebook.Id,CurrencyIsoCode = 'USD');
        insert opp;
        OpportunityLineItem lineItem =  new OpportunityLineItem(Product2Id = prodLst[0].Id,OpportunityId=opp.Id,Quantity = 21,TotalPrice = 20,PricebookEntryId = pbeStd.Id );
        insert lineItem;
        
        OpportunityProductHistory__c histItem = new OpportunityProductHistory__c(AssetId__c = assetObj.Id,OpportunityId__c = opp.id);
        insert histItem;
        //List<OpportunityLineItem> lineItemList =  new List<OpportunityLineItem>();
       // lineItemList.add(lineItem);
        //CreateOppProductHistory_Cont.createOppProdHistoryRecords(lineItemList)
    }
     public static testmethod void getOppProductHistoryTest()
	{
        List<OpportunityLineItem> lineItemList =  [Select id,Product2Id,OpportunityId,ListPrice from OpportunityLineItem];
        system.assert(lineItemList.size()>0);
        CreateOppProductHistory_Cont.createOppProdHistoryRecords(lineItemList);
        List<OpportunityProductHistory__c> historyList = [Select id,Name from OpportunityProductHistory__c];
        system.assert(historyList.size()>0);
        CreateOppProductHistory_Cont.lightningTableWrapper inst = new CreateOppProductHistory_Cont.lightningTableWrapper();
        inst = CreateOppProductHistory_Cont.getSourceRecords('opportunity',lineItemList[0].id);
        String str = '[{"Id":"/lightning/r/'+historyList[0].Id+'/view"}]';
        CreateOppProductHistory_Cont.updateOpportunityProductHistoryRecords(str,'Closed Won','Price');
    }
}