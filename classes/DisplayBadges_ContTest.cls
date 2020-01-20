/*
 * Author : Phaniram Upalapati
 * Description : Test Class for DisplayBadges_Cont.
 */
@IsTest
public class DisplayBadges_ContTest {
    
    @testSetup
    public Static void setUpData(){
        
        List<ContentVersion> cvLst = new List<ContentVersion>();
        
        ContentVersion cv = new ContentVersion(Title = 'TestCV', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        
        ContentVersion cv2 = new ContentVersion(Title = 'TestCV2', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body2'));
        
        cvLst.add(cv);
        cvLst.add(cv2);
        
        insert cvLst;
        
        List<contentVersion> versionlst = [Select contentDocumentId from ContentVersion where Id in :cvLst];
        
        Badge__c badge = new Badge__c();
        badge.Name =  'Test badge';
        badge.Status__c = 'Active';
        badge.ImageAcquired__c = versionlst[1].ContentDocumentId;
        
        insert badge;
        
        List<BadgeAssignment__c> baLst = new List<BadgeAssignment__c>();
          BadgeAssignment__c ba = new BadgeAssignment__c();
          ba.BadgeId__c = badge.Id;
          ba.UserId__c = userInfo.getUserId();
          ba.Status__c = 'Active';
        
          BadgeAssignment__c ba1 = new BadgeAssignment__c();
          ba1.BadgeId__c = badge.Id;
          ba1.UserId__c = userInfo.getUserId();
          ba1.Status__c = 'Inactive';
        
          baLst.add(ba);
          baLst.add(ba1);
        
          insert baLst;
    }
    
    /* Testing Badge Assignments to the users */
    public static testMethod void testBadgeAssignement(){

        Test.startTest();

          List<DisplayBadges_Cont.BadgesWrapper> lst = DisplayBadges_Cont.getBadgeDetails(userInfo.getUserId(),'');
          List<DisplayBadges_Cont.BadgesWrapper> lst2 = DisplayBadges_Cont.getBadgeDetails(userInfo.getUserId(),'user');

          system.assertEquals(2, lst.size());
        
        Test.stopTest();
        
    }
    
    /* Testing Badge Assignments Negative Scenario */
    public static testMethod void testBadgeAssignementNegative(){
        
        Badge__c bb =[Select Id, Status__c from Badge__c Where Name = 'Test badge' LIMIT 1];
        bb.Status__c = 'Inactive';
        
        update bb;
        
        Test.startTest();
          
           List<DisplayBadges_Cont.BadgesWrapper> lst = DisplayBadges_Cont.getBadgeDetails(userInfo.getUserId(),'');

           system.assertEquals(0, lst.size());
        
        Test.stopTest();
        
    }

}