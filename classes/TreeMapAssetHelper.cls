/* 
@Author: Ankur Gupta
@Created Date: 30 April 2018
@Description: This class contains all the useful methods related to asset scenario.
@Last Updated By: Ankur Gupta
@Last Update Date: 9 may 2018
@Last Updated Reason: Added asset helper methods and comments.
*/
public with sharing class TreeMapAssetHelper {
	
	/*
    @Method Name: getAllAssetsOfOpportunity
    @Method Desc: It will return all Assets associated with the Primary Quote to the lightning component.
    @Input parameter type: (string intelligenceId)
    @Return type: list<TreeMapController.TreeMapGenericWrapper>
    */
    @AuraEnabled
    public static list<TreeMapController.TreeMapGenericWrapper> getAllAssetsOfOpportunity(string intelligenceId){

    	//get lesson learned record id
        Intelligence__c intelligence= [select id, name, Opportunity__c,LessonLearnedId__c, DrivedTo__c,Class__c,QuoteLineId__c, Remarks__c, MainCategories__c,SubCategories__c from Intelligence__c where id=:intelligenceId];
        string oppId= intelligence.Opportunity__c; // get opportunity id
            
        opportunity oppObj= [select id, name, accountId, (Select id, name, SBQQ__Primary__c from SBQQ__Quotes2__r where SBQQ__Primary__c=true) from opportunity where id=:oppId limit 1];
        
        string accountId= oppObj.accountId;
        string primaryQuoteId;
        
        list<TreeMapController.TreeMapGenericWrapper> wrapperClassList= new list<TreeMapController.TreeMapGenericWrapper>();
        // if primary qupte exists
        if(oppObj.SBQQ__Quotes2__r.size() > 0){
        	
        	primaryQuoteId= oppObj.SBQQ__Quotes2__r[0].id;        	
        	set<string> assetSet= new set<string>();
        	for(SBQQ__QuoteLine__c quoteLineItem :[select id, name, SBQQ__RenewedAsset__c, Service_Asset__c, SBQQ__UpgradedAsset__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:primaryQuoteId AND (SBQQ__RenewedAsset__c !=null OR Service_Asset__c !=null OR SBQQ__UpgradedAsset__c!=null)]){
        		
				//When QuoteLine is selected on price Intelligence then the Quoteline related assets only considered for Treemap
				if(string.isNotBlank(intelligence.QuoteLineId__c) && quoteLineItem.Id != intelligence.QuoteLineId__c){
                  continue;
				}
				if(quoteLineItem.SBQQ__RenewedAsset__c !=null){ // checking qupte line items is associated to Renewed Asset 
        			assetSet.add(quoteLineItem.SBQQ__RenewedAsset__c);
        		}else if(quoteLineItem.Service_Asset__c !=null){ // checking qupte line items is associated to Service Asset
        			assetSet.add(quoteLineItem.Service_Asset__c);
        		}else if(quoteLineItem.SBQQ__UpgradedAsset__c !=null){ // // checking qupte line items is associated to upgraded Asset
        			assetSet.add(quoteLineItem.SBQQ__UpgradedAsset__c); 
        		}        		
        	}

        	set<string> recordTypeSet= new set<string>();
        	string plantAssetId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        	string trainAssetId= Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Train').getRecordTypeId();
        	recordTypeSet.add(plantAssetId);
        	recordTypeSet.add(trainAssetId);
        	// get asset of tyoe Planr and Train
        	map<id,Asset> assetMap= new map<id,Asset>([select id, name, recordTypeId, parentId from Asset where id IN :assetSet AND recordTypeId IN :recordTypeSet]);
        	
        	set<string> expRelationSet= new set<string>();
        	for(ExperienceRelation__c expRelationObj : [select id, name, AssetId__c, AccountRelationTyp__c from ExperienceRelation__c where AssetId__c IN :assetMap.keySet() AND IntelligenceId__c=:intelligenceId]){
        		expRelationSet.add(expRelationObj.AssetId__c); // create exp relation set of asset id
        	}
			
			// create and populate the wrapper data 
    		getWrapperData(assetMap,expRelationSet,plantAssetId,trainAssetId,wrapperClassList);
    			
        }
        
    	return wrapperClassList; // return wrapper list    		
    }
    
    /*
    @Method Name: createAssetExperienceRelation
    @Method Desc: This method will create experience relation record for the particular record id. It will return the success/Failure message to 
    @Input parameter type: (string accId, string intelligenceId)
    @Return type: string
    */
    @AuraEnabled
    public static string createAssetExperienceRelation(string assetIdTmp, string intelligenceId){
  
        list<ExperienceRelation__c> expRelationList= new list<ExperienceRelation__c>();
        try{  
        	
        	// create new experience relation record
            ExperienceRelation__c expRelation= new ExperienceRelation__c();
            expRelation.IntelligenceId__c= intelligenceId;
            string assetId;
            if(assetIdTmp.contains('_')){ // if '_' exists in asset id then we need to break it and take the asset id
            	string [] assetIdList= assetIdTmp.split('_');
            	assetId= assetIdList[0];            	 
            }else{
            	assetId= assetIdTmp;
            }    		
			expRelation.AssetId__c= assetId; // populate asset id
        	
            expRelationList.add(expRelation);
              
            insert expRelationList; // record inserted
        }catch(exception ex){
            return ex.getMessage();
        }
        
        return 'Record has been created.';
    	
    }
    
    /*
    @Method Name: deleteAssetExperienceRelation
    @Method Desc: This method will delete experience relation record for the particular record id. 
    @Input parameter type: (string assetIdTmp, string intelligenceId)
    @Return type: string
    */
    @AuraEnabled
    public static string deleteAssetExperienceRelation(string assetIdTmp, string intelligenceId){
    	
    	string dmlMessage;
    	try{
	    	string assetId;
	        if(assetIdTmp.contains('_')){
	        	string [] assetIdList= assetIdTmp.split('_'); // break asset id and take asset id to delete the records
	        	assetId= assetIdList[0];            	 
	        }else{
	        	assetId= assetIdTmp;
	        }    		
			// query on exp relation records to get the particular record of asset id
	    	list<ExperienceRelation__c> expRelationDelete= [select id, name, AccountId__c, AccountRelationTyp__c, Country__c, IntelligenceId__c from ExperienceRelation__c where AssetId__c=:assetId AND IntelligenceId__c=:intelligenceId limit 1];
  	
        	if(expRelationDelete.size() > 0){
        		delete expRelationDelete; // delete exp relation record       
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
    @Method Name: getWrapperData
    @Method Desc: This method create and populate wrapper data  
    @Input parameter type: (map<id,Asset> assetMapTmp, set<string> expRelationSetTmp, string plantAssetIdTmp, string trainAssetIdTmp, list<TreeMapController.TreeMapGenericWrapper> wrapperClassListTmp)
    @Return type: void
    */
    private static void getWrapperData(map<id,Asset> assetMapTmp, set<string> expRelationSetTmp, string plantAssetIdTmp, string trainAssetIdTmp, list<TreeMapController.TreeMapGenericWrapper> wrapperClassListTmp){
    	
    	for(asset assetObj :assetMapTmp.values()){
					 
			TreeMapController.TreeMapGenericWrapper assetDetails= new TreeMapController.TreeMapGenericWrapper();
			assetDetails.label= assetObj.name;
			
			if(assetObj.recordTypeId == plantAssetIdTmp){ // if asset is of 'Plant' type 
				assetDetails.id= assetObj.id + '_Plant'; // then add '_Plant' in the asset id string						
				assetDetails.parentId= '';
				assetDetails.level=2;												
			}else if(assetObj.recordTypeId == trainAssetIdTmp){ // if asset is of 'Train' type
			 	assetDetails.id= assetObj.id;			
 			 	if(assetObj.parentId !=null){
 			 		assetDetails.parentId= assetObj.parentId;
 			 	}else{
 			 		assetDetails.parentId= '';
 			 	}						
				assetDetails.level=3;						
			}  
			  
			if(expRelationSetTmp.size() > 0){
				assetDetails.isSelected= expRelationSetTmp.contains(assetObj.id); // if exp relation is already exists with this asset id then set value to True otherwise False
			}else{
				assetDetails.isSelected=false;
			}
			 
			wrapperClassListTmp.add(assetDetails); // populate wrapper
		}    	
    }	   
}