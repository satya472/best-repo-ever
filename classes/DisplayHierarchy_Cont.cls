/*
* Author : Phaniram Upalapati
* Description : Controller for fetching details Hierarchy Details
* Associated To : DisplayHierarchyTree
* Test Class : DisplayHierarchy_ContTest
*/
public class DisplayHierarchy_Cont {
    
     /*
      * Description : Methods fetches the details of the records in Hierarchy format
      * Input Param: recordId - Id of the current Record on which the component is dragger
      *              objectName - object Name of the record
      * Return Type: List<RecordItems> - Wrapper class Containing details of the records as per
      *              the tree hierarchy
      */
    @AuraEnabled
    public static List<RecordItems> getHierarchyDetails(Id recordId, string objectName){
        
        List<RecordItems> fullListOfAccounts = new List<RecordItems>();
        List<RecordItems> fullListOfAssets = new List<RecordItems>();
        List<Id> accountIds = new List<Id>();
        Id accRecordId;
        Id currentRecAccId;
      try{   
          
          if(!objectName.equalsIgnoreCase('Asset') && !objectName.equalsIgnoreCase('Account')){
              return null;
          } 
          
        //Fetching the Account details if the invocation happend from Asset Record
        if(objectName.equalsIgnoreCase('Asset')){
            Asset currentRecord = [Select Id,Name,RootAssetId,AccountId from Asset Where id=:recordId LIMIT 1];
                       
            //Checking and fetching the Account details based on the TopLevelParentAssetId field
            //If the value is null that means the Asset record itself the top level asset so
            //we will directly fetch the AccountId
            if(string.isBlank(currentRecord.RootAssetId)){
                accRecordId = currentRecord.AccountId;
                currentRecAccId = currentRecord.AccountId;
            }else{
                //If there is a TopLevelAssetId then we query the accountId details from that Top Level Asset record.
                Asset parentAsset = [Select Id,Name,AccountId from Asset Where id=:currentRecord.RootAssetId LIMIT 1];
                accRecordId = parentAsset.AccountId;
                currentRecAccId = parentAsset.AccountId;
            }
        }else{
            accRecordId = recordId;
            currentRecAccId = recordId;
        }  
          
          //Fetching the Top Level account Id(from current account if there is a parent account) to display the hierarchy
          accRecordId = [Select Id,Name,ParentHoldingId__c from Account where id = :accRecordId].ParentHoldingId__c;

            //Fetching Account Details
            Map<Id,Account> accountMap = new Map<Id,Account>([Select Id,Name,ParentId,Type,ParentHoldingId__c from Account  ORDER BY Name ASC]);
                 
            //Fetching the Account Record Ids which needs to displayed in TreeHierarchy structure
            List<Id> accLst = getHierarchyIdsList(currentRecAccId, accountMap,new List<Id>());
         
            Map<Id, sObject> assetMap = new Map<Id, sObject>([Select Id,Name,AccountId,RootAssetId,ParentId,RecordType.Name from Asset Where AccountId in :accountMap.keySet() ORDER BY Name ASC]);
           
          
            //Fetching the Asset Record Ids which needs to displayed in TreeHierarchy structure
            List<Id> assetLst = objectName.equalsIgnoreCase('Asset')?getHierarchyIdsList(recordId, assetMap,new List<Id>()):null;
        
            //System.debug('assetLst : '+assetLst);
          
            List<RecordItems> accountHierarchy = new List<RecordItems>();
            //Looping through Account records
            for(Account accountRec: accountMap.values()){
                if(accountRec.Id == accRecordId){
                    //Preparing the record in Tree Component Format
                    RecordItems recItem = new RecordItems(accountRec.Id, (string.isBlank(accountRec.Type)?'':accountRec.Type+': ')+accountRec.Name, true, null,Label.Util_LtngURLFormat1+accountRec.Id+Label.Util_LtngURLFormat2,((accountRec.Id == currentRecAccId) && !objectName.equalsIgnoreCase('Asset'))?' (current) ':'');
                    //Once the record is Added to the list we are removing it from the map
                    accountMap.remove(accountRec.Id);
                    //Calling the method to fetch the child
                    accountHierarchy.add(getChildRecords(accountMap,accountRec.Id,recItem,'Account',assetMap,accLst,assetLst,currentRecAccId,objectName.equalsIgnoreCase('Asset')?recordId:null,(accountRec.Id == currentRecAccId)?true:false));
                    if( recItem.items ==  null){
                        recItem.items = new List<RecordItems>();
                    }
                    //Fetching the child records only if it is the Current Account on which hierarchy is displayed
                    if(accountRec.Id == currentRecAccId){
                        //Fetching the Asset records associated to the Account record
                        recItem.items.addAll(getAssetHierarchy(assetMap,accountRec.Id,assetLst,objectName.equalsIgnoreCase('Asset')?recordId:null));
                    } 
                    
                }
            }
            
            return accountHierarchy;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
     /*
      * Description : Methods fetches the details of the recordIds that needs to be displayed as part of TreeHierarchy Structure.
      *               From the current Record the method fetches all the parent recordIds.
      * Input Param: currentRecId - Id of the Record on Which the Hierarchy Tree needs to be displayed
      *              sobjMap - Map of records
      *              idsLst - List of ids that must be displayed as part of Hierarchy tree.
      * Return Type: List<Id> - List of Ids.
      */
    private static List<Id> getHierarchyIdsList(Id currentRecId, Map<Id,sObject> sobjMap, List<Id> idsLst){
        
        //Fetching ObjName from the current record
        String objName = currentRecId.getSObjectType().getDescribe().getName();
        
        if(objName.equalsIgnoreCase('Account')){
            Account acc = (Account)sobjMap.get(currentRecId);
            if(string.isNotBlank(acc.ParentId) && currentRecId != acc.ParentHoldingId__c){
                idsLst.add(currentRecId);
                idsLst = getHierarchyIdsList(acc.ParentId,sobjMap,idsLst);
            }else{
                idsLst.add(currentRecId);
            }
        }else{
            Asset acc = (Asset)sobjMap.get(currentRecId);
            if(string.isNotBlank(acc.ParentId)){
                idsLst.add(currentRecId);
                idsLst = getHierarchyIdsList(acc.ParentId,sobjMap,idsLst);
            }else{
                idsLst.add(currentRecId);
            }
        }
        //System.debug('idsLst : '+idsLst);
        return idsLst;
    }
    
     /*
      * Description : Methods fetches the details of the child records in Hierarchy format for the parentId
      * Input Param: sObjectMap - Map of the parent records from which we need to prepare the hierarchy(Account->Account / Asset->Asset)
      *              parentId - Id of the parent record based on which the child records are filtered.
      *              recItem - Hierarchy record Format of the parent to which all the child records from the method are added.
      *              objectAPIName - Api Name of the Object for which the loop runs
      *              childMap - childMap contains map of child records related to the parent Object. 
      *              accLstIds - List of Account Ids that must be displayed as part of tree hierarchy Structure
      *              assetIds - List of Account Ids that must be displayed as part of tree hierarchy Structure
      *              curRecAccId - Id of the current Account Record on which Tree hierarchy must be displayed.
      *              curRecAssetId - Id of the current Asset Record on which Tree hierarchy must be displayed.
      * Return Type: RecordItems - returns the record that contains full mapping.
      */
    private static RecordItems getChildRecords( Map<Id, sObject> sObjectMap,Id parentId,RecordItems recItem, String objectAPIName, Map<Id, sObject> childMap,List<Id> accLstIds,List<Id> assetIds,Id curRecAccId,Id curRecAssetId,Boolean currentRecReached){

            RecordItems childRec;
            //Looping sObject records so that the code can be used for multiple Objects
            for(sObject sObjRec : sObjectMap.values()){
                if(objectAPIName.equalsIgnoreCase('Account')){
                    Account records = (Account)sObjRec;
                    //Checking for child records and they must be present in the hierarchy list i.e  NO sibling records
                    if(records.ParentId == parentId){
                        system.debug('@@: reached: '+currentRecReached);
                        system.debug('@@:accLst: '+accLstIds);
                         if((curRecAssetId != null && currentRecReached) || (!currentRecReached && !accLstIds.contains(records.Id))){
                             continue;
                         }
                        if(recItem.items == null){
                            recItem.items = new List<RecordItems>();
                        }
                        sObjectMap.remove(records.Id);
                        //Preparing the child record as per the Tree hierarchy format
                        childRec = new RecordItems(records.Id, (string.isBlank(records.Type)?'':records.Type+': ')+records.Name, true, null,Label.Util_LtngURLFormat1+records.Id+Label.Util_LtngURLFormat2,((records.Id == curRecAccId) && (curRecAssetId == null))?' (current) ':'');
                        //Calling the method to get the child records for the current record
                        recItem.items.add(getChildRecords(sObjectMap,records.Id,childRec,objectAPIName,childMap,accLstIds,assetIds,curRecAccId,curRecAssetId,(currentRecReached || records.Id == curRecAccId)));
                        if(childRec.items == null){
                            childRec.items = new List<RecordItems>();
                        }
                        //Fetching Child Asset records for Child and current Account record
                        if(currentRecReached || (records.Id == curRecAccId)){
                            //Calling the method to get the Asset child records for the current record
                           
                            childRec.items.addAll(getAssetHierarchy(childMap,records.Id,assetIds,curRecAssetId));
                            
                        }
                        
                    }
                }else if(objectAPIName.equalsIgnoreCase('Asset')){
                    Asset records = (Asset)sObjRec;
                    if(records.ParentId == parentId){
                        system.debug('@@: reached: '+currentRecReached);
                        system.debug('@@:assetLst: '+assetIds);
                        //Fetching Asset records only which are in the list and the child records of the current asset record 
                        if(curRecAssetId != null && !currentRecReached && !assetIds.contains(records.Id)){
                                continue;
                        }
                        if(recItem.items == null){
                            recItem.items = new List<RecordItems>();
                        }
                        sObjectMap.remove(records.Id);
                        //Calling the method to get the Asset child records for the current record
                        childRec = new RecordItems(records.Id, records.RecordType.Name+': '+records.Name, true, null,Label.Util_LtngURLFormat1+records.Id+Label.Util_LtngURLFormat2,(records.Id == curRecAssetId)?' (current) ':'');
                        recItem.items.add(getChildRecords(sObjectMap,records.Id,childRec,objectAPIName,null,accLstIds,assetIds,curRecAccId,curRecAssetId,(currentRecReached || (records.Id == curRecAssetId))));
                    }
                }
                
            }
            return recItem;
    }

     /*
      * Description : Methods fetches the details of the Asset records in Hierarchy format for the parentId
      * Input Param: assetMap - Map of the asset records from which we need to prepare the hierarchy related to the parent Id
      *              parentId - Id of the parent record based on which the Asset records are filtered.
      *              assetIds - List of asset record ids that needs to be displayed in Hierarchy Structure
      *              currentAssetId - Record Id of the current asset.
      * Return Type: List<RecordItems> - returns the List of asset records in required Tree Hierarchy format.
      */    
    private static List<RecordItems> getAssetHierarchy(Map<Id, sObject> assetMap, Id parentId, List<Id> assetIds, Id currentAssetId){ 

        List<RecordItems> assetHierarchy = new List<RecordItems>();
        for(sObject sObjRec: assetMap.values()){
            Asset assetRec = (Asset)sObjRec;
            if(assetRec.ParentId == null && assetRec.AccountId == parentId ){
                system.debug('@@: currentAsset: '+currentAssetId);
                 system.debug('@@:assetLst: '+assetIds);
                if(assetIds != null && !assetIds.contains(assetRec.Id) && currentAssetId != null) {
                    continue;
                }
                RecordItems recItem = new RecordItems(assetRec.Id, assetRec.RecordType.Name+': '+assetRec.Name, true, null,Label.Util_LtngURLFormat1+assetRec.Id+Label.Util_LtngURLFormat2,(assetRec.Id == currentAssetId)?'(current)':'');
                assetMap.remove(assetRec.Id);
                assetHierarchy.add(getChildRecords(assetMap,assetRec.Id,recItem,'Asset',null,new List<Id>(),assetIds,parentId,currentAssetId,(currentAssetId == assetRec.Id)?true:false));
            }
        }
        return assetHierarchy;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> getAssetHierarchyDetailsCEP(Id recordId, string objectName){
      
         /*   Map<Id, sObject> assetMap = new Map<Id, sObject>([Select Id,Name,AccountId,RootAssetId,ParentId,RecordType.Name from Asset Where AccountId = :recordId ORDER BY Name ASC]);
           
          
            //Fetching the Asset Record Ids which needs to displayed in TreeHierarchy structure
            List<Id> assetLst = objectName.equalsIgnoreCase('Asset')?getHierarchyIdsList(recordId, assetMap,new List<Id>()):null;
        
            List<RecordItems> hierarchyItems = new List<RecordItems>();*/

            return [Select Id,Name,AccountId,RootAssetId,ParentId,RecordType.Name from Asset Where AccountId = :recordId ORDER BY Name ASC];

    }
    
    
   /*
    * Description: Class for storing the Hierarchy record details
    */
    public class RecordItems {  
        
        @AuraEnabled  
        public string label { get; set; }  
        
        @AuraEnabled  
        public string name { get; set; }  
        
        @AuraEnabled  
        public Boolean expanded { get; set; }  
        
        @AuraEnabled  
        public List<RecordItems> items { get; set; }  
        
        @AuraEnabled
        public String href{get; set;}
        
        @AuraEnabled
        public String metatext{get; set;}
        
        public RecordItems( String name, String label, Boolean expanded, List<RecordItems> items,String href,String metatext) {  
            this.label = label;  
            this.name = name;  
            this.expanded = expanded;  
            this.items = items;   
            this.href = href;
            this.metatext = metatext;
        }  
    }  
}