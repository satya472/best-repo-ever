/**
* @author Jens Becker
* @date Creation 04/12/2017
* @date Modification 04/12/2017
* @description Questionnaire_Cont – Class used as an apex controller for the lightning components for questionnary
*/
public class Questionnaire_Cont {
    /**
* @author Sara Elalaoui
* @date 02/07/2017
* @description get questions according to the questionnary Id
* @param String questionnaireId
* return List<Question>
* @throws 
*/
    @AuraEnabled
    public static QuestionnaireWrapper getQuestions(String questionnaireId, String loAProjectId){
        system.debug('##loAProjectId: '+ loAProjectId);
        Map<String, RiskTopic__c> existingTopicsMap = new Map<String, RiskTopic__c>();
        QuestionnaireWrapper qw = new QuestionnaireWrapper();
        Set<String> AnsweredOptionStrings = new Set<String>();

        // This list will help us, to identify the questions, which have been answered already
        List<RiskTopic__c> existingTopics = [SELECT Id, Name,QuestionId__c,Question__c,Status__c, RequestForRelease__c,InitialBid__c,CustomerRequest__c,AnsweroptionId__c,AnswerText__c,AnswerNumber__c, AdditionalNotes__c, AnswerCurrency__c,ProcessStepId__c,ProcessControlStatus__c,PMLoADataId__c FROM RiskTopic__c
        WHERE PMLoADataId__c =:loAProjectId
        ];

        //We put them into a map
        for(RiskTopic__c topic: existingTopics){
            existingTopicsMap.put(topic.QuestionId__c, topic);
            AnsweredOptionStrings.add(topic.AnsweroptionId__c);
        }

        List<Question> qlistObjects = new List<Questionnaire_Cont.Question>();
        List<Question__c> qlist = [SELECT Id, Name, AnswerType__c,EntryCriteriaEvaluation__c,Question__c,QuestionnaireObjectId__r.Sequence__c, RecordTypeFieldsetIdentifier__c, QuestionnaireObjectId__r.Cap__c, QuestionnaireObjectId__r.Id, QuestionnaireObjectId__r.Name, QuestionnaireObjectId__r.ProcessType__c,QuestionnaireObjectId__r.QuestionnaireType__c , Sequence__c, HideAnswerOptions__c, QuestionHeader__c,ShowMitigationactionbutton__c,IsSubQuestion__c,QuestionHelpText__c,Predefinedfieldname__c,Predefinefrom__c,WhenToDisplayField__c,
                                    (SELECT OptionText__c, Name, BRCLabel__c, OptionHelpText__c, AddInfoHelpText__c, Answervalue__c, ShowAddInfo__c, Predefinefrom__c, ProcessControlStatus__c,ThisAnswerOption__c from Answer_Options__r ORDER BY Sequence__c ASC),
                                    (SELECT Id, ForgivenAnswerId__c, Name from AnswerQuestionRelations__r)
                                    from Question__c
                                    WHERE QuestionnaireObjectId__r.MasterQuestionnaire__c =:questionnaireId  ORDER BY Sequence__c ASC];

        // get the AnswerQuestionRelations for all questions in this questionnaire
        List<AnswerQuestionRelation__c> aqrList =[ SELECT ForgivenAnswerId__c, AskthisQuestionId__c from AnswerQuestionRelation__c
        WHERE AskthisQuestionId__r.QuestionnaireObjectId__c =:questionnaireId ORDER BY ForgivenAnswerId__c];

        // throw them into an addressable map of list
        Map<String, List<String>> aqrStringsByStrings = new Map<String, List<String>>();

        for(AnswerQuestionRelation__c aqr:aqrList){
            if(!aqrStringsByStrings.containsKey(aqr.ForgivenAnswerId__c)){
                aqrStringsByStrings.put(aqr.ForgivenAnswerId__c, new List<String>());
            }
            aqrStringsByStrings.get(aqr.ForgivenAnswerId__c).add(aqr.AskthisQuestionId__c);
        }
        
        /*
         * Loop for fetching the Questionnaire ids and Related Loa Risk Classificatin records
         */
        Map<Id,Id> questionnaireLOAClassMap = new Map<Id,Id>();
        
        Set<Id> questionnaireIds = new Set<Id>();
        
        for(Question__c q:qlist){
            questionnaireIds.add(q.QuestionnaireObjectId__r.Id);
        }


        for(LoARiskClassification__c loa :[Select Id,Name,QuestionnaireId__c from LoARiskClassification__c Where QuestionnaireId__c IN :questionnaireIds AND PMLoAProjectId__c	 = :loAProjectId]){
            questionnaireLOAClassMap.put(loa.QuestionnaireId__c,loa.Id);
        }

        for(Question__c q:qlist){
            Question qo = new Question(q);
            if(existingTopicsMap.containsKey(q.Id)){
                qo.AnswerGiven = existingTopicsMap.get(q.Id);
            }

            // this section will identify the questions, which are normally hidden (Is Sub Question), but are triggered based on
            // given answers in previous questionnaires!!
            if(!q.AnswerQuestionRelations__r.isEmpty()){
                for(AnswerQuestionRelation__c aqr: q.AnswerQuestionRelations__r){
                    if(AnsweredOptionStrings.contains(aqr.ForgivenAnswerId__c)){
                        qo.isHidden = false;
                    }
                }
            }

            // we need to identify AnswerQuestionRelations__r from all options for the specific question
            // and put them into a map. This will help the component, which related questions we will show on demand in the component
            // based on a given answer
            if(!q.Answer_Options__r.isEmpty()){
                for(AnswerOption__c answerOption : q.Answer_Options__r){
                    if(aqrStringsByStrings.containsKey(answerOption.id)){

                        qo.RelatedQuestionsMap.put(answerOption.id, aqrStringsByStrings.get(answerOption.id));
                    }
                }
            }
            system.debug('## Full Blown question: ' + qo);
            qlistObjects.add(qo);
        }
        
        //RecordType Map from Third Party Involved Object
        Map<String,Id> thirdPartyRecordTypeMap = new Map<String,Id>();
        for(RecordType recType: [SELECT Id,Name,Description,DeveloperName FROM RecordType Where SobjectType= 'ThirdPartyInvolved__c']){
            thirdPartyRecordTypeMap.put(recType.DeveloperName,recType.Id);
        }
         

        qw.questionsList = qlistObjects;
        qw.questionnaireLOAClassMap = questionnaireLOAClassMap;
        qw.thirdPartyRecordTypeMap = thirdPartyRecordTypeMap;
        return qw;
    }

    
     @AuraEnabled
    public static List<QuestionnaireWrapper> getQuestionStructure(String questionnaireId, String loAProjectId) {
        Map<String, RiskTopic__c> existingTopicsMap = new Map<String, RiskTopic__c>();
        Set<String> AnsweredOptionStrings = new Set<String>();
        List<QuestionnaireWrapper> returnValue = new List<QuestionnaireWrapper>();
        // This list will help us, to identify the questions, which have been answered already
        List<RiskTopic__c> existingTopics = [SELECT Id, Name,QuestionId__c,Question__c,Status__c, RequestForRelease__c,InitialBid__c,CustomerRequest__c,AnsweroptionId__c,AnswerText__c,AnswerNumber__c, AdditionalNotes__c, AnswerCurrency__c,ProcessStepId__c,ProcessControlStatus__c,PMLoADataId__c FROM RiskTopic__c
        WHERE PMLoADataId__c =:loAProjectId
        ];

        //We put them into a map
        for(RiskTopic__c topic: existingTopics){
            existingTopicsMap.put(topic.QuestionId__c, topic);
            AnsweredOptionStrings.add(topic.AnsweroptionId__c);
        }

        /** Now we pull all questions, related answeroptions and related sub question
         * records.
         */
        List<Question> qlistObjects = new List<Questionnaire_Cont.Question>();
        List<Question__c> qlist = [SELECT Id, Name, AnswerType__c,EntryCriteriaEvaluation__c,Question__c,QuestionnaireObjectId__r.Sequence__c, RecordTypeFieldsetIdentifier__c, QuestionnaireObjectId__r.Cap__c, QuestionnaireObjectId__r.Id, QuestionnaireObjectId__r.Name, QuestionnaireObjectId__r.ProcessType__c,QuestionnaireObjectId__r.QuestionnaireType__c , Sequence__c, HideAnswerOptions__c, QuestionHeader__c,ShowMitigationactionbutton__c,IsSubQuestion__c,QuestionHelpText__c,Predefinedfieldname__c,Predefinefrom__c,WhenToDisplayField__c,
        (SELECT OptionText__c, Name, BRCLabel__c, OptionHelpText__c, AddInfoHelpText__c, Answervalue__c, ShowAddInfo__c, Predefinefrom__c, ProcessControlStatus__c,ThisAnswerOption__c from Answer_Options__r ORDER BY Sequence__c ASC),
        (SELECT Id, ForGivenAnswerId__c, Name from AnswerQuestionRelations__r)
        from Question__c
        WHERE QuestionnaireObjectId__r.MasterQuestionnaire__c =:questionnaireId  ORDER BY Sequence__c ASC];


        // get the AnswerQuestionRelations for all questions in this questionnaire
        List<AnswerQuestionRelation__c> aqrList =[ SELECT ForGivenAnswerId__c, AskthisQuestionId__c from AnswerQuestionRelation__c
        WHERE AskthisQuestionId__r.QuestionnaireObjectId__c =:questionnaireId ORDER BY ForGivenAnswerId__c];

        // throw them into an addressable map of list
        Map<String, List<String>> aqrStringsByStrings = new Map<String, List<String>>();

        for(AnswerQuestionRelation__c aqr:aqrList){
            if(!aqrStringsByStrings.containsKey(aqr.ForGivenAnswerId__c)){
                aqrStringsByStrings.put(aqr.ForGivenAnswerId__c, new List<String>());
            }
            aqrStringsByStrings.get(aqr.ForGivenAnswerId__c).add(aqr.AskthisQuestionId__c);
        }



        /** Lets Lets pull all questionnaires which are related with the Master questionnaire
        /**
        /** Lets */

        Map<id,Questionnaire__c> tmpQuestionnairesMap = new Map<id,Questionnaire__c>([SELECT Id, Name,EntryCriteriaEvaluation__c,Sequence__c, ParentId__c, Cap__c, QuestionnaireType__c FROM Questionnaire__c
        WHERE MasterQuestionnaire__c=:questionnaireId  ORDER BY Sequence__c ASC]);

        /** We will pull now existing Risk Classes from the LoA PM record according
         * to the questionnaire id's
         */
        List<LoARiskClassification__c> tmpARiskClassifications = [Select id, Name, QuestionnaireId__c,Status__c from LoARiskClassification__c WHERE PMLoAProjectId__c =:loAProjectId AND QuestionnaireId__c IN :tmpQuestionnairesMap.keySet() ];

        /**Put the structure of the the questionnaire into an addressable map of
         * QuestionnaireWrapper
         */
        Map<id, QuestionnaireWrapper> qnrCollection = new Map<id, QuestionnaireWrapper>();

        for(id qnrId:tmpQuestionnairesMap.keySet()){
            if(!qnrCollection.containsKey(qnrId)){
                qnrCollection.put(qnrId, new QuestionnaireWrapper());
            }
            qnrCollection.get(qnrId).questionnaire = tmpQuestionnairesMap.get(qnrId);
            qnrCollection.get(qnrId).questionsList = new List<Questionnaire_Cont.Question>();

        }
        for(LoARiskClassification__c rc:tmpARiskClassifications){
            if(qnrCollection.containsKey(rc.QuestionnaireId__c)){
                qnrCollection.get(rc.QuestionnaireId__c).riskClass =rc;
            }
        }


        /**  We collect all questions and related objects into the question wrapper
        /**  *
        /**  */
        for(Question__c q:qlist){
            Question qo = new Question(q);
            if(existingTopicsMap.containsKey(q.Id)){
                qo.AnswerGiven = existingTopicsMap.get(q.Id);
            }

            // this section will identify the questions, which are normally hidden (Is Sub Question), but are triggered based on
            // given answers in previous questionnaires!!
            if(!q.AnswerQuestionRelations__r.isEmpty()){
                for(AnswerQuestionRelation__c aqr: q.AnswerQuestionRelations__r){
                    if(AnsweredOptionStrings.contains(aqr.ForGivenAnswerId__c)){
                        qo.isHidden = false;
                    }
                }
            }

            // we need to identify AnswerQuestionRelations__r from all options for the specific question
            // and put them into a map. This will help the component, which related questions we will show on demand in the component
            // based on a given answer
            if(!q.Answer_Options__r.isEmpty()){
                for(AnswerOption__c answerOption : q.Answer_Options__r){
                    if(aqrStringsByStrings.containsKey(answerOption.id)){

                        qo.RelatedQuestionsMap.put(answerOption.id, aqrStringsByStrings.get(answerOption.id));
                    }
                }
            }
            if(qnrCollection.containsKey(q.QuestionnaireObjectId__c)){

                qnrCollection.get(q.QuestionnaireObjectId__c).questionsList.add(qo);
            }
            //qlistObjects.add(qo);
        }

        return qnrCollection.values();

    }
    
