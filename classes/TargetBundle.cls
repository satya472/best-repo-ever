public virtual with sharing class TargetBundle {
    public Id originId;
    public String targetName;
    public Map<String, Set<String>> filters;
    public String description;
    public String targetType; // Predefined or Ad Hoc
    public String targetKey;
    public Datetime targetExpireDate;
    public Datetime lastModifiedDate;
    public String lastModifiedByName;
}