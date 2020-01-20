/*
* Author: Yash Raikwar
* Date: 13-Feb-2019
* Description: Asynchronous calls to perform HTTP callout to Siemens ID to create new users and then another callout to 
* reset his password in Siemens ID
* Calling Apex: SyncCommunityUserWithSiemensID_TrigAct
*/
public class CreateUserInSiemensId_Queueable implements Queueable, Database.AllowsCallouts {
    List<User> communityUserList;
    Integer listIndex;
    Boolean isTriggerContext;
    SiemensIDRequestParameters__mdt requestParameters;

    //Constructor
    public CreateUserInSiemensId_Queueable(List<User> contextUserList, Integer index, Boolean isTriggerContext) {
        this.communityUserList = contextUserList;
        this.listIndex = index;
        this.isTriggerContext = isTriggerContext;
        requestParameters = new SiemensIDRequestParameters__mdt();
        if(CEPUserAccess_Util.runningInASandbox()){
            requestParameters = [SELECT Id,DeveloperName,QualifiedApiName,AccessTokenEndpointURL__c,AccessTokenRefreshDate__c,AccessToken__c,
                            ClientId__c,ClientSecret__c,ConnectionType__c,CreateUserEndpointURL__c,PasswordResetEndpointURL__c,
                            AccessTokenAudience__c,AccessTokenGrantType__c
                            FROM SiemensIDRequestParameters__mdt
                            WHERE QualifiedApiName = 'Siemens_ID_Staging'
                            LIMIT 1];
        }else{
            requestParameters = [SELECT Id,DeveloperName,QualifiedApiName,AccessTokenEndpointURL__c,AccessTokenRefreshDate__c,AccessToken__c,
                                ClientId__c,ClientSecret__c,ConnectionType__c,CreateUserEndpointURL__c,PasswordResetEndpointURL__c,
                                AccessTokenAudience__c,AccessTokenGrantType__c
                                FROM SiemensIDRequestParameters__mdt
                                WHERE QualifiedApiName = 'Siemens_ID'
                                LIMIT 1];
        }
    }

