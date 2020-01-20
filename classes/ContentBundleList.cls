/**
 * The response returned by all IRenderAction classes.
 */

public with sharing class ContentBundleList {

    /** Whether there are more results that could be returned, client needs to know how to retrieve further results. */
    public Boolean hasMore;

    /** The list of content bundles to be returned */
    public List<ContentBundle> contentBundles;

    /** The SocialBundle data associated with the content bundles being returned **/
    public Map<String, SocialBundle> socialBundles;

    /** A map for adding custom information into the response object. **/
    public Map<String, String> contentProperties;

    /**
     * Creates a response with the given list of content bundles and sets hasMore to false.
     *
     * @param contents The list of bundles.
     */
    public ContentBundleList(List<ContentBundle> contents) {
        this(contents, new Map<String, SocialBundle>(), false);
    }

    /**
     * Creates a response with the given list of content bundles and related socialBundles.
     * is set to false.
     *
     * @param contents The list of bundles.
     * @param more true if there are more results, false if not.
     */
    public ContentBundleList(List<ContentBundle> contents, Map<String, SocialBundle> social) {
        this(contents, social, false);
    }

    /**
     * Creates a response with the given list of content bundles, of related socialBundles, and
     * whether there are more results or not
     *
     * @param contents the list of content bundles
     * @param social map of content origin id to social bundle
     * @param more true if there are more results, false if not.
     */
    public ContentBundleList(List<ContentBundle> contents, Map<String, SocialBundle> social, Boolean more) {
        contentBundles = contents;
        socialBundles = social;
        hasMore = more;
    }
}