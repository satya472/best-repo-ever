/*
* Author: Angelina Muddamalle
* Company: Accenture
* Date: 22-May-2018
* Description: BuyingCenterController called from BuyingCenterComponent
*/

public class BuyingCenterController {
    
    /*
* @description:Get Buying Center Details
*/
    @AuraEnabled
    public static BuyingCenterWrapper getBuyingCenterDetails (String recordId){
        BuyingCenterWrapper buyingCenterDetails = new BuyingCenterWrapper(); 
        List<Buying_Center_Member__c> buyingCenterMembers = new List<Buying_Center_Member__c>();
        
        //query for the buying center and selling center members
        Map<Id, Buying_Center_Member__c> bcmMap = getBuyingCenterMemberMap(recordId);      
        buyingCenterDetails.buyingCenterMemberList = bcmMap.values();
        
        List<Buying_Center_Relation__c> bcRelationList = getBuyingCenterRelationList(bcmMap.keySet());
        buyingCenterDetails.buyingCenterRelationList = bcRelationList;
        system.debug('buyingCenterDetails: '+buyingCenterDetails);
        return buyingCenterDetails;
    }
    
    /*
* @description:create Buying Center relation
*/     
    @AuraEnabled
    public static List<Buying_Center_Relation__c> createBuyingCenterRelation (String recordId, String sellingCenterMemberId, String buyingCenterMemberId){       
        Set<Id> centerMemberList = new Set<Id>{Id.valueOf(sellingCenterMemberId)};
            centerMemberList.add(Id.valueOf(buyingCenterMemberId));
        List<Buying_Center_Relation__c> bcRelationList = getBuyingCenterRelationList(centerMemberList);
        
        if(bcRelationList.size() == 0 ){
            Buying_Center_Relation__c buyingCenterRelation = new Buying_Center_Relation__c();
            buyingCenterRelation.BuyingCenterMember__c = buyingCenterMemberId;
            buyingCenterRelation.SellingCenterMember__c = sellingCenterMemberId;
            try {
                insert buyingCenterRelation;
            } catch (DmlException e) {
                System.debug(' Insert Failed on Buying Center Relation '+e.getMessage());
            }
        }
        List<Buying_Center_Relation__c> finalBCRelationList = getBuyingCenterDetails(recordId).buyingCenterRelationList;
        return finalBCRelationList;
    }
    
    /*
* @description:Delete Buying Center Relation 
*/     
    @AuraEnabled
    public static List<Buying_Center_Relation__c> deleteBuyingCenterRelation (String recordId, String sellingCenterMemberId, String buyingCenterMemberId){     
        Set<Id> centerMemberList = new Set<Id>{Id.valueOf(sellingCenterMemberId)};
            centerMemberList.add(Id.valueOf(buyingCenterMemberId));
        List<Buying_Center_Relation__c> bcRelationList = getBuyingCenterRelationList(centerMemberList);
        try {
            delete bcRelationList;                
        } catch (DmlException e) {
            System.debug(' Delete Failed on Buying Center Relation '+e.getMessage());
        }
        List<Buying_Center_Relation__c> finalBCRelationList = getBuyingCenterDetails(recordId).buyingCenterRelationList;
        return finalBCRelationList;
    } 
    
