public with sharing virtual class ProfileBundle {
    public String profileId { get; set; }
    public String profileName { get; set; }
    public String licenseType { get; set; }
    public Map<String, Boolean> permissions { get; set; }
    public Map<Id, Map<String, Boolean>> permissions_content_type { get; set; }
    public Map<Id, Map<String, Boolean>> permissions_library { get; set; }
    public Boolean hasOrchestraCMSApplicationAccess { get; set; }
    public List<UserBundle> users { get; set; }
    public Boolean activated { get; set; }
    public Boolean licenseExpired { get; set; }
}