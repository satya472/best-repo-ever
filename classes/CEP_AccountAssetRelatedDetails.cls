public class CEP_AccountAssetRelatedDetails {
    @AuraEnabled public static Account getAccountDetailsMethod(String recordId){
        Account accRecord=[SELECT Id,Name FROM Account WHERE Id=:recordId];
        return accRecord;
    }
    
    @AuraEnabled public static List<Asset> getParentAssetDetailsCEP(String parentAccountId){
        List<Asset> assetList=new List<Asset>();
        assetList=[SELECT Id,Name,AccountId,RootAssetId,ParentId,RecordType.Name FROM Asset 
                               WHERE AccountId =: parentAccountId AND ParentId=NULL ORDER BY Name ASC];
        return assetList;
    }
    
    @AuraEnabled public static List<Asset> getChildAssetDetails(List<String> parentAssetIds, String selectedContactId){
        List<String> parentAssetIdsList=parentAssetIds;
        List<Asset> childAssetList=new List<Asset>();
        if(selectedContactId=='' || selectedContactId==NULL || String.isEmpty(selectedContactId)){
            childAssetList=[SELECT Id,Name,AccountId,RootAssetId,ParentId,RecordType.Name FROM Asset 
                            WHERE ParentId in: parentAssetIdsList ORDER BY Name ASC];
            System.debug('in if call ---->'+childAssetList.size());
        }else{
            List<Asset> tempAssetList=new List<Asset>();
            List<ContactAsset__c> tempAssetConList=new List<ContactAsset__c>();
            Set<Id> childAssetIdsWithSelectedContact = new Set<Id>();
            tempAssetList=[SELECT Id,Name,(SELECT AssetId__c FROM ContactAssets__r WHERE ContactId__c=:selectedContactId) FROM Asset 
                            WHERE ParentId in: parentAssetIdsList ORDER BY Name ASC];
            if(NULL != tempAssetList && tempAssetList.size()>0){
                for(Asset temp:tempAssetList){
                    if(NULL != temp.ContactAssets__r && temp.ContactAssets__r.size()>0){
                        tempAssetConList.add(temp.ContactAssets__r);
                    }
                }
                if(NULL != tempAssetConList && tempAssetConList.size()>0){
                    for(ContactAsset__c conAsset:tempAssetConList){
                        childAssetIdsWithSelectedContact.add(conAsset.AssetId__c);
                    }
                }
                if(NULL != childAssetIdsWithSelectedContact && childAssetIdsWithSelectedContact.size()>0){
                    childAssetList=[SELECT Id,Name FROM Asset WHERE Id IN : childAssetIdsWithSelectedContact];
                }
            }
        }
        return childAssetList;
    }
    
    @AuraEnabled public static List<ContactAsset__c> getInsertedContactAssets(List<String> assetIds, String contactId){
        List<ContactAsset__c> contactAssetListToBeInserted=new List<ContactAsset__c>();
        if(NULL!=assetIds && assetIds.size()>0 && contactId!='' && contactId!=NULL){
            ContactAsset__c conAsset;
            for(String assetId:assetIds){
                conAsset=new ContactAsset__c();
                conAsset.AssetId__c=assetId;
                conAsset.ContactId__c=contactId;
                contactAssetListToBeInserted.add(conAsset);
            }
            insert contactAssetListToBeInserted;
        }
        return contactAssetListToBeInserted;
    }
}