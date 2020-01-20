/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 10-Sept-2018
* Description: MeetingReportController called from MeetingReportComponent
*/

public class MeetingReportOpportunityController {
    
    //Methods for the generic record selector component
    @AuraEnabled
    public static String getSearchScope() {
        String searchScopeList = '[{"label":"Account Opportunities", "value": "accountOpportunities","selected": "true"},'+
                '{"label": "My Opportunities", "value": "myOpportunities"}, {"label": "All Opportunities", "value": "allOpportunities"}]';                
        return searchScopeList;
    }
    
        /*
Method Name	: getFieldSetName
Purpose		: To get the FieldSet Name
*/
    @AuraEnabled
    public static String getFieldSetName() {
        String fieldSetName = 'MeetingReportOpportunityFields';        
        return fieldSetName;
    }
    
    /*
Method Name	: getSObjectName
Purpose		: To get the SObject Name 
*/
    @AuraEnabled
    public static String getSObjectName() {
        String sObjectName = 'Opportunity';
        return sObjectName;
    }    
    
    
    /*
Method Name	: getTableRows
Purpose		: To get the table data
*/    
    @AuraEnabled
    public static List<sObject> getRecords(String sObjectName, String searchScope, String fieldNameJson, MeetingReport__c record){        
        List<sObject> lstResult = new List<sObject>();
        Boolean whereFlag = false;
        String parentFieldName = null; 
        String parentRecordId = null;
        
        //SearchScope criterias
        if(searchScope == 'accountOpportunities'){
            parentFieldName='AccountId';
            parentRecordId = record.AccountId__c;
        }else if(searchScope == 'myOpportunities'){
            parentFieldName='OwnerId';
            parentRecordId = UserInfo.getUserId();
        }
        
        //get list of already existing opportunity ids
        List<String> meetingOppList =  new List<String>();
        List<MeetingOpportunities__c> meetingOpps = [SELECT ID,MeetingReportId__c,Opportunity__c FROM MeetingOpportunities__c 
                                                     WHERE MeetingReportId__c =: record.Id];
        for(MeetingOpportunities__c mo : meetingOpps){
            meetingOppList.add(mo.Opportunity__c);
        }
        
        try{   
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            query += ' WHERE ';
            
            //opp is not a meeting opp already
            if(meetingOppList.size()>0){
                string oppIds = String.join(meetingOppList,'\',\'');
                query += 'ID NOT IN (\'' + oppIds+'\') AND ';
                whereFlag = true;
            }
                       
            //query by parentId
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                query += '(' ;
                query += parentFieldName + ' = \'' +  parentRecordId + '\'';
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
        }
        catch(Exception e){
            System.debug(' Delete Failed on Query '+e.getMessage());
        }
        return lstResult;
    }
    
    
    /*
* @description:create Meeting Opportunities
*/ 
    @AuraEnabled
    public static void createMeetingReportOpp(String searchScope, String meetingReportId, Object[] oppList){     
         MeetingOpportunities__c meetingOppty;
         List<MeetingOpportunities__c> meetingOpptyToCreateList = new List<MeetingOpportunities__c>();
        
         for (Object value : oppList) {
            Map<String, Object> m = (Map<String, Object>)value;
            meetingOppty =  new MeetingOpportunities__c();
            meetingOppty.MeetingReportId__c = meetingReportId;
            meetingOppty.Opportunity__c = (String)m.get('Id'); 
            meetingOpptyToCreateList.add(meetingOppty);
         }
        if(meetingOpptyToCreateList.size() > 0)
        	insert meetingOpptyToCreateList;
    }
        
}