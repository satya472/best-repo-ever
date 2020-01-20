/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 21-June-18
* Description: Test class for ServiceExpEngine controller
* 
*/
@isTest
public class ServiceExpEngine_Test 
{
    @testSetup
    static void setupTestData() 
	{        
		Account acct = new Account(name='Test Account');
		insert acct;
		opportunity opp = new Opportunity(Name= 'Opportunity',StageName='Qualifying',CloseDate=System.today().addMonths(1), AccountId=acct.Id);
		insert opp;
		Price_Experience__c priceExp =  new Price_Experience__c(Name='Test PE',Competitor_Account__c=acct.Id,Opportunity__c=opp.Id);
		insert priceExp;
        PriceExperienceLine__c explineRec;
		List<PriceExperienceLine__c> lstPriceExpLines = new List<PriceExperienceLine__c>();
        for(Integer i=0;i<3;i++)
        {
            explineRec = new PriceExperienceLine__c();
            explineRec.Name = 'ProdLine '+ i;
            explineRec.PriceExperienceId__c = priceExp.id;
            explineRec.ProductName__c= 'ProdLine '+ i;
            explineRec.ProductPrice__c = '100';
            lstPriceExpLines.add(explineRec);
        }
        insert lstPriceExpLines;
		OpportunityCompetition__c oppComp = new OpportunityCompetition__c( CompetitorAccount__c=acct.ID,Opportunity__c=opp.Id);
		insert oppComp;
    }    
    
    public static testmethod void NoExpRecsforComp()
    {
        test.startTest();
        //directly call the getCompData method
        opportunity opp = [Select Id,StageName from Opportunity where StageName ='Qualifying'];
        Price_Experience__c priceExp = [Select Id,Name,Opportunity__c from Price_Experience__c where Name = 'Test PE'];
        system.assertEquals(priceExp.Opportunity__c, opp.Id);
                
        ServiceExpEngine.getCompData(priceExp.Id);
        test.stopTest();
    }
    
    public static testmethod void ExpRecsforComp()
    {
        test.startTest();
        //directly call the getCompData method
        opportunity opp = [Select Id,StageName from Opportunity where StageName ='Qualifying'];
        Price_Experience__c priceExp = [Select Id,Name,Opportunity__c from Price_Experience__c where Name = 'Test PE'];
        system.assertEquals(priceExp.Opportunity__c, opp.Id);
        
        OpportunityCompetition__c oppComp = [Select Name,CompetitorAccount__c from OpportunityCompetition__c ];
		        
		Price_Experience__c priceExpRec = new Price_Experience__c();
        priceExpRec.ConfidenceLevel__c = '20%';
        priceExpRec.Siemens_Price_Experience__c = priceExp.Id;
        priceExpRec.Competitor_Account__c = oppComp.CompetitorAccount__c;
        priceExpRec.CompetitorPricingSource__c = 'Rumor';
        priceExpRec.Opportunity__c = opp.Id;
        insert priceExpRec;
        
        ServiceExpEngine.getCompData(priceExp.Id);
        
        PriceExperienceLine__c explineRec;
        List<PriceExperienceLine__c> lstPriceExpLines = new List<PriceExperienceLine__c>();
        for(Integer i=0;i<2;i++)
        {
            explineRec = new PriceExperienceLine__c();
            explineRec.Name = 'ProdLine '+ i;
            explineRec.PriceExperienceId__c = priceExpRec.id;
            explineRec.ProductName__c= 'ProdLine '+ i;
            explineRec.ProductPrice__c = '100';
            lstPriceExpLines.add(explineRec);
        }
        insert lstPriceExpLines;
        
        List<Price_Experience__c> lstPriceExp = [Select Siemens_Price_Experience__c,Competitor_Account__c,Competitor_Account__r.Name,
                                                        Opportunity__c,CompetitorPricingSource__c,ConfidenceLevel__c
                                                    	from Price_Experience__c 
                                                        where Siemens_Price_Experience__c = : priceExp.Id];
		system.assert(lstPriceExp.size() > 0); 
        
        
        ServiceExpEngine.getPicklistOptions('Price_Experience__c', 'CompetitorPricingSource__c');
        
        List<ServiceExpEngine.PriceExperienceWrapper> lstWrapper = ServiceExpEngine.getCompData(priceExp.Id);        
        system.assertEquals(lstWrapper[0].CompetitorName,'Test Account');
        test.stopTest();
    }
    
