/*
* Author: Phaniram Upalapati
* Date: 02-May-2019
* Description: Custom ContentDocumentLinkTrigger_TrigAct handler for ContentDocumentLink Trigger
* 
*/
public class ContentDocumentLinkTrigger_TrigAct extends TriggerHandler{
    
     /*
    ** Fire logic for beforeInsert context
    */
    public override void beforeInsert(TriggerContext context) 
    {

        Set<String> objectLst = new Set<String>{'CEP_AssetNotification__c'};

        for(ContentDocumentLink cdl:(List<ContentDocumentLink>)context.newList){

            if(objectLst.contains(string.valueOf(cdl.LinkedEntityId.getSObjectType().getDescribe().getName()))){
                cdl.Visibility='AllUsers';
                cdl.ShareType='V';
            }

        }


    }
    
}