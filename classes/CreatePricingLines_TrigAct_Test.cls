/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 21-June-18
* Description: Test class for CreatePricingLines_TrigAct controller
* 
*/
@isTest
public class CreatePricingLines_TrigAct_Test {

    @testSetup
    static void setupTestData() 
	{        
		Account acct = new Account(name='Test Account');
		insert acct;
		opportunity opp = new Opportunity(Name= 'Opportunity',StageName='Qualifying',CloseDate=System.today().addMonths(1), AccountId=acct.Id);
		insert opp;
        
        string plantAssetId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        
        Asset assetObj= new Asset();
        assetObj.name= 'test Plant Asset';
        assetObj.AccountId= acct.Id;
        assetObj.recordtypeId= plantAssetId;
        insert assetObj;
		//Asset asst = new Asset(Name = 'Test Asset',AccountId=acct.Id);
		//insert asst;
		Product2 prd = new Product2(Name = 'Test Product',Asset__c=assetObj.Id);
		insert prd;
		
		Contract cont = new Contract(Name = 'Test Contract',AccountId =acct.Id);
		insert cont;
		SBQQ__ContractedPrice__c conPrice = new SBQQ__ContractedPrice__c(SBQQ__Account__c = acct.Id,SBQQ__Contract__c = cont.Id,
                                                                         SBQQ__Discount__c=10,SBQQ__Product__c = prd.Id);
		insert conPrice;
		//SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__Account__c = acct.Id,SBQQ__Opportunity2__c = opp.Id);
		//insert quoteRec;
		
        SBQQ__Quote__c primaryQuote= new SBQQ__Quote__c();
        primaryQuote.SBQQ__Primary__c=true;
        primaryQuote.SBQQ__Account__c= acct.Id;
        primaryQuote.SBQQ__Opportunity2__c= opp.id;
        primaryQuote.SBQQ__PaymentTerms__c='Net 30';
        primaryQuote.Tool_Provision_Rate__c=2.7;
        primaryQuote.Tool_Weekly_Rate__c=1.8;
        //primaryQuote.SBQQ__PricebookId__c='01s0E000000JKCM';
 
        insert primaryQuote;
 		SBQQ.TriggerControl.disable();       
        SBQQ__QuoteLine__c quoteLineItem= new SBQQ__QuoteLine__c();

        quoteLineItem.SBQQ__Quote__c= primaryQuote.id;
        quoteLineItem.SBQQ__RenewedAsset__c = assetObj.id;
        quoteLineItem.SBQQ__PricingMethod__c= 'List';
        quoteLineItem.SBQQ__Description__c='Some text';
        quoteLineItem.SBQQ__SpecialPriceType__c= 'Contracted Price';
        quoteLineItem.SBQQ__SubscriptionScope__c='Quote';
          
        insert quoteLineItem;
        
		//SBQQ__QuoteLine__c quoteLineRec = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quoteRec.Id,SBQQ__Product__c=prd.Id,Asset__c=asst.Id,
          //                                                      SBQQ__ContractedPrice__c =conPrice.Id );
		//insert quoteLineRec;
		
		Price_Experience__c priceExp =  new Price_Experience__c(Name='Test PE',Competitor_Account__c=acct.Id,Opportunity__c=opp.Id,QuoteId__c=primaryQuote.Id);
		insert priceExp;
        
    }    
    
    
    
    public static testmethod void ExpRecsforComp()
    {
        test.startTest();
        //directly call the getCompData method
        opportunity opp = [Select Id,StageName from Opportunity where StageName ='Qualifying'];
        Price_Experience__c priceExp = [Select Id,Name,Opportunity__c from Price_Experience__c where Name = 'Test PE'];
        system.assertEquals(priceExp.Opportunity__c, opp.Id);
        
    }
}