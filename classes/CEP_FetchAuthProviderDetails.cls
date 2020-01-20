/*
 * Created By: Siddarth Chowdhary
 * Description: The role of this class is to fetch details of Auth Provider so that they can be requested by frontend component(s)
 * Test Class: <Pending>
 */
public with sharing class CEP_FetchAuthProviderDetails {
    @AuraEnabled
    public static Map<String, Object> getAuthProviders() {

      try { 
        AuthProvider authProvider = new AuthProvider();
		Map<String, Object> authProviderDetails = new Map<String, Object>();

        if(CEPUserAccess_Util.runningInASandbox()) {
            authProvider = 	[SELECT DeveloperName,ConsumerKey,AuthorizeUrl from AuthProvider
                            WHERE FriendlyName = 'Login_Staging'
                            LIMIT 1];
        } else {
            authProvider = 	[SELECT DeveloperName,ConsumerKey,AuthorizeUrl from AuthProvider
                            WHERE FriendlyName = 'Login'
                            LIMIT 1];
        }

        authProviderDetails.put('developer_name', authProvider.DeveloperName);
        authProviderDetails.put('client_id', authProvider.ConsumerKey);
		authProviderDetails.put('authorize_url', authProvider.AuthorizeUrl);

		return authProviderDetails;

      } catch(Exception ex){
        throw new AuraHandledException(ex.getMessage());
      }
      
    }
}