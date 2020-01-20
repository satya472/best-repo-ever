public with sharing class RenderingAPIRequest extends APIRequest {

    // parameter keys
    public static final String ORDER_BY = 'order';
    public static final String LIMIT_BY = 'limit';
    public static final String OFFSET = 'offset';
    public static final String RENDER_TYPE = 'renderType';
    public static final String STATUS = 'status';

    // statusType values
    public static final String PUBLISHED = 'published';
    public static final String UNPUBLISHED = 'unpublished';
    public static final String ALL = 'all';

    // renderType values
    public static final String TAXONOMY = 'taxonomy';
    public static final String CONTENT_TYPE = 'contentType';
    public static final String ORIGIN_ID = 'originId';

    // request flag keys
    public static final String TARGETED = 'targeted';
    public static final String NO_RENDERING = 'noRendering';
    public static final String WITH_CONTENT_BUNDLE = 'withContentBundle';
    public static final String WITH_SOCIAL_BUNDLE = 'withSocialBundle';
    public static final String DEFAULT_TEMPLATE_ONLY = 'defaultTemplateOnly';

    // list parameter keys
    public static final String CONTENT_LAYOUTS = 'contentLayouts';
    public static final String ACCESS_LEVELS = 'accessLevels';
//    public static final String PREDEFINED_TARGETS = 'predefinedTargets';
    public static final String CONTENT_TYPES = 'contentTypes';
    public static final String CONTENT_TYPE_IDS = 'contentTypeIds';
    public static final String CONTENT_NAMES = 'contentNames';
    public static final String TAG_PATHS = 'tagPaths';
    public static final String ORIGIN_IDS = 'originIds';
    public static final String PAGE_NAME = 'pageName';
    public static final String PAGE_URL = 'pageURL';

    public Map<String, List<String>> adHocTargets;
    public List<List<String>> predefinedTargets;
    public List<List<String>> layoutsForTaxonomy;
    public Map<String, String> pageInstanceProperties;
    public Map<String, String> contentProperties;
    public Map<String, String> contentLayoutProperties;
}