//TODO:This autogenerated class includes the basics for a Registration
//Handler class. You will need to customize it to ensure it meets your needs and
//the data provided by the third party.

global class AutocreatedRegHandler1544443583675 implements Auth.RegistrationHandler{
    public class MyException extends Exception {}
    
    global boolean canCreateUser(Auth.UserData data) {
        //TODO: Check whether we want to allow creation of a user with this data
        //Set<String> s = new Set<String>{'usernamea', 'usernameb', 'usernamec'};
        //if(s.contains(data.username)) {
        //return true;
        //}
        system.debug('data---->> '+data);
        return false;
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        if(!canCreateUser(data)) {
            //Returning null or throwing an exception fails the SSO flow
            //return null;
            User u = [SELECT Id , username 
                      FROM User 
                      WHERE Email =: data.email 
                      AND isActive = true 
                      AND Profile.UserLicense.Name != 'Salesforce'
                      LIMIT 1];
            if(u != null){
                return u;
            }else{
                throw new MyException('--------->> No user found!');
            }
            
        }
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            //We have a community id, so create a user with community access
            //TODO: Get an actual account
            Account a = [SELECT Id FROM account WHERE name='Accenture'];
            Contact c = new Contact();
            c.accountId = a.Id;
            c.email = data.email;
            c.firstName = data.firstName;
            c.lastName = data.lastName;
            //insert(c);
            
            //TODO: Customize the username and profile. Also check that the username doesn't already exist and
            //possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
            User u = new User();
            Profile p = [SELECT Id FROM profile WHERE name='Customer Portal User'];
            u.username = data.username + '@accenture.com';
            u.email = data.email;
            u.lastName = data.lastName;
            u.firstName = data.firstName;
            String alias = data.username;
            //Alias must be 8 characters or less
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.alias = alias;
            u.languagelocalekey = UserInfo.getLocale();
            u.localesidkey = UserInfo.getLocale();
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = 'America/Los_Angeles';
            u.profileId = p.Id;
            u.contactId = c.Id;
            System.debug('User Data fetching2---->'+u);
            //return u;
            return null;
        } else {
            //This is not a community, so create a regular standard user
            User u = new User();
            Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
            //TODO: Customize the username. Also check that the username doesn't already exist and
            //possibly ensure there are enough org licenses to create a user. Must be 80 characters
            //or less.
            u.username = data.username + '@myorg.com';
            u.email = data.email;
            u.lastName = data.lastName;
            u.firstName = data.firstName;
            String alias = data.username;
            //Alias must be 8 characters or less
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.alias = alias;
            u.languagelocalekey = UserInfo.getLocale();
            u.localesidkey = UserInfo.getLocale();
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = 'America/Los_Angeles';
            u.profileId = p.Id;
            //return u;
            return null;
        }
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User u = [SELECT Id , username 
                  FROM User 
                  WHERE Profile.UserLicense.Name != 'Salesforce'
                  AND isActive = true 
                  AND Id=:userId
                  LIMIT 1];
        //User u = new User(id=userId);
        //TODO: Customize the username. Must be 80 characters or less.
        //u.username = data.username + '@myorg.com';
        if(NULL!=u){
            u.email = data.email;
            u.lastName = data.lastName;
            u.firstName = data.firstName;
        }else{
            throw new MyException('--------->> No user found in update!-->'+userId+'----portAL ID--->'+portalId);
        }
        //String alias = data.username;
        //Alias must be 8 characters or less
        //if(alias.length() > 8) {
        //alias = alias.substring(0, 8);
        //}
        //u.alias = alias;
        //update(u);
    }
}