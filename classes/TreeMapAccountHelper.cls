/* 
@Author: Ankur Gupta
@Created Date: 26 April 2018
@Description: This class contains all the useful methods related to account scenario.
@Last Updated By: Ankur Gupta
@Last Update Date: 9 May 2018
@Last Updated Reason: Added helper methods and comments.
*/
public with sharing class TreeMapAccountHelper {
  	
	/*
    @Method Name: getOpportunityCompetition
    @Method Desc: It will return the opportunity Competitor records wrapper to the lightning component.
    @Input parameter type: (string intelligenceId)
    @Return type: list<TreeMapGenericWrapper>
    */
    @AuraEnabled  
    public static list<TreeMapController.TreeMapGenericWrapper> getAccountHierarchy(string intelligenceId){

        list<string> accountRelationType= new list<string>();
        accountRelationType.add('Customer');
        accountRelationType.add('Site');
        
        // get lesson learned record id
        Intelligence__c intelligence = [select id, name, Opportunity__c,LessonLearnedId__c, DrivedTo__c, Class__c, Remarks__c, MainCategories__c,SubCategories__c from Intelligence__c where id=:intelligenceId];
        string oppId= intelligence.Opportunity__c; // get opportunity id
        
        opportunity oppObj= [select id, name, accountId, account.parentId, account.name, account.billingCountry from opportunity where id=:oppId limit 1];
        
        string accountId= oppObj.accountId; // account associated to a paerticular opportunity
        string parentId= oppObj.account.parentId; // Check if account has parent id or not
        string accBillingCountry;
        string accName;
         
        account accParent= new account();
        map<string,boolean> mapOfAccIdWithIsSelectValue= new map<string,boolean>();
		list<TreeMapController.TreeMapGenericWrapper> wrapperClassList= new list<TreeMapController.TreeMapGenericWrapper>();
		        
        if(parentId !=null){
        	accParent= [select id, name, billingCountry, site, parentId, (select id, name, site, Type, parentId from ChildAccounts where Type='Site') from account where id=:parentId];
        	accBillingCountry= accParent.billingCountry;
        	accName= accParent.name;
        	
        	set<string> accountIdSet= new set<string>();
        	accountIdSet.add(accParent.id);
        	
        	for(account accChildObj :accParent.ChildAccounts){
        		accountIdSet.add(accChildObj.id);	
        	}
        	// Fill the map of user selected values 
        	getIsSelectedValuesInMap(intelligenceId, accountRelationType, accountIdSet, mapOfAccIdWithIsSelectValue);
        	
        	// Create wrapper for Parent component of tree	        	
        	TreeMapController.TreeMapGenericWrapper accCountryDetails= new TreeMapController.TreeMapGenericWrapper();
        	accCountryDetails.id= accParent.id + '_' + accParent.billingCountry;
        	accCountryDetails.label= accParent.billingCountry;
        	accCountryDetails.parentId='';        	 
        	accCountryDetails.level=1;
        	accCountryDetails.isSelected= mapOfAccIdWithIsSelectValue.get(accCountryDetails.id);
        	wrapperClassList.add(accCountryDetails);
        	// Create wrapper for country name of parent account
        	TreeMapController.TreeMapGenericWrapper accNameDetails= new TreeMapController.TreeMapGenericWrapper();
        	accNameDetails.id= accParent.id;
        	accNameDetails.label= accParent.name;
        	accNameDetails.level=2;
        	accNameDetails.parentId= accParent.id;
        	accNameDetails.isSelected= mapOfAccIdWithIsSelectValue.get(accParent.id);
        	wrapperClassList.add(accNameDetails);
        	  
        	map<string,account> siteMap= new map<string,account>();
        	for(account accObj: accParent.ChildAccounts){
    			if(!siteMap.containsKey(accObj.id)){
    				siteMap.put(accObj.id,accObj);	
    			}	
        	}
        	// create wrappper for child accounts
        	for(account accObj: siteMap.values()){
        		TreeMapController.TreeMapGenericWrapper childElementDetails= new TreeMapController.TreeMapGenericWrapper();
        		childElementDetails.id= accObj.id + '_Site';
	        	childElementDetails.label= accObj.name;
	        	childElementDetails.level=3;
	        	childElementDetails.parentId= accObj.parentId;
	        	childElementDetails.isSelected= mapOfAccIdWithIsSelectValue.get(accObj.id);
	        	wrapperClassList.add(childElementDetails);
        	}
    	// If parent account doesn't exists
        }else{
        	accBillingCountry= oppObj.account.billingCountry;	
        	accName= oppObj.account.name;
        	
        	set<string> accountIdSet= new set<string>();
        	accountIdSet.add(oppObj.accountId);
        	// Fill map of user selected values
        	getIsSelectedValuesInMap(intelligenceId, accountRelationType, accountIdSet, mapOfAccIdWithIsSelectValue);
        	// Create wrapper of child account for country where parent id is null
        	TreeMapController.TreeMapGenericWrapper accCountryDetails= new TreeMapController.TreeMapGenericWrapper();
        	accCountryDetails.id= oppObj.accountId + '_' + accBillingCountry;
        	accCountryDetails.label= accBillingCountry;
        	accCountryDetails.parentId='';
        	accCountryDetails.level=1;
        	accCountryDetails.isSelected= mapOfAccIdWithIsSelectValue.get(accCountryDetails.id);
        	wrapperClassList.add(accCountryDetails);
        	// Create wrapper of child account for name where parent id is null
        	TreeMapController.TreeMapGenericWrapper accNameDetails= new TreeMapController.TreeMapGenericWrapper();
        	accNameDetails.id= oppObj.accountId;
        	accNameDetails.label= accName;
        	accNameDetails.parentId= oppObj.accountId;
        	accNameDetails.level=2;
        	accNameDetails.isSelected= mapOfAccIdWithIsSelectValue.get(oppObj.accountId);
        	wrapperClassList.add(accNameDetails);        	
        }
          
        return wrapperClassList; // return wrapper list
    }
    
    /*
    @Method Name: createAccountExperienceRelation
    @Method Desc: This method will create experience relation record for the particular record id. It will return the success/Failure message to 
    @Input parameter type: (string accId, string intelligenceId)
    @Return type: string
    */
    @AuraEnabled
    public static string createAccountExperienceRelation(string accId, string intelligenceId){
    
        list<ExperienceRelation__c> expRelationList= new list<ExperienceRelation__c>();
        try{  
        	
        	// create new experience relation record
            ExperienceRelation__c expRelation= new ExperienceRelation__c();
            expRelation.IntelligenceId__c= intelligenceId;
            // If '_' doesnt exists means it is customer account
        	if(!accId.contains('_')){
        		expRelation.AccountRelationTyp__c= 'Customer';
				expRelation.AccountId__c= accId;
        	}else{ // If '_' esists
        		if(accId.contains('Site')){ // if string contains 'Site'
        			expRelation.AccountRelationTyp__c= 'Site';
        			string []strList = accId.split('_');
        			expRelation.AccountId__c= strList[0];
        		}else{
        			string []strList = accId.split('_');
	        		expRelation.AccountId__c= strList[0];
	        		expRelation.Country__c= strList[1];
        		}        		
        	}

            expRelationList.add(expRelation);
            // Experience relation list inserted
            insert expRelationList;
        }catch(exception ex){
            return ex.getMessage();
        }
        
        return null;
    }
    
    /*
    @Method Name: deleteAccountExperienceRelation
    @Method Desc: This method will delete experience relation record for the particular record id. 
    @Input parameter type: (string accId, string intelligenceId)
    @Return type: string
    */
    @AuraEnabled
    public static string deleteAccountExperienceRelation(string accId, string intelligenceId){
        
        string dmlMessage;
       try{
	        string accountId;
	        string accountRelationType;
	        if(accId.contains('_')){ // get the account id and relationship type
	        	string [] strList= accId.split('_');
	        	accountId= strList[0];
	        	
	        	if(strList[1] =='Site'){
	        		accountRelationType= 'Site';	
	        	}else{
	        		accountRelationType= '';
	        	}
	        }else{
	        	accountId= accId;
	        	accountRelationType= 'Customer';
	        }
	        
	        // query exp relation for deletion
	        list<ExperienceRelation__c> expRelationDelete= [select id, name, AccountId__c, AccountRelationTyp__c, Country__c, IntelligenceId__c from ExperienceRelation__c where IntelligenceId__c=:intelligenceId AND AccountId__c=:accountId AND AccountRelationTyp__c=:accountRelationType limit 1];
        	
	    	if(expRelationDelete.size() > 0){
	    		delete expRelationDelete;       
	    		dmlMessage= 'Record has been deleted successfully.';
	    	}else{
	    		dmlMessage= 'No records found.';        		
	    	}
        }catch(exception ex){
        	dmlMessage= ex.getMessage();            
        }        
        return dmlMessage;
    }
    
    /*
    @Method Name: getIsSelectedValuesInMap
    @Method Desc: This method add true/false value for a particular record in a tree component. 
    @Input parameter type: (string intelligenceIdTmp, list<string> accountRelationTypeTmp, set<string> accountIdSetTmp, map<string,boolean> mapOfAccIdWithIsSelectValueTmp)
    @Return type: void
    */
    private static void getIsSelectedValuesInMap(string intelligenceIdTmp, list<string> accountRelationTypeTmp, set<string> accountIdSetTmp, map<string,boolean> mapOfAccIdWithIsSelectValueTmp){
    	
    	list<ExperienceRelation__c> expRelationList= new list<ExperienceRelation__c>();
		expRelationList= [select id, name, AccountId__c, AccountRelationTyp__c, Country__c, AccountId__r.name, IntelligenceId__c from ExperienceRelation__c where IntelligenceId__c=:intelligenceIdTmp AND ((AccountRelationTyp__c IN :accountRelationTypeTmp AND AccountId__c IN :accountIdSetTmp) OR (AccountId__c IN :accountIdSetTmp AND Country__c!=null))];
        	   
    	for(string accId :accountIdSetTmp){
    		boolean isPresent=false; 
    		for(ExperienceRelation__c expRel :expRelationList){
    			if(expRel.AccountId__c==accId){ // if exp relation exists between account and lesson
    				isPresent=true;  
    				if(expRel.Country__c !=null){
    					string accIdWithCountry= accId +'_' + expRel.Country__c; 
    					mapOfAccIdWithIsSelectValueTmp.put(accIdWithCountry,true); // put true if relation of account with country exists
    				}else if(expRel.AccountRelationTyp__c=='Customer' || expRel.AccountRelationTyp__c=='Site'){        					 
    					mapOfAccIdWithIsSelectValueTmp.put(accId,true); // put true if relation of account with customer exists
    				}
    			}
    		}	        		
    		if(!isPresent){
    			mapOfAccIdWithIsSelectValueTmp.put(accId,false); // put false if exp relation doesnt exists
    		}
    	} 

    }    
}