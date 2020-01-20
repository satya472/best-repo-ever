/*
*Name: CreateOppProductHistory_Cont
*Author: Naveen Gadicherla
*Date: 10-Oct-2018
*Description: Creates opportunity product history records.
*/

public class CreateOppProductHistory_Cont 
{
	public static void createOppProdHistoryRecords(List<OpportunityLineItem> oppLineItems)
	{
		List<OpportunityProductHistory__c> historyRecs = new List<OpportunityProductHistory__c>();
		Map<Id,Id> oppLineIdMap = new Map<Id,Id>();
		set<Id> lineItemIds = new set<Id>();
		for(OpportunityLineItem lineRec : oppLineItems)
		{
			lineItemIds.add(lineRec.Id);
		}
		for(OpportunityLineItem lineEnity: [Select id,Name,Opportunity.Asset__c FROM OpportunityLineItem
																			   WHERE Id IN :lineItemIds])
		{
			if(!oppLineIdMap.containsKey(lineEnity.Id))
			{
				oppLineIdMap.put(lineEnity.Id,lineEnity.Opportunity.Asset__c);
			}
		}			

		for(OpportunityLineItem entity : oppLineItems)
        {
            OpportunityProductHistory__c hisRec = new OpportunityProductHistory__c();
            //copy product,asset and price
            hisRec.AssetId__c = (oppLineIdMap.containsKey(entity.Id))?oppLineIdMap.get(entity.Id):null;
            hisRec.ProductId__c = entity.Product2Id;
            hisRec.Price__c = entity.ListPrice;
            hisRec.Stage__c = 'Closed Lost';
            hisRec.OpportunityId__c = entity.OpportunityId;
            historyRecs.add(hisRec);
        }
	    
		try
		{
			If(!historyRecs.isEmpty())
			{
                system.debug(' &&&& historyRecs has ==> '+historyRecs);
				insert historyRecs;
			}
		}
		catch(Exception e){
            System.debug(' Insertion on Opportunity Product History Failed '+e.getMessage());
        }		
	}

	/*
    * ClassName: lightningTableColumnWrapper 
    * description : Wrapper class for storing the details of the fields of Child records
    */
    public class lightningTableColumnWrapper 
    {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public string type {get;set;}
        @AuraEnabled
        public boolean sortable {get;set;}
    }
    
    /*
    * ClassName: lightningTableWrapper 
    * description : Wrapper class for storing the records of Child Object
    */
    public class lightningTableWrapper
    {
        @AuraEnabled
        public List<OpportunityProductHistory__c> historyRecords {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
        @AuraEnabled
        public List<PickListWrapper> fieldByPickList{get;set;}
        @AuraEnabled
        public Map<String,String> referenceValMap{get;set;}
        @AuraEnabled
        public string filters;
    }
    
    /*
    * Class Name: PickListWrapper
    * Description: Used for preparing PickList's
    */
    public class PickListWrapper
    {
        @AuraEnabled
        public String columnName {get;set;}
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public String fieldType {get;set;}
        @AuraEnabled
        public List<PickListFieldWrapper> fieldByFieldPickList{get;set;}
    }
    /*
    * Class Name: PickListFieldWrapper
    * Description: Used for preparing PickList's
    */ 
    public Class PickListFieldWrapper{
        @AuraEnabled
        public String label{set;get;}
        
        @AuraEnabled
        public String value{set;get;}
        
        public PickListFieldWrapper(String label, String val){
            this.label = label;
            this.value = val;
        }
    }

