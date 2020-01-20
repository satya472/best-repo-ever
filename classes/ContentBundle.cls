public virtual with sharing class ContentBundle {

    // fields on the content
    public Id contentId;
    public Id originId;
    public String siteName;
    public String siteId;
    public Boolean excludeFromSearch;
    public Datetime publishedStartDate;
    public Datetime originalPublishedStartDate;
    public Datetime publishedEndDate;
    public String lockedBy;
    public Datetime lockedDate;
    public String createdBy;
    public String lastModifiedBy;
    public Datetime createdDate;
    public Datetime lastModifiedDate;

    public List<Version> versionsAndRevisions;
    public Decimal version;
    public Decimal revision;

    public List<ContentBundle> children;

    // status variables
    public Boolean readonly;
    public Boolean published;
    public Boolean sentForApproval;
    public Boolean expired;
    public Boolean locked;
    public Boolean lockedByMe;

    // permission variables
    public Boolean allowEdit;
    public Boolean allowPublish;
    public Boolean allowSendForApproval;
    public Boolean allowClone;
    public Boolean allowExpire;
    public Boolean allowDelete;
    public Boolean allowVersioning;
    public Boolean allowRevisioning;
    public Boolean allowTarget;
    public Map<String, ContentLanguageStatus> languageStatuses;
    public ContentTypeBundle contentType;
    public Map<String, List<AttributeBundle.ContentAttribute>> contentAttributes;
    public Map<String, AttributeBundle.ContentMetaAttribute> contentMetaAttributes;
    public Map<String, ContentLayoutBundle> contentLayouts;
    public List<TaxonomyBundle> taxonomyTagPaths;
    public List<TargetBundle>contentTargets;

    public class Version {
        public Decimal version;
        public Decimal revision;
        public Datetime publishedStartDate;
        public Datetime publishedEndDate;
        public Boolean published;
        public Boolean expired;
        public Boolean sentForApproval;
    }

    public class ContentLanguageStatus {
        public Boolean isAddedToContent;
        public Boolean canTranslate;
        public Boolean isTranslated;
        public Boolean isActive;
        public String languageCode;
    }

}