/*
* Author: Jens Becker
* Company: salesforce.com
* Date: 17-April-2018
* Description: Used to provide values for the LOAGateStatus component to show in a path
*
* ToDo: Test classes. Make the component generic to prevent complex test classes and provide multi usage.
*
*/
public with sharing class LOAGateStatusController {

    @AuraEnabled
    public static List<String> getStages(String loAReportId,String fieldName , String sObjectName, String parentSobjectId, String parentSObjectField ){
        List<String> gates = new List<String>();

        String soql = 'SELECT  ' + fieldName + ' FROM ' +  sObjectName + ' WHERE '+ parentSObjectField +' = \''+ parentSobjectId+ '\' ORDER BY '+fieldName+' DESC';
        System.debug('## soql '+ soql);
        List<sObject> returnList = Database.Query(soql);
        for(SObject step : returnList){
            gates.add(String.valueOf(step.get(fieldName)));
        }
        return gates;
    }
}