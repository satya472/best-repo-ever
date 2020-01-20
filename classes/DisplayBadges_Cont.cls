/*
* Author : Phaniram Upalapati
* Description : Controller for fetching details Badges related to the User
* Associated To : DisplayBadges
* Test Class : DisplayBadges_ContTest
*/
public class DisplayBadges_Cont {
    
    /*
    * Description : Methods fetches the details of the Badges assigned to the user
    * Input Param: recordId - Id of the current Record on which the component is placed       
    * Return Type: List<BadgesWrapper> - Containing details of status of the assigned Badge and
    *              Content version of the badge image.
    * 16-08-2018: Naveen-Added condition to check if the component is on home page(other than user page).
    */
    @AuraEnabled
    public static List<BadgesWrapper> getBadgeDetails(String recordId, String objName) {
        Map<Id,BadgeAssignment__c> assignedBadgesMap = new Map<Id,BadgeAssignment__c>();
        try{
            if( !String.isBlank(objName))
            {
            	assignedBadgesMap = new Map<Id,BadgeAssignment__c>([Select Id,Name,DateReceived__c,BadgeId__c,BadgeId__r.ImageAcquired__c,BadgeId__r.Name,Status__c from BadgeAssignment__c Where UserId__c = :recordId AND BadgeId__r.Status__c = 'Active' LIMIT 100]);
            }
            else
            {
                Id userId = UserInfo.getUserId();
                assignedBadgesMap = new Map<Id,BadgeAssignment__c>([Select Id,Name,DateReceived__c,BadgeId__c,BadgeId__r.ImageAcquired__c,BadgeId__r.Name,Status__c from BadgeAssignment__c Where UserId__c = :userId AND BadgeId__r.Status__c = 'Active' LIMIT 100]);
            }
            
            Set<Id> imageDocumentIds = new Set<Id>();          
            for(BadgeAssignment__c rec: assignedBadgesMap.values()){
                  if(string.isNotBlank(rec.BadgeId__r.ImageAcquired__c)){  
                    imageDocumentIds.add(rec.BadgeId__r.ImageAcquired__c);
                  }
            }
            
            List<BadgesWrapper> wrapLst = new List<BadgesWrapper>();
            String receivedDetails;
            
            // Looping through the ContentDocument records to prepare Wrapper Class
            // Containing details of ContentVersion(to display Image) and status of the Badge Assigned
            for(ContentDocument doc: [select Id,LatestPublishedVersionId,title from ContentDocument Where Id in :imageDocumentIds]){
                for(BadgeAssignment__c rec: assignedBadgesMap.values()){
                    if(doc.Id == rec.BadgeId__r.ImageAcquired__c){
                        receivedDetails = rec.BadgeId__r.Name;
                        if(rec.Status__c == 'active' && rec.DateReceived__c != null){
                            receivedDetails = receivedDetails +'\nReceived On: \n'+string.valueOf(rec.DateReceived__c);
                        }
                        wrapLst.add(new BadgesWrapper(rec.Status__c,doc.LatestPublishedVersionId,receivedDetails,rec.DateReceived__c));
                    }
                }
            }
            
            return wrapLst;
        }catch(Exception e){
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage());    
        }

    }
    
    /*
    * Description: Class for storing the Status and ContentVersion Details
    *              so that Images are displayed on UI
    */
    public class BadgesWrapper{
        @AuraEnabled
        public String status{set;get;}
        
        @AuraEnabled
        public String contentVersionId{set;get;}
        
        @AuraEnabled
        public String title{set; get;}
        
        @AuraEnabled
        public Date dateReceived{set;get;}
        
        public BadgesWrapper(String status,String contentVersionId,String title,Date dateReceived){
            this.status = status;
            this.contentVersionId = contentVersionId;
            this.title = title;
            this.dateReceived = dateReceived;
        }
    }
    
}