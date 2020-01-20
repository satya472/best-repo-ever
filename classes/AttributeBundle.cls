public abstract with sharing class AttributeBundle {

    public String languageCode { get; set; }
    public Boolean simple { get; set; }

    public virtual class ContentMetaAttribute extends AttributeBundle {
        public String metaContentName { get; set; }
        public String metaContentTitle { get; set; }
        public String metaContentDescription { get; set; }
    }

    public virtual class ContentAttribute extends AttributeBundle {
        public String name { get; set; }
        public String value { get; set; }
        public String valueType { get; set; }
    }

}