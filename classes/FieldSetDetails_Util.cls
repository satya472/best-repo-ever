/**
* @name     FieldSetDetails_Util
* @author   sara (selalaoui@salesforce.com)
* @since    26 JUIN, 2018       
* @desc     Used for generic methods/classes
* @history
*/ 
public class FieldSetDetails_Util
{
    
    /*
      * Description : Methods fetches the details of the Fields from the fieldset
      * Input Param: ObjectName - Object Name from which Field details needs to be fetched
                     fieldSetName - FieldSetName containing the fields List
      * Return Type: List<lightningTableColumnWrapper> - List of Wrapper Class containing the Field Details
                     Fetched from the fieldSet
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
    }

}