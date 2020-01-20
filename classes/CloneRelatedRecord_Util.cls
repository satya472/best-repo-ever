/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 29-March-2018
* Description: Utility Class
*/

public class CloneRelatedRecord_Util {
    
    /*
    * @description: method to fetch the data from custom metadata type
    */
    public static List<CloneRelatedRecord__mdt> fetchAllFieldMappings(String fieldMappingId) {        
        List<CloneRelatedRecord__mdt> fieldMappingsList = [SELECT Id, IsActive__c, DefaultValue__c, SourceField__c, TargetField__c,  
                                                       IsParent__c,ParentField__c, IsExternal__c, SourceRecordField__c FROM CloneRelatedRecord__mdt 
                                                       WHERE FieldMappingID__c = :fieldMappingId AND IsActive__c = TRUE];
        return fieldMappingsList;
    }  
    
    /*
    * @description: method to fetch the data from custom mmetadata type
    */
    public static List<SObject> createTargetRecordList(Map<Id,List<SObject>> sourceTargetObjectMap, List<SObject> sourceRecordList, 
                                                       List<CloneRelatedRecord__mdt> fieldMappingList, String targetObject, String keyField){    
        SObject targetRec ;               
        List<SObject> targetRecordList = new List<SObject>();
        
        //map the values        
        for(SObject sourceRec : sourceRecordList){
            List<SObject> targetParentList = sourceTargetObjectMap.get((String)sourceRec.get(keyField));
            for(SObject targetParent : targetParentList){                
                SObjectType targetRecType = Schema.getGlobalDescribe().get(targetObject);
                targetRec = targetRecType.newSObject() ;
                Map<String,Schema.SObjectField> targetRecfields = targetRecType.getDescribe().fields.getMap();
                
                for(SObject recordData : fieldMappingList){              
                    //get source field, source value, target field details 
                    String targetField = (String)recordData.get('TargetField__c');
                    String sourceField = (String)recordData.get('SourceField__c');
                    Object sourceFieldValue;
                    
                    //if there is no source field use default field value
                    if(sourceField != null){                                       
                        //if the field is a parent field
                        if((Boolean)recordData.get('IsParent__c')){
                            sourceFieldValue = targetParent.get((String)recordData.get('ParentField__c'));
                        }   
                        else if((Boolean)recordData.get('IsExternal__c')){
                            sourceFieldValue = targetParent.get((String)recordData.get('SourceField__c')) +'-'+
                                sourceRec.get((String)recordData.get('SourceRecordField__c')); 
                        }else{
                            sourceFieldValue = sourceRec.get(sourceField);
                        }
                    }
                    else
                        sourceFieldValue = recordData.get('DefaultValue__c');
                    
                    //map to the field on the basis of the data type                    
                    Schema.DisplayType fielddataType = targetRecfields.get((String)recordData.get('TargetField__c')).getDescribe().getType();
                    
                    if(fielddataType == Schema.DisplayType.BOOLEAN) 
                        targetRec.put(targetField, Boolean.valueOf(sourceFieldValue));                          
                    else
                        targetRec.put(targetField, sourceFieldValue);
                }
                targetRecordList.add(targetRec);
            }            
        }
        return targetRecordList;
    } 
    
    /*
    *Author: Naveen
    * @description: Generic method that copies values from Source to Destination object
    */
     public static List<SObject> createTargetRecords( List<SObject> sourceRecordList, 
                                                       string fieldMappingId, String targetObject,
                                                        String recordValue, String recId){    
        SObject targetRec ;               
        List<SObject> targetRecordList = new List<SObject>();
        Map<String,sObject> targetRecMap = new Map<String,sObject>();
        List<CloneRelatedRecord__mdt> fieldMappingList = CloneRelatedRecord_Util.fetchAllFieldMappings(fieldMappingId);
                                                            system.debug(' fieldMappingList ==  '+fieldMappingList);
        system.debug(' recordValue has '+recordValue);
                                                            system.debug(' recId has '+recId);
		system.debug(' sourceRecordList has '+sourceRecordList);                                                        
        String targetObjectQuery = ' Select ';

        Integer maxSize = fieldMappingList.Size();
        Integer progress = 0;
        for(SObject recordData : fieldMappingList)
        {   
            targetObjectQuery += (String)recordData.get('TargetField__c') + ',';
                
        }       
        targetObjectQuery = targetObjectQuery.removeEnd(',')+' FROM '+Schema.getGlobalDescribe().get(targetObject);
                                                            system.debug('  --- targetObjectQuery '+targetObjectQuery);
        List<sObject> targetList = Database.query(targetObjectQuery );
        for(sObject entity:targetList)
        {
            targetRecMap.put((String)entity.get('Name'),entity);
        }
        //map the values        
        for(SObject sourceRec : sourceRecordList)
        {
            SObjectType targetRecType = Schema.getGlobalDescribe().get(targetObject);
            targetRec = targetRecType.newSObject() ;
            Map<String,Schema.SObjectField> targetRecfields = targetRecType.getDescribe().fields.getMap();
            Boolean canInsert=true;
            
            for(SObject recordData : fieldMappingList)
            {              
                //get source field, source value, target field details 
                String targetField = (String)recordData.get('TargetField__c');
                String sourceField = (String)recordData.get('SourceField__c');
                system.debug(' targetField === '+targetField);
                system.debug(' sourceField === '+sourceField);
                Object sourceFieldValue;               
                //if there is no source field use default field value
                if(sourceField != null)
                {                            
                     String[] fieldLst = sourceField .split('\\.');
                      if(fieldLst.size() == 1)
                      {
                        sourceFieldValue = sourceRec.get(sourceField);
                      }else if(fieldLst.size() == 2)
                      {
                        sourceFieldValue = sourceRec.getSObject(fieldLst[0]).get(fieldLst[1]);
                      }
                }
                else
                {
                    sourceFieldValue = recordData.get('DefaultValue__c');
                }
               /* if( 'Name' == sourceField && targetRecMap.containsKey((String)sourceFieldValue ))
                {
                    system.debug(' === sourceFieldValue'+sourceFieldValue);
                    system.debug(' === targetRecMap'+targetRecMap);
                    system.debug(' Already Exists');
                    //canInsert = false; //make sure if the record exists we break out of loop. This variable avoids adding this rec to list
                    break;
                }*/
               //map to the field on the basis of the data type                    
                Schema.DisplayType fielddataType = targetRecfields.get((String)recordData.get('TargetField__c')).getDescribe().getType();
                if(fielddataType == Schema.DisplayType.BOOLEAN) 
                    targetRec.put(targetField, Boolean.valueOf(sourceFieldValue));                        
                else
                    targetRec.put(targetField, sourceFieldValue);
            }
            //String idFiled = 'LOAReportId__c';
             targetRec.put(recId, recordValue); 
            //if(canInsert){ 
                
            
            targetRecordList.add(targetRec);
            system.debug(' targetRecordList has '+targetRec);
            //}     
        }
        return targetRecordList;
    }
    
    
      
}