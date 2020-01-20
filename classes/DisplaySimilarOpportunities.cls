/*
*Author: G.Naveen Kumar
*Date:7-Jul-18
*Description: DisplaySimilarOpportunities fetches similar opportunities related to the LOA report
*/
public class DisplaySimilarOpportunities 
{
    @AuraEnabled
    public static LightningTableWrapper fetchSimilarOpportunities( Id recId,String objectName)
    {        
        List<String> lstfieldstoget = new List<String>();
        List<Opportunity> amtOpportunities = new List<Opportunity>();
        List<LOAReport__c> loaEntities = new List<LOAReport__c>();
        List<SBQQ__Quote__c> quoteRec = new List<SBQQ__Quote__c>();
        List<Opportunity> oppRecords = new List<Opportunity> ();
        Map<Id,Id> prodMap = new Map<Id,Id>();
        Map<Id,Id> assetMap = new Map<Id,Id>();
        Set<id> exitsSimOppSet = new Set<Id>();
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper>();
        LightningTableWrapper ltngTableWrapper = new LightningTableWrapper();
        //Fetch the Field Details from Fieldset
        lstTableColumn = getFieldDetails(Label.SimilarOpportunities);
        
        for(lightningTableColumnWrapper fieldColumn : lstTableColumn)
        {
            lstfieldstoget.add(String.valueOf(fieldColumn.fieldName));                          
        }
        Map<String,String> referenceMap = new Map<String,String>();
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
        try
        {
            
            if(objectName == Label.LOAReportObject)
            {
                loaEntities = [Select id,QuoteId__c FROM LOAReport__c where Id = :recId ];
                if(!loaEntities.isEmpty())
                {
                    quoteRec = [Select id,Name,SBQQ__Opportunity2__c FROM SBQQ__Quote__c Where Id = :loaEntities[0].QuoteId__c];
                    for(SBQQ__QuoteLine__c quoteEntities : [Select id,Name,SBQQ__Product__c,SBQQ__Quote__c,Service_Asset__c 
                                                            FROM SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteRec[0].Id])
                    {
                        //similarQuotes.add(quoteEntities.SBQQ__Quote__c.SBQQ__Product__c);
                        prodMap.put(quoteEntities.Id,quoteEntities.SBQQ__Product__c);
                        assetMap.put(quoteEntities.Id,quoteEntities.Service_Asset__c);
                    }
                    oppRecords = [Select Id,Name,Amount FROM Opportunity where Id = :quoteRec[0].SBQQ__Opportunity2__c];
                }
            }
            else if(objectName == Label.OpportunityObject)
            {
                oppRecords = [Select Id,Name,Amount,SBQQ__PrimaryQuote__c FROM Opportunity where Id = :recId];
                for(SBQQ__QuoteLine__c quoteEntities : [Select id,Name,SBQQ__Product__c,SBQQ__Quote__c,Service_Asset__c 
                                                        FROM SBQQ__QuoteLine__c where SBQQ__Quote__c = :oppRecords[0].SBQQ__PrimaryQuote__c])
                {
                    prodMap.put(quoteEntities.Id,quoteEntities.SBQQ__Product__c);
                    assetMap.put(quoteEntities.Id,quoteEntities.Service_Asset__c);
                }   
            }
            if(!oppRecords.isEmpty())
            {            
            	for(SimilarOpportunity__c existsOppsList : [Select id,Name,Opportunity__c,SimilarOpportunity__c 
                                                      		FROM SimilarOpportunity__c
                                                      		WHERE Opportunity__c = :oppRecords[0].Id ])
               {
                   exitsSimOppSet.add(existsOppsList.SimilarOpportunity__c);
               }                    
                Decimal lowAmount = (oppRecords[0].Amount) - (oppRecords[0].Amount * 0.2);
                Decimal highAmount = (oppRecords[0].Amount) + (oppRecords[0].Amount * 0.2);
                String whereClause = '';
                if(lowAmount > 0 && highAmount > 0)
                {
                    whereClause = ' WHERE Amount >=' +lowAmount+' AND Amount <='+highAmount + ' AND Id != \''+oppRecords[0].Id+'\'' ;
                }
                
                String queryString = 'Select Id,'+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                   					 ' FROM Opportunity';
                
                if(!string.isBlank(whereClause))
                {
                    queryString = queryString + whereClause;
                }            
                queryString = queryString;   
                amtOpportunities= database.query(queryString);
            }
            List<Opportunity> prodOpportunities = getOppBasedOnProducts(prodMap,String.escapeSingleQuotes(String.join(lstfieldstoget,',')));
            List<Opportunity> assetOpportunities = getOppBasedOnAsset(assetMap,String.escapeSingleQuotes(String.join(lstfieldstoget,',')));
            if(!prodOpportunities.isEmpty())
            {
                amtOpportunities.addAll(prodOpportunities);
            }
            if(!assetOpportunities.isEmpty())
            {
                amtOpportunities.addAll(assetOpportunities);
            }
            
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
            for(Opportunity oppRec:amtOpportunities )
            {
                if(!opportunityMap.containsKey(oppRec.Id) && !exitsSimOppSet.contains(oppRec.Id) )
                {
                    opportunityMap.put(oppRec.Id,oppRec);
                }
            }
            ltngTableWrapper.tableRecord = opportunityMap.Values();
            ltngTableWrapper.total = ltngTableWrapper.tableRecord.Size();
            ltngTableWrapper.tableColumn = lstTableColumn;  
            ltngTableWrapper.referenceValMap = referenceMap;
        }catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());    
        }   
        
        return ltngTableWrapper;
    }
    
    /*
    * Description : Methods fetches the details of the Fields from the fieldset
    * Input Param: ObjectName - Object Name from which Field details needs to be fetched
    fieldSetName - FieldSetName containing the fields List
    * Return Type: List<lightningTableColumnWrapper> - List of Wrapper Class containing the Field Details
    Fetched from the fieldSet
    */
    @AuraEnabled
    Public static List<lightningTableColumnWrapper> getFieldDetails(String fieldSetName)
    {
        try
        { 
            List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper> ();
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('opportunity').getDescribe();
            Schema.FieldSet fieldSetObj = objResult.FieldSets.getMap().get(fieldSetName);
            
            lightningTableColumnWrapper colWrapper;
            if(!Test.isRunningTest())
            {
                for(Schema.FieldSetMember fieldResult : fieldSetObj.getFields())
                {
                    colWrapper = new lightningTableColumnWrapper();
                    colWrapper.label = fieldResult.getLabel();
                    colWrapper.fieldName = fieldResult.getFieldPath();
                    colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                    colWrapper.sortable = true;
                    lstTableColumn.add(colWrapper);
                }
            }else
            {
                //For test Class Purpose
                colWrapper = new lightningTableColumnWrapper();
                DescribeFieldResult fieldResult = objResult.fields.getMap().get('Name').getDescribe();
                colWrapper.label = fieldResult.getLabel();
                colWrapper.fieldName = fieldResult.getName();
                colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                colWrapper.sortable = false;
                lstTableColumn.add(colWrapper);
            }
            return lstTableColumn;
            
        }catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }      
    }
    //
    //Fetch Similar opportunities that matches QuoteLineItems Products
    //
    @AuraEnabled
    Public static List<Opportunity> getOppBasedOnProducts(Map<id,id> prodMap,string fields)
    {
        Set<Id> similarQuotes = new Set<Id>();
        List<Opportunity> similarOpps = new List<Opportunity>();
        
        for(SBQQ__QuoteLine__c quoteEntities : [Select id,Name,SBQQ__Product__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c where SBQQ__Product__c IN :prodMap.values()
                                                AND Id NOT IN :prodMap.keySet()
                                                AND SBQQ__Quote__r.SBQQ__Primary__c =  true])
        {
            similarQuotes.add(quoteEntities.SBQQ__Quote__c);
        }
        String queryString = 'Select Id,'+ fields+ ' from Opportunity  WHERE SBQQ__PrimaryQuote__c IN :similarQuotes';
        
        similarOpps = database.query(queryString);
        return similarOpps;
    }
    //
    //Fetch Similar opportunities based on QuoteLineItem's Asset matching with Frame text field
    //
    @AuraEnabled
    Public static List<Opportunity> getOppBasedOnAsset(Map<id,Id> assetMap,string fields)
    {
        Set<string> frameValues = new Set<string>();
        set<Id> allAssets = new Set<Id>();
        Set<Id> similarQuotes = new Set<Id>();
        List<Opportunity> similarOpps = new List<Opportunity>();
        
        for(Asset astEntity : [Select id,Name,Frame__c FROM Asset Where Id IN :assetMap.Values()])
        {
            frameValues.add(astEntity.Frame__c);
        }
        for(Asset astRecs : [Select id,Name FROM Asset Where Frame__c IN :frameValues])
        {
            allAssets.add(astRecs.Id);
        }
        for(SBQQ__QuoteLine__c relQuotes : [Select id,Name,SBQQ__Product__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c where Service_Asset__c IN :allAssets
                                            AND Id NOT IN :assetMap.KeySet()
                                            AND SBQQ__Quote__r.SBQQ__Primary__c = true])
        {
            similarQuotes.add(relQuotes.SBQQ__Quote__c);
        }
        String queryString = 'Select Id,'+fields+ ' from Opportunity  WHERE SBQQ__PrimaryQuote__c IN :similarQuotes';
        
        similarOpps = database.query(queryString);
        return similarOpps;
    }
    //
    //Method to insert similar opportunities. Check if the selected opportunities already exists. 
    //If yes, will not include them for Insertion
    //
    @AuraEnabled
    Public static void createSimilarOpportunities(string sourceRecordList,String recId, String objName)
    {
        List<opportunity> oppList = new List<opportunity>();
        set<id> oppIds = new set<id>();
        set<id> oppEditIds = new set<id>();
        set<id> existsOppIds = new set<id>();
        List<Opportunity> oppRecords = NEW List<Opportunity>();
        List<SimilarOpportunity__c> insertSimilarOpps = new List<SimilarOpportunity__c>();
        
        if(sourceRecordList != null && sourceRecordList != '')
        {
            oppList = (List<opportunity>)JSON.deserialize(sourceRecordList,List<opportunity>.class);
        }
        if(!oppList.isEmpty())
        {
            for(opportunity oppEntity: oppList)
            {   
                string str = oppEntity.Id;
          
                string[] splits =str.split('/');
                oppEditIds.add(splits[3]);
            }
            if(objName == Label.LOAReportObject)
            {
                List<LOAReport__c> loaEntities = [Select id,QuoteId__c FROM LOAReport__c where Id = :recId ];
                if(!loaEntities.isEmpty())
                {
                    List<SBQQ__Quote__c> quoteRec = [Select id,Name,SBQQ__Opportunity2__c FROM SBQQ__Quote__c Where Id = :loaEntities[0].QuoteId__c];
                    oppRecords = [Select Id,Name,Amount FROM Opportunity where Id = :quoteRec[0].SBQQ__Opportunity2__c];
                }
        	}
            else if (objName == Label.OpportunityObject)
            {
               oppRecords = [Select Id,Name,Amount FROM Opportunity where Id = :recId]; 
            }
            // check if the selected similar opportunities already inserted earlier
            List<SimilarOpportunity__c> existsOpps = [Select id,Name,Opportunity__c,SimilarOpportunity__c 
                                                      FROM SimilarOpportunity__c
                                                      WHERE Opportunity__c = :oppRecords[0].Id 
                                                      AND SimilarOpportunity__c  IN :oppEditIds];
            //Add similar opp to set to make sure we dont reinsert them again
            if(!existsOpps.isEmpty())
            {
                for(SimilarOpportunity__c simOpp:existsOpps)
                {
                    existsOppIds.add(simOpp.SimilarOpportunity__c);
                }
            }
            for(Id id:oppEditIds)
            {
                if(!existsOppIds.contains(Id))
                {
                    SimilarOpportunity__c entity = new SimilarOpportunity__c();
                    entity.Opportunity__c = oppRecords[0].Id;
                    entity.SimilarOpportunity__c = Id;
                    insertSimilarOpps.add(entity);
                }
                
            }
            try{
                if(!insertSimilarOpps.isEmpty())
                {
                    insert insertSimilarOpps;
                }
            }
            catch(Exception ex)
            {
                throw new AuraHandledException(ex.getMessage());
            }
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
        public List<opportunity> tableRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled
        public Map<String,String> referenceValMap{get;set;}
    }
    
}