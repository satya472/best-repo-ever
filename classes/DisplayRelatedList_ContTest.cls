/*
 * Author : Phaniram Upalapati
 * Description : Test Class for DisplayRelatedList_Cont.
 */
@IsTest
public class DisplayRelatedList_ContTest {

    @testSetup
    public Static void setUpData(){
        
        LOABusinessRule__c businessRule = new LOABusinessRule__c();
        businessRule.Name = 'TestRelatedList BusinessRule';
        businessRule.LOAClassification__c = 'Financial';
        
        insert businessRule;
        
        LOAApprovalGate__c approvalGate = new LOAApprovalGate__c();
        approvalGate.Name = 'TestData LOAApprovalGate';
        approvalGate.LevelOfAuthority__c = 'BR1 Division';
        
        insert approvalGate;
        
        LOAApprover__c approver = new LOAApprover__c();
        approver.ApproverType__c = 'Financial';
        approver.Name = 'TestRelatedList Approver';
        approver.LOAApprovalGateId__c = approvalGate.Id;
        approver.UserId__c = UserInfo.getUserId();
        
        insert approver;
        
        List<LOADeviation__c> deviationlst = new List<LOADeviation__c>();
        LOADeviation__c deviation;
        for(Integer i=0;i<10;i++){
            deviation = new LOADeviation__c();
            deviation.Name = 'TestRelatedList Deviation'+i;
            deviation.LOABusinessRuleId__c = businessRule.Id;
            deviation.LOAApprovalGateId__c = approvalGate.Id;
            deviation.StartDate__c = system.today();
            
            deviationlst.add(deviation);
        }

        insert deviationlst;
        
    } 
    
    //Testing PositiveScenario for related List Data Fetching
    public static testmethod void testingRealtedListComponent(){
        
        List<LOAApprover__c> approverData = [Select Id,Name,LOAApprovalGateId__c from LOAApprover__c LIMIT 1];
        List<LOAApprovalGate__c> approvalGate = [Select Id,Name from LOAApprovalGate__c Where Name  = 'TestData LOAApprovalGate' LIMIT 1];
        
        Test.startTest();
        
           String parentId = DisplayRelatedList_Cont.getParentInformationFromRecord('LOAApprover__c','LOAApprovalGateId__c',approverData[0].Id);
           
           DisplayRelatedList_Cont.lightningTableWrapper listWrapper = DisplayRelatedList_Cont.getsObjectRecords('LOADeviation__c','','standard:asset_relationship','','LOADeviation',parentId,'LOAApprovalGateId__c','','');
           
           system.assertEquals(10, listWrapper.tableRecord.size());
        
           listWrapper = DisplayRelatedList_Cont.getsObjectRecords('LOADeviation__c','LOA','standard:asset_relationship','','LOADeviation',approvalGate[0].Id,'LOAApprovalGateId__c','','');
           
           system.assertEquals(10, listWrapper.tableRecord.size());
        
           //Testing by Providing additional Filter as Input
           listWrapper = DisplayRelatedList_Cont.getsObjectRecords('LOADeviation__c','LOA','standard:asset_relationship','','LOADeviation',approvalGate[0].Id,'LOAApprovalGateId__c','name = \'TestRelatedList Deviation1\'','BusinessUnit__c');
           
           system.assertEquals(1, listWrapper.tableRecord.size());
        
            try{
               //Testing By Providing Wrong API Name for the ParentObjectIdField.
               parentId = DisplayRelatedList_Cont.getParentInformationFromRecord('LOAApprover__c','LOAApprovalGate__c',approverData[0].Id);
            }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
            }
            
            try{
               //Testing By Providing Wrong API Name for the ParentField.
              listWrapper = DisplayRelatedList_Cont.getsObjectRecords('LOADeviation__c','LOA','standard:asset_relationship','','LOADeviation',approvalGate[0].Id,'LOAApprovalGate__c','','');
            }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        
            try{
               //Testing By Providing Wrong FilterBy field API Name.
              listWrapper = DisplayRelatedList_Cont.getsObjectRecords('LOADeviation__c','LOA','standard:asset_relationship','','LOADeviation',approvalGate[0].Id,'LOAApprovalGate__c','','stage');
            }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        
             try{
               //Testing By Providing Wrong Object API Name.
              List<DisplayRelatedList_Cont.lightningTableColumnWrapper> testrecs = DisplayRelatedList_Cont.getFieldDetails('LOADeviation','TestingDataSet','LOADeviation');
            }catch(Exception ex){
                system.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        
        Test.stopTest();
    }
    
    //Testing Negative scenario for relatedList Component.
    public static testmethod void testNegativeRealtedListScenario(){
        List<LOAApprover__c> approverData = [Select Id,Name,LOAApprovalGateId__c from LOAApprover__c LIMIT 1];
        List<LOAApprovalGate__c> approvalGate = [Select Id,Name from LOAApprovalGate__c Where Name  = 'TestData LOAApprovalGate' LIMIT 1];
        
        Test.startTest();
        
           //Providing Wrong ParentId as Input for fetching the details
           DisplayRelatedList_Cont.lightningTableWrapper listWrapper = DisplayRelatedList_Cont.getsObjectRecords('LOADeviation__c','LOA','standard:asset_relationship','','LOADeviation',approverData[0].Id,'LOAApprovalGateId__c','','');
           
           system.assertEquals(0, listWrapper.tableRecord.size());
        
        Test.stopTest();
    }
}