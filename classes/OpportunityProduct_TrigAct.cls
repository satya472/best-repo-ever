/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 12-Oct-2018
* Description: Custom OpportunityProduct_TrigAct
* 
*/
public class OpportunityProduct_TrigAct extends TriggerHandler 
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
    }
     /*
    * Fire logic for beforeDelete context
    */
    public override void beforeDelete(TriggerContext context) 
    {
        List<OpportunityLineItem> oppProdList = context.oldList;
        CreateOppProductHistory_Cont.createOppProdHistoryRecords(oppProdList);
    }
    
    /*
    * Fire logic for afterDelete context
    */
    public override void afterDelete(TriggerContext context) 
    {
    }
        
}