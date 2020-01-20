@IsTest
public with sharing class TreeMapControllerTest {
    
   @testSetup
    static void setupTestData() {
               
        //user creation
        Profile profId= [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        String orgId = UserInfo.getOrganizationId();
        String dateString= String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser= new User(  firstname = 'test',
                lastName = 'user',
                email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = profId.id
            );
        insert tuser;
        
        List<Product2> prodLst = new List<Product2>();
        for(Integer i=0;i<10;i++){
         Product2 prod = new Product2();
         prod.Name = 'TestTreeMap Prod'+i;
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
        
        Pricebook2 newPriceBook = new Pricebook2(Name='Treemap PriceBook', isActive=True);
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

        // add accounts
        List<Account> accList = new List<Account>();
        Account parentAcc = new Account( Name='Test Account', billingCountry='United States',Price_Book__c = newPriceBook.Id);
        accList.add(parentAcc);
        insert accList;
        
        Account childAcc= new Account( Name='Child Test Account', ParentId=parentAcc.id, Type='Site',Price_Book__c = newPriceBook.Id);
        insert childAcc; 
            
        List<Opportunity> oppsList = new List<Opportunity>();        
                  
        oppsList.add(new Opportunity(Name= childAcc.Name+ ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 
      
        insert oppsList;
        
        Intelligence__c cstIntelligence= new Intelligence__c();
        cstIntelligence.Opportunity__c= oppsList[0].id;
        cstIntelligence.Title__c ='lesson name';
        cstIntelligence.IntelligenceType__c = 'Price Intelligence';
        cstIntelligence.CompetitorPrice__c = 200.00;
        
        insert cstIntelligence;
        
        OpportunityCompetition__c oppComp= new OpportunityCompetition__c();
        oppComp.CompetitorAccount__c= childAcc.id;
        oppComp.Opportunity__c= oppsList[0].id;
        //oppComp.name='Opp Comp Name';
        insert oppComp;
        
        SBQQ__Quote__c primaryQuote= new SBQQ__Quote__c();
        primaryQuote.SBQQ__Primary__c=true;
        primaryQuote.SBQQ__Account__c= childAcc.Id;
        primaryQuote.SBQQ__Opportunity2__c= oppsList[0].id;
        primaryQuote.SBQQ__PaymentTerms__c='Net 30';
        primaryQuote.Tool_Provision_Rate__c=2.7;
        primaryQuote.Tool_Weekly_Rate__c=1.8;
        primaryQuote.SBQQ__Opportunity2__c = oppsList[0].id;
        //primaryQuote.SBQQ__PricebookId__c='01s0E000000JKCM';
 
        insert primaryQuote;
        
        //update primaryQuote;
        
        //the Id of the quote
		String quoteId = primaryQuote.id;
		//the Id of the product to add to the quote
		String productId = prodLst[0].Id;//'01t0N000008hlBV';
		//the Id of the pricebook for the quote and product being added
		String pricebookId =  newPriceBook.Id;//'01s0E000000JKCM';
		//the currency code
		String currencyCode = 'USD';
		
        string plantAssetId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        string trainAssetId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
        
        Asset assetObj= new Asset();
        assetObj.name= 'test Plant Asset';
        assetObj.AccountId= childAcc.Id;
        assetObj.recordtypeId= plantAssetId;
        insert assetObj;
        
        Asset trainAsset= new Asset();
        trainAsset.name= 'test Train Asset';
        trainAsset.AccountId= childAcc.Id;
        trainAsset.recordtypeId= trainAssetId;
        insert trainAsset;
        
        SBQQ.TriggerControl.disable();

        SBQQ__QuoteLine__c quoteLineItem1= new SBQQ__QuoteLine__c();

        quoteLineItem1.SBQQ__Quote__c= primaryQuote.id;
        quoteLineItem1.SBQQ__RenewedAsset__c = assetObj.id;
        quoteLineItem1.SBQQ__PricingMethod__c= 'List';
        quoteLineItem1.SBQQ__Description__c='Some text';
        quoteLineItem1.SBQQ__SpecialPriceType__c= 'Contracted Price';
        quoteLineItem1.SBQQ__SubscriptionScope__c='Quote';
          
        insert quoteLineItem1;

        
        SBQQ__QuoteLine__c quoteLineItem2= new SBQQ__QuoteLine__c();
        quoteLineItem2.SBQQ__Quote__c= primaryQuote.id;
        quoteLineItem2.Service_Asset__c = trainAsset.id;
        insert quoteLineItem2;
        
        SBQQ__QuoteLine__c quoteLineItem3= new SBQQ__QuoteLine__c();
        quoteLineItem3.SBQQ__Quote__c= primaryQuote.id;
        quoteLineItem3.SBQQ__UpgradedAsset__c = trainAsset.id;
        insert quoteLineItem3;
        
    } 
    
    public static testmethod void getOpportunityCompetitionTest(){
        
        Intelligence__c custInte= [select id, name from Intelligence__c limit 1];
        OpportunityCompetition__c oppComp= [select id, name, CompetitorAccount__c from OpportunityCompetition__c];
        
        string custIntelliId= custInte.id;
        string accountId= oppComp.id;
        string contrlName= System.Label.TreeMapOpportunityCompHelper;
        
        test.startTest();       
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);
            TreeMapController.createExperienceRelation(accountId,custIntelliId,contrlName);
            
            ExperienceRelation__c expRelation= new ExperienceRelation__c();
            expRelation.IntelligenceId__c= custInte.id;
            expRelation.AccountId__c = oppComp.CompetitorAccount__c; 
            expRelation.AccountRelationTyp__c= 'Competitor';        
            insert expRelation;
            
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);          
            TreeMapController.deleteExperienceRelation(accountId,custIntelliId,contrlName);
            TreeMapController.createExperienceRelation('','',contrlName);
            TreeMapController.deleteExperienceRelation(null,null,contrlName);
            
        test.stopTest();
        
    }
    
    public static testmethod void getAccountHierarchyTest(){
        
        Intelligence__c custInte= [select id, name from Intelligence__c limit 1];
        string custIntelliId= custInte.id;
        string contrlName= System.Label.TreeMapAccountHelper;
        
        test.startTest();                   
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);   
            
            account parentAcc= [Select id, name from Account where name='Test Account'];
            
            opportunity opp= [select id, name, AccountId from opportunity];         
            opp.accountId= parentAcc.id;
            update opp; 
            
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);
            TreeMapController.createExperienceRelation(parentAcc.Id,custIntelliId,contrlName);
            
            string accountId= parentAcc.Id + '_Site';
            TreeMapController.createExperienceRelation(accountId,custIntelliId,contrlName);
            
            accountId= parentAcc.Id + '_United States';
            TreeMapController.createExperienceRelation(accountId,custIntelliId,contrlName);
            
            ExperienceRelation__c expRelation= new ExperienceRelation__c();
            expRelation.IntelligenceId__c= custInte.id;
            expRelation.AccountId__c = parentAcc.id; 
            expRelation.AccountRelationTyp__c= 'Customer';          
            insert expRelation;
            
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);
            TreeMapController.deleteExperienceRelation(parentAcc.id,custIntelliId,contrlName);
            
            accountId= parentAcc.Id + '_Site';
            TreeMapController.deleteExperienceRelation(accountId,custIntelliId,contrlName);
            
            TreeMapController.deleteExperienceRelation(null,null,contrlName);
            
        test.stopTest();
        
    }
    
    public static testmethod void getAllAssetsOfOpportunityTest(){
        
        Intelligence__c custInte= [select id, name from Intelligence__c limit 1];
        string custIntelliId= custInte.id;
        string contrlName= System.Label.TreeMapAssetHelper;
        Asset plantAsset= [select id, name from Asset where name='test Plant Asset'];
        test.startTest();                   
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);   

            ExperienceRelation__c expRelation= new ExperienceRelation__c();
            expRelation.IntelligenceId__c= custInte.id;
            expRelation.AssetId__c = plantAsset.id;                     
            insert expRelation;
            
            TreeMapController.getCurrentRecordStatus(custIntelliId,contrlName);
            TreeMapController.createExperienceRelation(plantAsset.id,custIntelliId,contrlName);
            TreeMapController.deleteExperienceRelation(plantAsset.id,custIntelliId,contrlName);
            
            string assetId= plantAsset.Id + '_Plant';
            TreeMapController.createExperienceRelation(assetId,custIntelliId,contrlName);
            TreeMapController.deleteExperienceRelation(assetId,custIntelliId,contrlName);
            
            TreeMapController.createExperienceRelation(null,null,contrlName);            
            TreeMapController.deleteExperienceRelation(null,null,contrlName);
            
            Asset trainAsset= [select id, name, parentId from Asset where name='test Train Asset'];
            trainAsset.parentId= plantAsset.id;
            update trainAsset;
            
            TreeMapController.getCurrentRecordStatus(custInte.id,contrlName);
            TreeMapController.deleteExperienceRelation(assetId,custIntelliId,contrlName);
            TreeMapController.deleteExperienceRelation(assetId,custIntelliId,contrlName);
            
        test.stopTest();
        
    }
    
    public static testmethod void getQuoteLineItemsTest(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
       User usr = new User(Alias = 'TreeMap', Email='Treemap@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='TreeeMap', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='treeMap@orgTest.com');
        
        Account acc = [Select id,name from Account Where Name = 'Child Test Account' LIMIT 1];
        opportunity opp = [Select Id,name from opportunity Where AccountId = :acc.Id LIMIT 1];
        Intelligence__c ci = [Select id,name from Intelligence__c Where Opportunity__c = :opp.Id LIMIT 1];
                
        Test.startTest();
        system.runAs(usr){
            
            List<SBQQ__QuoteLine__c> qli = TreeMapController.getQuoteLineItems(opp.Id, 'Opportunity');
            
            system.assertEquals(3, qli.size());    
                        
            //Updating CustomerIntelligence with the QuoteLineId            
            TreeMapController.updateIntelligenceRecord(ci.Id, qli[0].Id);
            
            ci = [Select id,name,QuoteLineId__c from Intelligence__c Where Opportunity__c = :opp.Id LIMIT 1];
            system.assertEquals(qli[0].Id, ci.QuoteLineId__c);
        }
        
        test.stopTest();
        
    }
       
}