    /*
    * Execute method to perform callouts to Siemens ID
    */
    public void execute(QueueableContext context) {
        String reqBody = '';
        HttpRequest request;
        HttpResponse newUserResponse = new HttpResponse();
        HttpResponse pwdResetResponse = new HttpResponse();
        HttpResponse existingUserResponse = new HttpResponse();
        
        //Check if the list index is avaialble in list
        if(communityUserList != null && listIndex < communityUserList.size() && requestParameters != null){
            //Create JSON body
            Map<String, Object> jsonBodyMap = new Map<String, Object>();
            jsonBodyMap.put('user_id', '');
            jsonBodyMap.put('connection', requestParameters.ConnectionType__c);
            jsonBodyMap.put('email', communityUserList[listIndex].Email);
            //jsonBodyMap.put('username', communityUserList[listIndex].Email);
            jsonBodyMap.put('password', generateRandomPassword());
            jsonBodyMap.put('email_verified', true);
            //Put source in the body
            Map<String, Object> appMetadata = new Map<String, Object>();
            appMetadata.put('user_source', Label.Siemens_Id_User_Source_GreenField);
            jsonBodyMap.put('app_metadata',appMetadata);
            //Put user metadata in the body
            Map<String, Object> userMetadata = new Map<String, Object>();
            userMetadata.put('given_name', communityUserList[listIndex].FirstName);
            userMetadata.put('family_name', communityUserList[listIndex].LastName);
            userMetadata.put('language', 'en');
            jsonBodyMap.put('user_metadata',userMetadata);

            //Convert the MAP into JSON
            reqBody = JSON.Serialize(jsonBodyMap);
            //Send HTTP Request
            newUserResponse = sendHttpRequest(reqBody, 'new_user', '');
            
            system.debug('newUserResponse------>> '+newUserResponse);
            //Check if the current user is a siemens internal user through his email address
            //If yes, do not send him the password change email, because he will log in using CES onto community
            String emailDomain = communityUserList[listIndex].Email.substringAfter('@');

            //Check response code, if success get user_id from the response
            if(emailDomain != null && emailDomain != '' && !emailDomain.equalsIgnoreCase('siemens.com')){
                if(newUserResponse != null && newUserResponse.getStatusCode() == 201){
                    Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(newUserResponse.getBody());

                    //Now after successfull user creatation, initiate a password change request to the new user
                    jsonBodyMap = new Map<String, Object>();
                    jsonBodyMap.put('connection', requestParameters.ConnectionType__c);
                    jsonBodyMap.put('client_id', requestParameters.ClientId__c);
                    jsonBodyMap.put('email', communityUserList[listIndex].Email);

                    //Convert the MAP into JSON
                    reqBody = JSON.Serialize(jsonBodyMap);
                    //Send HTTP Request
                    pwdResetResponse = sendHttpRequest(reqBody, 'password_reset','');

                    //Call asynch method to update user in case of trigger context
                    if(isTriggerContext){
                        CreateUserInSiemensId_Queueable.updateUserIdAfterInsertAsync(communityUserList[listIndex].Id, String.valueOf(jsonResponseMap.get('user_id')));
                    }else{
                        updateUserIdAfterInsertSync(communityUserList[listIndex], String.valueOf(jsonResponseMap.get('user_id')));
                    }
                    

                //The case wehre user is already presnet in the Siemens ID system with the same email address
                }else if(newUserResponse != null && newUserResponse.getStatusCode() == 409){
                    //Get userID from Siemens to be stored in the federation id field
                    existingUserResponse = sendHttpRequest('', 'existing_user', EncodingUtil.urlEncode(communityUserList[listIndex].Email, 'UTF-8'));
                    
                    if(existingUserResponse != null && existingUserResponse.getStatusCode() == 200){
                        system.debug('existingUserResponse------>> '+existingUserResponse.getBody());
                        //Parse the response and get the user id
                        List<Object> jsonResponseList = (List<Object>) JSON.deserializeUntyped(existingUserResponse.getBody());
                        Map<String, Object> jsonResponseMap = (Map<String, Object>) jsonResponseList[0];
                        
                        //Call asynch method to update user in case of trigger context
                        if(isTriggerContext){
                            CreateUserInSiemensId_Queueable.updateUserIdAfterInsertAsync(communityUserList[listIndex].Id, String.valueOf(jsonResponseMap.get('user_id')));
                        }else{
                            updateUserIdAfterInsertSync(communityUserList[listIndex], String.valueOf(jsonResponseMap.get('user_id')));
                        }
                    }
                //Send error email to the running user in case there is any failure in the callout
                }else{
                    String emailBody = 'Hello '+UserInfo.getName()+'<br/><br/>'+
                                        'An internal error occured while transferring below mentioned user to Siemens Id.<br/>'+
                                        'Name: '+ communityUserList[listIndex].FirstName + ' ' + communityUserList[listIndex].LastName +'<br/>'+
                                        'Email: '+ communityUserList[listIndex].Email +'<br/>'+
                                        'Link: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+communityUserList[listIndex].Id+'" >'+
                                        URL.getSalesforceBaseUrl().toExternalForm()+'/'+communityUserList[listIndex].Id+'</a><br/><br/>'+
                                        'Please contact the CEP Administration Team (cep.team.us@internal.siemens.com) mentioning the below details. '+
                                        'The team will also migrate the user to Siemens Id after resolution, hence no action is required from your side.<br/>'+
                                        '<b>Status Code: '+ newUserResponse.getStatusCode()+'<br/>'+
                                        'Response Body: '+newUserResponse.getBody()+ '<br/><br/></b>'+
                                        'Please Note: The new user would not be able to access CEP until the resolution.<br/><br/>'+
                                        'Thank you!';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> toAddresseList = new List<String>();
                    toAddresseList.add(UserInfo.getUserEmail());
                    mail.setToAddresses(toAddresseList);
                    mail.setSenderDisplayName('CEP Admin');
                    mail.setSubject('Error occured while communicating with Siemens Id');
                    mail.setHTMLBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
            //Queueable chaining:
            //Send user list along with the index of user which needs to be created in Siemens ID
            if(listIndex+1 < communityUserList.size()){
                CreateUserInSiemensId_Queueable createUsers = new CreateUserInSiemensId_Queueable(communityUserList,listIndex+1,isTriggerContext);
                if(!Test.isRunningTest()){
                    System.enqueueJob(createUsers);
                }
            }
        }
    }

    /*
    * Method to generate a random string to be set as an intial password in Siemens ID 
    */
    private String generateRandomPassword() {
        final String charSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomPwd = '';
        
        while (randomPwd.length() < 10) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charSet.length());
            randomPwd += charSet.substring(idx, idx+1);
        }
        //Making the password more strong to avoid weak password errors
        randomPwd += '$1Az';
        return randomPwd;
    }

