public with sharing class ProfileAPIRequest extends APIRequest {

    //listParameters allowed keys
    public static String PROFILE_IDS = 'profileIds';
    public static String USER_IDS = 'userIds';

    // List of Actions
    public static String GET_PROFILES = 'getProfiles';
    public static String ADD_USERS = 'addUsers';
    public static String REMOVE_USERS = 'removeUsers';

    //requestFlags allowed keys
    public static String ALL_PROFILES = 'allProfiles';
    public static String LIST_USERS = 'listUsers';

    public ProfileAPIRequest(){
        super();
    }
}