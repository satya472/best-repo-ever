/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 18-March-2018
* Description: 
Custom TrainStatusChange_TrigAct
* 
*/
public class TrainStatusChange_TrigAct extends TriggerHandler 
{
    //TriggerHandler handlerInstance = new TriggerHandler();
    String getLabelName = Label.BipassParentIdConditionForDataUpdate;
    integer countEquip;
    integer countTrain;
    public Id assetEquipRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
    public Id assetPlantRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
    public Id assetTrainRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
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
        /*(Developer- Rupinder Kaur) Added Logic for calculating No. of related trains and equipments*/
        /*Logic Begins*/
        
        if (!this.hasRun())
        {
            system.debug(' $$$ in EquipmentRollupOnAccount_TrigAct  after insert ');
            
            Set<Id> insertRecordIds = new Set<Id>(); //will have ParentIDs of record type Equipment and Train
            List<Asset> insertAssetEntities = context.newList;
            for(Asset insertEntity :insertAssetEntities)
            {
                if(insertEntity.ParentId != null && (insertEntity.RecordTypeId == assetEquipRecordTypeId || insertEntity.RecordTypeId == assetTrainRecordTypeId)){
                    insertRecordIds.add(insertEntity.ParentId);
                }
            }
            
            Map<Id,Asset> InsertrecMap = new Map<Id,Asset>([Select RecordTypeId,(Select id,RecordTypeId from ChildAssets),NoOfRelatedEquipments__c,NoOfRelatedTrains__c from Asset where id in :InsertrecordIds  ]);
            
            system.debug('@@'+InsertrecMap);
            
            if(!InsertrecMap.isEmpty())
            {
                for(Asset entityRec :InsertrecMap.values())
                {
                    countEquip=0;
                    countTrain=0;
                    /*(Start)To calculate child asset of type equipment and train on train and plant respectively*/
                    
                    for(Asset childRec :entityRec.ChildAssets)
                    {
                        if(childRec.RecordTypeId == assetEquipRecordTypeId && entityRec.RecordTypeId == assetTrainRecordTypeId)
                        {
                            countEquip++;
                        }
                        if(childRec.RecordTypeId == assetTrainRecordTypeId && entityRec.RecordTypeId == assetPlantRecordTypeId)
                        {
                            countTrain++;
                        } 
                        
                    }
                    /*(End)To calculate child asset of type equipment and train on train and plant respectively*/
                    
                    
                    
                    system.debug('##'+entityRec.ChildAssets.size());
                    
                    entityRec.NoOfRelatedEquipments__c = countEquip;
                    entityRec.NoOfRelatedTrains__c = countTrain;
                    InsertrecMap.put(entityRec.id,entityRec);
                    
                }
            }
            if(!insertRecMap.isEmpty())
            {  
                try{
                    system.debug('i am inserted');
                    update insertRecMap.values();
                    this.markRun();
                }
                Catch(Exception e)
                {
                    System.debug(' Update Failed'+e.getMessage());
                }
            }
            
            updateTrainStatus(context.newList); //Will update status on train w.r.t equipment status
            
        }
        /*Logic Ends */
        /*(Developer- Rupinder Kaur) Added Logic for calculating No. of related trains and equipments*/
        
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
        