    //Send Http Request and return reponse back
    private HttpResponse sendHttpRequest(String requestBody, String requestType, String userEmail){
        //Get access token from metadata type
        String accessToken = requestParameters.AccessToken__c;
        HttpResponse response = new HttpResponse();
        Http httpObj;
        //Prepare http request
        HttpRequest request = new HttpRequest();
        //Create request based on the type
        if(requestType == 'new_user'){
            request.setEndpoint(requestParameters.CreateUserEndpointURL__c);
            request.setHeader('Authorization','Bearer '+accessToken);
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(requestBody);
        }else if(requestType == 'password_reset'){
            request.setEndpoint(requestParameters.PasswordResetEndpointURL__c);
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(requestBody);
        }else if(requestType == 'existing_user'){
            request.setHeader('Authorization','Bearer '+accessToken);
            request.setMethod('GET');
            request.setEndpoint(requestParameters.AccessTokenAudience__c+'users-by-email?email='+userEmail);
        }

        system.debug('BODY------>> '+requestBody);
        system.debug('REQUEST----->> '+request);
        
        try {
            httpObj = new HTTP();
            response = httpObj.send(request);
        } catch (Exception ex) {
            System.debug('Exception while sending HTTP request--->> '+ex.getMessage());
        }
        return response;
    }

    /*
    * Future method to update the Federation Id field with the unique Siemens Id field from Siemens ID
    */
    @future
    public static void updateUserIdAfterInsertAsync(Id userId, String userFedId){
        List<User> userList = new List<User>();

        if(userId != null && userFedId != null && userFedId != ''){
            userList = [SELECT Id, FederationIdentifier,AvailableInSiemensID__c,
                        		Profile.UserLicense.Name 
                            FROM User
                            WHERE Id = :userId];

            if(userList != null && !userList.isEmpty()){
                //Do not update federation id field for internal Salesforce users, so that they can use SSO to login to Salesforce
                if(!'Salesforce'.equalsIgnoreCase(userList[0].Profile.UserLicense.Name)){
                    userList[0].FederationIdentifier = userFedId;
                }
                
                userList[0].AvailableInSiemensID__c = true;

                try{
                    //Update user
                    Database.update(userList,false);
                }catch (Exception ex) {
                    System.debug('Exception while updating user--->> '+ex.getMessage());
                }
            }
        }
    }

    /*
    * Method to update the Federation Id field with the unique Siemens Id field from Siemens ID synchronously
    */
    public void updateUserIdAfterInsertSync(User userRecord, String userFedId){
        
        if(userRecord != null && userFedId != null && userFedId != ''){
            if(!'Salesforce'.equalsIgnoreCase(userRecord.Profile.UserLicense.Name)){
                userRecord.FederationIdentifier = userFedId;
            }
            
            userRecord.AvailableInSiemensID__c = true;
            try{
                //Update user
                Database.update(userRecord,false);
            }catch (Exception ex) {
                System.debug('Exception while updating user--->> '+ex.getMessage());
            }
        }
    }
}