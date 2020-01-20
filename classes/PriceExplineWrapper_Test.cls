/*
 * 
 
*/
@isTest
public class PriceExplineWrapper_Test
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
        
    }    
    
    public static testmethod void SortRecords()
    {
        test.startTest();
        Price_Experience__c priceExp = [Select Id,Name,Opportunity__c from Price_Experience__c where Name = 'Test PE'];
        opportunity opp = [Select Id,StageName from Opportunity where StageName ='Qualifying'];
        system.assertEquals(priceExp.Opportunity__c, opp.Id);        
        
        PriceExperienceLine__c explineRec;
        
        PriceExplineWrapper temp;
        List<PriceExplineWrapper> priceExpLinelist = new  List<PriceExplineWrapper> ();
        for(Integer i=0;i<2;i++)
        {
            explineRec = new PriceExperienceLine__c();
            explineRec.Name = 'ProdLine '+ i;
            explineRec.PriceExperienceId__c = priceExp.id;
            explineRec.ProductName__c= 'ProdLine '+ i;
            explineRec.ProductPrice__c = '100';
            
            temp=new PriceExplineWrapper(explineRec,'100');
            priceExpLinelist.add(temp);
        }
        priceExpLinelist.sort();
        test.stopTest();
    }
    

}