        //Custom business logic
        if (!this.hasRun())
        {   
            
            /*(Developer- Rupinder Kaur) Added Logic for calculating No. of related trains and equipments*/
            
            Set<Id> recordIds = new Set<Id>(); 
            List<Asset> assetNewRecords = context.newList;
            Map<Id,Asset> assetOldRecords = (Map<Id,Asset>)context.oldMap;
            
            //Will fetch parentIds of both old and new records
            for(Asset entity :assetNewRecords)
            {
                If(assetOldRecords.get(entity.Id).ParentId != entity.ParentId || getLabelName =='True') //Bipass when updating for equipment and train
                {
                    if(entity.ParentId != null && (entity.RecordTypeId == assetEquipRecordTypeId || entity.RecordTypeId == assetTrainRecordTypeId))
                    {
                        recordIds.add(entity.ParentId);
                    }
                    if(assetOldRecords.get(entity.Id).ParentId != null )
                    {
                        recordIds.add(assetOldRecords.get(entity.Id).ParentId);
                        
                    }
                }
            }
            
            Map<Id,Asset> recMap = new Map<Id,Asset>([Select RecordTypeId,(Select id,RecordTypeId from ChildAssets ),
                                                      NoOfRelatedTrains__c,NoOfRelatedEquipments__c 
                                                      from Asset where id in :recordIds]);
            
            
            if(!recMap.isEmpty())
            {
                for(Asset entity :recMap.values())
                {
                    countEquip=0;
                    countTrain=0;
                    /*(Start)To calculate child asset of type equipment and train on train and plant respectively*/
                    
                    for(Asset childRec :entity.ChildAssets)
                    {
                        if(childRec.RecordTypeId == assetEquipRecordTypeId && entity.RecordTypeId == assetTrainRecordTypeId)
                        {
                            countEquip++;
                        }
                        if(childRec.RecordTypeId == assetTrainRecordTypeId && entity.RecordTypeId == assetPlantRecordTypeId)
                        {
                            countTrain++;
                        } 
                        
                    }
                    /* (End)To calculate child asset of type equipment and train on train and plant respectively*/
                    
                    
                    
                    system.debug('##'+entity.ChildAssets.size());
                    
                    entity.NoOfRelatedEquipments__c = countEquip;
                    entity.NoOfRelatedTrains__c = countTrain;
                    recMap.put(entity.id,entity);
                    
                    
                    
                }
            }
            
            
            
            if(!recMap.isEmpty())
            {
                try{
                    update recMap.values();
                    this.markRun();
                }
                catch(Exception e)
                {
                    System.debug(' Update Failed '+e.getMessage());
                }
            }
            
            
            if(getLabelName =='False'){ //Bipass when updating for equipment and train
                updateTrainStatus(context.newList);
            }
        }
        
        
    }
    
    /*
* Fire logic for beforeDelete context
*/
    public override void beforeDelete(TriggerContext context) {
        
    }
    
    /*
* Fire logic for afterDelete context
*/
    public override void afterDelete(TriggerContext context) {
        
        /*Logic Starts */
        /*(Developer- Rupinder Kaur) Added Logic for calculating No. of related trains and equipments 
after deleting respective records*/
        
        if (!this.hasRun())
        {
            system.debug(' $$$ in EquipmentRollupOnAccount_TrigAct  after delete ');
            
            Set<Id> recordIds = new Set<Id>(); //will have IDs with record type Equipment and Train
            List<Asset> assetEntities = context.oldList;
            for(Asset entity :assetEntities)
            {
                if(entity.ParentId != null && (entity.RecordTypeId == assetEquipRecordTypeId || entity.RecordTypeId == assetTrainRecordTypeId)){
                    recordIds.add(entity.ParentId);
                }
            }
            
            Map<Id,Asset> recMap = new Map<Id,Asset>([Select RecordTypeId,(Select id,RecordTypeId from ChildAssets ),NoOfRelatedEquipments__c,NoOfRelatedTrains__c from Asset where id in :recordIds]);
            
            if(!recMap.isEmpty())
            {
                for(Asset entityRec :recMap.values())
                {
                    countEquip=0;
                    countTrain=0;
                    /*(Start)To calculate child asset of type equipment and train on train and plant respectively*/
                    
                    for(Asset childRec :entityRec.ChildAssets)
                    {
                        if(childRec.RecordTypeId == assetEquipRecordTypeId && entityRec.RecordTypeId == assetTrainRecordTypeId)
                        {
                            countEquip++;
                        }
                        if(childRec.RecordTypeId == assetTrainRecordTypeId && entityRec.RecordTypeId == assetPlantRecordTypeId)
                        {
                            countTrain++;
                        } 
                        
                    }
                    /*(End)To calculate child asset of type equipment and train on train and plant respectively*/
                    
                    
                    system.debug('####'+entityRec.ChildAssets.size());
                    
                    entityRec.NoOfRelatedEquipments__c = countEquip;
                    entityRec.NoOfRelatedTrains__c = countTrain;
                    recMap.put(entityRec.id,entityRec);
                    
                    
                    
                    
                }
            }
            if(!recMap.isEmpty())
            {  
                try{
                    update recMap.values();
                    this.markRun();
                }
                Catch(Exception e)
                {
                    System.debug(' Update Failed on Account '+e.getMessage());
                }
            }
        }
        /*Logic Ends */
        /*(Developer- Rupinder Kaur) Added Logic for calculating No. of related trains and equipments 
after deleting respective records*/
    }
    
    /*
* Fire logic for beforeUndelete context
*/
    public override void beforeUndelete(TriggerContext context) {
        
    }
    
    /*
* Fire logic for afterUndelete context
*/
    public override void afterUndelete(TriggerContext context) {
        
    }
    
    /*
* Fire logic for finish context
*/
    public override void finish(TriggerContext context) 
    {
    }
    
    //
    //updateTrainStatus: Updates Parent Train record status based on 
    //                   child equipments' status on update of child Equipment
    //
    public  void updateTrainStatus(List<Asset> assetEntities)
    {
        Map<Id,List<String>> activeMap =  new Map<Id,List<String>>();
        Map<Id,List<String>> inActiveMap =  new Map<Id,List<String>>();
        Set<Id> assetIds = new Set<Id>();
        List<Asset> updateParentList = new List<Asset>();
        system.debug(' %%%% Test');
        //Call returnStatusMap method
        returnStatusMap(assetEntities,activeMap,inActiveMap,assetIds);
        
        for( Id assetId :assetIds)
        {
            Asset assetRec = new Asset();
            Integer activeCount =0;
            Integer inActiveCount = 0;
            if(!activeMap.isEmpty() && activeMap!=null)
            {
                activeCount = activeMap.get(assetId).size();
            }
            
            if(!inActiveMap.isEmpty() && inActiveMap != null)
            {
                inActiveCount = inActiveMap.get(assetId).size();
            }
            assetRec.Id = assetId;
            If( 0 == activeCount &&  0 != inActiveCount)
            {
                assetRec.TrainStatus__c = 'Inactive';
            }
            else if ( 0 != activeCount && 0 != inActiveCount)
            {
                assetRec.TrainStatus__c = 'Partially Active';
            }
            else if( 0 != activeCount )
            {
                assetRec.TrainStatus__c = 'Active';
            }
            
            updateParentList.add(assetRec);
        }
        if(!updateParentList.isEmpty())
        {
            try{
                update updateParentList;
                this.markRun();
            }
            catch(Exception e)
            {
                System.debug('Update Failed on Account'+ e.getMessage());
            }
        }
        
    }
    
    
    // returnStatusMap: Returns the active and Inactive maps
    Public void returnStatusMap(List<Asset> assetList, Map<id,List<string>> activeAssetMap, Map<id,List<String>> inactiveAssetMap,Set<id> assetIds)
    {
        List<String> statusList = new List<String>();
        for(Asset entity :assetList)
        {
            if(entity.ParentId!= null && entity.RecordTypeId == assetEquipRecordTypeId )//declare it on top and get recordtype id *
            {
                assetIds.add(entity.ParentId);
            }
        }
        if(!assetIds.isEmpty())
        {
            for(Asset entityRec : [select id, OperatingStatus__c,ParentId  
                                   FROM Asset
                                   WHERE
                                   ParentId in : assetIds])
            {
                
                if(!activeAssetMap.containskey(entityRec.ParentId) && entityRec.OperatingStatus__c == 'Active')
                {
                    activeAssetMap.put(entityRec.ParentId,new List<String>{entityRec.OperatingStatus__c});
                }
                else if(entityRec.OperatingStatus__c == 'Active')
                {
                    statusList = activeAssetMap.get(entityRec.ParentId);
                    statusList.add(entityRec.OperatingStatus__c);
                    activeAssetMap.put(entityRec.parentId,statusList);
                }
        	        
                if(!inactiveAssetMap.containskey(entityRec.ParentId) && entityRec.OperatingStatus__c != 'Active')
                {
                    inactiveAssetMap.put(entityRec.ParentId,new List<String>{entityRec.OperatingStatus__c});
                }
                else if(entityRec.OperatingStatus__c != 'Active')
                {
                    statusList = inactiveAssetMap.get(entityRec.ParentId);
                    statusList.add(entityRec.OperatingStatus__c);
                    inactiveAssetMap.put(entityRec.parentId,statusList);
                }
                
            }
        }
    }
}