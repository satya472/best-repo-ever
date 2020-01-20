/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 29-March-2018
* Description: CreateLOAReportTeamFromOpp_TrigAct overrides handler functionality to update   
*              the opportunity team members with the account team members
* 
*/
public class CreateLOAReportTeamFromOpp_TrigAct extends TriggerHandler{
    /*
    * @description:Copy Opportunity Team Members when LOA Report is created
    */
    public override void afterInsert(TriggerContext context)
    {
        
        if (!this.hasRun())
        {           
            //variable declaration 
            Map<Id,List<LOAReport__c>> quoteIdLOAReportMap = new Map<Id,List<LOAReport__c>>();
            Map<Id,List<SObject>> sourceTargetObjectMap = new Map<Id,List<SObject>>();
            List<SObject> targetRecordList = new List<SObject>();
            
            List<LOAReport__c> loaReportEntitiesList = context.newList;
            for(LOAReport__c entity : loaReportEntitiesList)
            {
                if(entity.QuoteId__c != null){
                    List<LOAReport__c> loaReportlst = quoteIdLOAReportMap.get(entity.QuoteId__c);
                    if(loaReportlst == null)
                        loaReportlst = new List<LOAReport__c>();
                    loaReportlst.add(entity);                    
                    quoteIdLOAReportMap.put(entity.QuoteId__c, loaReportlst);
                }
            }
            
            //get the mapping between quote and opportunity
            List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c 
                                          WHERE ID IN :quoteIdLOAReportMap.keySet()];            
            for(SBQQ__Quote__c quote : quoteList){                
                sourceTargetObjectMap.put(quote.SBQQ__Opportunity2__c, quoteIdLOAReportMap.get(quote.Id));
            }
            
            //get the list of the source object records : OpportunityTeamMember 
            List<SObject> sourceRecordList = [SELECT Id, OpportunityId, OpportunityAccessLevel, TeamMemberRole, UserId 
             								  FROM OpportunityTeamMember 
                                              WHERE OpportunityId IN :sourceTargetObjectMap.keySet()];                       
            
            //get the source-target object field mappings
            List<CloneRelatedRecord__mdt> fieldMappingList = CloneRelatedRecord_Util.fetchAllFieldMappings('CreateLOAReportTeamFromOpportunity');
            
            if(!sourceRecordList.isEmpty() && !fieldMappingList.isEmpty())
            {           
				targetRecordList = CloneRelatedRecord_Util.createTargetRecordList(sourceTargetObjectMap, sourceRecordList,
                                                                                  fieldMappingList, 'LOAReportTeam__c','OpportunityId');
            } 
            //system.debug(' targetRecordList :'+targetRecordList);
           
            //persist records to the database
            if(!targetRecordList.isEmpty())
            {
                try{
                    insert targetRecordList;
                    this.markRun();
                }
                Catch(Exception e)
                {
                    System.debug(' Insert Failed on LOA Report Team Member '+e.getMessage());
                }
            }
        }
    }   
}