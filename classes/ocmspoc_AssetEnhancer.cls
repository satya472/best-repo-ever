global virtual with sharing class ocmspoc_AssetEnhancer implements cms.IContentBundlerEnhancer {
	public String enhanceContent(String jsonRequest, String jsonContentBundleList) {
        APIRequest request = (APIRequest) JSON.deserialize(jsonRequest, APIRequest.class);
        ContentBundleList bundleList = (ContentBundleList) JSON.deserialize(jsonContentBundleList, ContentBundleList.class);
        
        bundleList.contentProperties = getAssetInfo(bundleList.contentBundles);
        
        return JSON.serialize(bundleList);
    }
    
    private Map<String, String> getAssetInfo(List<ContentBundle> contentBundles) {
        Map<Id, Id> assetMap = new Map<Id, Id>();
        Map<String, String> contentProperties = new Map<String, String>();
        for (ContentBundle bundle : contentBundles) {
            List<AttributeBundle.ContentAttribute> attributes = bundle.contentAttributes.get('en_US');
            for (AttributeBundle.ContentAttribute attr : attributes) {
                if (attr.name == 'assetId') {
                    assetMap.put(attr.value, bundle.originId);
                    break;
                }
            }
        }

        if (assetMap.keySet().size() > 0) {
            List<Asset> assets = [SELECT Name FROM Asset WHERE Id IN :assetMap.keySet()];

            for (Asset a : assets) {
                contentProperties.put(assetMap.get(a.Id), JSON.serialize(a));
            }
        }

        return contentProperties;
    }
}