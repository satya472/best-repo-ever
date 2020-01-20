/*
* Author : Phaniram Upalapati
* Description : Controller for fetching Parent Child records
* Associated To : DisplayParentChildRecords
* Test Class : 
*/
public With Sharing class DisplayParentChildRecords_Cont {
    
    /*
      * Description : Methods fetches the details of the Child Records
      * Input Param: parentObjName - Object Name of the Parent
                     childObjName - Object Name of the child
                     parentFilter - Filter to fetch the Parent records
                     childFilter - Filter to fetch the child records
                     fieldApiName - API Name referring to the parent Object
                     childRecordFieldSet - Fielset containing the fields details that needs to be displayed on to screen
      * Return Type: List<ParentChildWrapper> - List of Wrapper class records containing Parent and Child record Details
                     
    */ 
    @AuraEnabled
    public static List<ParentChildWrapper> getParentChildRecordDetails(String parentObjName, String childObjName, String parentFilter, String childFilter, String fieldApiName,String childRecordFieldSet){

        List<ParentChildWrapper> recordsWrapper = new List<ParentChildWrapper>();
        
        Map<Id,sobject> parentRecMap = getParentRecords(parentObjName,parentFilter);
       
        TableWrapper childWrapperDetails = getChildRecords(childObjName,childFilter,fieldApiName,childRecordFieldSet,parentRecMap.keySet());
        
        List<sObject> recMap;
        ParentChildWrapper wrapper;
        for(Id parentId: parentRecMap.keySet()){
            recMap = new List<sObject>();
            wrapper = new ParentChildWrapper();
            for(sobject sRec: childWrapperDetails.tableRecord){
                if(sRec.get(fieldApiName) == parentId){
                    recMap.add(sRec);
                }
            }
            
            wrapper.childRecordsDetails = new TableWrapper();
            wrapper.childRecordsDetails.tableRecord = new List<sObject>(recMap);
            wrapper.childRecordsDetails.tableColumn = new List<TableColumnWrapper>(childWrapperDetails.tableColumn);
            wrapper.parentRecId = parentId;
            wrapper.parentRecName = (String)(parentRecMap.get(parentId)).get('Name');
            
            recordsWrapper.add(wrapper);
        }
        
        return recordsWrapper;
        
    }

    /*
      * Description : Methods fetches the details of the Parent Records
      * Input Param: parentObjName - Object Name of the Parent
                     parentFilter - Filter to fetch the Parent records
      * Return Type: Map<Id,sobject> - Map of parent Records          
    */ 
    private static Map<Id,sobject> getParentRecords(String parentObjName, String parentFilter){
        
        String query = 'Select Id,Name from '+parentObjName;
        if(!String.isBlank(parentFilter)){
            query = query+' Where '+ parentFilter;
        }
        
        Map<Id,sobject> parentRec = new Map<Id,sobject>(Database.query(query));
        
        return parentRec;
    }   

     /*
      * Description : Methods fetches the details of the Child Records
      * Input Param: childObjName - Object Name of the child
                     childFilter - Filter to fetch the child records
                     fieldApiName - API Name referring to the parent Object
                     fieldSet - Fielset containing the fields details that needs to be displayed on to screen
                     parentRecordIds - List of ParentIds for which the child records needs to be fetched
      * Return Type: TableWrapper - Wrapper class containing Column and Record Details
                     
    */    
    private static TableWrapper getChildRecords(String childObjName, String childFilter, String fieldApiName, String fieldSet,Set<Id> parentRecordIds){
        
        TableWrapper recordDetailsWrapper = new TableWrapper();
        List<TableColumnWrapper> columnDetails = getFieldDetails(childObjName,fieldSet);
        List<String> fields = new List<String>();
        
        for(TableColumnWrapper fieldColumn : columnDetails){
              fields.add(String.valueOf(fieldColumn.fieldName));
        }
        
        String queryString = 'Select '+fieldApiName+','+ String.escapeSingleQuotes(String.join(fields,','))+
                                     ' from '+ String.escapeSingleQuotes(childObjName);
        
        if(!parentRecordIds.isEmpty()){
            queryString = queryString +' Where '+fieldApiName+' IN :parentRecordIds';
        }else{
            throw new AuraHandledException(Label.DisplayParentChildRecords_ErrorMsg);
        }
        
        if(!String.isBlank(childFilter)){
            queryString = queryString + ' AND '+ childFilter;
        }

        recordDetailsWrapper.tableColumn = columnDetails;

        recordDetailsWrapper.tableRecord = Database.query(queryString);
        
        return recordDetailsWrapper;
    }
    
    /*
      * Description : Methods fetches the details of the Fields from the fieldset
      * Input Param: ObjectName - Object Name from which Field details needs to be fetched
                     fieldSetName - FieldSetName containing the fields List
      * Return Type: List<lightningTableColumnWrapper> - List of Wrapper Class containing the Field Details
                     Fetched from the fieldSet
    */
    @AuraEnabled
    Public static List<TableColumnWrapper> getFieldDetails(String ObjectName,String fieldSetName){
          try{ 
            List<TableColumnWrapper> lstTableColumn = new list<TableColumnWrapper> ();
            
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
            Schema.FieldSet fieldSetObj = objResult.FieldSets.getMap().get(fieldSetName);

              TableColumnWrapper colWrapper;
              if(!Test.isRunningTest()){
                for(Schema.FieldSetMember fieldResult : fieldSetObj.getFields()){
                   colWrapper = new TableColumnWrapper();
                   colWrapper.label = fieldResult.getLabel();
                   colWrapper.fieldName = fieldResult.getFieldPath();
                   colWrapper.type = String.valueof(fieldResult.getType()).toLowerCase();
                   colWrapper.sortable = true;
                   lstTableColumn.add(colWrapper);
                }
                  
              }else{
                  //For test Class Purpose
                   colWrapper = new TableColumnWrapper();
                   DescribeFieldResult fieldResult = objResult.fields.getMap().get('Name').getDescribe();
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
     * ClassName: lightningTableColumnWrapper ,
     * description : Wrapper class for storing the details of the fields of Child records
     */
     public class TableColumnWrapper {
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
     * ClassName: TableWrapper 
     * description : Wrapper class for storing the records of Child Object
     */
    public class TableWrapper{
        @AuraEnabled
        public List<sObject> tableRecord {get;Set;}
        @AuraEnabled
        public List<TableColumnWrapper> tableColumn {get;set;}       
    }
    
    /*
     * ClassName: ParentChildWrapper 
     * description : Wrapper class for storing the records of Child Object
     */
    public class ParentChildWrapper{
        @AuraEnabled
        public String parentRecName{set;get;}
        @AuraEnabled
        public String parentRecId{set;get;}
        @AuraEnabled
        public TableWrapper childRecordsDetails {get;set;}       
    }

}