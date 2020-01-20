public with sharing class ContentFilteringAPIRequest extends APIRequest {
    // Status values
    public static final String PUBLISHED = 'published';
    public static final String UNPUBLISHED = 'unpublished';
    public static final String EXPIRED = 'expired';
    public static final String PENDING_APPROVAL = 'pendingApproval';
    public static final String LOCKED = 'locked';

    // List of Actions
    public static final String GET_CONTENT = 'getContent';

    // parameters allowed
    public static final String FILTERS = 'filters';
    public static final String LIMIT_BY = 'limit';
    public static final String OFFSET = 'offset';

    // List Parameters allowed
    public static final String ORDER_BY = 'order';

    public ContentFilteringAPIRequest() {
        super();
    }
}