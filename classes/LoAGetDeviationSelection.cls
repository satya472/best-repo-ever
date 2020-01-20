/**
 * Created by jens.becker on 25.04.18.
 */

public with sharing class LoAGetDeviationSelection {

    @AuraEnabled
    public static List<LOABusinessRule__c> getQuestionnairesSObjects(String lReportId , String filter, String filterL1 ){
        List<LOABusinessRule__c> rules = new List<LOABusinessRule__c>();
        Set<Id> existingIds = new Set<Id>();
        String levelFilter = '';
        if(!String.isEmpty(filterL1)){
            levelFilter = ' AND SectionNumberLevel1__c=\''+ filterL1 +'\'';
        }

        //if we have a reportid of a LoA Report, we can fetch already existing Approval topics
        if(!String.isEmpty(lReportId)){
            for(LOAApprovalTopics__c Apt:[SELECT LOADeviationIDTxT__c from LOAApprovalTopics__c WHERE LOAReportId__c=:lReportId])
            existingIds.add(apt.LOADeviationIDTxT__c);
        }
        
        //[Yash] - Added a check of user's region with the segment on the deviation to only fetch relevant deviations for the user's region
        String userRegion = [Select Region__c From User Where Id = :UserInfo.getUserId()][0].Region__c;

        String rulesSOQL = 'Select Id,Name,Description__c,BusinessSpecificComments__c,SectionNumberLevel1__c,  (SELECT id, Name,Status__c,Business_Rule_Type__c,LOAApprovalGateId__r.Name,LOABusinessRuleId__r.Name, LOABusinessRuleId__r.Description__c, LOAApprovalGateId__r.OwnerId,DescriptionOfDeviation__c from Deviations__r'+
               ' WHERE Id NOT IN :existingIds ';
        //[Yash] - Add a region check if the region is populated on user
        if(userRegion != null && userRegion != ''){
            rulesSOQL += ' AND Segment__c = \'PS PG '+userRegion+'\' ';
        }
        rulesSOQL += ' ORDER BY LOAApprovalGateId__r.Name DESC) FROM LOABusinessRule__c WHERE Stage__c = \'Active\' AND LOAClassification__c =\''+filter + '\''+
                levelFilter+
                ' ORDER BY SectionNumberLevel1__c, SectionNumberLevel2__c,SectionNumberLevel3__c,SectionNumberLevel4__c';

        rules = database.query(rulesSOQL);
        system.debug(rulesSOQL);
        return rules;
    }

    @AuraEnabled
    public static Map<String,List<String>> getLevel1Options(){
        Map<String,List<String>> returnMap = new  Map<String,List<String>>();

        AggregateResult[] ruleOptions = [Select LOAClassification__c,SectionNumberLevel1__c, count(id)
        FROM LOABusinessRule__c
        WHERE Stage__c = 'Active' and LOAClassification__c!=''
        GROUP BY LOAClassification__c,SectionNumberLevel1__c
        ORDER BY LOAClassification__c,SectionNumberLevel1__c
        ];
        for (AggregateResult ar : ruleOptions)  {
            if(!returnMap.containsKey(String.valueOf(ar.get('LOAClassification__c')))){
                returnMap.put(String.valueOf(ar.get('LOAClassification__c')),new List<String>());
            }
            returnMap.get(String.valueOf(ar.get('LOAClassification__c'))).add(String.valueOf(ar.get('SectionNumberLevel1__c')));
        }
        return returnMap;
    }



    @AuraEnabled
    public static void createApprovalsTopicsFromMap( Map<String,Object> collectionItems, String loaReportId, String quoteId, String gateId, String topicType,List<LOADeviation__c> options){

        String repId = '';

        system.debug('## QuoteId'+quoteId);
        system.debug('## ReportIdId'+loaReportId);
        List<LOAApprovalTopics__c> appTopics = new List<LOAApprovalTopics__c>();

        for(LOADeviation__c dev : options){
            LOAApprovalTopics__c appTopic= new LOAApprovalTopics__c();

            if(!String.isEmpty(loaReportId)){
                appTopic.LOAReportId__c = loaReportId;
            }
            if(!String.isEmpty(quoteId)){
                appTopic.QuoteId__c = quoteId;
            }
            appTopic.Name = dev.LOABusinessRuleId__r.Name;
            appTopic.Baseline__c =dev.LOABusinessRuleId__r.Description__c;
            appTopic.Deviation_Description__c = dev.DescriptionOfDeviation__c;
            appTopic.ApprovalGateId__c = dev.LOAApprovalGateId__c;
            appTopic.ApprovalTopicType__c = dev.Business_Rule_Type__c;
            appTopic.ApprovalTopicType__c = dev.Business_Rule_Type__c;
            appTopic.LoAApprovalGateIDTxT__c = dev.LOAApprovalGateId__c;
            appTopic.LOABusinessRuleIDTxT__c = dev.LOABusinessRuleId__c;
            appTopic.LOADeviationIDTxT__c = dev.Id;

            appTopics.add(appTopic);
        }
        insert appTopics;
    }

}