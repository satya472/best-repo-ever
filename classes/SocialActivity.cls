public with sharing class SocialActivity {

    //true/false, whether there is a SocialData_Activity__c.Liked record for this user.
    public Boolean likedByMe;

    //the date time the item was liked by the user
    public Datetime likedDate;

    // true/false, whether there is a SocialData_Activity__c.Viewed record for this user.
    public Boolean viewedByMe;

    //the date time the item was last viewed by the user
    public Datetime viewedDate;

}