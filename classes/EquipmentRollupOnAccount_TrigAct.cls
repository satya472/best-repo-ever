/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 12-March-2018
* Description: EquipmentRollupOnAccount_TrigAct overrides handler functionality to update noofequipments field on 
*              Account when child Equip Asset is created/edited
* 
*/
public class EquipmentRollupOnAccount_TrigAct extends TriggerHandler 
{
     String getLabelName = Label.BipassParentIdConditionForDataUpdate;
    public Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
    //TriggerHandler handlerInstance = new TriggerHandler();
    
    /*
* @description:Update NoofEquipments field on Account when equipment is created
*/
    public override void afterInsert(TriggerContext context)
    {
        
        if (!this.hasRun())
        {
            system.debug(' $$$ in EquipmentRollupOnAccount_TrigAct  after insert ');
            
            Set<Id> accIds = new Set<Id>();
            List<Asset> assetEntities = context.newList;
            for(Asset entity :assetEntities)
            {
                if(entity.AccountId != null && entity.RecordTypeId == assetRecordTypeId){
                    accIds.add(entity.AccountId);
                }
            }
            
            Map<Id,Account> accMap = new Map<Id,Account>([Select NoOfRelatedEquipments__c from Account where id in :accIds]);
            
            if(!accMap.isEmpty())
            {
                for(Asset entityRec :assetEntities)
                {
                    if(accMap.containsKey(entityRec.AccountId))
                    {
                        if(accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c== null)
                        {
                            accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c = 1;
                        }
                        else 
                        {
                            accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c= accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c+ 1;
                            
                        }        
                    }
                }
            }
            if(!accMap.isEmpty())
            {
                try{
                    update accMap.values();
                    this.markRun();
                }
                Catch(Exception e)
                {
                    System.debug(' Update Failed on Account '+e.getMessage());
                }
            }
        }
    }
    
    /*
* @description:Update NoofEquipments field on Account when equipment is edited
*/
    public override void afterupdate(TriggerContext context)
    {
        
        if (!this.hasRun())
        {
            system.debug(' $$$ in EquipmentRollupOnAccount_TrigAct  after insert ');
            
            Set<Id> accIds = new Set<Id>();
            List<Asset> assetEntities = context.newList;
            Set<Id> OldrecordIds = new Set<Id>(); 
            Set<Id> NewrecordIds = new Set<Id>(); 
            Map<Id,Asset> assetOldRecords = (Map<Id,Asset>)context.oldMap;
            
            
            for(Asset entity :assetEntities)
            {
                If(assetOldRecords.get(entity.Id).AccountId != entity.AccountId && entity.RecordTypeId == assetRecordTypeId)
                {
                    accIds.add(entity.AccountId);
                    NewrecordIds.add(entity.AccountId);
                } 
                accIds.add(assetOldRecords.get(entity.Id).AccountId);
                OldrecordIds.add(assetOldRecords.get(entity.Id).AccountId);
            }
            
            
            Map<Id,Account> accMap = new Map<Id,Account>([Select NoOfRelatedEquipments__c from Account where id in :accIds]);
            
            
            if(!accMap.isEmpty())
            {
                for(Asset entity :assetEntities)
                {
                    Id rec = (entity.AccountId != null)?entity.AccountId:null;
                    Id oldRec = (assetOldRecords.get(entity.Id).AccountId != null) ? assetOldRecords.get(entity.Id).AccountId:null;
                     system.debug('*'+OldrecordIds.contains(oldRec));
                    if(OldrecordIds.contains(oldRec) && entity.RecordTypeId == assetRecordTypeId)
                    {
                        system.debug('*');
                        if(accMap.get(oldRec).NoofrelatedEquipments__c != null && accMap.get(oldRec).NoofrelatedEquipments__c > 0)
                        {
                            accMap.get(oldRec).NoofrelatedEquipments__c= accMap.get(oldRec).NoofrelatedEquipments__c- 1;
                            
                        }
                    }
                    if(NewrecordIds.contains(rec) && entity.RecordTypeId == assetRecordTypeId)
                    {
                        if(accMap.get(rec).NoofrelatedEquipments__c == null )
                        {
                            accMap.get(rec).NoofrelatedEquipments__c = 1;
                            
                        }
                        else
                        {
                            accMap.get(entity.AccountId).NoofrelatedEquipments__c= accMap.get(entity.AccountId).NoofrelatedEquipments__c+ 1;
                        }
                    }
                }
            }
            
            if(!accMap.isEmpty())
            {
                try{
                    update accMap.values();
                    this.markRun();
                }
                catch(Exception e)
                {
                    System.debug(' Update Failed '+e.getMessage());
                }
            }
        }
    }
    
    /**
* @description: This overiden method decrements count on noofequipment field on Account when equiment is deleted.
*/
    public override void afterDelete(TriggerContext context) 
    {
        if (!this.hasRun())
        {
            system.debug(' $$$ in EquipmentRollupOnAccount_TrigAct  after delete ');
            Set<Id> accIds = new Set<Id>();
            List<Asset> assetEntities = context.oldList;
            for(Asset entity :assetEntities)
            {
                if(entity.AccountId != null && entity.RecordTypeId == assetRecordTypeId)
                {
                    accIds.add(entity.AccountId);
                }
            }
            
            Map<Id,Account> accMap = new Map<Id,Account>([Select NoOfRelatedEquipments__c from Account where id in :accIds]);
            if(!accMap.isEmpty() )
            {
                for(Asset entityRec :assetEntities)
                {
                    if(accMap.containsKey(entityRec.AccountId))
                    {
                        if(accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c != null  )
                        {
                            
                            accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c= accMap.get(entityRec.AccountId).NoOfRelatedEquipments__c- 1;
                        }        
                    }
                }
            }
            if(!accMap.isEmpty())
            {
                update accMap.values();
                this.markRun();
            }
        }
        
        
    }
}