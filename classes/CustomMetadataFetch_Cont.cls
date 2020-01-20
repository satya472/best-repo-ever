/*
 * Author : Phaniram Upalapati
 * Description : Controller for fetching details from Custome Metadata based on the metadata Name provided
 * Associated To : QuickAction Component for Mobile
 * Test Class : CustomMetadataFetch_ContTest
 */
public class CustomMetadataFetch_Cont {
    
    @AuraEnabled
    public static List<sObject> fetchCustomMetadataRecords(String metaDataName, String objectName, String fields){

        String queryString = 'Select '+String.escapeSingleQuotes(fields)+' from '+ String.escapeSingleQuotes(objectName)+ ' Where DeveloperName = \''+metaDataName+'\'';
        
        List<sObject> recDetails= database.query(queryString);
     
        return recDetails;
    }
}