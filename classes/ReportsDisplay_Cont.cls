/*
 * Author : Phaniram Upalapati
 * Description : Controller For fetching the details of Reports.
 * Associated To : DisplayReportComponent
 * Test Class : ReportsDisplay_ContTest
*/

public with sharing class ReportsDisplay_Cont {

	/*
     * Description : Methods fetches the details of the reports i.e related 
                   row data and headers.
     * Input Param : Reports Api Name, Filter Values, RecordId of the current Record
	 * Return Type: String
	*/
	@AuraEnabled
	public static String getReportResponse(String reportAPIName, String filterParam, String recordId) {
        try{
            return JSON.serialize(Analytics_Util.getReportResponse(reportAPIName, filterParam, recordId));
        }catch(Exception e){
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());    
        }
	}
}