/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 10-Sept-2018
* Description: MeetingReportAttendeeController called from MeetingReportAttendeeComponent
*/

public class MeetingReportAttendeeController {
    
    //Methods for the generic record selector component
    @AuraEnabled
    public static String getSearchScope() {
       String searchScopeList = '[{"label":"Account Team", "value": "accountTeam","selected": "true"},'+
       			'{"label":"Account Contacts", "value": "accountContacts"},'+
                '{"label":"All Salesforce Users", "value":"allSFUsers"},'+
                '{"label":"All Contacts", "value":"allContacts"}]';              
        return searchScopeList;
    }
    
        /*
Method Name	: getFieldSetName
Purpose		: To get the FieldSet Name
*/
    @AuraEnabled
    public static String getFieldSetName(String searchScope) {
        String fieldSetName;
        if(searchScope != null && (searchScope == 'allSFUsers'|| searchScope == 'accountTeam')){
            fieldSetName = 'MeetingAttendeeUserFields';
        }else{
            fieldSetName = 'MeetingAttendeeContactFields';
        } 
        return fieldSetName;
    }
    
    /*
Method Name	: getSObjectName
Purpose		: To get the SObject Name 
*/
    @AuraEnabled
    public static String getSObjectName(String searchScope) {
        String sObjectName;
        if(searchScope != null && (searchScope == 'allSFUsers'|| searchScope == 'accountTeam')){
            sObjectName = 'User';
        }else{
            sObjectName = 'Contact';
        }
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
        if(searchScope == 'accountContacts' || searchScope == 'accountTeam'){
            parentFieldName='AccountId';
            parentRecordId = record.AccountId__c;
        }
        
        //get list of already existing attendee ids
        List<String> meetingAttendeeList =  new List<String>();
        List<MeetingAttendee__c> meetingAttendees = [SELECT ID, MeetingReportId__c, UserId__c, ContactId__c FROM MeetingAttendee__c 
                                                     WHERE MeetingReportId__c =: record.Id];
        for(MeetingAttendee__c ma : meetingAttendees){
            if(ma.UserId__c != null )
            	meetingAttendeeList.add(ma.UserId__c);
            else
                meetingAttendeeList.add(ma.ContactId__c);
        }
        
        try{   
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            query += ' WHERE ';
            
            //meeting attendee is associated already
            if(meetingAttendeeList.size()>0){
                string contactIds = String.join(meetingAttendeeList,'\',\'');
                query += 'ID NOT IN (\'' + contactIds+'\') AND ';
                whereFlag = true;
            }
                       
            //query by parentId
            if(searchScope == 'accountTeam'){
                query += 'ID IN ( SELECT UserId FROM AccountTeamMember WHERE ' ;
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
                query += ')' ;
                whereFlag = true;
            }else if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                query += '(' ;
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
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
    public static void createMeetingReportAttendee(String searchScope, String meetingReportId, Object[] contactList){     
         MeetingAttendee__c meetingAttendee;
         List<MeetingAttendee__c> MeetingAttendeeToCreateList = new List<MeetingAttendee__c>();
        
         for (Object value : contactList) {
            Map<String, Object> m = (Map<String, Object>)value;
            meetingAttendee =  new MeetingAttendee__c();
            meetingAttendee.MeetingReportId__c = meetingReportId;
            if(searchScope != null && (searchScope == 'allSFUsers'|| searchScope == 'accountTeam')){
                meetingAttendee.UserId__c = (String)m.get('Id'); 
            }else{
                meetingAttendee.ContactId__c = (String)m.get('Id'); 
            }  
            MeetingAttendeeToCreateList.add(meetingAttendee);
         }
        if(MeetingAttendeeToCreateList.size() > 0)
        	insert MeetingAttendeeToCreateList;
    }
        
}