public with sharing class LanguageAPIRequest extends APIRequest {

    // List of Actions
    public static final String ADD_LANGUAGE = 'addLanguage';
    public static final String EDIT_LANGUAGE = 'editLanguage';
    public static final String ADD_DEFAULT_LANGUAGE = 'addDefaultLanguage';
    public static final String SET_DEFAULT_LANGUAGE = 'setDefaultLanguage';
    public static final String DISABLE_LANGAUGE = 'disableLanguage';
    public static final String ENABLE_LANGUAGE = 'enableLanguage';
    public static final String GET_AVAILABLE_LANGUAGES = 'getAvailableLanguages';
    public static final String SET_TRANSLATION_GROUP = 'setTranslationGroup';
    public static final String ADD_USERS_TO_TRANSLATION_GROUP = 'addUsersToTranslationGroup';
    public static final String REMOVE_USERS_FROM_TRANSLATION_GROUP = 'removeUsersFromTranslationGroup';
    public static final String GET_TRANSLATION_GROUPS = 'getTranslationGroups';
    public static final String SET_SITE_LANGUAGE_FLAGS = 'setSiteLanguageFlags';
    public static final String GET_SALESFORCE_LANGUAGES = 'getSalesforceLanguages';
    public static final String GET_UNUSED_SALESFORCE_LANGUAGES = 'getUnusedSalesforceLanguages';

    // parameters allowed
    public static final String ID = 'id';
    public static final String NAME = 'name';
    public static final String LABEL = 'label';
    public static final String CODE = 'code';
//    public static final String DESCRIPTION = 'description';
    public static final String PRIORITY = 'priority';
    public static final String groupId = 'groupId';

    // listparameters allowed
    public static final String IDS = 'ids';
//    public static final String USER_IDS = 'userIds';
//    public static final String CODES = 'codes';

    //requestFlags allowed keys
//    public static final String ADD_USER_TO_GROUP = 'addUserToGroup';
//    public static final String ALLOW_FALLBACK = 'allowfb';
//    public static final String USER_USER_LANGUAGE = 'useUserLanguage';
//    public static final String ENABLE_COOKIE = 'enableCookie';

    public LanguageAPIRequest(){
        super();
    }
}