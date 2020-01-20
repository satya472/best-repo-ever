/*
*Author: G.Naveen Kumar
*Date:24-Jul-18
*Description: Test class for SMN_DisplayJobletsController
*/
@IsTest
public class SMN_DisplayJobletsControllerTest {
   @testSetup
    static void setupTestData() 
	{      
        // add accounts
        List<Account> accList = new List<Account>();
        Account parentAcc = new Account( Name='Test Account', billingCountry='United States');
        accList.add(parentAcc);
        insert accList;
        
        Account childAcc= new Account( Name='Child Test Account', ParentId=parentAcc.id, Type='Site');
        insert childAcc; 
            
        List<Opportunity> oppsList = new List<Opportunity>();        
                  
        oppsList.add(new Opportunity(Name=  'First Opp ', StageName='Qualifying',Amount = 1110,
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 

		oppsList.add(new Opportunity(Name=  'Second Opp ', StageName='Qualifying',Amount = 1110,
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 
        oppsList.add(new Opportunity(Name=  'Third Opp ', StageName='Qualifying',Amount = 1110,
                                         CloseDate=System.today().addMonths(1), AccountId=childAcc.Id)); 
		insert oppsList;
        
        //Cpq Quote Creation
		SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=oppsList[0].Id, SBQQ__Account__c=oppsList[0].AccountId);

        insert cpqQuote;


		List<Work_Package__c> packList = new List<Work_Package__c>();
		Work_Package__c workPack1 = new Work_Package__c(Name = 'Test Work Package' ,Status__c='Active',Sequence_Order__c = 1,
														Context_Object__c='Opportunity',ContextField__c = 'StageName',ContextValue__c='Qualifying',
                                                        Work_Description__c = 'Test Description',Period_Type__c	= 'Hours',Period__c =21);
		Work_Package__c workPack2 = new Work_Package__c(Name = 'Test Work Package2' ,Status__c='Active',Sequence_Order__c = 2,
														Context_Object__c= 'Opportunity',ContextField__c = 'StageName',ContextValue__c='Qualifying',
                                                       Work_Description__c = 'Test Description2',Period_Type__c	= 'Days',Period__c =21);
        Work_Package__c workPack3 = new Work_Package__c(Name = 'Test Work Package3' ,Status__c='Active',Sequence_Order__c = 3,
														Context_Object__c= 'Opportunity',ContextChildObject__c='SBQQ__Quote__c',ContextField__c = 'StageName',ContextValue__c='Qualifying',
                                                       Work_Description__c = 'Test Description3',Period_Type__c	= 'Weeks',Period__c =21);
		
		packList.add(workPack1);
		packList.add(workPack2);
        packList.add(workPack3);
		insert packList;
		
		List<Worklet_Item__c> workletsList = new List<Worklet_Item__c>();
		
		Worklet_Item__c workItem1 = new Worklet_Item__c(Name = 'Test Worklets One',Status__c='Open',Sequence__c=1,Parent_Context_ID__c = oppsList[0].Id);

		insert workItem1;
	}
    public static testmethod void getWorkletsTestMethods()
	{
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User usr = new User(Alias = 'TestSeg', Email='TestSegmentation@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='hierarchy', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestSegmentation@orgTest.com');
        Test.startTest();
        system.runas(usr){

            List<opportunity> oppList = [Select id,Name,StageName from opportunity];
            Worklet_Item__c wi = [Select id,Name,Status__c from Worklet_Item__c where Name ='Test Worklets One'];
            system.assert(oppList.size()>0);
            List<String> str = new List<string>();
            
            SMN_DisplayJobletsController.JobWrapper jb1 = SMN_DisplayJobletsController.getListTodisplay(oppList[0].Id,'Opportunity', (SObject)oppList[0],'SMN_WorkletListing','SMN_Work_PackageListing', '','');
            system.assertEquals(2, jb1.workPackageTableWrapper.tableRecord.size());
            
            jb1 = SMN_DisplayJobletsController.getListTodisplay(oppList[0].Id,'Opportunity', (SObject)oppList[0],'SMN_WorkletListing','SMN_Work_PackageListing', 'SBQQ__Opportunity2__c','SBQQ__Quote__c');
            system.assertEquals(3, jb1.workPackageTableWrapper.tableRecord.size());
            
            SMN_DisplayJobletsController.updateWorkletStatus(wi.Id,'Complete');
            Worklet_Item__c readWI = [Select id,Name,Status__c from Worklet_Item__c where Name ='Test Worklets One'];
            system.assertEquals('Complete', readWI.Status__c);
        }
        
        Test.stopTest();
        
	}
    
    public static testmethod void createWorkletTestMethod()
	{
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User usr = new User(Alias = 'TestSeg', Email='TestSegmentation@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='hierarchy', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestSegmentation@orgTest.com');
        Test.startTest();
         system.runas(usr){
             
            List<opportunity> oppList = [Select id,Name,StageName from opportunity];
            Worklet_Item__c wi = [Select id,Name,Status__c from Worklet_Item__c where Name ='Test Worklets One'];
            system.assert(oppList.size()>0);
          
             SMN_DisplayJobletsController.JobWrapper  jb1  = SMN_DisplayJobletsController.getListTodisplay(oppList[0].Id,'Opportunity', (SObject)oppList[0],'SMN_WorkletListing','SMN_Work_PackageListing', 'SBQQ__Opportunity2__c','SBQQ__Quote__c');
             SMN_DisplayJobletsController.createWorklets(JSON.serialize(jb1.workPackageTableWrapper.tableRecord),oppList[0].Id,(SObject)oppList[0]);
          
            List<Worklet_Item__c> createdList = [Select id,Name,Status__c from Worklet_Item__c where Name like '%Test Work%'];
            system.assert(createdList.size()>0);
         }
        Test.stopTest();
    }
    public static testmethod void designFieldSelectionTestMethod()
	{
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName  = 'opportunity';
        LightningDesignFieldSelection inst = new LightningDesignFieldSelection(context);
        VisualEditor.DataRow dr = inst.getDefaultValue();
        VisualEditor.DynamicPickListRows dpl = inst.getValues();
        system.assert(dpl!=null);
    }
    
    public static testmethod void relatedObjectSelectionTestMethod()
	{
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName  = 'opportunity';
        LightningDesignRelatedObjectSelection inst = new LightningDesignRelatedObjectSelection(context);
        VisualEditor.DataRow dr = inst.getDefaultValue();
        VisualEditor.DynamicPickListRows dpl = inst.getValues();
        system.assert(dpl!=null);
    }
}