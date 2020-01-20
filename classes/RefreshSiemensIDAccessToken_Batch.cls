/*
* Author: Yash Raikwar
* Date: 11-Mar-2019
* Description: Batch sceduled to be run daily to refresh Siemens ID access token to perform API callouts
* from Salesforce
* Test Class: RefreshSiemensIDAccessToken_BatchTest
*/
global class RefreshSiemensIDAccessToken_Batch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
    
    //Schedulable Execute method
    global void execute(SchedulableContext schContObj) {
        //Execute the same batch to perform API callout
        Database.executebatch(new RefreshSiemensIDAccessToken_Batch());
    }

    //Batchable Start method
    global Database.QueryLocator start(Database.Batchablecontext BC){
        refreshToken();
        String query = 'SELECT Id FROM Account LIMIT 0';
        return Database.getQueryLocator(query);
    }

    //Batchable Execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope){}

    //Batchable Finish method
    global void finish(Database.BatchableContext BC){}



    //Method to refresh access token by making an API callout, and then saving the new token to a custom metatadata type
    private void refreshToken(){
        SiemensIDRequestParameters__mdt requestParameters = new SiemensIDRequestParameters__mdt();
        if(CEPUserAccess_Util.runningInASandbox()){
            requestParameters = [SELECT Id,DeveloperName,QualifiedApiName,AccessTokenEndpointURL__c,AccessTokenRefreshDate__c,AccessToken__c,
                                ClientId__c,ClientSecret__c,AccessTokenAudience__c,AccessTokenGrantType__c
                                FROM SiemensIDRequestParameters__mdt
                                WHERE QualifiedApiName = 'Siemens_ID_Staging'
                                LIMIT 1];
        }else{
            requestParameters = [SELECT Id,DeveloperName,QualifiedApiName,AccessTokenEndpointURL__c,AccessTokenRefreshDate__c,AccessToken__c,
                                ClientId__c,ClientSecret__c,AccessTokenAudience__c,AccessTokenGrantType__c
                                FROM SiemensIDRequestParameters__mdt
                                WHERE QualifiedApiName = 'Siemens_ID'
                                LIMIT 1];
        }

        if(requestParameters != null){
            String reqBody = '';
            Http httpObj;
            HttpRequest tokenRequest = new HttpRequest();
            HttpResponse tokenResponse = new HttpResponse();

            //Create JSON body
            Map<String, Object> jsonBodyMap = new Map<String, Object>();
            jsonBodyMap.put('client_id', requestParameters.ClientId__c);
            jsonBodyMap.put('client_secret', requestParameters.ClientSecret__c);
            jsonBodyMap.put('audience', requestParameters.AccessTokenAudience__c);
            jsonBodyMap.put('grant_type', requestParameters.AccessTokenGrantType__c);

            //Convert the MAP into JSON
            reqBody = JSON.Serialize(jsonBodyMap);
            
            //Prepare http request
            tokenRequest.setMethod('POST');
            tokenRequest.setHeader('Content-Type','application/json');            
            tokenRequest.setEndpoint(requestParameters.AccessTokenEndpointURL__c);
            
            tokenRequest.setBody(reqBody);

            system.debug('BODY------>> '+reqBody);
            system.debug('REQUEST----->> '+tokenRequest);
            
            try {
                httpObj = new HTTP();
                //Send HTTP request
                tokenResponse = httpObj.send(tokenRequest);

                //Check response and if successful, save the access token
                if(tokenResponse != null && tokenResponse.getStatusCode() == 200){
                    Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse.getBody());
                    String newAccessToken = String.valueOf(jsonResponseMap.get('access_token'));
                    system.debug('Access Token------>> '+ newAccessToken);
                    //Prepare the deployment of the metadata type
                    Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                    customMetadata.fullName = 'SiemensIDRequestParameters__mdt.'+requestParameters.DeveloperName;
                    customMetadata.label = requestParameters.DeveloperName;
                    //Add field values
                    //Access Token
                    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                    customField.field = 'AccessToken__c';
                    customField.value = newAccessToken;
                    customMetadata.values.add(customField);
                    //Refresh Date
                    customField = new Metadata.CustomMetadataValue();
                    customField.field = 'AccessTokenRefreshDate__c';
                    customField.value = datetime.now();
                    customMetadata.values.add(customField);
                    System.debug('Metadata Object------->> '+customMetadata);

                    //Instantiate metadata deploycontainer class
                    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                    mdContainer.addMetadata(customMetadata);
                    //Instantiate metadata deployment class
                    CustomMetadataCallback callback = new CustomMetadataCallback();             
                    //Send deploy call
                    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
                }

            } catch (Exception ex) {
                System.debug('Exception--->> '+ex.getMessage());
            }
        }
    }
}