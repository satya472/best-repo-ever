/* 
@Author: Ankur Gupta
@Created Date: 23 April 2018
@Description: This class contains all the useful methods related to opportunity competitor scenario.
@Last Updated By: Ankur Gupta
@Last Update Date: 9 May 2018
@Last Updated Reason: Added helper methods and comments.
*/
public with sharing class TreeMapOpportunityCompHelper {
	
	 /*
    @Method Name: getOpportunityCompetition
    @Method Desc: It will return the opportunity Competitor records wrapper to the lightning component.
    @Input parameter type: (string intelligenceId)
    @Return type: list<TreeMapController.TreeMapGenericWrapper>
    */    
    @AuraEnabled 
    public static list<TreeMapController.TreeMapGenericWrapper> getOpportunityCompetition(string intelligenceId){
        
        // get lesson learned record id
        Intelligence__c intelligence= [select id, name, Opportunity__c, LessonLearnedId__c,  (select id, name, AccountId__c, AccountRelationTyp__c,  Country__c, IntelligenceId__c from ExperienceRelations__r where AccountRelationTyp__c='Competitor'), DrivedTo__c, Class__c, Remarks__c, MainCategories__c,SubCategories__c from Intelligence__c where id=:intelligenceId];
        string oppId= intelligence.Opportunity__c; // get opportunity id
          
        opportunity oppObj= [select id, name, accountId from opportunity where id=:oppId limit 1];
        string accountId= oppObj.accountId;

        // get opportunity competition record
        list<OpportunityCompetition__c> oppCompList= new list<OpportunityCompetition__c>();
        oppCompList= [select id, name, CompetitorAccount__r.Name,Advantages__c, OpportunityAccount__c, Stage__c, Strength__c, Threats__c, Weakness__c, Opportunity__c, CompetitorAccount__c from OpportunityCompetition__c where Opportunity__c=:oppId];

        // Opportunity wrapper list
        list<TreeMapController.TreeMapGenericWrapper> oppCompWrapperList= new list<TreeMapController.TreeMapGenericWrapper>();
        
        // checking for existing records of experience relation and comparing with opportunity competition
        if(intelligence.ExperienceRelations__r.size() > 0 && oppCompList.size() > 0){
        	
        	map<id,OpportunityCompetition__c> mapOfOppCompWithAccount= new map<id,OpportunityCompetition__c>();
        
	        for(OpportunityCompetition__c oppCompObjTmp: oppCompList){
				if(!mapOfOppCompWithAccount.containsKey(oppCompObjTmp.CompetitorAccount__c))
					mapOfOppCompWithAccount.put(oppCompObjTmp.CompetitorAccount__c,oppCompObjTmp);				
	        }
	        
            set<string> expRelationAccountID= new set<string>(); // create map of competitor account
            for(ExperienceRelation__c expRelationObj: intelligence.ExperienceRelations__r){
                expRelationAccountID.add(expRelationObj.AccountId__c);
            }
            system.debug(' expRelationAccountID '+ expRelationAccountID);
            // populating list of wrapper 
            for(OpportunityCompetition__c oppCompObj: mapOfOppCompWithAccount.Values()){
                TreeMapController.TreeMapGenericWrapper oppCompWrapper= new TreeMapController.TreeMapGenericWrapper();
                
                oppCompWrapper.id= oppCompObj.CompetitorAccount__c;
                //Updated With Competitor Name instead of Auto Number
                oppCompWrapper.label= oppCompObj.CompetitorAccount__r.Name;
                if(expRelationAccountID.contains(oppCompObj.CompetitorAccount__c)) // Checking if it exists in database
                    oppCompWrapper.isSelected= true; // True, if it is already exists
                else
                    oppCompWrapper.isSelected= false; // False, if not exists
                oppCompWrapper.level=3;
                oppCompWrapper.parentId='';
                
                
                oppCompWrapperList.add(oppCompWrapper); // populate wrapper
            }   
        }else{
            string jsonOppCompString;
            if(oppCompList.size()==0){
                return new list<TreeMapController.TreeMapGenericWrapper>(); // return empty list if competitor is not found
            }else{

    			map<id,OpportunityCompetition__c> mapOfOppCompWithAccount= new map<id,OpportunityCompetition__c>();
        
		        for(OpportunityCompetition__c oppCompObjTmp: oppCompList){
					if(!mapOfOppCompWithAccount.containsKey(oppCompObjTmp.CompetitorAccount__c))
						mapOfOppCompWithAccount.put(oppCompObjTmp.CompetitorAccount__c,oppCompObjTmp);				
		        }
    			// Create wrapper with opp Comp
                for(OpportunityCompetition__c oppCompObj: mapOfOppCompWithAccount.values()){
                    TreeMapController.TreeMapGenericWrapper oppCompWrapper= new TreeMapController.TreeMapGenericWrapper();
                    
                    oppCompWrapper.id= oppCompObj.CompetitorAccount__c;
                    //Updated With Competitor Name instead of Auto Number
                    oppCompWrapper.label= oppCompObj.CompetitorAccount__r.Name;
                    oppCompWrapper.isSelected= false;
                    oppCompWrapper.level=3;
                    oppCompWrapper.parentId='';
                    
                    oppCompWrapperList.add(oppCompWrapper); // populating wrapper with competitor records
                }    
            }        
        }

        return oppCompWrapperList; // retrun wrapper list to a tree component
    }
    
    /*
    @Method Name: createOppCompExperienceRelation
    @Method Desc: This method will create experience relation record for the particular record id. It will return the success/Failure message to 
    @Input parameter type: (string accId, string intelligenceId)
    @Return type: string
    */
    @AuraEnabled
    public static string createOppCompExperienceRelation(string accId, string intelligenceId){

        list<ExperienceRelation__c> expRelationList= new list<ExperienceRelation__c>();
        try{  
            // create new experience relation record
            ExperienceRelation__c expRelation= new ExperienceRelation__c();
           
            expRelation.AccountId__c= accId;
            expRelation.AccountRelationTyp__c= 'Competitor';
            expRelation.IntelligenceId__c= intelligenceId;
            
            expRelationList.add(expRelation);
            
            database.insert(expRelationList,false);
        }catch(exception ex){
            return ex.getMessage();
        }
        
        return 'Record has been created successfully.';
    }
     
     /*
    @Method Name: deleteOppCompExperienceRelation
    @Method Desc: This method will delete experience relation record for the particular record id. 
    @Input parameter type: (string accId, string intelligenceId)
    @Return type: string
    */ 
    @AuraEnabled
    public static string deleteOppCompExperienceRelation(string accId, string intelligenceId){
        
        list<ExperienceRelation__c> expRelationDelete= [select id, name, AccountId__c, AccountRelationTyp__c, Country__c, IntelligenceId__c from ExperienceRelation__c where IntelligenceId__c=:intelligenceId AND AccountId__c=:accId AND AccountRelationTyp__c='Competitor' limit 1];
        
        try{  
            database.delete(expRelationDelete,false);
        }catch(exception ex){
            return ex.getMessage();
        }
        
        return 'Record has been deleted' ;
    }
    
}