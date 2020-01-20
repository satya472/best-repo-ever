@isTest
public with sharing class CEPFootPrintSoapCont_Test {
    
    //public static user creation function used in all below functions.
    public static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'FP', Email='FootPrint1@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='Print', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='FootPrint1@orgTest.com');
        return u1;
    }
    
    //prepare create case data .
    public static Map<string, String> prepareCreateCaseData(User u1){
        
        Map<String, String> caseData = new Map<String, String>();
        caseData.put('firstName', u1.LastName);
        caseData.put('lastName', u1.LastName);
        caseData.put('email', u1.Email);
        caseData.put('account', 'DemoPlantTXP');
        caseData.put('contractUid', '2221');
        caseData.put('plantPart', 'Unit 1');
        caseData.put('remoteConnectionType', '');
        caseData.put('contractServiceLevel', 'Unlimited__bhours');
        caseData.put('gtmHq', 'Patrick__bSurkemper');
        caseData.put('ticketPriority', 'low');
        caseData.put('productLine', 'SPPA__uT2000');
        caseData.put('startOfContract', '2016-06-20 00:00:00.000');        
        caseData.put('onCallSupport', 'Yes');
        caseData.put('hotlineHrs', '2016-06-20 00:00:00.000');
        caseData.put('contractPriority', 'US');
        caseData.put('entitlement', 'Support as LTSP');
        caseData.put('scopeOfContract', 'Hotline__bDCS');
        caseData.put('productLevel1', 'CM');
        caseData.put('productLevel2', 'CM');
        caseData.put('powerPlantId', '25');
        caseData.put('numberOfHighPriority', '');
        caseData.put('accountCopy', 'Germany (DE)');
        caseData.put('location', '2016-06-20 00:00:00.000');
        caseData.put('defaultTicketExeBy', 'US__bREC__bTicket__bExecution');
        caseData.put('gtmRegion', 'Wolfgang Gerndt');
        caseData.put('onCallSupportTimeTable', '');
        caseData.put('onCallSupportAvailable', 'Yes');
        caseData.put('projectSiemensResponsible', '');
        caseData.put('endOfWarranty', '');
        caseData.put('description', 'Lorem Ipsum has been the industry');
        caseData.put('priorityNumber', '3');
        caseData.put('status', 'Open');
        caseData.put('title', 'Lorem Ipsum is simply dummy text');
        caseData.put('projectId', '2');
        return caseData;
    }
    
    
    @IsTest 
    static void testDataFetchContracts(){
        
        User u1 = CEPFootPrintSoapCont_Test.createUser();
        system.runAs(u1){ 
            test.startTest();
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new CEPMockHttpResponse('get_contracts'));
            Map<string, Map<String,String>> contractList = CEPCaseCont.getContracts('30');
            system.assertEquals(2, contractList.size());
            test.stopTest();
        }
    }
   
    
    @IsTest 
    static void testInvalidDataFetchContracts(){
        
        User u1 = CEPFootPrintSoapCont_Test.createUser();
        system.runAs(u1){ 
            test.startTest();
            try {
            	// Set mock callout class 
            	Test.setMock(HttpCalloutMock.class, new CEPMockHttpResponse('invalid_contracts'));
            	Map<string, Map<String,String>> contractList = CEPCaseCont.getContracts('30');
            	system.assertEquals(2, contractList.size());
            } catch(Exception ex){
                system.assert(ex.getMessage().contains('null object'));
            }
            test.stopTest();
        }
    }
    
    
    @IsTest 
    static void testDataCreateCase(){
        
        User u1 = CEPFootPrintSoapCont_Test.createUser();
        Map<string, String> caseData = CEPFootPrintSoapCont_Test.prepareCreateCaseData(u1);
        system.runAs(u1){ 
            test.startTest();
            String dataJson = JSON.serialize(caseData);
            Test.setMock(HttpCalloutMock.class, new CEPMockHttpResponse('create_case'));
            String caseNumber = CEPCaseCont.insertCase(dataJson);
            system.assertEquals('1071280', caseNumber);
            test.stopTest();
        }    
    }
    
    @IsTest 
    static void testDataGetCaseDetail(){
        
        User u1 = CEPFootPrintSoapCont_Test.createUser();
        system.runAs(u1){ 
            test.startTest();
            Map<String, String> tempList = new Map<String, String>();
        	tempList.put('plantId', '25');
        	tempList.put('mrId', '1071281');
            String dataJson = JSON.serialize(tempList);
            Test.setMock(HttpCalloutMock.class, new CEPMockHttpResponse('case_detail'));
            Map<String, Map<String,String>> caseDetail = CEPCaseCont.getCaseDetail(dataJson);
            system.assertEquals(1, caseDetail.size());
            system.assertEquals(new Set<String>{'2-1071281'}, caseDetail.keyset());
            test.stopTest();
        }    
    }
    
    @IsTest 
    static void testDataGetCases(){
        
        User u1 = CEPFootPrintSoapCont_Test.createUser();
        system.runAs(u1){ 
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEPMockHttpResponse('get_cases'));
            Map<String, Map<String,String>> cases = CEPCaseCont.getCases();
            system.assertEquals(2, cases.size());
            system.assertEquals(new Set<String>{'2-1071295', '2-1071296'}, cases.keyset());
            test.stopTest();
        }    
    }
    
    @IsTest 
    static void testDataUpdateCase(){
        
        User u1 = CEPFootPrintSoapCont_Test.createUser();
        system.runAs(u1){ 
            test.startTest();
            Map<String, String> tempList = new Map<String, String>();
        	tempList.put('mrId', '1071281');
            tempList.put('description', 'Test class description update');
            String dataJson = JSON.serialize(tempList);
            Test.setMock(HttpCalloutMock.class, new CEPMockHttpResponse('update_case'));
            String caseNumber = CEPCaseCont.updateCase(dataJson);
            system.assertEquals('1071281', caseNumber);
            test.stopTest();
        }    
    }
}