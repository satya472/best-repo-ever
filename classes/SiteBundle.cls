public with sharing virtual class SiteBundle {
    public Id siteId;
    public String siteName;
    public String siteLabel;
    public String siteUrl;
    public String siteSecureUrl;
    public String sitePrefix;
    public String siteDomain;
    public String siteSecureDomain;
    public String defaultLanguage;
    public Boolean targetingEnabled;
    public Boolean multilingualEnabled;
    public Boolean approvalProcessEnabled;
    public Boolean complianceEnabled;
    public List<LanguageBundle> languages;
    public List<TargetBundle> targets;
    public List<ProfileBundle> profiles;
    public String salesforceBaseUrl;
    public String orgDomainUrl;
}