    public static testmethod void UpsertRecords()
    {
        test.startTest();
        opportunity opp = [Select Id,StageName from Opportunity where StageName ='Qualifying'];
        Price_Experience__c priceExp = [Select Id,Name,Opportunity__c from Price_Experience__c where Name = 'Test PE'];
        system.assertEquals(priceExp.Opportunity__c, opp.Id);
        
        String jsonString = '[{"CompetitorName":"Test Site","NewExpLineWrapper":[{"NewProductLine":{"PriceExperienceId__c":"a3L0E000000UQTjUAO","ProductName__c":"ProductName2","ProductPrice__c":"800","Id":"a3V0E000000D7i9UAC"},"RelatedProductPrice":"700"},{"NewProductLine":{"PriceExperienceId__c":"a3L0E000000UQTjUAO","ProductPrice__c":"0","ProductName__c":"Test Product1"},"RelatedProductPrice":"720"},{"NewProductLine":{"PriceExperienceId__c":"a3L0E000000UQTjUAO","ProductPrice__c":"0","ProductName__c":"Test Product3"},"RelatedProductPrice":"600"}],"NewPriceExp":{"Siemens_Price_Experience__c":"a3L0E000000TuKfUAK","Competitor_Account__c":"0010E00000LYdR7QAL","CompetitorPricingSource__c":"Internal Estimation","ConfidenceLevel__c":"20%","Id":"a3L0E000000UQTjUAO","Competitor_Account__r":{"Name":"Test Site","Id":"0010E00000LYdR7QAL"}},"PriceExpId":"a3L0E000000TuKfUAK","ProductNames":["ProductName2","Test Product1","Test Product3"],"RelatedPriceExpLines":[{"Id":"a3V0E000000D6wrUAC","PriceExperienceId__c":"a3L0E000000TuKfUAK","ProductName__c":"ProductName2","ProductPrice__c":"700"},{"Id":"a3V0E000000D7LDUA0","PriceExperienceId__c":"a3L0E000000TuKfUAK","ProductName__c":"Test Product1","ProductPrice__c":"720"},{"Id":"a3V0E000000D6wmUAC","PriceExperienceId__c":"a3L0E000000TuKfUAK","ProductName__c":"Test Product3","ProductPrice__c":"600"}]}]';
        
        OpportunityCompetition__c oppComp = [Select Name,CompetitorAccount__c from OpportunityCompetition__c ];
		        
		Price_Experience__c priceExpRec = new Price_Experience__c();
        priceExpRec.ConfidenceLevel__c = '20%';
        priceExpRec.Siemens_Price_Experience__c = priceExp.Id;
        priceExpRec.Competitor_Account__c = oppComp.CompetitorAccount__c;
        priceExpRec.CompetitorPricingSource__c = 'Rumor';
        priceExpRec.Opportunity__c = opp.Id;
        insert priceExpRec;
        
        ServiceExpEngine.getCompData(priceExp.Id);
        
        PriceExperienceLine__c explineRec;
        List<PriceExperienceLine__c> lstPriceExpLines = new List<PriceExperienceLine__c>();
        PriceExplineWrapper temp;
        List<PriceExplineWrapper> priceExpLinelist = new  List<PriceExplineWrapper> ();
        for(Integer i=0;i<2;i++)
        {
            explineRec = new PriceExperienceLine__c();
            explineRec.Name = 'ProdLine '+ i;
            explineRec.PriceExperienceId__c = priceExpRec.id;
            explineRec.ProductName__c= 'ProdLine '+ i;
            explineRec.ProductPrice__c = '100';
            lstPriceExpLines.add(explineRec);
            
            temp=new PriceExplineWrapper(explineRec,'100');
            priceExpLinelist.add(temp);
        }
        insert lstPriceExpLines;
        
        //create wrapper to pass to the upsert method
        List<PriceExperienceLine__c> lstPriceExp = [Select ProductName__c,ProductPrice__c,PriceExperienceId__c from PriceExperienceLine__c 
                                                    where PriceExperienceId__c = :priceExp.Id];
        ServiceExpEngine.PriceExperienceWrapper serviceExpWrapper = new ServiceExpEngine.PriceExperienceWrapper();
        serviceExpWrapper.CompetitorName = 'Test Account';
        serviceExpWrapper.NewPriceExp = priceExp;
        serviceExpWrapper.RelatedPriceExpLines = lstPriceExp;
        serviceExpWrapper.NewExpLineWrapper = priceExpLinelist;
        
       List<ServiceExpEngine.PriceExperienceWrapper> listUpserted = ServiceExpEngine.UpsertPriceExperience(jsonString);        
        
        test.stopTest();
    }
    

}