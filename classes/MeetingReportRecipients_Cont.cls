/*
* Author: Naveen Kumar Gadicherla
* Company: Accenture
* Date: 05-Sep-2018
* Description: MeetingReportRelatedEvents_Cont called from MeetingReportRelatedEvents component
*/

public class MeetingReportRecipients_Cont {
    
    //Methods for the generic record selector component
    @AuraEnabled
    public static String getSearchScope() 
    {
        String searchScopeList = '';
        searchScopeList = '[{"label":"Attendees", "value":"Attendees","selected": "true"},'+
            '{"label":"Account Team", "value":"actTeam"},'+
            '{"label":"All Salesforce Users", "value":"allSfdcUsers"},'+
           '{"label":"Account Contacts", "value":"actContatcs"},'+
            '{"label":"All Contacts", "value":"allContatcs"}]';
        
        return searchScopeList;
    }
     /*
	*Method Name	: getTableRecords
	*Purpose		: To get the table data
	*                 sObjectName->Name of the object to be queried.
	*				  searchScope: Defines the searchscope selected in UI.
	*				  fieldNameJson: Json representing fields.
	*                 record: Record on which component is placed.
	*/    
    @AuraEnabled
    public static List<sObject> getTableRecords(String sObjectName, String searchScope, String fieldNameJson, MeetingReport__c record)
    {   
        List<sObject> lstReurnResult = new List<sObject>();
        if( 'MeetingAttendee__c' == sObjectName)
        {
            lstReurnResult = getAttendeeRecords(sObjectName,searchScope,fieldNameJson,record);
        }
        else if( 'User' == sObjectName)
        {
            lstReurnResult = getUserRecords(sObjectName,searchScope,fieldNameJson,record);
        }
        else if( 'Contact' == sObjectName)
        {
            lstReurnResult = getContactRecords(sObjectName,searchScope,fieldNameJson,record);
        }
        
        return lstReurnResult;
      
        
    }
    
    @AuraEnabled
    public static String getSObjectName(String searchScope) 
    {
        String sObjectName;
        if(searchScope != null)
        { 
            if('Attendees' == searchScope)
            {
           	 	sObjectName = 'MeetingAttendee__c';
            }
            else if('actTeam' == searchScope || 'allSfdcUsers'== searchScope )
            {
                sObjectName = 'User';
            }else{
                
                sObjectName = 'Contact';
            }
        }
        return sObjectName;
    }
    
     /*
	 *Method Name	: getFieldSetName
	 *Purpose		: To get the FieldSet Name
	*/
    @AuraEnabled
    public static String getFieldSetName(String modalName) {
        String fieldSetName; 
        system.debug(' modalName is :  '+modalName);
        if('Attendees' == modalName )
        {
            fieldSetName = 'MeetingAttendeeFieldset';
        }else if('actTeam' == modalName || 'allSfdcUsers' == modalName){
            fieldSetName = 'MeetingRecipientsUserFieldset';
        }
        else if('actContatcs' == modalName || 'allContatcs' == modalName){
            fieldSetName = 'MeetingRecipientsContactFields';
        }
        system.debug(' IN getFieldSetName -- fieldSetName is : '+fieldSetName);
        return fieldSetName;
    }
    
     @AuraEnabled
    public static List<sObject> getAttendeeRecords(String sObjectName, String searchScope, String fieldNameJson, MeetingReport__c record)
    {
		List<sObject> lstResult = new List<sObject>();
        Boolean whereFlag = false;
        String parentFieldName = null; 
        String parentRecordId = null;
        //SearchScope criterias
        if(searchScope == 'Attendees'){
            parentFieldName='MeetingReportId__c';
            parentRecordId = record.Id;
        }
        try
        {
                    
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>(); 
			system.debug(' fieldNames has '+fieldNames);
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ', ContactId__c , UserId__c FROM ' + sObjectName;
            query += ' WHERE ';
                
            //query by parentId
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL)
            {
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
            }
            else
			{
				query = query.removeEnd(' WHERE ');
            }
            system.debug(' Attendee query has '+query);
            set<id> userIds = new set<id>();
			set<id> contactIds = new set<id>();
           for(MeetingRecipients__c rec: [select id,ContactId__c,UserId__c from MeetingRecipients__c
                                          WHERE MeetingReportId__c = :record.Id])
           {
				contactIds.add(rec.ContactId__c);       
				userIds.add(rec.UserId__c); 
           }
            system.debug(' Attendee query has '+query);
            for(sObject s : Database.query(query))
            {
                
                if(string.isBlank(((MeetingAttendee__c )s).UserId__c )&& !string.isBlank(((MeetingAttendee__c )s).ContactId__c))
                {
                    if(!contactIds.contains(((MeetingAttendee__c )s).ContactId__c))
                    {
                        lstResult.add(s);
                    }
                    
                }
                else if(string.isBlank(((MeetingAttendee__c )s).ContactId__c )&& !string.isBlank(((MeetingAttendee__c )s).UserId__c))
                {
                    if(!contactIds.contains(((MeetingAttendee__c )s).UserId__c))
                    {
                        lstResult.add(s);
                    }
                    
                }
                
            }
            system.debug(' lstResult has ' +lstResult);
        }
        catch(Exception e){
            System.debug(' Query on Attendee Failed '+e.getMessage());
        }
        return lstResult;
	}
    
