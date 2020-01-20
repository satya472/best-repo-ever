public virtual with sharing class FilteringBundle {
    public List<Filter> filters;
    public Map<Id, ContentBundle> contentBundles;
    public Map<Id, Integer> relevance;
    public Map<String, List<Id>> contentOrdering;
    public List<FolderItemBundle> folderItemBundles;
    public Integer totalItemCount;
}