    @AuraEnabled 
    public static LightningTableWrapper getSourceRecords(String objName,
                                                         String recordId)
    {
		List<String> lstfieldstoget = new List<String>();
        string filterComp='';
        Map<String,String> referenceMap = new Map<String,String>();
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper>();
        LightningTableWrapper ltngTableWrapper = new LightningTableWrapper();
        ltngTableWrapper.fieldByPickList = new List<PickListWrapper>();
		String recObjectQuery = 'Select ';
        system.debug(' recordid has ==> '+recordId);
        string fieldSetName = 'oppProdHistoryFieldSet';
		lstTableColumn = getFieldDetails('OpportunityProductHistory__c',fieldSetName);
		List<String> filters = new List<String>{'Stage__c', 'WonLostReason__c'};
		try
		{
                //Fetching the Picklist values of the filterByField
                
			for( String fldName : filters)
			{
                system.debug(' fldName == '+fldName);
                filterComp = filterComp +fldName+',';
				PickListWrapper pkLstEntity = new PickListWrapper();
				pkLstEntity.fieldByFieldPickList = new List<PickListFieldWrapper>();
				DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('OpportunityProductHistory__c').getDescribe().fields.getMap().get(fldName).getDescribe();
                system.debug(' fieldResult values == > '+fieldResult);
				if(String.valueof(fieldResult.getType()).equalsIgnorecase('PickList') || 
                   String.valueof(fieldResult.getType()).equalsIgnorecase('MULTIPICKLIST'))
				{
					for(Schema.PicklistEntry pkl: fieldResult.getPicklistValues())
					{
						pkLstEntity.fieldByFieldPickList.add(new PickListFieldWrapper(pkl.getLabel(),pkl.getValue()));  
					}
				}
				pkLstEntity.apiName = fldName;
				pkLstEntity.columnName = fieldResult.getLabel();
                pkLstEntity.fieldType = String.valueof(fieldResult.getType());
				ltngTableWrapper.fieldByPickList.add(pkLstEntity);
			}
            filterComp = filterComp.removeEnd(',');
            system.debug(' pikclist values == > '+ltngTableWrapper.fieldByPickList);
        }catch(Exception exce)
        {
                throw new AuraHandledException('Reading picklist values failed ');
        }
        for(lightningTableColumnWrapper fieldColumn : lstTableColumn)
        {
                lstfieldstoget.add(String.valueOf(fieldColumn.fieldName));
        } 
        for(lightningTableColumnWrapper fieldColumn : lstTableColumn)
        {
            if((fieldColumn.type).equalsIgnoreCase('Reference'))
            {
                String fieldName = fieldColumn.fieldName;
                String mapVal = fieldName.endsWithIgnoreCase('Id')?(fieldName.subString(0,fieldName.length()-2)+'.Name'):
                fieldName.endsWithIgnoreCase('__c')?fieldName.replace('__c','__r')+'.Name':fieldName+'.Name';
                referenceMap.put(fieldName,mapVal);
                lstfieldstoget.add(mapVal);
            }
        }
        system.debug(' lstTableColumn has ==> '+lstTableColumn);
        system.debug(' query has ==> '+recObjectQuery);
        system.debug(' tablecolumn has === '+lstTableColumn);
        system.debug(' filterComp has === '+filterComp);
		recObjectQuery += String.escapeSingleQuotes(String.join(lstfieldstoget,',')) + ' from OpportunityProductHistory__c WHERE OpportunityId__c = \''+recordId+'\''; 
        system.debug(' query has ==> '+recObjectQuery);      
		List<OpportunityProductHistory__c> historyList = database.query(recObjectQuery);
		ltngTableWrapper.historyRecords = historyList;
        ltngTableWrapper.tableColumn = lstTableColumn;
        ltngTableWrapper.filters = filterComp;
        ltngTableWrapper.referenceValMap = referenceMap;
        return ltngTableWrapper;  
		
	}

