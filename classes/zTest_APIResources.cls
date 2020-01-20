/**
 * This test class is for use with the OrchestraCMS API Resources classes.
 * This test class does not assert for any correctness, it only exercises the properties in the classes.
 *
 * Created by mwannamaker on 2017-09-06.
 */
@IsTest
private class zTest_APIResources {
    // Tests APIRequest.cls
    static testMethod void APIRequest() {

        // Create an API request.
        APIRequest apiRequest = new APIRequest();

        // Run getters against the parameters we need, setters will be covered as they're on the same line.
        Id objectId = apiRequest.objectId;
        String transactionId = apiRequest.transactionId;

        // Check the APIRequests single method, we can reuse the objectId variable as it's the right type.
        objectId = apiRequest.getID();

        // Set the requestFlags to null to trigger the conditional check when we run the getter next.
        apiRequest.requestFlags = null;
        Map<String, Boolean> requestFlags = apiRequest.requestFlags;

        // Set the parameters to null to trigger the conditional check when we run the getter next.
        apiRequest.parameters = null;
        Map<String, String> parameters = apiRequest.parameters;

        // Set the listParameters to null to trigger the conditional check when we run the getter next.
        apiRequest.listParameters = null;
        Map<String, List<String>> listParameters = apiRequest.listParameters;

        // Set the mapParameters to null to trigger the conditional check when we run getter next.
        apiRequest.mapParameters = null;
        Map<String, Map<String, String>> mapParameters = apiRequest.mapParameters;

    }

    // Tests AttributeBundle.cls
    static testMethod void AttributeBundle() {

        // Create a JSONMessage.APIResponse.
        AttributeBundle.ContentAttribute contentAttribute = new AttributeBundle.ContentAttribute();

        // The AttributeBundle settings and getters are on the same line.
        // This will help save writing test coverage for code coverage.

        // We need to get the AttributeBundle specific fields.
        String languageCode = contentAttribute.languageCode;
        Boolean simple = contentAttribute.simple;

        // Now let's get the AttributeBundle.ContentAttribute specific fields.
        String name = contentAttribute.name;
        String value = contentAttribute.value;
        String valueType = contentAttribute.valueType;

        // Create an AttributeBundle.ContentMetaAttribute.
        AttributeBundle.ContentMetaAttribute contentMetaAttribute = new AttributeBundle.ContentMetaAttribute();

        // Let's get the AttributeBundle.ContentMetaAttribute specific fields.
        String metaContentName = contentMetaAttribute.metaContentName;
        String metaContentTitle = contentMetaAttribute.metaContentTitle;
        String metaContentDescription = contentMetaAttribute.metaContentDescription;

    }

    // Tests ContentFilteringAPIRequest.cls
    static testMethod void ContentFilteringAPIRequest() {

        // We only need the ContentFilteringAPIRequest constructor for complete code coverage.
        ContentFilteringAPIRequest contentFilteringAPI = new ContentFilteringAPIRequest();

    }

    // Tests ContentLayoutBundle.cls
    static testMethod void ContentLayoutBundle() {

        // Create a ContentLayoutBundle.
        ContentLayoutBundle contentLayoutBundle = new ContentLayoutBundle();

        // We need to use a getter or setter for the layoutAttributes field.
        // This will complete necessary code coverage for this class.
        Map<String, List<AttributeBundle.ContentAttribute>> layoutAttributes = contentLayoutBundle.layoutAttributes;

    }

    // Tests ContentAPIRequest.cls
    static testMethod void ContentAPIRequest() {

        // Create a ContentAPIRequest.
        ContentAPIRequest contentAPI = new ContentAPIRequest();

        // We need to use a getter or setter for the bundle field.
        // This will complete necessary code coverage for this class.
        ContentBundle bundle = contentAPI.bundle;

    }

    // Tests Filter.cls
    static testMethod void Filter() {

        Filter f = new Filter();

    }

    // Tests FilterItem.cls
    static testMethod void FilterItem() {

        FilterItem f = new FilterItem();

    }

    // Tests FilteringAPIRequest.cls
    static testMethod void FilteringAPIRequest() {

        // We only need the FilteringAPIRequest constructor for complete code coverage.
        FilteringAPIRequest filteringAPI = new FilteringAPIRequest();

    }

    // Tests FilteringBundle.cls
    static testMethod void FilteringBundle() {

        FilteringBundle fBundle = new FilteringBundle();

    }

