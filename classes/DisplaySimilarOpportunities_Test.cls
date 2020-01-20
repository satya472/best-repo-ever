/*
*Author: G.Naveen Kumar
*Date:9-Jul-18
*Description: Test class for DisplaySimilarOpportunities
*/
@IsTest
public with sharing class DisplaySimilarOpportunities_Test {
   @testSetup
    static void setupTestData() 
	{      
        // add accounts
        List<Account> accList = new List<Account>();
        Account parentAcc = new Account( Name='Test Account', billingCountry='United States');
        accList.add(parentAcc);
        insert accList;
        
        Account childAcc= new Account( Name='Child Test Account', ParentId=parentAcc.id, Type='Site');
        insert childAcc; 
            
        List<Opportunity> oppsList = new List<Opportunity>();        
                  
        oppsList.add(new Opportunity(Name=  'Main Opportunity ', StageName='Qualifying',Amount = 1110,
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 
		
		oppsList.add(new Opportunity(Name=  'Amount Opportunity ', StageName='Qualifying',Amount = 1116,
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 
		
		oppsList.add(new Opportunity(Name=  'Product Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id));
		
		oppsList.add(new Opportunity(Name=  'Asset Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 
      
        insert oppsList;
        
        Product2 prod = new Product2(Name = 'Test Product',ProductCode = 'TEST',isActive = true);
		insert prod;
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
		
        SBQQ__Quote__c primaryQuote= new SBQQ__Quote__c();
        primaryQuote.SBQQ__Primary__c=true;
        primaryQuote.SBQQ__Account__c= childAcc.Id;
        primaryQuote.SBQQ__Opportunity2__c= oppsList[0].id;
        primaryQuote.SBQQ__PaymentTerms__c='Net 30';
        primaryQuote.Tool_Provision_Rate__c=2.7;
        primaryQuote.Tool_Weekly_Rate__c=1.8;
        
		SBQQ__Quote__c primaryProdQuote= new SBQQ__Quote__c();
        primaryProdQuote.SBQQ__Primary__c=true;
        primaryProdQuote.SBQQ__Account__c= childAcc.Id;
        primaryProdQuote.SBQQ__Opportunity2__c= oppsList[2].id;
        primaryProdQuote.SBQQ__PaymentTerms__c='Net 30';
        primaryProdQuote.Tool_Provision_Rate__c=2.7;
        primaryProdQuote.Tool_Weekly_Rate__c=1.8;

		SBQQ__Quote__c primaryAssetQuote= new SBQQ__Quote__c();
        primaryAssetQuote.SBQQ__Primary__c=true;
        primaryAssetQuote.SBQQ__Account__c= childAcc.Id;
        primaryAssetQuote.SBQQ__Opportunity2__c= oppsList[3].id;
        primaryAssetQuote.SBQQ__PaymentTerms__c='Net 30';
        primaryAssetQuote.Tool_Provision_Rate__c=2.7;
        primaryAssetQuote.Tool_Weekly_Rate__c=1.8;
		
		quoteList.add(primaryQuote);
		quoteList.add(primaryProdQuote);
		quoteList.add(primaryAssetQuote);
		insert quoteList;
        
        //the currency code
		String currencyCode = 'USD';
		
        string equipAssetMainId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        string equipAssetOppId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        
        Asset assetObj= new Asset();
        assetObj.name= 'test Plant Asset';
        assetObj.AccountId= childAcc.Id;
        assetObj.recordtypeId= equipAssetMainId;
		assetObj.Frame__c = 'Test Frame';
        insert assetObj;
        
        Asset equipAsset = new Asset();
        equipAsset.name= 'test Train Asset';
        equipAsset.AccountId= childAcc.Id;
        equipAsset.recordtypeId= equipAssetOppId;
		equipAsset.Frame__c = 'Test Frame';
        insert equipAsset;
        
        SBQQ.TriggerControl.disable();
		List<SBQQ__QuoteLine__c> quoLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineItem1= new SBQQ__QuoteLine__c();

        quoteLineItem1.SBQQ__Quote__c= primaryQuote.id;
        quoteLineItem1.SBQQ__Product__c = prod.id;
        quoteLineItem1.SBQQ__PricingMethod__c= 'List';
        quoteLineItem1.SBQQ__Description__c='Some text';
        quoteLineItem1.SBQQ__SpecialPriceType__c= 'Contracted Price';
        quoteLineItem1.SBQQ__SubscriptionScope__c='Quote';
		
		SBQQ__QuoteLine__c quoteLineItem2= new SBQQ__QuoteLine__c();

        quoteLineItem2.SBQQ__Quote__c= primaryQuote.id;
        quoteLineItem2.SBQQ__Product__c = prod.id;
        quoteLineItem2.SBQQ__PricingMethod__c= 'List';
        quoteLineItem2.SBQQ__Description__c='Some text';
        quoteLineItem2.SBQQ__SpecialPriceType__c= 'Contracted Price';
        quoteLineItem2.SBQQ__SubscriptionScope__c='Quote';
		quoteLineItem2.Service_Asset__c = assetObj.id;
         
		quoLineList.add(quoteLineItem1);
		quoLineList.add(quoteLineItem2);
        
        SBQQ__QuoteLine__c quoteLineProduct= new SBQQ__QuoteLine__c();
        quoteLineProduct.SBQQ__Quote__c= primaryProdQuote.id;
		quoteLineProduct.SBQQ__Product__c = prod.id;
                
        SBQQ__QuoteLine__c quoteLineAsset= new SBQQ__QuoteLine__c();
        quoteLineAsset.SBQQ__Quote__c= primaryAssetQuote.id;
        quoteLineAsset.SBQQ__UpgradedAsset__c = equipAsset.id;
        
		quoLineList.add(quoteLineProduct);
		quoLineList.add(quoteLineAsset);
		
		insert quoLineList;
		
		LOAReport__c loaRec = new LOAReport__c(Name='Test Loa',QuoteId__c=primaryQuote.id);
		insert loaRec;

    } 
    
    public static testmethod void getOpportunityCompetitionTest()
	{
        List<opportunity> oppList =[Select id,name from opportunity ];
		system.assert(oppList.size() > 0);
		List<LOAReport__c> loaList = [Select id,Name FROM LOAReport__c where Name = 'Test Loa'];
		system.assertEquals('Test Loa',loaList[0].Name);
        
		test.startTest();
        DisplaySimilarOpportunities.lightningTableWrapper  lst= new DisplaySimilarOpportunities.lightningTableWrapper();
        DisplaySimilarOpportunities.lightningTableWrapper  lst2= new DisplaySimilarOpportunities.lightningTableWrapper();
		lst = DisplaySimilarOpportunities.fetchSimilarOpportunities(loaList[0].Id,'LOAReport__c');
        lst2 = DisplaySimilarOpportunities.fetchSimilarOpportunities(oppList[0].Id,'opportunity');
        List<DisplaySimilarOpportunities.lightningTableColumnWrapper> lstWrap = DisplaySimilarOpportunities.getFieldDetails('SimilarOpportunities');
        system.assert(lstWrap.Size() > 0 );
        test.stopTest();
        
    }
    
    public static testmethod void createSimilarOpportunityTest()
    {
        List<opportunity> oppList =[Select id,name from opportunity ];
        List<LOAReport__c> loaList = [Select id,Name FROM LOAReport__c where Name = 'Test Loa'];
        String str = '[{"Id":"/lightning/r/'+oppList[0].Id+'/view"}]';
        DisplaySimilarOpportunities.createSimilarOpportunities(str,loaList[0].Id,'LOAReport__c');
        DisplaySimilarOpportunities.createSimilarOpportunities(str,oppList[0].Id,'opportunity');
        List<SimilarOpportunity__c> similarOpps = [Select id,Name FROM SimilarOpportunity__c];
        system.assert(similarOpps.size() >0);
        
    }

}