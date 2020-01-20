/*
 * Author : Naveen Kumar Gadicherla
 * Description : Test Class for FetchDeviationRecords.
 */
@IsTest
public class FetchDeviationRecords_ContTest {

    @TestSetup
    public Static void setUpData(){
        
        LOABusinessRule__c businessRule = new LOABusinessRule__c();
        businessRule.Name = 'TestRelatedList BusinessRule';
        businessRule.LOAClassification__c = 'Financial';
        insert businessRule;
        
        LOAApprovalGate__c approvalGate = new LOAApprovalGate__c();
        approvalGate.Name = 'TestData LOAApprovalGate';
        approvalGate.LevelOfAuthority__c = 'BR1 Division';
        insert approvalGate;
        
        LOAApproval_Gate_Step__c approvalGateStep = new LOAApproval_Gate_Step__c();
        approvalGateStep.Approval_Gate__c = 'Test LOA Approval Gate Step';
        approvalGateStep.Status__c = 'Open';
        insert approvalGateStep;
        
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
        
        List<LOAApprovalTopics__c> lstapprTopics = new List<LOAApprovalTopics__c>();
        LOAApprovalTopics__c approvalTopic1 = new LOAApprovalTopics__c();
        approvalTopic1.Name = 'Test';
        approvalTopic1.LOADeviationIDTxT__c = (String)deviationlst[0].Id;
        approvalTopic1.Approval_Gate_Step__c = approvalGateStep.Id;
        lstapprTopics.add(approvalTopic1);
        
        LOAApprovalTopics__c approvalTopic2 = new LOAApprovalTopics__c();
        approvalTopic2.Name = 'TestRelatedList Deviation1';
        approvalTopic2.LOADeviationIDTxT__c = (String)deviationlst[1].Id;
        approvalTopic2.Approval_Gate_Step__c = approvalGateStep.Id;
        lstapprTopics.add(approvalTopic2);
        
		insert lstapprTopics;
    } 
    
    //Testing PositiveScenario for related List Data Fetching
    public static testmethod void testingRelatedListComponent(){
        
        List<LOAApprover__c> approverData = [Select Id,Name,LOAApprovalGateId__c from LOAApprover__c LIMIT 1];
        List<LOAApprovalGate__c> approvalGate = [Select Id,Name from LOAApprovalGate__c Where Name  = 'TestData LOAApprovalGate' LIMIT 1];
        List<LOADeviation__c> devList = [Select Id,Name,Status__c,BusinessUnit__c,LOABusinessRuleId__r.LOAClassification__c,LOAApprovalGateId__c,LOABusinessRuleId__c from LOADeviation__c ];
        
        Test.startTest();
        	FetchDeviationRecords.LightningTableWrapper listWrapper =  FetchDeviationRecords.getSourceRecords('LOADeviation__c','DeviationFieldset' ,'','Status__c','DeviationToApproval','LOAReportId__c','Test','LOAApprovalTopics__c','Name','','','','');  
        	system.assertEquals(1, listWrapper.existingRecord.size());
           
			List<FetchDeviationRecords.lightningTableColumnWrapper> testrecs = FetchDeviationRecords.getFieldDetails('LOADeviation__c','DeviationFieldset');
			system.assert(testrecs.Size() > 0);
        Test.stopTest();
    }
    
    //Testing ParamString Related List scenario for relatedList Component.
    public static testmethod void testParamStringRelatedListScenario()
    {
        Test.startTest();
        	List<LOADeviation__c> devList = [Select Id,Name,Status__c,BusinessUnit__c,LOABusinessRuleId__r.LOAClassification__c,LOAApprovalGateId__c,LOABusinessRuleId__c from LOADeviation__c ];
        	String queryParam = 'Select CreatedById,Id,Name,LOAApprovalGateId__c,LOABusinessRuleId__c from LOADeviation__c';
        	FetchDeviationRecords.LightningTableWrapper testFilter1 =  FetchDeviationRecords.getSourceRecords('LOADeviation__c','DeviationFieldset' ,'name','Status__c','DeviationToApproval','LOAReportId__c','Test','LOAApprovalTopics__c','Name',queryParam,devList[0].Id,'LOADeviation__c','Name');  
        	system.assertEquals(1, testFilter1.existingRecord.size());
        Test.stopTest();
    }
    
    //Testing createTargetObjectRecords scenario for relatedList Component.
    public static testmethod void testcreateTargetObjectRecordsScenario()
    {
        Test.startTest();
        	List<LOADeviation__c> devList = [Select Id,Name,Status__c,BusinessUnit__c, BusinessRuleClassification__c, LOABusinessRuleId__r.LOAClassification__c,LOAApprovalGateId__c,LOABusinessRuleId__c from LOADeviation__c ];
        	FetchDeviationRecords.createTargetObjectRecords(devList,'DeviationToApproval','LOAApprovalTopics__c','Test','InitialBid__c');
        	//check if LOAApprovalTopics__c record created?
        	List<LOAApprovalTopics__c> lstResult = [select id from LOAApprovalTopics__c];
        	System.assert(lstResult.size() > 0);
        Test.stopTest();
    }
    
    //Testing Negative scenario for relatedList Component.
    public static testmethod void testNegativeRelatedListScenario()
    {
        Test.startTest();
        	//Providing Wrong ParentId as Input for fetching the details
        	FetchDeviationRecords.LightningTableWrapper testFilter =  FetchDeviationRecords.getSourceRecords('LOADeviation__c','DeviationFieldset' ,'name = \'TestRelatedList Unrelated\'','Status__c','DeviationToApproval','LOAReportId__c','','LOAApprovalTopics__c','Id','','','','');  
        	system.assertEquals(0, testFilter.existingRecord.size());
        Test.stopTest();
    }
}