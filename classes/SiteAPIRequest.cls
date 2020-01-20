/**
 * Created by danuta on 2017-02-22.
 */

public with sharing class SiteAPIRequest extends APIRequest {
    //parameters
    public static String SITE_NAME = 'siteName';
    public static String TARGET_REQUEST = 'targetRequest';
    //requestFlags
    public static String LANGUAGES = 'languages';
    public static String TARGETS = 'targets';

    // List of Actions
    public static String GET_SITE_INFO = 'getSiteInfo';

    public SiteAPIRequest(){
        super();
    }
}