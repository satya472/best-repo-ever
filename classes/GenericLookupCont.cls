public class GenericLookupCont {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        //Create a Dynamic SOQL Query For Fetching Record List with LIMIT 5
        String sQuery =  'SELECT Id, Name FROM ' +ObjectName + ' WHERE Name LIKE: searchKey ORDER BY CreatedDate DESC LIMIT 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}