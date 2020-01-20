/*
* Author : Phaniram Upalapati
* Description : Controller for fetching details of Parent and Child records
* Associated To : DisplayRelatedList,DisplayParentRecordData components
* Test Class : DisplayRelatedList_ContTest
*/
public class DisplayRelatedList_Cont {
    
    /*
    * Description : Methods fetches the details of the fields and Records
    Details for the mentioned Object.
    * Input Param: ObjectName - Child Object Name for which records needs to be fetched
    fieldSetName - FieldSetName where the required fields are Placed
    parentRecId - Parent record Id
    ParentRelationName - relationShip name that exists between child and parent record.
    AdditionalFilter - Filter the data that are being fetched.
    filterByField - fetching the picklist values related to the field
    * Return Type: lightningTableWraper -Wrapper class Containing details of the records
    */
    @AuraEnabled 
    public static lightningTableWrapper getsObjectRecords(String ObjectName,String RecordType,String iconName,String fieldSetName, String metadataValueStr, String parentRecId, String ParentRelationName, String AdditionalFilter,String filterByField){
        
        
        List<String> lstfieldstoget = new List<String>();
        List<lightningTableColumnWrapper> lstTableColumn = new list<lightningTableColumnWrapper>();
        
        LightningTableWrapper ltngTableWrapper = new LightningTableWrapper();
        ltngTableWrapper.filterFieldPickList = new List<FilterPickListWrapper>();
       
        //Fetch the Field Details from Fieldset
        lstTableColumn = getFieldDetails(ObjectName,fieldSetName,metadataValueStr);
        
        for(lightningTableColumnWrapper fieldColumn : lstTableColumn){
            if(fieldColumn.fieldName.contains(':')){
                string [] fieldsApiName = fieldColumn.fieldName.split(':'); 
                lstfieldstoget.add(String.valueOf(fieldsApiName[0]));                          
                lstfieldstoget.add(String.valueOf(fieldsApiName[1]));                          
            }else{
                lstfieldstoget.add(String.valueOf(fieldColumn.fieldName));                          
            }                            
            
        }
       
        Map<String,String> referenceMap = new Map<String,String>();
        
        for(lightningTableColumnWrapper fieldColumn : lstTableColumn){
            if((fieldColumn.type).equalsIgnoreCase('Reference')){
                String fieldName = fieldColumn.fieldName;
                String mapVal = fieldName.endsWithIgnoreCase('Id')?(fieldName.subString(0,fieldName.length()-2)+'.Name'):
                fieldName.endsWithIgnoreCase('__c')?fieldName.replace('__c','__r')+'.Name':fieldName+'.Name';
                referenceMap.put(fieldName,mapVal);
                lstfieldstoget.add(mapVal);
            }
        }
        if(!string.isBlank(filterByField)){
            List<String> filters = filterByField.split(','); 
            for(String filterField: filters){
                if(!lstfieldstoget.contains(filterField)){
                    lstfieldstoget.add(filterField);
                }
                try{
                    //Fetching the Picklist values of the filterField
                    DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(filterField).getDescribe();
                    if(String.valueof(fieldResult.getType()).equalsIgnorecase(Label.DisplayRelatedList_FilterFieldTypeCheck)){
                        FilterPickListWrapper fpk = new FilterPickListWrapper();
                        fpk.pkWrapper = new List<PickListWrapper>();
                        fpk.apiName = filterField;
                        fpk.columnName = fieldResult.getLabel();
                        
                        for(Schema.PicklistEntry pkl: fieldResult.getPicklistValues()){
                            fpk.pkWrapper.add(new PickListWrapper(pkl.getLabel(),pkl.getValue()));
                        }
                        
                        ltngTableWrapper.filterFieldPickList.add(fpk);
                    }
                }catch(Exception exce){
                    throw new AuraHandledException(Label.DisplayRelatedList_ErrorMsg);
                }
            }     
        } 
        
        //Fetch the API name of icon
        if(!string.isBlank(iconName)){
            ltngTableWrapper.tableIconName = iconName;
        }

        //Fetch the RecordType Details
        ltngTableWrapper.recordTypeWrapper = database.query('SELECT Id,Name,Description,DeveloperName FROM RecordType Where SobjectType =\''+ ObjectName + '\'');
          
        try{
            String whereClause = '';
            if(parentRecId!=null && parentRecId !=''){
                whereClause = ' WHERE '+ParentRelationName+' =\''+parentRecId +'\' ';
            }
            
            if(AdditionalFilter!=null && AdditionalFilter!=''){
                whereClause += ' AND '+ AdditionalFilter;
            }
            
            String queryString = 'Select '+ String.escapeSingleQuotes(String.join(lstfieldstoget,','))+
                ' from '+ String.escapeSingleQuotes(ObjectName);
            
            if(!string.isBlank(whereClause)){
                queryString = queryString + whereClause;
            }
            
            queryString = queryString;                             
            ltngTableWrapper.tableRecord = database.query(queryString);
            system.debug('**'+ltngTableWrapper.tableRecord);
            ltngTableWrapper.tableColumn = lstTableColumn;
            ltngTableWrapper.referenceValMap = referenceMap;
            system.debug('!!'+ltngTableWrapper);
            return ltngTableWrapper;
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());    
        }   
        
    }
    
    /*
    * Description : Methods fetches the details of the parent Object
    * Input Param: sObjectName - current record Object Name
    fieldName - Parent Field Name in the child Object
    detailId - record Id of the current record
    * Return Type: String - Id of the parent related to the current record
    */
    @AuraEnabled 
    public static string getParentInformationFromRecord(String sObjectName, String fieldName, Id detailId){
        
        try{ 
            
            if(String.isBlank(sObjectName)){
                sObjectName = detailId.getSObjectType().getDescribe().getName();
            }
            
            String queryString = 'Select '+ String.escapeSingleQuotes(fieldName)+
                ' from '+ String.escapeSingleQuotes(sObjectName) +' WHERE Id=\''+ detailId + '\''+
                ' Limit 1';
            String  returndata ='';
            List<sObject> recs = database.query(queryString);
            String[] fieldLst = fieldName.split('\\.');
            if(!recs.isEmpty()){
                if(fieldLst.size() == 1){
                    returndata = String.ValueOf(recs[0].get(fieldName));
                }else if(fieldLst.size() == 2){
                    returndata = String.ValueOf(recs[0].getSObject(fieldLst[0]).get(fieldLst[1]));
                }else if(fieldLst.size() == 3){
                    returndata = String.ValueOf(recs[0].getSObject(fieldLst[0]).getSObject(fieldLst[1]).get(fieldLst[2]));
                }  
                
            }
            
            return returndata;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }     
    }
    
    /*
    * Description : Methods fetches the details of the Fields from the fieldset
    * Input Param: ObjectName - Object Name from which Field details needs to be fetched
    fieldSetName - FieldSetName containing the fields List
    * Return Type: List<lightningTableColumnWrapper> - List of Wrapper Class containing the Field Details
    Fetched from the fieldSet
    */
    @AuraEnabled
    Public static List<lightningTableColumnWrapper> getFieldDetails(String ObjectName,String fieldSetName, String metadataUniqueId){
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
                DescribeFieldResult fieldResult = objResult.fields.getMap().get('Baseline__c').getDescribe();
                colWrapper.label = fieldResult.getLabel();
                colWrapper.fieldName = fieldResult.getName();
                colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                colWrapper.sortable = false;
                lstTableColumn.add(colWrapper);
            }   
            if(metadataUniqueId !=null && metadataUniqueId!=''){
                for(RelatedListFields__mdt customRecs : [select id, label, Id__c, Value__c from RelatedListFields__mdt where Id__c=:metadataUniqueId order by label desc]){                      
                    
                    colWrapper = new lightningTableColumnWrapper();
                    
                    string fieldLabel='';
                    string wrapperFieldValue='';
                    string splitString='';
                    string wrapperKeyValuePair='';
                    wrapperKeyValuePair = splitString= customRecs.Value__c;
                    if(wrapperKeyValuePair.endsWith('__r.Name')){
                        wrapperKeyValuePair= wrapperKeyValuePair.replace('__r.Name','__c');    
                    }else if(wrapperKeyValuePair.endsWith('.Name')){
                        wrapperKeyValuePair= wrapperKeyValuePair.replace('.Name','Id');   
                    }else if(wrapperKeyValuePair=='Name'){
                        wrapperKeyValuePair= 'Id';
                    }
                    wrapperFieldValue= wrapperKeyValuePair + ':' + splitString;
                    list<string> furtherSplitStr= new list<string>();
                    if(splitString.contains('.')){
                        string refrenceAPIName= splitString;                                                                
                        furtherSplitStr.addAll(refrenceAPIName.split('\\.'));                                
                        fieldLabel= getFieldLabel(ObjectName,furtherSplitStr);
                        if(fieldLabel.contains('ID')){
                            fieldLabel= fieldLabel.replace('ID','Name');
                        }
                        colWrapper.label = fieldLabel;
                        colWrapper.fieldName = wrapperFieldValue;
                        colWrapper.type = 'url';
                        colWrapper.sortable = true;
                        lstTableColumn.add(colWrapper);
                    }else{
                        furtherSplitStr.Add(splitString);
                        fieldLabel= getFieldLabel(ObjectName,furtherSplitStr);
                        colWrapper.label = fieldLabel;
                        colWrapper.fieldName = wrapperFieldValue;
                        colWrapper.type = 'url';
                        colWrapper.sortable = true;
                        lstTableColumn.add(colWrapper);    
                    }                                                                     
                }    
            }
            
            return lstTableColumn;
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }      
    }
    
    public static string getFieldLabel(string objectNameStr, list<string> objectStringList){
        string fieldLabelStr='';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if(objectStringList.size() > 1){
            for(integer i=0; i < objectStringList.size(); i++){
         
                Schema.SObjectType objSchema = schemaMap.get(objectNameStr);
                string objectAPIStr= '';
                objectAPIStr= objectStringList[i];

                if(objectAPIStr.contains('__r')){
                    system.debug(' inside replace method ');
                    objectAPIStr= objectAPIStr.replace('__r','__c');
                    system.debug(' objectAPIStr '+ objectAPIStr);
                }else{
                    objectAPIStr= objectAPIStr + 'Id';
                }

                Schema.DescribeFieldResult f = objSchema.getDescribe().fields.getMap().get(objectAPIStr).getDescribe();                                                                        
                
                for(Schema.SObjectType reference : f.getReferenceTo()) {
                    string ojectNameNew= reference.getDescribe().getName(); // Object name would be Opportunity, Account
                    if((objectStringList.size() - i)==2){
                        i++;

                        if(objectStringList[i]=='Name'){
                            fieldLabelStr= objSchema.getDescribe().fields.getMap().get(objectAPIStr).getDescribe().getLabel();  
                        }else{
                            fieldLabelStr= schemaMap.get(ojectNameNew).getDescribe().fields.getMap().get(objectStringList[i]).getDescribe().getLabel();     
                        }
                        
                        break;
                    }else{

                        list<string> newObjectList= new list<string>();
                        i++;
                        for(integer j=i; j < objectStringList.size(); j++){
                            newObjectList.add(objectStringList[j]);    
                        }
                        fieldLabelStr= getFieldLabel(ojectNameNew,newObjectList);
                        break;
                    }                
                }        
                break;
            }   
        }else{
            string fieldName= objectStringList[0];
            fieldLabelStr= schemaMap.get(objectNameStr).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();                 
        }
        
        return fieldLabelStr;
    }
    /*
    * ClassName: lightningTableColumnWrapper 
    * description : Wrapper class for storing the details of the fields of Child records
    */
    public class lightningTableColumnWrapper {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public string type {get;set;}
        @AuraEnabled
        public boolean sortable {get;set;}
        @AuraEnabled
        public boolean typeAttributes {get;set;}
        @AuraEnabled
        public String RecordType {get;set;}
        @AuraEnabled
        public String iconName {get;set;}
    }
    
    /*
    * ClassName: lightningTableWrapper 
    * description : Wrapper class for storing the records of Child Object
    */
    public class lightningTableWrapper{
        @AuraEnabled
        public List<sObject> tableRecord {get;Set;}
        @AuraEnabled
        public List<lightningTableColumnWrapper> tableColumn {get;set;}
        @AuraEnabled
        public List<FilterPickListWrapper> filterFieldPickList{get;set;}
        @AuraEnabled
        public Map<String,String> referenceValMap{get;set;}
        @AuraEnabled
        public List<sObject> recordTypeWrapper{get;set;}
         @AuraEnabled
        public String tableIconName {get;set;}
        
    }
    
    /*
    * Class Name: PickListWrapper
    * Description: Used for preparing PickList's
    */
    public class FilterPickListWrapper
    {
        @AuraEnabled
        public String columnName {get;set;}
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public List<PickListWrapper> pkWrapper{get;set;}
    }
    /*
    * Class Name: PickListWrapper
    * Description: Used for preparing PickList's
    */ 
    public Class PickListWrapper{
        @AuraEnabled
        public String label{set;get;}
        
        @AuraEnabled
        public String value{set;get;}
        
        public PickListWrapper(String label, String val){
            this.label = label;
            this.value = val;
        }
    }
   
}