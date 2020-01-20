/*
* Author : Phaniram Upalapati
* Description : Test Class for DisplayRecordHealth_Cont.
*/
@IsTest
public class DisplayRecordHealth_ContTest {
    
    @testsetup
    public static void testData(){
        Account acc = new Account( Name='Test OppHealthAccount');
        insert acc;
        
        opportunity oppRec = new Opportunity();
        oppRec.CloseDate = system.now().date().addDays(90);
        oppRec.Name = 'Test HealthOpp';
        oppRec.StageName = 'Qualifying';
        oppRec.AccountId = acc.Id;
        oppRec.CurrencyIsoCode = 'USD';
        insert oppRec;
        
    }
    
     /* Method to test whether the class returning the Asset and Account hierarchy details properly or not */
    public static testMethod void testRecordhealth(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User u1 = new User(Alias = 'DispHea', Email='TestDisplayRecordhealth@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='recordHealth', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestDisplayRecordhealth@orgTest.com');
        
        Opportunity opp = [Select Id,Name,Description,NextStep from Opportunity Where Name = 'Test HealthOpp' LIMIT 1];
                
        Test.startTest();
        
        system.runAs(u1) {
            
            List<DisplayRecordHealth_Cont.HealthWrapper> wrapperLst = DisplayRecordHealth_Cont.getRecordHealthDetails(opp.Id, 'Opportunity');
            //All the Health Records must be returned
            system.assertEquals(6, wrapperLst.size());
            
            //All the returned Health record must be Incompleted
            Integer i = 0;
            for(DisplayRecordHealth_Cont.HealthWrapper wrap: wrapperLst){
                if(!wrap.completed){
                    i++;
                }
            }
            //Incompleted HealthIndicators count
            system.assertEquals(6, i);
            
            //Updating the opportunity with Description and Next Step details
            opp.Description = 'Test Health Desc';
            opp.NextStep = 'Test health NextStep';
            Update opp;
            
            wrapperLst = DisplayRecordHealth_Cont.getRecordHealthDetails(opp.Id, 'Opportunity');

            i = 0;
            for(DisplayRecordHealth_Cont.HealthWrapper wrap: wrapperLst){
                if(wrap.completed){
                    i++;
                }
            }
            //2 Health indicators must be completed
            system.assertEquals(2, i);
            
            
        }

        Test.stopTest();
        
        
    }
    
     /* Method to test whether the class returning the Asset and Account hierarchy details properly or not */
    public static testMethod void testNegativeRecordhealth(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User u1 = new User(Alias = 'DispHea', Email='TestDisplayRecordhealth1@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='recordHealth1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestDisplayRecordhealth1@orgTest.com');
        
        Account acc = [Select Id,Name from Account Where Name = 'Test OppHealthAccount' LIMIT 1];
                
        Test.startTest();
        
        system.runAs(u1) {
            
            List<DisplayRecordHealth_Cont.HealthWrapper> wrapperLst = DisplayRecordHealth_Cont.getRecordHealthDetails(acc.Id, 'Account');
            //No health Calculation as of now for Account Object
            system.assertEquals(0, wrapperLst.size());
            
        }

        Test.stopTest();
        
        
    }
    
}