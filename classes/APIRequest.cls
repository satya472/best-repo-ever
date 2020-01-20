/********************************************************************************************
     *  Generic class used to represent a request to the API.
     *
     ****/
public virtual with sharing class APIRequest {

    public static final String NODATA = 'noData';
    public static final String ALLDATA = 'allData';
    public static final String FOR_EDIT = 'forEdit';
    public static final String UNPUBLISHED = 'unpublished';
    public static final String LATEST = 'latest';
    public static final String PUBLISHED = 'published';
    public static final String LOCK = 'lock';

    public Id objectId;
    public String transactionId;

    /**
     *  Request flags - indicators of data the api shoud refresh and return. If the request included a bundle and any flag other then
     *                  noData is specified, that data will be re-queried from the data base and the updated in the supplied bundle.
     *                  Any data in the bundle that was not requested will be returned to the caller as supplied:
     *
     *  versions    -Retrieve Content data and the list of content versions. - Default FALSE
     *  layouts     -Retrieve ContentLayoutInstance data. -  Default TRUE
     *  attributes  -Retrieve attributes.  Content layout attributes only retrieved if layouts are true
     *  allData     -Retrieve ALL data on the content incuding attributes, versions and content data.
     *  noData      -Return only a success/failure indicator  - Default unless specified by the API call
     */
    public Map<String, Boolean> requestFlags { get{
        if (this.requestFlags == null) {
            this.requestFlags = new Map<String, Boolean>();
        }
        return(this.requestFlags);
    } set; }

    /***
     *Map containing request parameters that are single items. (EX: String VersionString)
     */
    public Map<String, String> parameters { get{
        if (this.parameters == null) {
            this.parameters = new Map<String, String>();
        }
        return(this.parameters);
    } set; }

    /***
     *Map containing request parameters that include lists of items. (EX: List<String> Languages)
     */
    public Map<String, List<String>> listParameters { get{
        if (this.listParameters == null) {
            this.listParameters = new Map<String, List<String>>();
        }
        return(this.listParameters);
    } set; }

    /***
     * Map containing request parameters that include lists of items. (EX: List<String> Languages)
     */
    public Map<String, Map<String, String>> mapParameters { get{
        if (this.mapParameters == null) {
            this.mapParameters = new Map<String, Map<String, String>>();
        }
        return(this.mapParameters);
    } set; }

    public APIRequest() {
        this.requestFlags = new Map<String, Boolean>();
        this.parameters = new Map<String, String>();
        this.listParameters = new Map<String, List<String>>();
        this.mapParameters = new Map<String, Map<String, String>>();
    }

    /**
     * Gets the id of the object this request is for.
     * @return The object ID, or null??
     */
    public virtual Id getID() {
        return (this.objectId);
    }

    
}