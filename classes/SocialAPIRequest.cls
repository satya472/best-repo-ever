public with sharing class SocialAPIRequest extends APIRequest{

    // List of Actions
    public static String LIKEIT= 'like';
    public static String UNLIKEIT = 'unlike';
    public static String VIEWIT = 'view';
    public static String GET_SOCIALDATA = 'getSocialData';
    public static String GET_MY_SOCIALDATA = 'getMySocialData';
    public static String GET_VIEWED_BY_ME  = 'getViewedByMe';
    public static String GET_LIKED_BY_ME   = 'getLikedByMe';
    public static String GET_MOST_LIKED   = 'getMostLiked';
    public static String GET_MOST_VIEWED   = 'getMostViewed';
    // request listParameters
    public static String ORIGIN_IDS = 'originIds';

    // request parameters
    public static String TYPE = 'type';
    public static String LIMIT_COUNT ='limit';

    public static Integer MAX_LIMIT = 500;

    public enum ITEM_TYPE {
        //Only Content is supported as a valid type for API version 5
        Media,
        Content,
        Page
    }

    public SocialAPIRequest() {
        super();
    }

}