/*
  Description: The class holds different methods which deals with the Assets
  Created By: Phaniram Upalapati
*/
public class CEPAssetPlantToolsCont {
   

  /*
    Description: The method is used to fetch the Asset records which are of type Plant and Equipment only
   */
   @AuraEnabled(cacheable=true)
   public static AssetGroupingClass getAssetDetails(){

       List<String> recordTypeName = new List<String>{'Equipment','Plant'};

       List<Id> assetList = new List<Id>();

       AssetGroupingClass agc = new AssetGroupingClass();

       User usr = [Select Id,ContactId from User Where Id  = :UserInfo.getUserId()];
       
       List<ContactAsset__c> contactAssetList = [Select AssetId__c,AssignedApplications__c from ContactAsset__c Where ContactId__c = :usr.contactId];
       
       agc.contactAssetList = contactAssetList;

       for(ContactAsset__c ca: contactAssetList){
             assetList.add(ca.AssetId__c);
       }

       agc.assetList = [Select Id,Name,RootAssetId,RecordType.DeveloperName from Asset Where RecordType.DeveloperName in :recordTypeName and Id IN :assetList];
      
       return agc;

   }


   /*
     Description: The method is used to fetch the notification records related to the assets
    */
   @AuraEnabled(cacheable=true)
   public static List<CEP_AssetNotification__c> getNotificationDetails(){

       List<Id> assetList = new List<Id>();
       Set<String> assetType = new Set<String>();

       User usr = [Select Id,ContactId,country from User Where Id  = :UserInfo.getUserId()];

       for(ContactAsset__c ca: [Select AssetId__c,AssetId__r.ControlSystemType__c from ContactAsset__c Where ContactId__c = :usr.contactId]){
             assetList.add(ca.AssetId__c);
             if(string.isNotBlank(ca.AssetId__r.ControlSystemType__c)){
                assetType.add(ca.AssetId__r.ControlSystemType__c);
             }
       }

       List<CEP_AssetNotification__c> assetNotificationLst = [Select Id,Name,Description__c,Contact__c,Status__c,NotificationImportance__c,Asset__c,AssetType__c,Asset__r.Name,NotificationDate__c from CEP_AssetNotification__c Where (Asset__c in :assetList  OR Contact__c = :usr.contactId OR Country__c = :usr.country) AND Status__c = 'Publish' AND Id NOT IN (Select AssetNotification__c from NotifiedContact__c Where Contact__c = :usr.contactId)];
 
      List<CEP_AssetNotification__c> controlSysassetNotificationLst = [Select Id,Name,Description__c,Contact__c,Status__c,NotificationImportance__c,Asset__c,AssetType__c,Asset__r.Name,NotificationDate__c from CEP_AssetNotification__c Where AssetType__c != '' AND Status__c = 'Publish' AND Id NOT IN (Select AssetNotification__c from NotifiedContact__c Where Contact__c = :usr.contactId)];

       for(String type: assetType){

         for(CEP_AssetNotification__c can: controlSysassetNotificationLst){
           if(can.AssetType__c.indexOf(type) != -1){
             assetNotificationLst.add(can);
           }
         }

       }

        List<CEP_AssetNotification__c> acknowledgedassetNotificationLst = [Select Id,Name,Description__c,Contact__c,Status__c,NotificationImportance__c,Asset__c,AssetType__c,Asset__r.Name,NotificationDate__c,(Select AssetNotification__c,NotificationStatus__c,AcknowledgedDate__c from Notified_Contacts__r Where Contact__c = :usr.contactId) from CEP_AssetNotification__c Where Id IN (Select AssetNotification__c from NotifiedContact__c Where Contact__c = :usr.contactId)];

       if(acknowledgedassetNotificationLst.size() > 0){
           assetNotificationLst.addAll(acknowledgedassetNotificationLst);
       }
       
       return assetNotificationLst;
   }

   /*
     Description: The method fetches the ContentDocument i.e. files related to the recordId Passed
    */
   @AuraEnabled
   public static List<ContentVersion> getfilesInfo(String recordId){

      // return [Select ContentDocumentId from ContentDocumentLink Where LinkedEntityId = :recordId];
      List<Id> lstIds= new List<Id>();
      for(ContentDocumentLink lnk: [Select ContentDocumentId from ContentDocumentLink Where LinkedEntityId = :recordId]){
          lstIds.add(lnk.ContentDocumentId);
      }
     return [Select Id,Title,FileExtension,FileType from ContentVersion Where ContentDocumentId in :lstIds AND IsLatest = true];
     
   }

   public Class AssetGroupingClass{
     @AuraEnabled
     public List<Asset> assetList{set;get;}

     @AuraEnabled
     public List<ContactAsset__c> contactAssetList{set;get;}
   }
}