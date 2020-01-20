/*
* Author: Yash Raikwar
* Date: 14-Feb-2019
* Description: Test class to generate mock response for test class testing - SyncCommunityUserWithSiemensID_TrigAct
*/
@isTest
public class MockHttpResponseGeneratorSiemensId_Test implements HttpCalloutMock{
    String requestType;
    public MockHttpResponseGeneratorSiemensId_Test(String type){
        this.requestType = type;
    }
    //Mock response method to return mock response into the test execution
    public HTTPResponse respond(HTTPRequest req) {
        SiemensIDRequestParameters__mdt requestParameters = new SiemensIDRequestParameters__mdt();
        
        requestParameters = [SELECT Id,DeveloperName,QualifiedApiName,AccessTokenEndpointURL__c,AccessTokenRefreshDate__c,AccessToken__c,
                            ClientId__c,ClientSecret__c,ConnectionType__c,CreateUserEndpointURL__c,PasswordResetEndpointURL__c,
                            AccessTokenAudience__c,AccessTokenGrantType__c
                            FROM SiemensIDRequestParameters__mdt
                            WHERE QualifiedApiName = 'Siemens_ID'
                            LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        //Create mock response for create new user http callout
        if(requestType == 'new_user'){
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "4321test1234","user_id": "4321test1234"}');
            res.setStatusCode(201);
            return res;
        }else if(requestType == 'existing_user'){
            // Create a mock response for existing user http callout
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "4321test1234","user_id": "4321test1234"}');
            res.setStatusCode(409);
            return res;
        }else if(requestType == 'password_change'){
            // Create a mock response for password change http callout
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "4321test1234","user_id": "4321test1234"}');
            res.setStatusCode(200);
            return res;
        }else{
            // Create a mock response for access token http callout
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "4321test1234","user_id": "4321test1234"}');
            res.setStatusCode(200);
            return res;
        }
    }
}