/*
* Author : Rupinder Kaur
* Description : Test Class for LoaGateStatusController. As it basically is a generic APEX class, which returns a list of child record
* field values, we can create any kind of parent child object relationship records and show assert values
*/
@isTest
public class LOAGateStatusControllerTest {

    @testsetup
    public static void testData(){

        //Id equipId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        //create an account
        Account acc = new Account( Name='Test ParentChild',Type='Site');
        insert acc;
        List<Contact> cons = new List<Contact>();

        Contact con1 = new Contact(AccountId=acc.id, FirstName='TestName1', LastName='TestLastName1');
        cons.add(con1);
        Contact con2 = new Contact(AccountId=acc.id, FirstName='TestName2', LastName='TestLastName2');
        cons.add(con2);
        Contact con3 = new Contact(AccountId=acc.id, FirstName='TestName3', LastName='TestLastName3');
        cons.add(con3);

        insert cons;

    }

    /* Method to test whether the class returning the parent and child records properly or not */
    public static testMethod void testControllerMethod(){

        List<Account> accsCreated = [SELECT Id, Name FROM Account WHERE Name='Test ParentChild'];

        String accId = accsCreated[0].id;

        Test.startTest();
        List<String> getTestStages = LOAGateStatusController.getStages( '','LastName', 'Contact', accId, 'AccountId' );
                system.assertEquals(3,getTestStages.size());

        Test.stopTest();

    }

}