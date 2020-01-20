/*
* Author : Rupinder Kaur
* Description : Class to send email to Meeting Recipients with attached PDF
* Associated To : EmailtoMeetingRecipients Process Automation Flow
* Test Class : EmailPDFtoMeetingRecipientsTest
*/
public class EmailPDFtoMeetingRecipients {
    /*
* Description : Methods fetches the details of the Meeting report and Meeting Recipient 
and sends an Email with Pdf
* Input Param:  meetingReportLst - Meeting Report record of the Current record
*/
    @InvocableMethod           //This methods is made invocable so that it can be called through flow
    public static void sendMeetingEmail(List<MeetingReport__c> meetingReportLst) {
        
        Id meetingReportId;
        
        if(meetingReportLst != null && !meetingReportLst.isEmpty()){
            meetingReportId = meetingReportLst[0].id;
        }

        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<MeetingRecipients__c> meetingRecipientLst = [SELECT Id,ContactId__c,UserId__c,ContactId__r.Email,
                                                          UserId__r.Email FROM MeetingRecipients__c 
                                                          WHERE MeetingReportId__c = :meetingReportId];
        MeetingReport__c meetingRecord = [SELECT Id, VisitDate__c, Title__c FROM MeetingReport__c WHERE id = :meetingReportId];

        List<String> emailIds = new List<String>();
        
        //Add Email ids of all the meeting recipients into a list
            for(MeetingRecipients__c recipientId :meetingRecipientLst){
                if(!String.isBlank(recipientId.ContactId__c)){
                    emailIds.add(recipientId.ContactId__r.Email);
                }
                else if(!String.isBlank(recipientId.UserId__c)){
                    emailIds.add(recipientId.UserId__r.Email);
                }
            }
        String pdfMeetingDate='';
        String fileName;
        if(meetingRecord.VisitDate__c != null)
        {
        DateTime meetingDate = meetingRecord.VisitDate__c;
        Date meetingDateFormat = date.newinstance(meetingDate.year(), meetingDate.month(), meetingDate.day());
        pdfMeetingDate = meetingDateFormat.format();
       }
        fileName = pdfMeetingDate+'_'+meetingRecord.Title__c+'.pdf';
        
        //Email subject and body(content) to be sent (Start)
        String emailSubject = meetingRecord.Title__c+' '+pdfMeetingDate;
        String messageBody = '<html><body>Dear all,<br/><br/>Please review the attached Meeting Report "'+emailSubject+'".<br/><br/>Thanks and best regards</body></html>';
        //Email subject and body(content) to be sent (End)
        
        //For Pdf Attachment along with the email(Start)
        PageReference pdf;
        Blob attbody;
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        pdf = Page.AttachMeetingReportAsPDF;
        pdf.getParameters().put('id',meetingRecord.Id);
        
        if(Test.isRunningTest()) {  //Returns true if called by code contained in a test method, false otherwise 
            attbody = blob.valueOf('Unit.Test');
         }else{
            attbody = pdf.getContent();
        }
        efa1.setBody(attbody);
        efa1.setFileName(fileName);
        fileAttachments.add(efa1);
        //For Pdf Attachment along with the email(End)
        
        email.setSubject(emailSubject);
        email.setHtmlBody(messageBody);
        email.setSaveAsActivity(True);
        email.setWhatId(meetingRecord.id);
        email.setFileAttachments(fileAttachments);
        email.setToAddresses(emailIds);
        lstEmail.add(email);          
        Messaging.sendEmail(lstEmail);
    }
    
    
}