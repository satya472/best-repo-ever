public virtual with sharing class ContentLayoutBundle {
    public String contentLayoutId;
    public String label;
    public String name;
    public String viewPage;
    public String editPage;
    public String editComponent;
    public String controllerNamespace;
    public String controllerName;
    public Boolean ctcManaged;
    public String generateTemplate;
    public String resourceName;
    public List<String> styleSheets;
    public String attributeDefinitionId;
    public String attributeDefinition;

    public String contentLayoutInstanceId;
    public Map<String, List<AttributeBundle.ContentAttribute>> layoutAttributes { get; set; }

}