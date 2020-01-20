/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 9-April-2018
* Description: CreateLOAReportTeamFromApprovers_TrigAct overrides handler functionality to update   
*              the LOA Risk Report Team Members with the Approval Gate Approvers
* 
*/
public class CreateLOAReportTeamFromApprovers_TrigAct extends TriggerHandler{
    /*
* @description:Copy Approval Gate Approvers to LoA Risk Report Team Members
*/
    public override void beforeInsert(TriggerContext context)
    {
        
        if (!this.hasRun())
        {           
            List<LOAReportTeam__c> targetRecordList = new List<LOAReportTeam__c>();
            Map<Id, List<LOAApprovalTopics__c>> sourceTargetObjectMap = new Map<Id, List<LOAApprovalTopics__c>>();
            List<Id> loaReportLIdList = new List<Id>();
            List<Id> quoteIdList = new List<Id>();
            
            List<LOAApprovalTopics__c> loaApprovalTopicsList =  context.newList;
            for(LOAApprovalTopics__c entity : loaApprovalTopicsList){
                quoteIdList.add(entity.QuoteId__c);
                if(entity.LoAApprovalGateIDTxT__c != null||entity.ApprovalGateId__c != null){
                    Id approvalGateId = entity.LoAApprovalGateIDTxT__c != null ? entity.LoAApprovalGateIDTxT__c : entity.ApprovalGateId__c;
                    List<LOAApprovalTopics__c> approvalTopicslst = sourceTargetObjectMap.get(approvalGateId);
                    if(approvalTopicslst == null)
                        approvalTopicslst = new List<LOAApprovalTopics__c>();
                    entity.ApprovalGateId__c = approvalGateId;
                    approvalTopicslst.add(entity);
                    sourceTargetObjectMap.put(approvalGateId,approvalTopicslst);
                }
            }
            
            //get the related report id; if it doesnt exist create
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>([SELECT Id, Name, LOA_Report__c,LOA_Report__r.Id 
                                                                       FROM SBQQ__Quote__c WHERE ID IN :quoteIdList]);
            Map<Id, Id> quoteReportIdMap = new Map<Id,Id>();
            List<LOAReport__c> createLOAReportList = new List<LOAReport__c>();
            
            for(SBQQ__Quote__c quote : quoteList){
                if(quote.LOA_Report__c == null){
                    createLOAReportList.add(new LOAReport__c(Name = quote.Name+' LOA Report',QuoteId__c = quote.Id, Status__c = 'Draft'));
                    quoteReportIdMap.put(quote.Id, null);
                }else
                    quoteReportIdMap.put(quote.Id, quote.LOA_Report__r.Id);
                
            }
            insert createLOAReportList;
            
            for (LOAReport__c loaRep: createLOAReportList){
                quoteReportIdMap.put(loaRep.QuoteId__c,loaRep.Id );
            }
            system.debug('### quoteReportIdMap :'+quoteReportIdMap);
            //get the LOA Approval Gate
            Map<Id,LOAApprovalGate__c> loaApprovalGateMap = new Map<Id,LOAApprovalGate__c>([SELECT Name, Business_Unit__c, OwnerId, Segment__c 
                                                                                            FROM LOAApprovalGate__c WHERE ID IN :sourceTargetObjectMap.keyset()]);
            //get the LOA Approval Gate Step		
            List<LOAApproval_Gate_Step__c> loaApprovalStepList = new List<LOAApproval_Gate_Step__c>([SELECT Id, Approval_Gate__c, LOA_Report__c ,Approval_Gate_ID_txt__c
                                                                                                     FROM LOAApproval_Gate_Step__c 
                                                                                                     WHERE Approval_Gate_ID_txt__c IN :sourceTargetObjectMap.keyset()
                                                                                                     AND LOA_Report__c IN :quoteReportIdMap.values()]);	
            
            //create the LOA Approval Step if it does not exist
            List<LOAApproval_Gate_Step__c> createLoAGateStepList = new List<LOAApproval_Gate_Step__c>();
            Map<Id,Id> loaApprovalStepMap = new Map<Id,Id>();

            system.debug('loaApprovalStepList: '+loaApprovalStepList);
            if(loaApprovalStepList.size() == 0){
                for(Id approvalGateId : sourceTargetObjectMap.keyset()){
                    for(LOAApprovalTopics__c approvalTopic : sourceTargetObjectMap.get(approvalGateId)){
                        if(!loaApprovalStepMap.containsKey(approvalGateId)) {
                            LOAApproval_Gate_Step__c newGateStep = new LOAApproval_Gate_Step__c();
                            newGateStep.Approval_Gate_ID_txt__c = approvalGateId;// approvalTopic.ApprovalGateId__c;
                            newGateStep.Approval_Gate__c = loaApprovalGateMap.get(approvalGateId).Name;
                            newGateStep.Name = loaApprovalGateMap.get(approvalGateId).Name;
                            newGateStep.OwnerId = loaApprovalGateMap.get(approvalGateId).OwnerId;
                            newGateStep.Approver_Level__c = loaApprovalGateMap.get(approvalGateId).Segment__c;
                            system.debug('## quoteReportIdMap.get(approvalTopic.QuoteId__c) :' + quoteReportIdMap.get(approvalTopic.QuoteId__c));
                            newGateStep.LOA_Report__c = quoteReportIdMap.get(approvalTopic.QuoteId__c);
                            newGateStep.Status__c = 'Open';
                            createLoAGateStepList.add(newGateStep);
                            loaApprovalStepMap.put(approvalGateId ,null);
                        }
                    }
                }
                insert createLoAGateStepList;
            }

            system.debug('createLoAGateStepList: '+createLoAGateStepList);
            
            loaApprovalStepList.addAll(createLoAGateStepList);
            for(LOAApproval_Gate_Step__c gateStep:loaApprovalStepList){
                 loaApprovalStepMap.put(gateStep.Approval_Gate_ID_txt__c,gateStep.Id);
            }
            system.debug('loaApprovalStepMap: '+loaApprovalStepMap);
            
            sourceTargetObjectMap.clear();
            //get the relevant data from the context list
            for(LOAApprovalTopics__c entity : loaApprovalTopicsList)
            {
                if(entity.LoAApprovalGateIDTxT__c != null||entity.ApprovalGateId__c != null){
                    Id approvalGateId = entity.LoAApprovalGateIDTxT__c != null ? entity.LoAApprovalGateIDTxT__c : entity.ApprovalGateId__c;
                    List<LOAApprovalTopics__c> approvalTopicslst = sourceTargetObjectMap.get(approvalGateId);
                    if(approvalTopicslst == null)
                        approvalTopicslst = new List<LOAApprovalTopics__c>();
                    if(entity.LOAReportId__c == null){
                        entity.LOAReportId__c = quoteReportIdMap.get(entity.QuoteId__c);
                    }
                    entity.ApprovalGateId__c = approvalGateId;
                    entity.Approval_Gate_Step__c = loaApprovalStepMap.get(approvalGateId);
                    loaReportLIdList.add(entity.LOAReportId__c);
                    approvalTopicslst.add(entity);
                    sourceTargetObjectMap.put(approvalGateId,approvalTopicslst);
                }
            }   
            
            //get the list of the approvers for approval gate
            List<LOAApprover__c> sourceRecordList = [SELECT LOAApprovalGateId__c, ApproverType__c, UserId__c 
                                                     FROM LOAApprover__c WHERE LOAApprovalGateId__c IN :sourceTargetObjectMap.keyset()];
            
            //get the related LOA Report Team Members
            List<LOAReportTeam__c> loaReportTeamList = [SELECT Id, LOAReportId__c, UserId__c, Approver__c, ApprovalGate__c, InternalUpsertID__c 
                                                        FROM LOAReportTeam__c WHERE LOAReportId__c IN :loaReportLIdList];         
            
            //get the source-target object field mappings
            List<CloneRelatedRecord__mdt> fieldMappingList = CloneRelatedRecord_Util.fetchAllFieldMappings('CreateLOAReportTeamFromApprovers');
            
            List<LOAReportTeam__c> resultList =  new List<LOAReportTeam__c> ();
            if(!sourceRecordList.isEmpty() && !fieldMappingList.isEmpty())
            {           
                resultList = (List<LOAReportTeam__c>)CloneRelatedRecord_Util.createTargetRecordList(sourceTargetObjectMap, sourceRecordList,
                                                                                                    fieldMappingList, 'LOAReportTeam__c','LOAApprovalGateId__c');
            } 
            targetRecordList.addAll(resultList);
            //system.debug(' targetRecordList :'+targetRecordList);           
            
            //persist records to the database
            if(!targetRecordList.isEmpty())
            {
                try{
                    upsert targetRecordList InternalUpsertID__c;
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