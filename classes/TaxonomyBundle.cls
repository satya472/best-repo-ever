public virtual with sharing class TaxonomyBundle {
    public Id tagID; // the Id of the associated content
    public Id tagDefinitionID; // The ID of the Tag Definition
    public Id originID; // The origin ID of the root content
    public Id taxonomyID; // The ID of the root content
    public Map <String, String> languageMapOfPaths;
    public Map <String, String> languageMapOfTagNames;
    public List<TaxonomyBundle> children; // only available when requesting the full taxonomy structure
    public Integer depth;
}