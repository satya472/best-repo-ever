/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 5-June-2018
* Description: DisplayContactTableController called from DisplayContactComponent
*/

public class DisplayContactTableController {
    
    /*
Method Name	: getFieldSetData
Purpose		: To get the wrapper of Columns and Headers
*/
    @AuraEnabled
    public static String getFieldSetData(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if(FsMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        system.debug('result: '+result);
        return '['+result+']';
    }
    
    @AuraEnabled
    public static String getRecordsBCM(String sObjectName, String parentFieldName, String parentRecordId, String fieldNameJson, String recordId, String searchKey){
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        Boolean whereFlag = false;
        
        try{
            List<String> bcmContactList =  new List<String>();
            //get the list of Contacts as BCM on opportunity
            List<Buying_Center_Member__c> bcmRecords = [SELECT Id, Name,Contact__c, Opportunity__c FROM Buying_Center_Member__c 
                                                        WHERE Opportunity__c =:recordId AND Contact__c != null];
            for(Buying_Center_Member__c bcm : bcmRecords){
                bcmContactList.add(bcm.Contact__c);
            }
            
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            query += ' WHERE ';
            
            //contact is not a bcm already
            if(bcmContactList.size()>0){
                string contactIds = String.join(bcmContactList,'\',\'');
                query += 'ID NOT IN (\'' + contactIds+'\') AND ';
                whereFlag = true;
            }
            
            //query by parentId
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                query += '(' ;
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
                
                //query by ids
                List<String> accContactRelationshipSet = new List<String>(getAccountContactRelationship(parentRecordId));
                if(accContactRelationshipSet.size()>0){
                    string contactIds = String.join(accContactRelationshipSet,'\',\'');
                    query += ' OR ID IN (\'' + contactIds+'\')';
                } 
                query += ')' ;
                query += ' AND ' ; 
                whereFlag = true;                
            }
            
            //query by search key
            if(searchKey != NULL && searchKey != ''){   
                query += '(' ;
                for(String field: fieldNames){
                    if(!field.contains('Id'))
                        query += field+' Like \'%'+searchKey+'%\' OR ';
                }
                query = query.removeEnd(' OR ');
                query += ')' ;
                whereFlag = true;
            }else{
                query = query.removeEnd(' AND ');
            }
            if(!whereFlag){
                query = query.removeEnd(' WHERE ');
            }
            
            system.debug(query);
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            } 
            system.debug(lstResult);
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
        }
        catch(Exception e){
            System.debug(' Delete Failed on Query '+e.getMessage());
        }
        return result;
    }
    
    @AuraEnabled
    public static String getRecordsSCM(String sObjectName, String parentFieldName, String fieldNameJson, String recordId, String searchKey){       
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        Boolean whereFlag = false;
        
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            if(sObjectName != 'Contact'){
                query += ' WHERE IsActive = true';
                whereFlag = true;
            }
            else
                query += ' WHERE ';
            
            //check if the user is already a SCM
            if(whereFlag)
                query += ' AND ';            
            List<Buying_Center_Member__c> scmRecords = [SELECT Id, Name, User__c, Contact__c, Opportunity__c, Type__c
                                                        FROM Buying_Center_Member__c 
                                                        WHERE Opportunity__c =:recordId AND (Type__c='Selling Center' 
                                                                                             OR Type__c='Buying Center')];
            List<String> scmUserList =  new List<String>();
            for(Buying_Center_Member__c scm : scmRecords){
                if(sObjectName != 'Contact')
                	scmUserList.add(scm.User__c);
                else
                    scmUserList.add(scm.Contact__c);
            }
            
            if(scmUserList.size()>0){
                string userIds = String.join(scmUserList,'\',\'');
                query += '(ID NOT IN (\'' + userIds+'\')) ';
                whereFlag = true;
            }
            
            //User is an OpportunityTeamMember
            List<Id> otmUserIdList = new List<Id>();
            if(parentFieldName != NULL && parentFieldName != ''){
                List<OpportunityTeamMember> otmList = [SELECT ID, OpportunityId, UserId FROM OpportunityTeamMember 
                                                       WHERE OpportunityId =: recordId];
                for(OpportunityTeamMember otm: otmList){
                    otmUserIdList.add(otm.UserId);
                }
                
                if(whereFlag){
                    query += ' AND ';
                }
                query += '(' ;                            
                string otmUserIds = String.join(otmUserIdList,'\',\'');
                query += ' ID IN (\'' + otmUserIds+'\')';
                query += ')' ;
                query += ' AND ' ; 
                whereFlag = true; 
            }
            
            
            //query by search key
            if(searchKey != NULL && searchKey != ''){   
                if(whereFlag){
                    query += ' AND ';
                }
                query += '(' ;
                for(String field: fieldNames){
                    if(!field.contains('Id'))
                        query += field+' Like \'%'+searchKey+'%\' OR ';
                }
                query = query.removeEnd(' OR ');
                query += ')' ;
                whereFlag = true;
            }else{
                query = query.removeEnd(' AND ');
            }
            if(!whereFlag){
                query = query.removeEnd(' WHERE ');
            }
            
            system.debug(query);
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            } 
            system.debug(lstResult);
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
            
        }
        catch(Exception e){
            System.debug(' Delete Failed on Query '+e.getMessage());
        }
        return result;
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getAttributeData(String sObjectName, String fieldSetName) {
        Map<String, List<String>> fieldValueMap = new Map<String, List<String>> ();
        
        try{
            // Get the describe for the object
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
            
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            
            if(FsMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    String dataType = String.valueOf(f.getType()).toLowerCase();
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"isAttribute":"true",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    
                    if(dataType == 'PICKLIST'){
                        List<String> options = new List<String>();
                        // Get the field dynamically
                        DescribeFieldResult fieldResult = objResult.fields.getMap().get(f.getFieldPath()).getDescribe();
                        List<Schema.PicklistEntry> picklistVal = fieldResult.getPicklistValues();
                        for (Schema.PicklistEntry p: picklistVal) {
                            options.add(p.getLabel());
                        }
                        fieldValueMap.put(jsonPart, options);
                    }else{
                        fieldValueMap.put(jsonPart, new List<String>());
                    }                    
                }
            }
        }
        catch(Exception e){
            system.debug('Error in get Attribute Data'+ e.getMessage());
        }
        system.debug('resultDataTable: '+fieldValueMap);
        return fieldValueMap;
    }
    
    private static Set<String> getAccountContactRelationship(String parentRecordId){
        Set<String> lstResult = new Set<String>();        
        List<AccountContactRelation> accountContactList = [SELECT AccountId, ContactId FROM AccountContactRelation 
                                                           WHERE AccountId =:parentRecordId];
        for(AccountContactRelation obj: accountContactList){
            lstResult.add(obj.ContactId);
        }
        return lstResult;
    }
    
    /*
* @description:create Buying Center Members 
*/     
    @AuraEnabled
    public static void createBuyingCentreMembers(String oppId, List<Buying_Center_Member__c> bcmList){
        //BuyingCenterController.createBuyingCentreMembers(oppId, bcmList);
    }
    
}