    /*
* @description:create Buying Center member 
*/ 
    @AuraEnabled
    public static void createBuyingCentreMembers(String modalName, String searchScope, String oppId, Object[] bcmList){ 
        List<Buying_Center_Member__c> bcmInsertList = new List<Buying_Center_Member__c>();
        List<OpportunityTeamMember> otmInsertList = new List<OpportunityTeamMember>();
        Buying_Center_Member__c newBCM;
        
        //get the position of the BCMS
        String bcmType;
        if(modalName != 'SCM'){
            bcmType = 'Buying Center';
        }else{
            bcmType = 'Selling Center';
        }
        List<Buying_Center_Member__c> nextBCMList = [SELECT ID, Type__c, Position__c FROM Buying_Center_Member__c 
                                                     WHERE Opportunity__c =:oppId AND Type__c =:bcmType];
        Integer position;
        if(nextBCMList != null)
            position = nextBCMList.size();
        else
            position = 0;
        
        // create BCM with the below contact ids
        for (Object value : bcmList) {
            Map<String, Object> m = (Map<String, Object>)value;
            newBCM = new Buying_Center_Member__c();
            newBCM.Opportunity__c = oppId; 
            newBCM.Category__c = (String)m.get('Category');
            newBCM.Status__c = (String)m.get('Status');
            newBCM.Buying_Role__c = (String)m.get('Role');
            newBCM.Type__c = bcmType;
            newBCM.Position__c = position +1;
            //get user/contact
            if(searchScope != null && searchScope == 'allContacts'){
                newBCM.Contact__c = (String)m.get('Id');
            }
            else if(modalName != 'SCM'){
                newBCM.Contact__c = (String)m.get('Id');
            }else{
                newBCM.User__c = (String)m.get('Id');
            }
            position++;
            system.debug(newBCM);
            
            bcmInsertList.add(newBCM);
            
            //if type = Selling Center create a new Opportunity Team Member
            if(newBCM.Type__c == 'Selling Center' && newBCM.User__c != null){
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.OpportunityId = oppId;
                otm.UserId = newBCM.User__c;
                otmInsertList.add(otm);
            }
        }
        
        
        insert bcmInsertList; 
        insert otmInsertList;
        
    }
    
    /*
* @description:delete Buying Center member 
*/ 
    @AuraEnabled
    public static void deleteBuyingCentreMembers(String recordId){
        system.debug('recordId: '+recordId);
        List<Buying_Center_Member__c> updateBCMList = new List<Buying_Center_Member__c>();
        try {
            Buying_Center_Member__c bcm = [SELECT ID, Type__c, Position__c, Opportunity__c FROM Buying_Center_Member__c WHERE ID =:recordId];
            List<Buying_Center_Member__c> nextBCMList = [SELECT ID, Type__c, Position__c FROM Buying_Center_Member__c 
                                                         WHERE Opportunity__c =:bcm.Opportunity__c AND Type__c =:bcm.Type__c 
                                                         AND Position__c > :bcm.Position__c];
            system.debug(nextBCMList);
            for(Buying_Center_Member__c newPosBCM : nextBCMList){
                if(newPosBCM != null){
                    newPosBCM.Position__c = newPosBCM.Position__c - 1;
                    updateBCMList.add(newPosBCM);
                }
            }            
            delete bcm; 
            update updateBCMList;
        } catch (DmlException e) {
            System.debug(' Delete Failed on Buying Center Member '+e.getMessage());
        }      
    } 
    
    /*
* @description:Get Buying Center Members List
*/    
    @AuraEnabled
    public static Map<Id, Buying_Center_Member__c> getBuyingCenterMemberMap (String recordId){
        Map<Id, Buying_Center_Member__c> bcmMap = new Map<Id, Buying_Center_Member__c>([SELECT Id, Name, Category__c, Status__c,
                                                                                        Buying_Role__c, Contact__c, Opportunity__c,Type__c,
                                                                                        Reports_to_Project_Setup__c, Position__c
                                                                                        FROM Buying_Center_Member__c WHERE Opportunity__c =:recordId]);
        return bcmMap;        
    }   
    
    /*
* @description:Get Buying Center Members List
*/    
    @AuraEnabled
    public static void updateBuyingCenterMember (List<Buying_Center_Member__c> centerMemberList){
        try {
            update centerMemberList; 
        } catch (DmlException e) {
            System.debug(' Update Failed on updateBuyingCenterMember method '+e.getMessage());
        } 
        
    }    
    
    /*
* @description:Get Buying Center Members List
*/
    private static List<Buying_Center_Relation__c> getBuyingCenterRelationList (Set<Id> bcmList){             
        List<Buying_Center_Relation__c> bcRelationList = [SELECT Id, Name, BuyingCenterMember__c, SellingCenterMember__c,
                                                          Competitor_Center_Member__c, Customer_Buying_Center_Member__c, Opportunity_Team_Member__c
                                                          FROM Buying_Center_Relation__c 
                                                          WHERE BuyingCenterMember__c IN:bcmList AND SellingCenterMember__c IN:bcmList];
        return bcRelationList;        
    }
    
