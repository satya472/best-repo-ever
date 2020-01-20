public with sharing class TaxonomyAPIRequest extends APIRequest {

    public TaxonomyBundle bundle;
    public Id contentId;
    public List<TaxonomyBundle> childrenToAdd;
    public List<TaxonomyBundle> categories;

    public TaxonomyAPIRequest() {
        super();
    }

    

}