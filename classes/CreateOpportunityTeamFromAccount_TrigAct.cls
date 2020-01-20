/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 29-March-2018
* Description: CreateOpportunityTeamFromAccount_TrigAct overrides handler functionality to update   
*              the opportunity team members with the account team members
*/

public class CreateOpportunityTeamFromAccount_TrigAct extends TriggerHandler {
	 
    /*
    * @description:Copy Account Team Members when Opportunity is created
    */
    public override void afterInsert(TriggerContext context)
    {
        
        if (!this.hasRun())
        {           
            //variable declaration  
            Map<Id,List<Opportunity>> accountOppMap = new Map<Id,List<Opportunity>>();
            Map<Id,List<SObject>> sourceTargetObjectMap = new Map<Id,List<SObject>>();
            List<SObject> targetRecordList = new List<SObject>();
            
            List<Opportunity> opptyEntitiesList = context.newList;
            for(Opportunity entity : opptyEntitiesList)
            {
                if(entity.AccountId != null){
                    List<Opportunity> opplst = accountOppMap.get(entity.AccountId);
                    if(opplst == null)
                        opplst = new List<Opportunity>();
                    opplst.add(entity);
                    accountOppMap.put(entity.accountId,opplst);
                }
            }
            
            //get the list of the account team members for the AccountId
            List<AccountTeamMember> sourceRecordList = [SELECT Id, AccountId, TeamMemberRole, OpportunityAccessLevel, UserId 
                                              FROM AccountTeamMember WHERE AccountId IN :accountOppMap.keySet()
                                              AND IsDeleted = FALSE];
            
            for(AccountTeamMember sourceRec : sourceRecordList){
				sourceTargetObjectMap.put(sourceRec.Id, accountOppMap.get(sourceRec.AccountId));               
            }
            
            //get the source-target object field mappings
            List<CloneRelatedRecord__mdt> fieldMappingList = CloneRelatedRecord_Util.fetchAllFieldMappings('CreateOpportunityTeamFromAccount');
            
            if(!sourceRecordList.isEmpty() && !fieldMappingList.isEmpty())
            {           
				targetRecordList = CloneRelatedRecord_Util.createTargetRecordList(sourceTargetObjectMap, sourceRecordList,
                                                                                  fieldMappingList, 'OpportunityTeamMember','Id');
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
                    System.debug(' Insert Failed on Opportunity Team Member '+e.getMessage());
                }
            }
        }
    }   
}