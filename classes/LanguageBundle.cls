public virtual with sharing class LanguageBundle {
    public Id languageId;
    public String name;
    public String label;
    public String code;
    public Boolean isActive;
    public Boolean allowsFallback;
    public Decimal priority;
    public String description;

    public Id siteId;
}