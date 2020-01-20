/***
     *  Generic class used to represent a request to the ContentAPI.
     *
***/

public virtual with sharing class ContentAPIRequest extends APIRequest {

    public static final String VERSIONS = 'versions';
    public static final String ATTRIBUTES = 'attributes';
    public static final String TAXONOMY = 'taxonomy';
    public static final String TARGETS = 'targets';
    public static final String LAYOUTS = 'layouts';

    // common request parameters accross API
    public static final String NAME = 'name';
    public static final String LAYOUT_NAMES = 'contentLayoutNames';
    public static final String PUBLISHED_END_DATE = 'publishedEndDate';
    public static final String PUBLISHED_START_DATE = 'publishedStartDate';
    public static final String CONTENT_TYPES = 'contentTypes';

    //Send for Approval request parameters
    public static final String COMMENT = 'comment';
    public static final String PRIORITY = 'priority';

    //getContent specific request parameters
    public static final String VERSION_NUMBER = 'versionNumber';
    public static final String VERSION_ID = 'versionId';

    //create content specific request parameters
    public static final String CONTENT_TYPE_NAME = 'contentTypeName';
    public static final String DESCRIPTION = 'description';
    public static final String LANGUAGES = 'languages';

    // List of Actions
    public static final String CREATE_CONTENT = 'createContent';
    public static final String GET_CONTENT = 'getContent';
    public static final String SAVE_CONTENT = 'saveContent';
    public static final String ADD_LAYOUT_TO_CONTENT = 'addLayoutToContent';
    public static final String REMOVE_LAYOUT_FROM_CONTENT = 'removeLayoutFromContent';
    public static final String NEW_CONTENT_VERSION = 'newContentVersion';
    public static final String NEW_CONTENT_REVISION = 'newContentRevision';
    public static final String PUBLISH_CONTENT = 'publishContent';
    public static final String EXPIRE_CONTENT = 'expireContent';
    public static final String REQUEST_LOCK = 'requestLock';
    public static final String RELEASE_LOCK = 'releaseLock';
    public static final String DELETE_CONTENT = 'deleteContent';
    public static final String SUBMIT_FOR_APPROVAL = 'submitForApproval';
    public static final String GET_CONTENT_LAYOUTS_TYPE_BY_TYPE_ID = 'getContentLayoutsByTypeID';
    public static final String GET_CONTENT_LAYOUTS_BY_TYPE_NAME = 'getContentLayoutsByTypeName';
    public static final String GET_CONTENT_TYPES_BY_NAME = 'getContentTypesByName';
    public static final String GET_CONTENT_TYPES = 'getContentTypes';
    public static final String ADD_TAG_TO_CONTENT = 'addTagToContent';
    public static final String REMOVE_TAG_FROM_CONTENT = 'removeTagFromContent';
    public static final String GET_TAGS_ON_CONTENT = 'getTagsOnContent';
    public static final String GET_TARGETS_ON_CONTENT = 'getTargetsOnContent';
    public static final String SET_TARGETS_FOR_CONTENT = 'setTargetsForContent';

    public ContentBundle bundle { get; set; }

    public ContentAPIRequest() {
        super();
    }
}