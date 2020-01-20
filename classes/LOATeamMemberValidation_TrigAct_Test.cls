/*
* Author - G. Naveen
* Apex covering 
* Test class for LOATeamMemberValidation_TrigAct
*/
@isTest

public class LOATeamMemberValidation_TrigAct_Test {
    
    @testSetup
    static void setupTestData() 
    {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(Alias = 'testUser', Email= 'abc@text.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileId.Id, FederationIdentifier='abc@text.com',
        TimeZoneSidKey='America/Los_Angeles', UserName=' abc@text.com');
        insert testUser;
    }
    
    static testMethod void testLOAUpdatePositive()
    {
        Test.startTest();
        User userRec = [Select id,name from User where LastName = 'Testing'];
        LOAReportTeam__c loaEntity = new LOAReportTeam__c(ApprovalGate__c = 'Test Gate Positive',UserId__c = userRec.Id, Approver__c =true);
        insert loaEntity ;
        TriggerHandler.resetAllHasRun();
        List<LOAReportTeam__c> readLOA = [Select id,name,Approver__c from LOAReportTeam__c where ApprovalGate__c = 'Test Gate Positive'];
        system.assertEquals(1,readLOA.size());
                readLOA[0].Approver__c = false;
        try{
            update(readLOA[0]);
        }
        catch(Exception e)
        {
            
        }
        Test.stopTest();
    }
    static testMethod void testLOAUpdateNegative()
    {
        Test.startTest();
        User userRec = [Select id,name from User where LastName = 'Testing'];
        LOAReportTeam__c loaEntity = new LOAReportTeam__c(ApprovalGate__c = 'Test Gate Negative',UserId__c = userRec.Id, Approver__c = true);
        insert loaEntity ;
        TriggerHandler.resetAllHasRun();
        LOAReportTeam__c readLOA = [Select id,name from LOAReportTeam__c where ApprovalGate__c = 'Test Gate Negative'];
        readLOA.Approver__c = false;
        try{
            update readLOA;
            LOAReportTeam__c readEntity = [Select id,name,Approver__c  from LOAReportTeam__c where name = 'Test Member Negative'];
            system.assertEquals(false,readEntity.Approver__c);
        }
        catch(Exception e)
        {
            system.assert(e.getMessage().contains('Approver cannot be unchecked when Approval Gate has Value'));
       
        } 
        Test.stopTest();
    }
    
    static testMethod void testLOADelete()
    {
        Test.startTest();
        User userRec = [Select id,name from User where LastName = 'Testing'];
        LOAReportTeam__c loaEntity = new LOAReportTeam__c(ApprovalGate__c = 'Test Gate Delete',UserId__c = userRec.Id, Approver__c = true);
        insert loaEntity;
        TriggerHandler.resetAllHasRun();
        LOAReportTeam__c readLOA = [Select id,name,Approver__c  from LOAReportTeam__c where ApprovalGate__c = 'Test Gate Delete'];
        readLOA.Approver__c = false;
        try{
            Delete readLOA;
        }
        catch(Exception e)
        {
            system.assert(e.getMessage().contains('You cannot delete Team Member When Approver Gate has Value'));
        }
        Test.stopTest();
    }
}