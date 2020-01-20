@IsTest
public with sharing class VoteLessonLearnedControllerTest{
    
     @testSetup
    static void setupTestData() 
    {       
        //user creation
         Profile profId= [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        String orgId = UserInfo.getOrganizationId();
        String dateString= String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser= new User(  firstname = 'test',
                            lastName = 'user',
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = profId.id
                            );
        insert tuser;

        // add accounts
        List<Account> accList = new List<Account>();
        Account acc = new Account( Name='Test Account');
        accList.add(acc);
        insert accList;
        
        List<Opportunity> oppsList = new List<Opportunity>();        
        for (account acct: accList) {            
            oppsList.add(new Opportunity(Name= acct.Name+ ' Opportunity ', StageName='Qualifying',
                                         CloseDate=System.today().addMonths(1), AccountId=acct.Id)); 
        }        
        insert oppsList;

        LessonsLearned__c bestPrac= new LessonsLearned__c();
        bestPrac.name='best prac name';
        insert bestPrac;
        
        }
        
    public testmethod static void getUserChioceTest(){
        
        test.startTest();
            LessonsLearned__c getBestPrac= [select id, name, UserChoice__c from LessonsLearned__c]; 
            
            getBestPrac.UserChoice__c=UserInfo.getUserId()+'_Up;';
            update getBestPrac;            
            string returnStr= VoteLessonLearnedController.getUserChioce(getBestPrac.id);
            system.assertEquals(returnStr,'Like');
            
            getBestPrac.UserChoice__c=UserInfo.getUserId()+'_Down;';
            update getBestPrac;            
            VoteLessonLearnedController.getUserChioce(getBestPrac.id);
        test.stopTest();        
    }
    
    public testmethod static void getUserChioceTest1(){
        
        test.startTest();
            LessonsLearned__c getBestPracObj= new LessonsLearned__c();
            getBestPracObj.name='test choice';            
            getBestPracObj.UserChoice__c='Up';
            insert getBestPracObj;
            
            string returnStr= VoteLessonLearnedController.getUserChioce(getBestPracObj.id); 
            system.assertEquals(returnStr,'Show');
                        
        test.stopTest();        
    }
    
    public testmethod static void getVoteTypeTest(){
        
        test.startTest();
            LessonsLearned__c bestPracObj= new LessonsLearned__c(); 
            bestPracObj.MainCategory__c='Cost Impact';
            bestPracObj.name='vote type test';
            //bestPracObj.ImpactClassification__c='Lower project costs';
            bestPracObj.Details__c='impact expected';
            bestPracObj.WhatActionsCanBeTaken__c='action taken';
            bestPracObj.stage__c='In Review';
            insert bestPracObj;
            
            string returnMsg= VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Up'); 
            LessonsLearned__c upadtedObj= [select id, name, UpVotes__c from LessonsLearned__c where name='vote type test'];
            system.assertEquals(upadtedObj.UpVotes__c,1);
            
            VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Down'); 
            
            bestPracObj.UserChoice__c=UserInfo.getUserId() +'_Up;';
            update bestPracObj;
            
            returnMsg= VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Down'); 
            system.assertEquals(returnMsg,'AlreadyVotedMsg');
            User testUsr= [select id, name from user where name='test user'];
            
            bestPracObj.UserChoice__c= testUsr + '_Down;';
            update bestPracObj;
            VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Down'); 
        test.stopTest();        
    }
    
    public testmethod static void getVoteUpTypeTest(){
        
        test.startTest();
            LessonsLearned__c bestPracObj= new LessonsLearned__c(); 
            bestPracObj.MainCategory__c='Cost Impact';
            //bestPracObj.ImpactClassification__c='Lower project costs';
            bestPracObj.Details__c='impact expected';
            bestPracObj.WhatActionsCanBeTaken__c='action taken';
            bestPracObj.stage__c='In Review';
            insert bestPracObj;

            VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Down'); 
            
            bestPracObj.UserChoice__c=UserInfo.getUserId() +'_Up;';
            update bestPracObj;
            
            VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Down'); 
            User testUsr= [select id, name from user where name='test user'];
            
            bestPracObj.UserChoice__c= testUsr + '_Up;';
            update bestPracObj;
            string returnMsg= VoteLessonLearnedController.getBestPractice(bestPracObj.id,'Down');
            system.assertEquals(returnMsg,'SuccessMsg'); 
            
        test.stopTest();        
    }
}