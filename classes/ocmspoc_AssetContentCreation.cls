public with sharing class ocmspoc_AssetContentCreation {
    private final Asset asset;
    public ocmspoc_AssetContentCreation(ApexPages.StandardController stdController) {
        Asset a = (Asset)stdController.getRecord();
        this.asset = [SELECT Id, Name, Content__c FROM Asset WHERE Id = :a.Id];
    }
    
    public PageReference createContent() {
        if (this.asset.Content__c == null) {
            ContentBundle bundle = new ContentBundle();
            bundle.contentType = new ContentTypeBundle();
            bundle.contentType.name = 'POCAsset';
            bundle.languageStatuses = new Map<String, ContentBundle.ContentLanguageStatus>();
            bundle.languageStatuses.put('en_US', createLanguageStatus('en_US', true, true));
            bundle.languageStatuses.put('de', createLanguageStatus('de', true, true));
            bundle.languageStatuses.put('es', createLanguageStatus('es', true, true));
            
            List<AttributeBundle.ContentAttribute> attributes = new List<AttributeBundle.ContentAttribute>();
            attributes.add(createContentAttribute('assetId', 'Id', this.asset.Id));
            bundle.contentAttributes = new Map<String, List<AttributeBundle.ContentAttribute>> {
                'en_US' => attributes,
                'de' => attributes,
                'es' => attributes
            };
                
            AttributeBundle.ContentMetaAttribute meta = new AttributeBundle.ContentMetaAttribute();
            meta.metaContentName = 'Asset - ' + this.asset.Name;
            bundle.contentMetaAttributes = new Map<String, AttributeBundle.ContentMetaAttribute> { 'en_US' => meta };
                
            ContentAPIRequest request = new ContentAPIRequest();
            request.bundle = bundle;
            
            Map<String, String> apiParams = new Map<String, String> {
                'service' => 'ContentAPI',
                'action' => ContentAPIRequest.CREATE_CONTENT,
                'contentRequest' => JSON.serialize(request),
                'sname' => 'Siemens_JEP',
                'application' => 'runtime',
                'apiVersion' => '5.0'
            };
                
            String response = cms.ServiceEndpoint.doActionApex(apiParams);
            JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) JSON.deserialize(response, JSONMessage.APIResponse.class);
            if (!apiResponse.isSuccess) {
                System.debug(apiResponse);
            }
            ContentBundle resultBundle = (ContentBundle) JSON.deserialize(apiResponse.responseObject, ContentBundle.class);
            
            this.asset.Content__c = resultBundle.originId;
            update this.asset;
        }
        
        PageReference redirect = new PageReference('/apex/cms__Manage?sname=Siemens_JEP&opencontent=' + this.asset.Content__c);
        redirect.setRedirect(true);
        return redirect;
    }
    
    private static ContentBundle.ContentLanguageStatus createLanguageStatus(String languageCode, Boolean isAddedToContent, Boolean isTranslated) {
        ContentBundle.ContentLanguageStatus status = new ContentBundle.ContentLanguageStatus();
        status.languageCode = languageCode;
        status.isAddedToContent = isAddedToContent;
        status.isTranslated = isTranslated;
    
        return status;
    }
    
    private static AttributeBundle.ContentAttribute createContentAttribute(String name, String valueType, String value) {
        AttributeBundle.ContentAttribute attr = new AttributeBundle.ContentAttribute();
        attr.name = name;
        attr.valueType = valueType;
        attr.value = value;
    
        return attr;
    }
}