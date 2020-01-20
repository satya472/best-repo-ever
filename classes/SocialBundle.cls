public virtual with sharing class SocialBundle {

    public Id originId;

    // The id of the SocialData__c object that is associated with the content or page.
    public Id socialID;

    // Status of the related object
    public String objectStatus; // Published, Unpublished, Expired

    //The number of likes from the SocialData__c record.
    public Integer likes;

    //The number of views from the SocialData__c record.
    public Integer views;

    //My social activity likes/views
    public SocialActivity socialActivity;

}