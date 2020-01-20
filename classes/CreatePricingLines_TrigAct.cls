/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 15-June-18
* Description: Trigger handler to Price Experience object to create price lines
Custom CreatePricingLines_TrigAct
* 
*/
public class CreatePricingLines_TrigAct extends TriggerHandler 
{
    
    /*
    ** Fire logic for beforeInsert context
    */
    public override void beforeInsert(TriggerContext context) 
    {
    }

    /*
    * Fire logic for afterinsert context
    */
    public override void afterInsert(TriggerContext context)
    {
        if (!this.hasRun())
        {
            createPricingLineItems(context.newList);
        }  
    }

    /*
    * Fire logic for beforeUpdate context
    */
    public override void beforeUpdate(TriggerContext context) {

    }
    
    /*
    * Fire logic for afterupdate context
    */
    public override void afterUpdate(TriggerContext context)
    {
        
    }
    
    /*
    * Fire logic for beforeDelete context
    */
    public override void beforeDelete(TriggerContext context) 
	{

    }
    
    /*
    * Fire logic for beforeUndelete context
    */
    public override void beforeUndelete(TriggerContext context) 
	{

    }

    /*
    * Fire logic for afterUndelete context
    */
    public override void afterUndelete(TriggerContext context) 
	{

    }
	
    /*
    * Fire logic for finish context
    */
	public override void finish(TriggerContext context) 
    {
    }

    //
    //createPricingLineItems: Create Price Exp Lines for Price exp 
    //
    public  void createPricingLineItems(List<Price_Experience__c> pricingEntities)
    {
        List<PriceExperienceLine__c> priceExpLineList = new List<PriceExperienceLine__c>();
		system.debug(' $$$ In createPricingLineItems ');
        if(pricingEntities != null && !pricingEntities.isEmpty())
        {
            Price_Experience__c pricExp =  pricingEntities[0];
            Id id = pricExp.QuoteId__c;
            List<SBQQ__QuoteLine__c> quoteLineItems = [select id,name ,SBQQ__Product__r.name,SBQQ__ContractedPrice__c 
                                                       from SBQQ__QuoteLine__c where SBQQ__Quote__c = :id ];
            
            if(quoteLineItems != null && !quoteLineItems.isEmpty())
            {
                for(SBQQ__QuoteLine__c lineEntity : quoteLineItems )
                {
                  PriceExperienceLine__c entity = new PriceExperienceLine__c();
                  entity.Name = lineEntity.name;
                  entity.PriceExperienceId__c = pricExp.Id;
                  entity.ProductName__c = lineEntity.SBQQ__Product__r.name;
                  entity.ProductPrice__c = lineEntity.SBQQ__ContractedPrice__c;
                  priceExpLineList.add(entity);
                  
                }
            }
            
            if(!priceExpLineList.isEmpty())
            {
                system.debug(' $$$ priceExpLineList has '+priceExpLineList);
                insert priceExpLineList;
                system.debug(' $$$ After insertion ');
            }
        }
		
    }
}