/*
* Author: Yash Raikwar
* Date: 12-Mar-2019
* Apex Covering: 
* 1. RefreshSiemensIDAccessToken_Batch
* 2. CustomMetadataCallback
*/
@isTest
public  class RefreshSiemensIDAccessToken_BatchTest {
    //Method to test HTTP callout to Siemens ID to get Access Token
    //and then update it in the custom metadata type
    @isTest
    public static void getAccessToken(){
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSiemensId_Test('access_token'));
        //Scheduling the job to run in next minute
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('Test token generation', CRON_EXP, new RefreshSiemensIDAccessToken_Batch() );   
        Test.stopTest();
    }

    //Test metadata callback class
    @isTest
    public static void testCallback(){
        Test.startTest();
        CustomMetadataCallback callbackObj = new CustomMetadataCallback();
        callbackObj.handleResult(new Metadata.DeployResult(), new Metadata.DeployCallbackContext());
        Test.stopTest();
    }
}