    // Tests FolderAPIRequest.cls
    static testMethod void FolderAPIRequest() {

        // We only need the FolderAPIRequest constructor for complete code coverage.
        FolderAPIRequest folderAPI = new FolderAPIRequest();

    }

    // Tests FolderItemBundle.cls
    static testMethod void FolderItemBundle() {

        FolderItemBundle fBundle = new FolderItemBundle();

    }

    // Tests LanguageAPIRequest.cls
    static testMethod void LanguageAPIRequest() {

        // We only need the LanguageAPIRequest constructor for complete code coverage.
        LanguageAPIRequest languageAPI = new LanguageAPIRequest();

    }

    // Tests LanguageBundle.cls
    static testMethod void LanguageBundle() {

        LanguageBundle lBundle = new LanguageBundle();

    }

    // Tests JSONMessage.cls
    static testMethod void JSONMessage() {

        // We only need the JSONMessage.MessageError constructor for code coverage of this subclass.
        JSONMessage.MessageError messageError = new JSONMessage.MessageError();

        // Create a JSONMessage.APIResponse.
        JSONMessage.APIResponse apiResponse = new JSONMessage.APIResponse();

        // We need to set a mock response object to utilize the getResponseAs method.
        // We'll use the UserBundle class to make a mock one for remaining code coverage due to its simplicity.
        apiResponse.responseObject = '{"userId":"'+UserInfo.getUserId()+'"}';
        Object apiResponseAs = apiResponse.getResponseAs(UserBundle.class);

    }

    // Tests ProfileAPIRequest.cls
    static testMethod void ProfileAPIRequest() {

        // We only need the ProfileAPIRequest constructor for complete code coverage.
        ProfileAPIRequest profileAPI = new ProfileAPIRequest();

    }

    // Tests ProfileBundle.cls
    static testMethod void ProfileBundle() {

        // Create a ProfileBundle.
        ProfileBundle profileBundle = new ProfileBundle();

        // The ProfileBundle has protected setters so we need to use gets, but they're on the same line anyway.
        // This will help save writing test coverage for code coverage.

        // We need to get the ProfileBundle fields.
        String profileId = profileBundle.profileId;
        String profileName = profileBundle.profileName;
        String licenseType = profileBundle.licenseType;

        Map<String, Boolean> permissions = profileBundle.permissions;
        Map<Id, Map<String, Boolean>> permissions_content_type = profileBundle.permissions_content_type;
        Map<Id, Map<String, Boolean>> permissions_library = profileBundle.permissions_library;

        List<UserBundle> users = profileBundle.users;
        Boolean activated = profileBundle.activated;
        Boolean licenseExpired = profileBundle.licenseExpired;
    }

    // Tests RenderResultBundle.cls
    static testMethod void RenderResultBundle() {

        // We only need to check RenderResultBundle contentRemaining for complete code coverage.
        Boolean renderResultBundle = new RenderResultBundle().contentRemaining;

    }

    // Tests SiteAPIRequest.cls
    static testMethod void SiteAPIRequest() {

        // We only need the SiteAPIRequest constructor for complete code coverage.
        SiteAPIRequest siteAPI = new SiteAPIRequest();

    }

    // Tests SiteBundle.cls
    static testMethod void SiteBundle() {

        SiteBundle sBundle = new SiteBundle();

    }

    // Tests SocialAPIRequest.cls
    static testMethod void SocialAPIRequest() {

        // We only need the SocialAPIRequest constructor for complete code coverage.
        SocialAPIRequest socialAPI = new SocialAPIRequest();

    }

    // Tests SocialActivity.cls
    static testMethod void SocialActivity() {

        // We only need the SocialActivity constructor for complete code coverage.
        SocialActivity sActivity = new SocialActivity();

    }

    // Tests SocialBundle.cls
    static testMethod void SocialBundle() {

        SocialBundle sBundle = new SocialBundle();

    }

    // Tests TargetingAPIRequest.cls
    static testMethod void TargetingAPIRequest() {

        // We only need the TargetingAPIRequest constructor for complete code coverage.
        TargetingAPIRequest targetingAPI = new TargetingAPIRequest();

    }

    // Tests TaxonomyAPIRequest.cls
    static testMethod void TaxonomyAPIRequest() {

        // We only need the TaxonomyAPIRequest constructor for complete code coverage.
        TaxonomyAPIRequest taxonomyAPI = new TaxonomyAPIRequest();

    }
    
    // Tests TranslationGroupBundle
    static testMethod void TranslationGroupBundle() {

        TranslationGroupBundle translationGroup = new TranslationGroupBundle();

    }

}