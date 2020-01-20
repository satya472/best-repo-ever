/*
* Author : Phaniram Upalapati
* Description : Test Class for CEPTrackAndTraceOrder_Cont.
*/
@isTest
public with sharing class CEPTrackAndTraceOrder_ContTest {
	
 @TestSetup
 public static void dataCreation(){
    List<TrackTrace__c> orderLst = new List<TrackTrace__c>();
	TrackTrace__c tt;
	for(Integer i=0;i<20;i++){
      tt = new TrackTrace__c();
	  tt.CustomerPONumber__c = ''+i;
	  tt.SalesOrderNumber__c= ''+i;
	  tt.CurrentStatusOrder__c= 'Order Entry';
      tt.orderEntryDate__c = system.Today().adddays(1);
	  tt.LastConfirmedDeliveryDate__c=system.Today().adddays(5+i);
	  tt.PartNumber__c=''+i;
	  tt.PartDescription__c= 'Test Data Part Description: '+i;
	  tt.RequestedQuantity__c= 2;
	  tt.ItemUnit__c= ''+i;
	  tt.IFANumber__c = ''+i;
	  tt.CustomerRequestedDate__c= system.Today().adddays(10);

	  orderLst.add(tt);

	}

	orderLst[2].CurrentStatusOrder__c = 'Order Confirmed';
    orderLst[2].orderConfirmedDate__C = system.Today().adddays(2);
	orderLst[3].CurrentStatusOrder__c = 'Initiation of Delivery';
    orderLst[3].orderConfirmedDate__C = system.Today().adddays(2);
    orderLst[3].InitiationOfDelivery__c = system.Today().adddays(3);
    
      tt = new TrackTrace__c();
	  tt.CustomerPONumber__c = ''+1;
	  tt.SalesOrderNumber__c= ''+1;
	  tt.CurrentStatusOrder__c= 'Ready to Ship';
      tt.orderEntryDate__c = system.Today().adddays(1);
      tt.orderConfirmedDate__c = system.Today().adddays(2);
      tt.InitiationOfDelivery__c = system.Today().adddays(3);
      tt.ReadyToShip__c = system.Today().adddays(4);
	  tt.LastConfirmedDeliveryDate__c=system.Today().adddays(5);
	  tt.OrderLineItemNo__c= 1;
	  tt.PartNumber__c=''+1;
	  tt.PartDescription__c= 'Test Data Part Description: '+1;
	  tt.RequestedQuantity__c= 2;
	  tt.IFANumber__c = ''+1;
	  tt.CustomerRequestedDate__c= system.Today().adddays(10);
	  orderLst.add(tt);
     
      tt = new TrackTrace__c();
	  tt.CustomerPONumber__c = ''+21;
	  tt.SalesOrderNumber__c= ''+1;
      tt.orderEntryDate__c = system.Today().adddays(1);
      tt.orderConfirmedDate__c = system.Today().adddays(2);
      tt.InitiationOfDelivery__c = system.Today().adddays(3);
      tt.ReadyToShip__c = system.Today().adddays(4);
      tt.GoodsIssueDate__c =  system.Today().adddays(5);
      tt.ReceiptByForwarder__c = system.Today().adddays(6);
      tt.MaterialAtDestination__c = system.Today().adddays(8);
	  tt.LastConfirmedDeliveryDate__c=system.Today().adddays(5);
	  tt.OrderLineItemNo__c= 2;
	  tt.PartNumber__c=''+1;
	  tt.PartDescription__c= 'Test Data Part Description: '+1;
	  tt.RequestedQuantity__c= 2;
	  tt.IFANumber__c = ''+22;
	  tt.CustomerRequestedDate__c= system.Today().adddays(10);
      orderLst.add(tt);
     
      tt = new TrackTrace__c();
	  tt.CustomerPONumber__c = ''+21;
	  tt.SalesOrderNumber__c= ''+21;
      tt.orderEntryDate__c = system.Today().adddays(2);
      tt.orderConfirmedDate__c = system.Today().adddays(2);
      tt.InitiationOfDelivery__c = system.Today().adddays(3);
      tt.ReadyToShip__c = system.Today().adddays(4);
      tt.GoodsIssueDate__c =  system.Today().adddays(5);
      tt.ReceiptByForwarder__c = system.Today().adddays(6);
      tt.MaterialAtDestination__c = system.Today().adddays(15);
	  tt.LastConfirmedDeliveryDate__c=system.Today().adddays(15);
	  tt.OrderLineItemNo__c= 2;
	  tt.PartNumber__c=''+1;
	  tt.PartDescription__c= 'Test Data Part Description: '+1;
	  tt.RequestedQuantity__c= 3;
	  tt.IFANumber__c = ''+22;
	  tt.CustomerRequestedDate__c= system.Today().adddays(10);
      orderLst.add(tt);
  
	insert orderLst;
 }

 /*Testing positive Scenario*/
 public static testmethod void testRecordFetch(){
    Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
    User u1 = new User(Alias = 'TT', Email='Tracktrace@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='Trace', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='Tracktrace@orgTest.com');

	system.runAs(u1){

		Test.startTest();

            String s = system.EncodingUtil.base64Encode(Blob.valueof('1;2;3;22'));
            List<TrackTrace__c> lst = CEPTrackAndTraceOrder_Cont.getTrackAndTraceOrders(s);
    
            system.assertEquals(4, lst.size());
        
            FieldSetDetails_Util.lightningTableWrapper childlst = CEPTrackAndTraceOrder_Cont.getTrackAndTraceChildOrderRecords('21', 'FieldSetForChildOrders');
        
           system.assertEquals(2, childlst.tableRecord.size());

		Test.stopTest();

	}

 }
    
    /*Testing Negative Scenario*/
    public static testmethod void testNegativeRecordFetch(){
    Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
    User u1 = new User(Alias = 'TT', Email='Tracktrace@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='Trace', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='Tracktrace@orgTest.com');

	system.runAs(u1){

		Test.startTest();
        
        try{
            List<TrackTrace__c> lst = CEPTrackAndTraceOrder_Cont.getTrackAndTraceOrders('Test123');
    
        }catch(Exception ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }

		Test.stopTest();

	}

 }



}