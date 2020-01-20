/*
* Author : Naveen Kumar Gadicherla
* Description : Controller for fetching Deviation Records.
* AdditionalFilter: Filter provided by admin as a string
*filterByField: Pikclist Filter provided by admin on Component
*fieldMappingId: Unique mapping id on custom metadata 
*fieldName: Parent Field Name on Target Object(eg: LOA Report Id on Approval Topic)
*sourceReportField: Target Parent's field on Cuurent record
*recordFields: Filter Field on the records on which component sitting. Used in query obtained from DA
* Test Class : FetchDeviationRecords_ContTest
*/
public class FetchDeviationRecords
{
    @AuraEnabled 
    public static LightningTableWrapper getSourceRecords(String ObjectName,String fieldSetName ,
                                                            String AdditionalFilter,String filterByField,
                                                            String fieldMappingId,
                                                            String fieldName, String fieldValue,
                                                            String targetObject,String sourceReportField,
                                                            string paramString,
                                                            String recordId, String recObject, String recordFields)
    {
        List<String> lstfieldstoget = new List<String>();
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper>();
        LightningTableWrapper ltngTableWrapper = new LightningTableWrapper();
        ltngTableWrapper.fieldByPickList = new List<PickListWrapper>();
        List<string>  addFilterList;
        List<string>  recFilterList;
        List<SObject> recEntities;
        String recObjectQuery = 'Select Id ';
        If(!string.isBlank(AdditionalFilter) && !string.isBlank(recordFields) )
        {
            addFilterList = AdditionalFilter.split(',');
            recFilterList = recordFields.split(',');
            recObjectQuery += ','+ recordFields + ' FROM '; 
            if(!string.isBlank(recObject))
            {
                recObjectQuery += recObject + ' WHERE '+'Id' + '='+'\''+recordId+'\'';
            }
            if( !string.isBlank(recObjectQuery))
            {
                recEntities = database.query(recObjectQuery);
            }
        }
        
        String mtdFields = '';
        Map<String,String> avoidDupFields = new Map<String,String>();
        String sField = '';
        String targetWhere = '';
        if( (sourceReportField != null && sourceReportField != '') &&
           (fieldValue != null && fieldValue != '') )
        {
            targetWhere += ' WHERE ' + sourceReportField + '='+ '\''+fieldValue+'\'';
        }
        //DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('LOADeviation__c').getDescribe();
        List<CloneRelatedRecord__mdt> mdtEntities = CloneRelatedRecord_Util.fetchAllFieldMappings(fieldMappingId);
        List<SObject> targetRecordList = new List<SObject>();
        Map<String,sObject> targetRecMap = new Map<String,sObject>();
        
        String targetObjectQuery = ' Select Id ,';
        
        
        for(CloneRelatedRecord__mdt mdtEntity: mdtEntities)
        { 
            if(  null !=  mdtEntity.SourceField__c  && '' != mdtEntity.SourceField__c )
            {
                mtdFields += mdtEntity.SourceField__c + ',';
                avoidDupFields.put(mdtEntity.SourceField__c,mdtEntity.SourceField__c);
            }
            if(mdtEntity.IsExternal__c == true && (mdtEntity.TargetField__c != null && mdtEntity.TargetField__c != ''))
            {
                sField = mdtEntity.TargetField__c; 
            }
            //framing target object query
            if(!avoidDupFields.containsKey((String)mdtEntity.get('TargetField__c')))
            {
                targetObjectQuery += (String)mdtEntity.get('TargetField__c') + ','; 
            }
        }
        targetObjectQuery = targetObjectQuery.removeEnd(',')+' FROM '+Schema.getGlobalDescribe().get(targetObject) +targetWhere;
        List<sObject> targetList = Database.query(targetObjectQuery );
        List<sObject> targetExists = new List<SObject>();
        List<sObject> notExists = new List<SObject>();

        for(sObject entity:targetList)
        {
            targetRecMap.put((Id)entity.get(sField),entity);
        }
        //Fetch the Field Details from Fieldset
        lstTableColumn = getFieldDetails(ObjectName,fieldSetName);
        
        for(lightningTableColumnWrapper fieldColumn : lstTableColumn)
        {
            IF(!avoidDupFields.containsKey(String.valueOf(fieldColumn.fieldName)))
            {
                lstfieldstoget.add(String.valueOf(fieldColumn.fieldName));
            }
        } 
        Map<String,String> referenceMap = new Map<String,String>();

        for(lightningTableColumnWrapper fieldColumn : lstTableColumn){
            if((fieldColumn.type).equalsIgnoreCase('Reference')){
                String fldName = fieldColumn.fieldName;
                String mapVal = fldName.endsWithIgnoreCase('Id')?(fldName.subString(0,fldName.length()-2)+'.Name'):
                fldName.endsWithIgnoreCase('__c')?fldName.replace('__c','__r')+'.Name':fldName+'.Name';
                referenceMap.put(fieldName,mapVal);
                lstfieldstoget.add(mapVal);
            }
        }
        if(!string.isBlank(filterByField)  )
        {
            try{
                //Fetching the Picklist values of the filterByField
                List<String> filters = filterByField.split(',');
                for( String fldName : filters)
                {
                    PickListWrapper pkLstEntity = new PickListWrapper();
                    pkLstEntity.fieldByFieldPickList = new List<PickListFieldWrapper>();
                    DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(fldName).getDescribe();
                    if(String.valueof(fieldResult.getType()).equalsIgnorecase('PickList'))
                    {
                        for(Schema.PicklistEntry pkl: fieldResult.getPicklistValues())
                        {
                            pkLstEntity.fieldByFieldPickList.add(new PickListFieldWrapper(pkl.getLabel(),pkl.getValue()));  
                        }
                    }
                    pkLstEntity.apiName = fldName;
                    pkLstEntity.columnName = fieldResult.getLabel();
                    ltngTableWrapper.fieldByPickList.add(pkLstEntity);
                }
            }catch(Exception exce)
            {
                throw new AuraHandledException('Please check the FilterBy Input value provided');
            }
        }
        try
        {
            String whereClause = ' ';   
            String queryString;
            if( !string.isBlank(AdditionalFilter) && !string.isBlank(recordFields))
            { 
                whereClause += ' WHERE ';
                for(Integer i = 0; i<addFilterList.size();i++)
                {
                    if( i < addFilterList.size()-1 ) 
                    {
                        whereClause += addFilterList[i]+'='+'\''+recEntities[0].get(recFilterList[i])+'\''+' AND ';
                    }
                    else
                    {
                        whereClause += addFilterList[i]+'='+'\''+recEntities[0].get(recFilterList[i])+'\'';
                    }
                }
            }
            else if( !string.isBlank(AdditionalFilter))
            {
                whereClause +=' WHERE ' + AdditionalFilter;
            }
            if(!string.isBlank(whereClause) && !string.isBlank(paramString))
            {
                queryString = paramString + whereClause;
            }
            else
            {   
                queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+','+mtdFields.removeEnd(',')+' from '+ String.escapeSingleQuotes(ObjectName);
            }
            if(!string.isBlank(whereClause) && string.isBlank(paramString))
            {
                queryString = queryString + whereClause;
            }
            queryString = queryString +  ' Limit 1000'; 
            List<sObject> devList = database.query(queryString);
            for( sObject devEntity : devList)
            {
                If(targetRecMap.containsKey(devEntity.Id))
                {
                    targetExists.add(devEntity);
                }
                else
                {
                    notExists.add(devEntity);
                }
            }
            ltngTableWrapper.existingRecord = targetExists;
            ltngTableWrapper.nonExistingRecord = notExists;
            ltngTableWrapper.tableColumn = lstTableColumn;
            return ltngTableWrapper;  
        }catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());    
        }   
        
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
            
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
            Schema.FieldSet fieldSetObj = objResult.FieldSets.getMap().get(fieldSetName);
            
            lightningTableColumnWrapper colWrapper;
            if(!Test.isRunningTest()){
                for(Schema.FieldSetMember fieldResult : fieldSetObj.getFields()){
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
    
    /*
     * createTargetObjectRecords: Creates target records
     */
    @AuraEnabled
    Public static void createTargetObjectRecords(List<SObject> sourceRecordList,
                                                 string fieldMappingId, 
                                                 String targetObject, 
                                                 String recValue,
                                                 String recId)
    {
        List<sObject>  objEntities = CloneRelatedRecord_Util.createTargetRecords(sourceRecordList,fieldMappingId,targetObject,recValue,recId);
        try{
            if(objEntities.size() >0)
            {
                insert objEntities;
            }
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());  
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
        public List<sObject> existingRecord {get;Set;}
        @AuraEnabled
        public List<sObject> nonExistingRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
        @AuraEnabled
        public List<PickListWrapper> fieldByPickList{get;set;}
        @AuraEnabled
        public Map<String,String> referenceValMap{get;set;}
        
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
    
}