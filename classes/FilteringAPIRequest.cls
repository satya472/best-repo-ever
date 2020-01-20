public with sharing class FilteringAPIRequest extends APIRequest {

    //Actions
//    public static final String GET_CONTENT_BY_NAME = 'getContentByName';
//    public static final String GET_RECENT_PUBLISHED_CONTENT = 'getRecentlyPublishedContent';
//    public static final String GET_FOLDER_ITEMS = 'getFolderItems';
//    public static String SEARCH_CONTENT = 'searchContent';
    //parameters
    public static final String LIMIT_COUNT = 'limit';
    public static final String OFFSET = 'offset';
    public static final String TERM = 'term';
    public static String FILTERS = 'filters';
    //listParams
//    public static final String CONTENT_NAMES = 'contentNames';
    public static final String CONTENT_TYPES_AND_LAYOUTS = 'contentTypesAndLayouts';
    public static final String FILTER_GROUPS = 'filterGroups';
    public static final String ORDER_BY = 'order';
    public static String IDS = 'ids';
    public static String PATHS = 'paths';
    public static String KINDS = 'kinds';
    //flags
    public static final String TAXONOMY = ContentAPIRequest.TAXONOMY;
    public static final String CONTENT_LAYOUTS = 'contentLayouts';
    public static final String CONTENT_TYPE = 'contentType';
    public static final String TARGETED = RenderingAPIRequest.TARGETED;
    public static final String ALL_CHILDREN = 'allChildren';


    // FilterType is just a set of well defined Strings that represent our filters
    public enum FilterType {
        Taxonomy, OriginalPublishedDate, PublishedDate
    }

    //Order of list of origins in contentOrdering
    //noinspection ApexUnusedDeclaration
    public enum OrderType {
        Relevance, OriginalPublishedDate, PublishedDate,
        StartDate, ExpiryDate
    }

    public FilteringAPIRequest() {
        super();
    }

}