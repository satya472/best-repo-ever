/*
 * Created By: Saurabh Agarwal
 * Description: This is a controller Class for CEPCase LWC which handles attachments.
 */
public with sharing class HotlineEmailCont {

    @AuraEnabled
    public static void sendHotlineEmail(String mailText, String fileValues) {
        
        HotlineEmailClass HotlineEmailObj = (HotlineEmailClass)JSON.deserialize(mailText, HotlineEmailClass.class);
        List<String> documentIds;
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(
          new String[] {
            'saurabh.agarwal@siemens.com'
          }
        );
        mail.setReplyTo('saurabh.agarwal@siemens.com');
        mail.setSenderDisplayName('SaurabhAgarwal');
        mail.setSubject(HotlineEmailObj.mailSubject);
        mail.setHtmlBody(HotlineEmailObj.mailBody);
        
        if (! String.isBlank(fileValues)) {
          documentIds = (List<String>) System.JSON.deserialize(fileValues, List<String>.class);

          List<Messaging.EmailFileAttachment> fileAttachmentsList = new List<Messaging.EmailFileAttachment>();

          for (String documentId : documentIds) {
            //Add to Attachmentfile file list
            Messaging.Emailfileattachment emailFileAttach;
            for(ContentVersion conVersionFile:[
                SELECT Id,VersionData,FileExtension,Title 
                FROM ContentVersion 
                WHERE ContentDocumentId = :documentId 
                AND IsLatest = true LIMIT 1]){
                
                emailFileAttach= new Messaging.Emailfileattachment();
                emailFileAttach.setFileName(conVersionFile.Title+'.'+conVersionFile.FileExtension);
                emailFileAttach.setBody(conVersionFile.VersionData);
                fileAttachmentsList.add(emailFileAttach);
            }
            mail.setFileAttachments(fileAttachmentsList);
          }
        } 

        mails.add(mail);

        try {
          if(!Test.isRunningTest()) {
            Messaging.sendEmail(mails);
          }
          for (String documentId : documentIds) {
            HotlineEmailCont.removeHotlineFile(documentId);
          }
          
        } catch(Exception ex) {
            System.debug('Error: Request to access JEP failed: '+ ex.getMessage());
        }
    }

    @AuraEnabled
    public static void removeHotlineFile(String documentId) {
      ContentDocument contentDocument = [SELECT Id FROM ContentDocument 
                WHERE Id=:documentId LIMIT 1];
      delete contentDocument;
    }

    /*Class for Parsing the JSon*/
    public class HotlineEmailClass {
        public String mailSubject {get;set;} 
        public String mailBody {get;set;} 
    }
    
    @AuraEnabled
    public static String fetchHotlineFile(String documentId) {
      ContentVersion contentVersionObj = [
        SELECT Id,ContentSize,FileExtension,Title 
        FROM ContentVersion 
        WHERE ContentDocumentId=:documentId 
        AND IsLatest = true LIMIT 1
      ];
      return JSON.serialize(contentVersionObj);
    }
}