    // Wrapper class to create buying center details with the below parameters 
    public class BuyingCenterWrapper{      
        @AuraEnabled public List<Buying_Center_Member__c> buyingCenterMemberList{get;set;}
        @AuraEnabled public List<Buying_Center_Relation__c> buyingCenterRelationList{get;set;}
    }
    
    /*
* Method Name   : getFieldSetData
* Purpose       : To get fieldset data
*/
    @AuraEnabled
    public static List<String> getFieldSetData(String sObjectName, String fieldSetName) {
        List<String> result = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if(FsMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    result.add(f.getFieldPath());
                }
            }
        }
        catch(Exception e){
            e.getMessage();
        }
        system.debug('result: '+result);
        return result;
    }    
    
    /*
* Method Name   : getFieldSetData
* Purpose       : To get fieldset data
*/
    @AuraEnabled
    public static String getOpportunityId(String objectAPI, String fieldAPI, String recordId) {
        String result = '';
        List<sObject> lstResult = new List<sObject>();
        String query = 'SELECT ' + fieldAPI + ' FROM ' + objectAPI +' WHERE ID = \''+recordId+'\'';
        for(sObject s : Database.query(query)){
            lstResult.add(s);
        } 
        if(lstResult.size() > 0) {
            sObject res = lstResult.get(0);
            result = (String)res.get(fieldAPI);
        }
        return result;
    }
    
    
    //Methods for the generic record selector component
    @AuraEnabled
    public static String getSearchScope(String modalName) {
        String searchScopeList = '';
        if(modalName != 'SCM'){
            searchScopeList = '[{"label":"Account Contacts", "value": "accountContacts","selected": "true"},'+
                '{"label": "All Contacts", "value": "allContacts"}]';            
        }else{
            searchScopeList = '[{"label":"Opportunity Team Members", "value":"otmContacts","selected": "true"},'+
                '{"label":"All Salesforce Users", "value":"allSFUsers"},'+
                '{"label":"All Contacts", "value":"allContacts"}]';
        }
        return searchScopeList;
    }
    
    /*
Method Name	: getSObjectName
Purpose		: To get the SObject Name
*/
    
    @AuraEnabled
    public static String getSObjectName(String modalName, String searchScope) {
        String sObjectName;
        if(searchScope != null && searchScope == 'allContacts'){
            sObjectName = 'Contact';
        }
        else if(modalName != 'SCM'){
            sObjectName = 'Contact';
        }else{
            sObjectName = 'User';
        }
        return sObjectName;
    }
    
    /*
Method Name	: getFieldSetName
Purpose		: To get the FieldSet Name
*/
    @AuraEnabled
    public static String getFieldSetName(String modalName) {
        String fieldSetName; 
        if(modalName != 'SCM'){
            fieldSetName = 'BuyingCenterContactFields';
        }else{
            fieldSetName = 'SellingCenterContactFields';
        }
        return fieldSetName;
    }
    
    /*
Method Name	: getTableRows
Purpose		: To get the table data
*/    
    @AuraEnabled
    public static List<sObject> getRecordsBCM(String sObjectName, String searchScope, String fieldNameJson, Opportunity record){
        system.debug('sObjectName: '+sObjectName);
        system.debug('searchScope: '+searchScope);
        system.debug('fieldNameJson: '+fieldNameJson);
        system.debug('record: '+record);
        
        List<sObject> lstResult = new List<sObject>();
        Boolean whereFlag = false;
        String parentFieldName = null; 
        String parentRecordId = null;
        //SearchScope criterias
        if(searchScope == 'accountContacts'){
            parentFieldName='AccountId';
            parentRecordId = record.AccountId;
        }
        
        try{
            List<String> bcmContactList =  new List<String>();
            //get the list of Contacts as BCM on opportunity
            List<Buying_Center_Member__c> bcmRecords = [SELECT Id, Name,Contact__c, Opportunity__c FROM Buying_Center_Member__c 
                                                        WHERE Opportunity__c =:record.Id AND Contact__c != null];
            for(Buying_Center_Member__c bcm : bcmRecords){
                bcmContactList.add(bcm.Contact__c);
            }
            
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            query += ' WHERE ';
            
            //contact is not a bcm already
            if(bcmContactList.size()>0){
                string contactIds = String.join(bcmContactList,'\',\'');
                query += 'ID NOT IN (\'' + contactIds+'\') AND ';
                whereFlag = true;
            }
            
            //query by parentId
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                query += '(' ;
                query += parentFieldName + '= \'' +  parentRecordId + '\'';
                
                //query by ids
                List<String> accContactRelationshipSet = new List<String>(getAccountContactRelationship(parentRecordId));
                if(accContactRelationshipSet.size()>0){
                    string contactIds = String.join(accContactRelationshipSet,'\',\'');
                    query += ' OR ID IN (\'' + contactIds+'\')';
                } 
                query += ')' ;
                whereFlag = true;                
            }else{
                query = query.removeEnd(' AND ');
            }
            
            if(!whereFlag){
                query = query.removeEnd(' WHERE ');
            }            
            system.debug(query);
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            } 
            system.debug(lstResult);
        }
        catch(Exception e){
            System.debug(' Delete Failed on Query '+e.getMessage());
        }
        return lstResult;
    }
    
    @AuraEnabled
    public static List<sObject> getRecordsSCM(String sObjectName, String searchScope, String fieldNameJson, Opportunity record){
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        Boolean whereFlag = false;
        String parentFieldName= null;
        
        //SearchScope criterias
        if(searchScope == 'otmContacts'){
            parentFieldName='OpportunityId';
        }
        
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();            
            String query = 'SELECT ID,' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            if(sObjectName != 'Contact'){
                query += ' WHERE IsActive = true';
                whereFlag = true;
            }
            else
                query += ' WHERE ';
            
            //check if the user is already a SCM        
            List<Buying_Center_Member__c> scmRecords = [SELECT Id, Name, User__c, Contact__c, Opportunity__c, Type__c
                                                        FROM Buying_Center_Member__c 
                                                        WHERE Opportunity__c =:record.Id AND (Type__c='Selling Center' 
                                                                                              OR Type__c='Buying Center')];
            List<String> scmUserList =  new List<String>();
            for(Buying_Center_Member__c scm : scmRecords){
                if(sObjectName != 'Contact')
                    scmUserList.add(scm.User__c);
                else
                    scmUserList.add(scm.Contact__c);
            }
            
            if(scmUserList.size()>0){
                if(whereFlag)
                    query += ' AND ';   
                string userIds = String.join(scmUserList,'\',\'');
                query += '(ID NOT IN (\'' + userIds+'\')) ';
                whereFlag = true;
            }
            
            //User is an OpportunityTeamMember
            List<Id> otmUserIdList = new List<Id>();
            if(parentFieldName != NULL && parentFieldName != ''){
                List<OpportunityTeamMember> otmList = [SELECT ID, OpportunityId, UserId FROM OpportunityTeamMember 
                                                       WHERE OpportunityId =: record.Id];
                for(OpportunityTeamMember otm: otmList){
                    otmUserIdList.add(otm.UserId);
                }
                
                if(whereFlag){
                    query += ' AND ';
                }
                query += '(' ;                            
                string otmUserIds = String.join(otmUserIdList,'\',\'');
                query += ' ID IN (\'' + otmUserIds+'\')';
                query += ')' ;
                whereFlag = true; 
            }
            
            if(!whereFlag){
                query = query.removeEnd(' WHERE ');
            }
            
            system.debug(query);
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            } 
            system.debug(lstResult);           
        }
        catch(Exception e){
            System.debug(' Delete Failed on Query '+e.getMessage());
        }
        return lstResult;
    }
    
    private static Set<String> getAccountContactRelationship(String parentRecordId){
        Set<String> lstResult = new Set<String>();        
        List<AccountContactRelation> accountContactList = [SELECT AccountId, ContactId FROM AccountContactRelation 
                                                           WHERE AccountId =:parentRecordId];
        for(AccountContactRelation obj: accountContactList){
            lstResult.add(obj.ContactId);
        }
        return lstResult;
    }
}