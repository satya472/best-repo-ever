public virtual with sharing class FolderItemBundle {
    // The id of the folderItem
    public Id id;
    // This is the content/page/media id
    public Id originId;
    public Id latestId;
    public Id parent;

    public String name;
    public String description;
    // The kind of thing this is (Page, Content, Media etc.)
    public String kind;
    // The type related to the kind.
    public String type;

    public Boolean published;
    public Datetime publishedStartDate;
    public Datetime publishedEndDate;
    public Integer versionNumber;
    public Integer revisionNumber;
    public String status;
    public String path;

    // Children of this folder
    public List<FolderItemBundle> children;
}