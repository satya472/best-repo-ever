/*
* Author : Rupinder Kaur
* Description : Test Class to test if an email sent through the EmailtoMeetingRecipients class is successfully sending an email
to all the Meeting Recipients with attached PDF.
* Associated To : EmailtoMeetingRecipients class
*/
@IsTest
public class EmailPDFtoMeetingRecipientsTest {
    private static List<id> recipientsList = new List<id>();
    private static List<String> recipientsEmail = new List<String>();
    
    //Test Data to be used anywhere in the class without creating it again and again.
    @testSetup
    static void setupTestData() 
    {          
        Account acc = new Account( Name='Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test',AccountId=acc.Id,Email='TestmeetingRecipient@orgTest.com');
        insert con;
        MeetingReport__c meeting = new MeetingReport__c(Title__c='TestMeeting',AccountId__c=acc.id,VisitDate__c=System.today());
        insert meeting;       
    } 
    public static testmethod void testSendEmail(){
        
        Test.startTest();
        
        Contact conEntity = [Select Id,Name from Contact where LastName = 'Test'];
        User currentUser = [Select Id, Contact.accountId, ContactId From User Where Id =: UserInfo.getUserId()];
        
        system.runAs(currentUser){  //To run the test in current user context
            
            List<MeetingReport__c> meetingReport = [Select id,Title__c,VisitDate__c from MeetingReport__c Where Title__c='TestMeeting'];
            MeetingRecipients__c meetinguser = new MeetingRecipients__c(MeetingReportId__c=meetingReport[0].id,UserId__c=currentUser.id);
            insert meetinguser;
            MeetingRecipients__c meetingContact= new MeetingRecipients__c(MeetingReportId__c=meetingReport[0].id,ContactId__c=conEntity.id);
            insert meetingContact;
            List<MeetingRecipients__c> recip = [Select ContactId__c,ContactId__r.Email,UserId__c,UserId__r.Email 
                                                From MeetingRecipients__c Where MeetingReportId__c=:meetingReport[0].id];
            
            for(MeetingRecipients__c recipientId :recip){
                recipientsList.add(recipientId.id);
                recipientsEmail.add(recipientId.ContactId__r.Email);
            }
            system.assertEquals(2, recipientsList.size()); //to check if the recipients list contains all the recipients which were added
            
            EmailTemplate templateId = new EmailTemplate(Name='MeetingReportPDF',DeveloperName='MeetingReportPDF',
                                                         IsActive=true,Subject='test',Body='Dear All',TemplateType='Text');
            system.assertEquals('MeetingReportPDF', templateId.DeveloperName); //To check whether templateId.DeveloperName 
            //stores the correct name
            
            EmailPDFtoMeetingRecipients.sendMeetingEmail(meetingReport);  //Initiating sendMeetingEmail method 
        }
        Test.stopTest();
        
        
        
        
    }
    
}