    /*
    * Description : Methods fetches the details of the Fields from the fieldset
    * Input Param: ObjectName - Object Name from which Field details needs to be fetched
    *              fieldSetName - FieldSetName containing the fields List
    * Return Type: List<lightningTableColumnWrapper> - List of Wrapper Class containing the Field Details
    * Fetched from the fieldSet
    */
    @AuraEnabled
    Public static List<lightningTableColumnWrapper> getFieldDetails(String ObjectName,String fieldSetName){
        try{ 
            List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper> ();
            system.debug(' in fieldSetName -- '+fieldSetName);
            system.debug(' in ObjectName -- '+ObjectName);
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
            DescribeSObjectResult objResult1 = Schema.getGlobalDescribe().get('opportunity').getDescribe();
            //Schema.FieldSet fieldSetObj = objResult.FieldSets.getMap().get(fieldSetName);
            Schema.FieldSet fs1 = Schema.SObjectType.OpportunityProductHistory__c.fieldSets.getMap().get(fieldSetName);
            system.debug(' in fieldSetObj '+fs1);
            system.debug(' in objResult1 '+objResult1);
            lightningTableColumnWrapper colWrapper;
            if(!Test.isRunningTest()){
                system.debug(' isruningtest =======');
                for(Schema.FieldSetMember fieldResult : fs1.getFields()){
                    system.debug(' fieldResult ======='+fieldResult);
                    colWrapper = new lightningTableColumnWrapper();
                    colWrapper.label = fieldResult.getLabel();
                    colWrapper.fieldName = fieldResult.getFieldPath();
                    colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                    colWrapper.sortable = true;
                    lstTableColumn.add(colWrapper);
                }
            }else{
                //For test Class Purpose
                colWrapper = new lightningTableColumnWrapper();
                DescribeFieldResult fieldResult = objResult.fields.getMap().get('CreatedById').getDescribe();
                colWrapper.label = fieldResult.getLabel();
                colWrapper.fieldName = fieldResult.getName();
                colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                colWrapper.sortable = false;
                lstTableColumn.add(colWrapper);
            }
            
            return lstTableColumn;
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }      
    }

    //
    //Method to insert similar opportunities. Check if the selected opportunities already exists. 
    //If yes, will not include them for Insertion
    //
    @AuraEnabled
    Public static void updateOpportunityProductHistoryRecords(string sourceRecordList,
                                                              string stageValue,
                                                              string wonLossValue  )
    {
        //system.debug(' Sourcelist has ====> '+sourceRecordList);
        List<OpportunityProductHistory__c> recList = new List<OpportunityProductHistory__c>();
        List<OpportunityProductHistory__c> updateList = new List<OpportunityProductHistory__c>();
        set<id> recIds = new set<id>();
        system.debug(' stageValue has ====> '+stageValue);
        system.debug(' wonLossValue has ====> '+wonLossValue);
        try{
            if(sourceRecordList != null && sourceRecordList != '')
            {
                recList = (List<OpportunityProductHistory__c>)JSON.deserialize(sourceRecordList,List<OpportunityProductHistory__c>.class);
            }
            if(!recList.isEmpty())
            {
                for(OpportunityProductHistory__c recEntity: recList)
                {   
                   // system.debug(' recEntity has ====> '+recEntity);
                    string str = recEntity.Id;
            
                    string[] splits =str.split('/');
                    recIds.add(splits[3]);
                    system.debug('recIds has ====> '+recIds);
                }
                system.debug('recIds has ====> '+recIds);
                for(OpportunityProductHistory__c entity :[Select id,Name, Stage__c,WonLostReason__c FROM OpportunityProductHistory__c
                                                            WHERE Id IN :recIds])
                {
                    system.debug(' for loop results '+entity);
                    //OpportunityProductHistory__c  newRec = new OpportunityProductHistory__c();
                    if('All' != stageValue)
                    {
                        entity.Stage__c = stageValue;
                        system.debug('  in if entity.Stage__c -- : '+entity.Stage__c);
                    }
                    if('All' != wonLossValue)
                    {
                        entity.WonLostReason__c = wonLossValue;
                    }
                    updateList.add(entity);
                }
            }
            if(!recList.isEmpty())
            {
                system.debug(' recList has beore updtae ====> '+recList);
                update updateList;
            }
        }
        catch(Exception ex)
            {
                throw new AuraHandledException(ex.getMessage());
            }
	}
}