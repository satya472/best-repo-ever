@isTest
public class Questionnaire_ContTest {
    
    @testsetup
    public static void testData(){
        
        Pricebook2 newPriceBook = new Pricebook2(Name='Questionnaire PriceBook', isActive=True);
        insert newPriceBook;

        Account acc = new Account( Name='Test Questionnaire',currencyIsoCode='USD',Price_Book__c = newPriceBook.Id);
        insert acc;
        
        opportunity oppRec = new Opportunity();
        oppRec.CloseDate = system.now().date().addDays(90);
        oppRec.Name = 'Test Ques Opp';
        oppRec.StageName = 'Qualifying';
        oppRec.AccountId = acc.Id;
        oppRec.CurrencyIsoCode = 'USD';
        oppRec.Pricebook2Id = newPriceBook.Id;
        insert oppRec;
        
        Questionnaire__c questionnaire = new Questionnaire__c();
        questionnaire.Name = 'Financial';
        questionnaire.ProcessType__c = 'Key Data';
        
        insert questionnaire;
        
        Questionnaire__c childquestionnaire = new Questionnaire__c();
        childquestionnaire.Name = 'Financial Child';
        childquestionnaire.ProcessType__c = 'Key Data';
        childquestionnaire.ParentId__c = questionnaire.Id;
        childquestionnaire.MasterQuestionnaire__c = (string)questionnaire.Id;
        
        insert childquestionnaire;
        
        List<Question__c> quesLst = new List<Question__c>();
        Question__c ques = new Question__c();
        ques.AnswerType__c = 'Picklist';
        ques.IsActive__c = true;
        ques.Name = 'Financial Ques';
        ques.Sequence__c = 1;
        ques.QuestionnaireObjectId__c = childquestionnaire.Id;
        
        quesLst.add(ques);
        
        Question__c ques1 = new Question__c();
        ques1.AnswerType__c = 'Picklist';
        ques1.IsActive__c = true;
        ques1.Name = 'Financial Ques2';
        ques1.Sequence__c = 2;
        ques1.QuestionnaireObjectId__c = childquestionnaire.Id;
        quesLst.add(ques1);
        
        insert quesLst;
        
        AnswerOption__c aop = new AnswerOption__c();
        aop.RelatedQuestionId__c = ques.Id;
        aop.Sequence__c = 1;
        aop.ValueType__c = 'ValueEntryText';
        
        insert aop;
        
        AnswerQuestionRelation__c aqr = new AnswerQuestionRelation__c();
        aqr.AskthisQuestionId__c = quesLst[1].Id;
        aqr.ForGivenAnswerId__c = aop.Id;
        
        insert aqr;
        
        PMReport__c pmloa = new PMReport__c();
        pmloa.OpportunityId__c = oppRec.Id;
        pmloa.Name = 'Test PMLOA';
        pmloa.ARE__c = '12345';
        pmloa.Stage__c = 'Key Data';
        
        insert pmloa;
        
    }
    
    public static testmethod void testQuestionnaire(){
        
         Profile p = [SELECT Id FROM Profile WHERE Name='System administrator'];
        User u1 = new User(Alias = 'DispHea', Email='TestDisplayRecordhealth@orgTest.com',
                           EmailEncodingKey='UTF-8', LastName='recordHealth', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestDisplayRecordhealth@orgTest.com');
        
        PMReport__c pm = [Select Id,Name,Stage__c,OpportunityId__c from PMReport__c Where Name = 'test PMLOA' LIMIT 1];
        
        Questionnaire__c questionnaire = [Select Id,Name from Questionnaire__c Where Name = 'Financial' LIMIT 1];
        
        Test.startTest();
        
            system.runAs(u1){
                
                List<Questionnaire__c> quesLst = Questionnaire_Cont.getQuestionnaire(pm.Stage__c, pm.Id);
                
                Questionnaire_Cont.QuestionnaireWrapper qw = Questionnaire_Cont.getQuestions(questionnaire.Id, pm.Id);
                
                List<ThirdPartyInvolved__c> thirdParties= Questionnaire_Cont.getThirdPartyRecords(pm.Id);
                List<AggregateResult> countryRsk = Questionnaire_Cont.getCountryRisks(pm.Id, new List<String>());
                
                List<Questionnaire_Cont.QuestionnaireWrapper> questionStructure = Questionnaire_Cont.getQuestionStructure(questionnaire.Id, pm.Id);
                
                String loaId = Questionnaire_Cont.getRiskClassRecord(questionnaire.Name, pm.Id, questionnaire.Id, '');
                
                String loaId2 = Questionnaire_Cont.createLOARiskClassRecord(questionnaire.Name, pm.Id, questionnaire.Id, 12, '', 'Financial');
            }
        Test.stopTest();
        
        
        
    }

}