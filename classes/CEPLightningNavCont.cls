/*
 * Created By: Prashant Verma
 * Description: This is a navigation Class handle all navigation related queries.
 */
public with sharing class CEPLightningNavCont {

    @AuraEnabled
    public static List<NavigationMenuItem> getNavigationItems() {

        List<NavigationMenuItem> navArr = [SELECT Id,Label,ParentId,Position, Type, Target FROM NavigationMenuItem WHERE Status = 'Live' 									   AND NavigationLinkSetId='0Lm1l0000004CLYCA2' order by position];

       return navArr;							 
    }

}