     /**
    * @author Sara Elalaoui
    * @date 02/07/2017
    * @description get list of Questionnaires according to the stageName
    * @param String stageName
    * return List<Questionnaire__c>
    * @throws 
    */
    @AuraEnabled
    public static List<Questionnaire__c> getQuestionnaire(String stageName, String projectIdString){
       try{
           
            Map<Id,Questionnaire__c> resultMap= new Map<Id,Questionnaire__c>([
                SELECT Id, Name,ProcessType__c,QuestionnaireType__c,StatusCheckField__c,DefaultStatus__c,ProcessDescription__c, Cap__c
                FROM Questionnaire__c
                WHERE ProcessType__c = : stageName
                    ORDER BY Sequence__c ASC
            ]);
            
             // get a list of currently established questionnaires and their status
            List<LoARiskClassification__c> existingTopics = [Select id, Name, QuestionnaireId__c,Status__c from LoARiskClassification__c WHERE PMLoAProjectId__c =:projectIdString AND QuestionnaireId__c IN :resultMap.keySet()];

            
            //Updating the Map with latest Status from the LOA Risk Classification
            //As the Questionnaire will contain Default(Fixed) Status values but its related LOA Risk Classification has Updated
            //Status values based on the questions answered
            Questionnaire__c qc;
            for(LoARiskClassification__c lrc: existingTopics){
                qc = resultMap.get(lrc.QuestionnaireId__c);
                if(qc != null){
                    qc.DefaultStatus__c = lrc.Status__c;
                    resultMap.put(qc.Id,qc);
                }
            }

            List<Questionnaire__c> result = resultMap.values();
            return result;
            
        }catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }
    }
    
     @AuraEnabled
    public static List<AggregateResult> getCountryRisks(String PM_LoARecordId, List<String> countries){
        List<AggregateResult> aggregateResults = [SELECT RiskType__c, MAX(RiskLevel__c) Risk,MAX(EquivalentRiskValue__c) Value from CountryRiskDetail__c
        WHERE RelatedCountry__c in :countries GROUP BY RiskType__c];


        return aggregateResults;
    }

    @AuraEnabled
    public static String getRiskClassRecord(String questionnaireName, String PMLoaReportIdString, String QuestionnaireIdString , String RiskTypeString){
        String recordId ='';
        List<LoARiskClassification__c> loaClasses = [SELECT Id, QuestionnaireId__c,TypeOfRisk__c, Name from LoARiskClassification__c WHERE QuestionnaireId__c =:QuestionnaireIdString AND PMLoAProjectId__c=:PMLoaReportIdString LIMIT 1];
        if(!loaClasses.isEmpty()){
            recordId=loaClasses[0].Id;
        }else{
            LoARiskClassification__c newRec = new LoARiskClassification__c(Name = questionnaireName, TypeOfRisk__c = RiskTypeString,  QuestionnaireId__c=QuestionnaireIdString, PMLoAProjectId__c= PMLoaReportIdString);

            insert newRec;
            recordId = newRec.Id;
        }
        return recordId;
    }
    
     @AuraEnabled
    public static String createLOARiskClassRecord(String questionnaireName, String PMLoaReportIdString, String QuestionnaireIdString ,Integer RiskCap,  String RiskTypeString,String topRiskClassification){

        String recordId ='';
        List<LoARiskClassification__c> loaClasses = [SELECT Id, QuestionnaireId__c,TypeofRisk__c, Name from LoARiskClassification__c WHERE QuestionnaireId__c =:QuestionnaireIdString AND PMLoAProjectId__c =:PMLoaReportIdString LIMIT 1];
        if(!loaClasses.isEmpty()){
            recordId=loaClasses[0].Id;
        }else{
            LoARiskClassification__c newRec = new LoARiskClassification__c(Name = questionnaireName, TypeofRisk__c = RiskTypeString,  cap__c=RiskCap, QuestionnaireId__c=QuestionnaireIdString, PMLoAProjectId__c= PMLoaReportIdString,TopRiskClassification__c =  topRiskClassification);
            insert newRec;
            recordId = newRec.Id;
        }
        return recordId;
    }

     @AuraEnabled
    public static List<ThirdPartyInvolved__c> getThirdPartyRecords(String loAProjectId){
                List<ThirdPartyInvolved__c> returnList= [SELECT Id, Name, BPCDDURL__c FROM ThirdPartyInvolved__c WHERE RecordType.DeveloperName='Business_Partner' AND PMLoAProjectId__c=:loAProjectId ];

        return returnList;
    }

    
    //question wrapper class 
    public class Question{
         @AuraEnabled
        public Question__c QuestionRecord {get; set;}

        @AuraEnabled
        public boolean isHidden {get;set;}

        @AuraEnabled
        public Map<String,AnswerOption__c> AnswerOptions {get; set;}

        @AuraEnabled
        public Map<String,List<String>> RelatedQuestionsMap {
            get{
                if(RelatedQuestionsMap == null){
                    RelatedQuestionsMap = new Map<String,List<String>>();
                }
                return RelatedQuestionsMap;
            }

            set;}

        @AuraEnabled
        public Set<String> ShowOnOptionStrings {get;set;}

        @AuraEnabled
        public RiskTopic__c AnswerGiven {get;set;}

        public Question(Question__c q){
            this.QuestionRecord = q;
            this.isHidden = false;
            //test, whether we need to hide the question
            if(q.IsSubQuestion__c>0){
                this.isHidden = true;
            }

            if(!q.Answer_Options__r.isEmpty()){
                Map<String,AnswerOption__c> aoMap = new Map<String,AnswerOption__c>();
                for(AnswerOption__c a :q.Answer_Options__r){
                    aoMap.put(a.Id, a);
                }
                this.AnswerOptions = aoMap;
            }
        }
    }
    
    /*
     * Wrapper Class to Hold List of Questions and Map of Questionnaire-LOA
     */ 
    public class QuestionnaireWrapper{
        @AuraEnabled
        List<Question> questionsList{Set;get;}

        @AuraEnabled
        public Questionnaire__c questionnaire {get;set;}

        @AuraEnabled
        public LoARiskClassification__c riskClass {get;set;}

        
        @AuraEnabled
        public Map<Id,Id> questionnaireLOAClassMap{get;set;}


        @AuraEnabled
        Public Map<String,Id> thirdPartyRecordTypeMap{set;get;}
        
    }
    /*
     * Wrapper Class to hold a list of Questionnaires with the status of already established Risk classifications
     */

    public class QuestionnaireButtonWrapper{
        @AuraEnabled
        Public Questionnaire__c questionnaire{get;set;}

        @AuraEnabled
        Public LoARiskClassification__c riskClassification {get;set;}

    }
}