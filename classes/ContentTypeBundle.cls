public virtual with sharing class ContentTypeBundle {

    public Id contentTypeId;
    public String name;
    public String label;
    public String type;
    public Id defaultLayoutId;

    public Boolean allowPastPublishing;
    public Boolean areAccessLevelRulesInherited;
    public Boolean isSharingControlledByTheParentType;
    public Boolean isExcludedFromSearchIndex;
    public Boolean contentTypeHasChildren;
    public Boolean isChildType;
    public Boolean isDeprecated;
    public Boolean isListable;
    public Boolean isManageable;
    public Boolean isLocked;

    // public Map<String, List<ContentTypeBundle>> childTypes;
    public Map<String, ContentTypeLayout> contentLayouts;

    // the content type/template relationship
    public class ContentTypeLayout {
        public ContentLayoutBundle contentLayout;
        public Boolean isAutomaticallyCreated;
        public Boolean isDefaultLayoutForType;
        public Boolean isLocked;
        public String previewPageId;
    }

}