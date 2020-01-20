/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 17-April-2018
* Description: OpportunityControllerTest class
*/

@isTest
public class OpportunityControllerTest {
    
    @testSetup
    static void setupTestData() 
    {                
        // For each account, add opportuntiy
        List<Opportunity> oppsList = new List<Opportunity>();        
        oppsList.add(new Opportunity(Name='Test Opportunity', StageName='Qualifying',SignificantChangeDetected__c=true,
                                     CloseDate=System.today().addMonths(1)));        
        //insert oppsList; 
    }
    
   /* static testMethod void testUpdateSignificantChange()
    {
        Test.startTest();        	        
        Id opportunityId = [SELECT ID, AccountId FROM Opportunity WHERE Name IN ('Test Opportunity') LIMIT 1].Id;
        OpportunityController.updateSignificantChange(opportunityId);
        Opportunity opp = [select Id, SignificantChangeDetected__c FROM Opportunity WHERE ID = :opportunityId LIMIT 1];
        system.assertEquals( opp.SignificantChangeDetected__c, false);
        Test.stopTest();
    }*/
}