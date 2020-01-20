/*
 * Author: Yash Raikwar
 * Description: Registration Handler controller to be used on the Auth. Provider setting to implement SSO on community
 * Test Class: CEP_SiemensIdAuthLoginContTest
*/
global class CEP_SiemensIdAuthLoginCont implements Auth.RegistrationHandler{
    public class MyException extends Exception {}
    
    global boolean canCreateUser(Auth.UserData data) {
        system.debug('data---->> '+data);
        return false;
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        if(!canCreateUser(data)) {
            List<Id> profileIdList = new List<Id>();
            List<User> userList = new List<User>();
            profileIdList = CEPUserAccess_Util.getProfileIdByCommunityName(System.Label.CustomerCommunityName);
            //Returning null or throwing an exception fails the SSO flow
            //return null;
            userList = [SELECT Id , Username, ProfileId, Email, isActive
                        FROM User 
                        WHERE Email = :data.email 
                        AND isActive = true 
                        AND ProfileId IN :profileIdList
                        LIMIT 1];
            if(userList != null && !userList.isEmpty()){
                return userList[0];
            }else{
                throw new MyException('No matching user found');
            }
        }
        return null;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        List<User> userList = new List<User>();
        userList = [SELECT Id , username 
                  FROM User 
                  WHERE isActive = true 
                  AND Id=:userId
                  LIMIT 1];
        if(userList != null && !userList.isEmpty()){
            //Do Nothing
        }else{
            throw new MyException('No user found in update!-->'+userId+'----portAL ID--->'+portalId);
        }
    }
}