@AuraEnabled
    public static List<sObject> getUserRecords(String sObjectName, String searchScope, String fieldNameJson, MeetingReport__c record)
    {
		List<sObject> lstResult = new List<sObject>();
        String parentFieldName = null; 
        String parentRecordId = null;
        //SearchScope criterias
        if(searchScope == 'actTeam')
        {
            parentFieldName='AccountId';
            parentRecordId = record.AccountId__c;
        }
        
        try
        {	
			List<String> actTeamStrList =  new List<String>();
            //get the list of Contacts as BCM on opportunity
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
            	List<AccountTeamMember> actTeamList = [SELECT Id,UserId FROM AccountTeamMember 
                                                        WHERE AccountId = : record.AccountId__c];
            	for(AccountTeamMember act : actTeamList)
            	{
                	actTeamStrList.add(act.UserId);
            	}
            }
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            query += ' WHERE ';
	
			//contact is not a bcm already
            if(actTeamStrList.size()>0 && parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL)
            {
                string userIds = String.join(actTeamStrList,'\',\'');
                query += 'ID IN (\'' + userIds+'\') ';
            }
            else if(actTeamStrList.size() == 0 && parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL)
            {
                return lstResult;
            }
			else
			{
				query = query.removeEnd(' WHERE ');
            }
			
			set<id> userIds = new set<Id>();
           for(MeetingRecipients__c mId: [select id,UserId__c from MeetingRecipients__c WHERE MeetingReportId__c = :record.Id])
           {
               userIds.add(mId.UserId__c);
           }
            for(sObject s : Database.query(query))
            {
                if(!userIds.contains(s.Id))
                {
                	lstResult.add(s);
                }
            } 
        }
        catch(Exception e){
            System.debug(' Insertion on User Failed '+e.getMessage());
        }
        return lstResult;
	}
    
    @AuraEnabled
    public static List<sObject> getContactRecords(String sObjectName, String searchScope, String fieldNameJson, MeetingReport__c record)
    {
		List<sObject> lstResult = new List<sObject>();
        String parentFieldName = null; 
        String parentRecordId = null;
        //SearchScope criterias
        if(searchScope == 'actContatcs'){
            parentFieldName='AccountId';
            parentRecordId = record.AccountId__c;
        }
        
        try
        {	
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
			query += ' WHERE ';
			if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL)
            {
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
            }
			else
			{
				query = query.removeEnd(' WHERE ');
            }
			set<id> contactIds = new set<Id>();
           for(MeetingRecipients__c mId: [select id,ContactId__c from MeetingRecipients__c WHERE MeetingReportId__c = :record.Id])
           {
               contactIds.add(mId.ContactId__c);
           }
            for(sObject s : Database.query(query))
            {
                if(!contactIds.contains(s.Id))
                {
                	lstResult.add(s);
                }
            } 
        }
        catch(Exception e){
            System.debug(' Insertion on Contact Failed '+e.getMessage());
        }
        return lstResult;
	}

    /*
	* @description:crate Meeting Event Record
	*/ 
    @AuraEnabled
    public static void createMeetingRecipientsRecords(String searchScope,String reportId, Object[] recordList)
    {
        List<MeetingRecipients__c> mrInsertList = new List<MeetingRecipients__c>();
        MeetingRecipients__c newRecipient;
        for (Object value : recordList) 
        {
            Map<String, Object> m = (Map<String, Object>)value;
            newRecipient = new MeetingRecipients__c();
            newRecipient.MeetingReportId__c = reportId;
            if('Attendees' == searchScope )
            {
                if(null != (String)m.get('UserId__c') && '' != (String)m.get('UserId__c'))
                {
                    newRecipient.UserId__c = (String)m.get('User') ;
                }
                else if(null != (String)m.get('ContactId__c') && '' != (String)m.get('ContactId__c'))
                {
                    newRecipient.ContactId__c = (String)m.get('ContactId__c');
                }    
                    
            }
            else if('actTeam' == searchScope || 'allSfdcUsers'== searchScope )
            {
                newRecipient.UserId__c = (String)m.get('Id');
            }
            else
            {
                newRecipient.ContactId__c = (String)m.get('Id');
            }
            mrInsertList.add(newRecipient);
        }
            
        try{
            if(!mrInsertList.isEmpty())
            {
                insert mrInsertList; 
            }
        }
        catch (DmlException e) {
            System.debug(' Insert Failed: '+e.getMessage());
        }
    }
    
}