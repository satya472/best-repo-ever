/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 16-Oct-2018
* Description: Custom OpportunityProduct_TrigAct handler for Opportunity Trigger
* 
*/
public class OpportunityTrigger_TrigAct extends TriggerHandler 
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
    }
     /*
    * Fire logic for beforeUpdate context
    */
    public override void beforeUpdate(TriggerContext context) 
    {
        
    }
    
    /*
    * Fire logic for afterupdate context
    */
    public override void afterUpdate(TriggerContext context)
    {
		//List<Opportunity> oldEntities = context.oldList;
		//List<Opportunity> newEntities = context.oldList;
		//Map<id,String> oldStatusMap = ;
		set<id> oppIds = new set<id>();
		List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
		Map<id,List<OpportunityLineItem>> oppLineItemsMap = new Map<id,List<OpportunityLineItem>>();
		List<OpportunityProductHistory__c> historyRecs = new List<OpportunityProductHistory__c>();
		try
		{
			for(opportunity opp:(List<opportunity>)context.newList)
			{
				opportunity oldOpp =  (opportunity)context.oldMap.get(opp.Id);
                system.debug(' oldOpp rec to be processed: '+oldOpp);
				if(!oldOpp.StageName.contains('Closed') && opp.StageName.contains('Closed'))
				{
					oppIds.add(oldOpp.id);
				}
			}
            
			for( OpportunityLineItem lineItem : [Select id,Name,Product2Id,ListPrice,Opportunity.Asset__c,Opportunity.StageName,Opportunity.WonLostReason__c
													     FROM OpportunityLineItem where OpportunityId IN :oppIds])
			{
				if(!oppLineItemsMap.containskey(lineItem.Id) )
                {
                    oppLineItemsMap.put(lineItem.Id,new List<OpportunityLineItem>{lineItem});
                }
                else
                {
                    lineItemList = oppLineItemsMap.get(lineItem.Id);
                    lineItemList.add(lineItem);
                    oppLineItemsMap.put(lineItem.Id,lineItemList);
                }
			}
			set<id> lineItemSet = oppLineItemsMap.keySet();
            system.debug(' opp keys: '+lineItemSet);
			for(Id oppId: lineItemSet )
			{
				List<OpportunityLineItem> oppProductsList = oppLineItemsMap.get(oppId);
				for(OpportunityLineItem lineEntity : oppProductsList)
				{
					OpportunityProductHistory__c hisRec = new OpportunityProductHistory__c();
					//copy product,asset and price
					hisRec.AssetId__c = lineEntity.Opportunity.Asset__c;
					hisRec.ProductId__c = lineEntity.Product2Id;
					hisRec.Price__c = lineEntity.ListPrice;
					hisRec.Stage__c = lineEntity.Opportunity.StageName;
					hisRec.WonLostReason__c = lineEntity.Opportunity.WonLostReason__c;
					hisRec.OpportunityId__c = oppId;
					historyRecs.add(hisRec);
				}
			}
			
			if(!historyRecs.isEmpty())
			{
				system.debug(' historyRecs has: '+historyRecs);
				insert historyRecs;
			}
		}
		catch(Exception e){
            System.debug(' Insertion on Opportunity Failed: '+e.getMessage());
        }
    }
     /*
    * Fire logic for beforeDelete context
    */
    public override void beforeDelete(TriggerContext context) 
    {
        //List<Asset> assetEntities = context.oldList;
        //CreateOppProductHistory_Cont.createOppProdHistoryRecords(assetEntities);
    }
    
    /*
    * Fire logic for afterDelete context
    */
    public override void afterDelete(TriggerContext context) 
    {
    }
        
}