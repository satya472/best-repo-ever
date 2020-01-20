public without sharing class CEP_GenericFileUploader {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getListOfDocuments(String recordId){
        List<ContentDocumentLink> cdlList=[SELECT Id,ContentDocument.Title,ContentDocument.ContentModifiedDate,ContentDocument.Owner.Name,
                                           ContentDocument.LatestPublishedVersionId,ContentDocumentId,LinkedEntityId 
                                           FROM ContentDocumentLink WHERE LinkedEntityId =:recordId AND Visibility='AllUsers' AND ShareType='V'];
        System.debug('cdlList size---->'+cdlList.size());
        System.debug('cdlList---->'+cdlList);
     return cdlList;
    }
}