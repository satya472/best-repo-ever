/*
 * Author: Yash Raikwar
 * Date: 13-Feb-2019
 * Description: Custom OpportunityProduct_TrigAct handler for User Trigger
 * Primary function is to keep all community users in sync with Siemens ID system. 
 * If user is created in Salesforce, an new user should be created in Siemens ID
 * Test Class: SyncCommunityUserWithSiemensID_Test
*/
public class SyncCommunityUserWithSiemensID_TrigAct extends TriggerHandler{
    /*
     * @description:After successfull insert of community user, perform two callouts to Siemens ID
     * 1. To create new user 
     * 2. To send an automated email for password change to the new user
     * And then update the user with a unique id given by Siemens ID in Federation Id field.
     */
    public override void afterInsert(TriggerContext context){
        List<User> communityUserList = new List<User>();
        
        if (!this.hasRun()){
            communityUserList = getCommunityUsers(context.newList);
            
            //Call queueable apex to perform multiple callouts per user, by passing it the user list
            if(communityUserList != null && !communityUserList.isEmpty()){
                //Send user list along with the index of user which needs to be created in Siemens ID
                CreateUserInSiemensId_Queueable createUsers = new CreateUserInSiemensId_Queueable(communityUserList,0,true);
                System.enqueueJob(createUsers);
                this.markRun();
            }
        }
    }
    
    /*
* Method to fetch community user ids from the context users after insert
*/
    private List<User> getCommunityUsers (List<User> userContextList){
        
        List<User> communityUserList = new List<User>();
        List<Id> profileIdList = new List<Id>();
        profileIdList = CEPUserAccess_Util.getProfileIdByCommunityName(System.Label.CustomerCommunityName);
        
        //Get community profile details to identify the affected users
        List<Profile> communityProfileList = new List<Profile>();
        if(profileIdList != null && !profileIdList.isEmpty()){
            communityProfileList = [SELECT Id,Name,UserLicenseId,UserLicense.Name 
                                FROM Profile 
                                WHERE Id IN :profileIdList];
        }
        
        if(communityProfileList != null && !communityProfileList.isEmpty()){
            for(User contextUser : userContextList){
                //Check if the user in context has one of the community member profile
                for(Profile commProfile : communityProfileList){
                    if(contextUser.ProfileId == commProfile.Id){
                        communityUserList.add(contextUser);
                    }
                }
            }
        }
        
        if(communityUserList != null && !communityUserList.isEmpty()){
            return communityUserList;
        }
        
        return null;
    }
}