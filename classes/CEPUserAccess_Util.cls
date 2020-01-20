/*
 * Author: Yash Raikwar
 * Date: 14-Mar-2019
 * Description: Utility class specifically written for the Customer portal user access
*/
public class CEPUserAccess_Util {
    
    //Method to return list of ProfileIds that have access to Community
    public static List<Id> getProfileIdByCommunityName(String communityName){
        List<Id> profileIdList = new List<Id>();
        List<NetworkMemberGroup> communityMemberList;
        
        //Get commuity id by name
        Network networkIdForCommunity = new Network();
        networkIdForCommunity = [SELECT Id FROM Network WHERE Name LIKE :communityName LIMIT 1];
        
        //Get profile ids who are listed as community members
        if(networkIdForCommunity != null){
            for(NetworkMemberGroup communityMember : [SELECT NetworkId, ParentId FROM NetworkMemberGroup WHERE NetworkId = :networkIdForCommunity.Id]){
                profileIdList.add(communityMember.ParentId);
            }
        }
        return profileIdList;
    }

    //Method to determine if the apex code is running in Sandbox or not
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}