public class GenericRecordSelectorController {
    /*
Method Name	: getSearchScope
Purpose	: To get the values of the search scope
*/
    @AuraEnabled
    public static String getSearchScope(String controllerName, String modalName) {
        String searchScopeList = '';
        if(controllerName == 'BuyingCenterController'){
            searchScopeList = BuyingCenterController.getSearchScope(modalName);
        }
        else if('MeetingReportRelatedEvents_Cont' == controllerName)
        {
            searchScopeList = MeetingReportRelatedEvents_Cont.getSearchScope();
        }
        else if('MeetingReportRecipients_Cont' == controllerName)
        {
            searchScopeList = MeetingReportRecipients_Cont.getSearchScope();
        }
        else if(controllerName == 'MeetingReportOpportunityController'){
            searchScopeList = MeetingReportOpportunityController.getSearchScope();
        }
        else if(controllerName == 'MeetingReportAttendeeController'){
            searchScopeList = MeetingReportAttendeeController.getSearchScope();
        }
        return searchScopeList;
    }
    /*
Method Name	: getFieldSetDataJSON
Purpose	: To get the wrapper of Columns and Headers
*/
    @AuraEnabled
    public static String getFieldSetDataJSON(String controllerName, String modalName) {
        String sObjectName;
        String fieldSetName;
        if(controllerName == 'BuyingCenterController'){
            fieldSetName = BuyingCenterController.getFieldSetName(modalName);
            sObjectName = BuyingCenterController.getSObjectName(modalName,'');
        }
        else if('MeetingReportRelatedEvents_Cont' == controllerName)
        {
            fieldSetName = 'MeetingReportRelatedEvents';
            sObjectName = 'Event__c';
        }
        else if('MeetingReportRecipients_Cont' == controllerName)
        {
            fieldSetName = MeetingReportRecipients_Cont.getFieldSetName(modalName);
            sObjectName = MeetingReportRecipients_Cont.getSObjectName(modalName);
        }
        else if(controllerName == 'MeetingReportOpportunityController'){
            fieldSetName = MeetingReportOpportunityController.getFieldSetName();
            sObjectName = MeetingReportOpportunityController.getSObjectName();
        }//modalname is searchscope value
        else if(controllerName == 'MeetingReportAttendeeController'){
            fieldSetName = MeetingReportAttendeeController.getFieldSetName(modalName);
            sObjectName = MeetingReportAttendeeController.getSObjectName(modalName);
        }
        //create the json of the fields
        String result = '';
        if(fieldSetName != null && sObjectName != null){
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
        }
        return '['+result+']';
    }
    /*
Method Name	: getTableRows
Purpose	: To get the table data
*/
    @AuraEnabled
    public static String getTableRows(String controllerName, String modalName, String searchScope, String fieldNameJson, sObject record) {
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        String sObjectName;
        if(controllerName == 'BuyingCenterController')
        {
            Opportunity opp = (Opportunity)record;
            sObjectName = BuyingCenterController.getSObjectName(modalName, searchScope);
            if(modalName != 'SCM')
                lstResult = BuyingCenterController.getRecordsBCM(sObjectName, searchScope, fieldNameJson, opp);
            else
                lstResult = BuyingCenterController.getRecordsSCM(sObjectName, searchScope, fieldNameJson, opp);
        }
        else if('MeetingReportRelatedEvents_Cont' == controllerName)
        {
            lstResult = MeetingReportRelatedEvents_Cont.getEventRecords('Event__c', searchScope, fieldNameJson,(MeetingReport__c)record);
        }
        else if('MeetingReportRecipients_Cont' == controllerName)
        {
            sObjectName = MeetingReportRecipients_Cont.getSObjectName(searchScope);
            lstResult = MeetingReportRecipients_Cont.getTableRecords(sObjectName, searchScope, fieldNameJson,(MeetingReport__c)record);
        }
        else if(controllerName == 'MeetingReportOpportunityController'){
            MeetingReport__c meetingReport = (MeetingReport__c)record;
            sObjectName = MeetingReportOpportunityController.getSObjectName();
            lstResult = MeetingReportOpportunityController.getRecords(sObjectName, searchScope, fieldNameJson, meetingReport);
        }
        else if(controllerName == 'MeetingReportAttendeeController'){
            MeetingReport__c meetingReport = (MeetingReport__c)record;
            sObjectName = MeetingReportAttendeeController.getSObjectName(searchScope);
            lstResult = MeetingReportAttendeeController.getRecords(sObjectName, searchScope, fieldNameJson, meetingReport);
        }
        if(lstResult.size() > 0) {
            result = JSON.serialize(lstResult);
        }
        return result;
    }
    /*
Method Name	: getTableRows
Purpose	: To get the table data
*/
    @AuraEnabled
    public static Map<String, List<String>> getAttributeData(String controllerName) {
        String sObjectName;
        String fieldSetName;
        Map<String, List<String>> fieldValueMap = new Map<String, List<String>> ();
        if(controllerName == 'BuyingCenterController'){
            sObjectName = 'Buying_Center_Member__c';
            fieldSetName = 'BuyingCenterMemberAttributes';
        }
        else if('MeetingReportRelatedEvents_Cont' == controllerName)
        {
            sObjectName = 'MeetingReport__c';
            fieldSetName = 'MeetingReportRelatedEvents';
        }
        if(sObjectName != null && fieldSetName != null){
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
        }
        return fieldValueMap;
    }
    /*
Method Name	: createNewRecords
Purpose	: To save the selected Records to the database
*/
    @AuraEnabled
    public static void createNewRecords(String controllerName, String modalName, String searchScope, String addRecordList, String recordId) {
        Object[] values = (Object[])System.JSON.deserializeUntyped(addRecordList);
        try
        {
            if(controllerName == 'BuyingCenterController'){
                BuyingCenterController.createBuyingCentreMembers(modalName, searchScope, recordId, values);
            }
            else if('MeetingReportRelatedEvents_Cont' == controllerName)
            {
                MeetingReportRelatedEvents_Cont.createMeetingEventRecords(recordId,values);
            }
            else if('MeetingReportRecipients_Cont' == controllerName)
            {
                MeetingReportRecipients_Cont.createMeetingRecipientsRecords( searchScope,recordId, values);
            }
            else if(controllerName == 'MeetingReportOpportunityController'){
                MeetingReportOpportunityController.createMeetingReportOpp(searchScope, recordId, values);
            }
            else if(controllerName == 'MeetingReportAttendeeController'){
                MeetingReportAttendeeController.createMeetingReportAttendee(searchScope, recordId, values);
            }
        }catch (Exception e){
            if(!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}