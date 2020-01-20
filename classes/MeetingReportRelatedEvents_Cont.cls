/*
* Author: Naveen Kumar Gadicherla
* Company: Accenture
* Date: 05-Sep-2018
* Description: MeetingReportRelatedEvents_Cont called from MeetingReportRelatedEvents component
*/

public class MeetingReportRelatedEvents_Cont {
    
    /*
	*Method Name	: getTableRows
	*Purpose		: To get the table data
	*                 sObjectName->Name of the object to be queried.
	*				  searchScope: Defines the searchscope selected in UI.
	*				  fieldNameJson: Json representing fields.
	*                 record: Record on which component is placed.
	*/    
    @AuraEnabled
    public static List<sObject> getEventRecords(String sObjectName, String searchScope, String fieldNameJson, MeetingReport__c record)
    {
        system.debug('sObjectName: '+sObjectName);
        system.debug('searchScope: '+searchScope);
        system.debug('fieldNameJson: '+fieldNameJson);
        system.debug('record: '+record);
        
        List<sObject> lstResult = new List<sObject>();
        Boolean whereFlag = false;
        String parentFieldName = null; 
        String parentRecordId = null;
        //SearchScope criterias
        if(searchScope == 'accRelEvents'){
            parentFieldName='AssetId__r.AccountId';
            parentRecordId = record.AccountId__c;
        }
        
        try
        {
                    
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            query += ' WHERE ';
                
            //query by parentId
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL)
            { 
                query += '(' ;
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
                query += ')' ;
                //whereFlag = true;                
            }else
            {
                query = query.removeEnd(' WHERE ');    
            }
            
            /* if(!whereFlag){
			query = query.removeEnd(' WHERE ');
			}  */           
            system.debug('query to be fired: '+query);
            set<id> eventIds = new set<id>();
           for(MeetingEvent__c mId: [select id,EventId__c from MeetingEvent__c])
           {
               eventIds.add(mId.EventId__c);
           }
            for(sObject s : Database.query(query))
            {
                if(!eventIds.contains(s.Id))
                {
                	lstResult.add(s);
                }
            } 
            system.debug(lstResult);
        }
        catch(Exception e){
            System.debug(' Insertion Failed on Meeting Event '+e.getMessage());
        }
        return lstResult;
    }
    
    //Methods for the generic record selector component
    @AuraEnabled
    public static String getSearchScope() {
        String searchScopeList = '';
        searchScopeList = '[{"label":"Account related Events", "value":"accRelEvents","selected": "true"},'+
            '{"label":"All Events", "value":"allEvents"}]';
        
        return searchScopeList;
    }
    
    /*
	* @description:crate Meeting Event Record
	*/ 
    @AuraEnabled
    public static void createMeetingEventRecords(String reportId, Object[] eventList)
    { 
        List<MeetingEvent__c> meetingEventInsertList = new List<MeetingEvent__c>();
        
        MeetingEvent__c newMeetingEvent;
        system.debug('&&& enetered into rec creation == ');
        
        for (Object value : eventList) 
		{
            Map<String, Object> m = (Map<String, Object>)value;
            newMeetingEvent = new MeetingEvent__c();
            newMeetingEvent.MeetingReportId__c = reportId; 
            newMeetingEvent.EventId__c = (String)m.get('Id');
            
            system.debug('&&& newMeetingEvent'+newMeetingEvent);
            
            meetingEventInsertList.add(newMeetingEvent);
        }
        try{
            if(!meetingEventInsertList.isEmpty())
            {
                system.debug('Just before insert');
                insert meetingEventInsertList; 
            }
        }
        catch (DmlException e) {
            System.debug(' Insert Failed: '+e.getMessage());
        }
    }
}