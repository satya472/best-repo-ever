/**
 * Author: Naveen Gadciherla
 * Company: Accenture
 * Date: 07-March-2018
 * Main point for trigger handling. Reads custom metadata, creates trigger instances when applicable and runs them.
 */
global class TriggerService {

    /**
    * @description method should be executed from the trigger. Retrieves number of trigger handlers and executes them basing on order index.
    */
    global static void onTrigger() {
        if (!Trigger.isExecuting) {
            throw new TriggerServiceException('This method should be called only from trigger');
        }
        // prepare context
        TriggerContext context = new TriggerContext(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap, Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
        executeActions(context);
    }

    @TestVisible
    private static void executeActions(TriggerContext context) {
        String sobjectType = getSObjectType(context);
        // instantiate handlers
        List<TriggerHandler> handlers = instantiateHandlers(sobjectType);
        // execute handlers
        for (TriggerHandler handler : handlers) {
            if (context.isBefore) {
                if (context.isInsert) {
                    handler.beforeInsert(context);
                } else if (context.isUpdate) {
                    handler.beforeUpdate(context);
                } else if (context.isDelete) {
                    handler.beforeDelete(context);
                } else if (context.isUndelete) {
                    handler.beforeUndelete(context);
                }
            } else if (context.isAfter) {
                if (context.isInsert) {
                    handler.afterInsert(context);
                } else if (context.isUpdate) {
                    handler.afterUpdate(context);
                } else if (context.isDelete) {
                    handler.afterDelete(context);
                } else if (context.isUndelete) {
                    handler.afterUndelete(context);
                }
            }
        }
        // execute finish actions        
        if (context.isAfter) {
            for (TriggerHandler handler : handlers) {
                handler.finish(context);
            }
        }
    }

    private static String getSObjectType(TriggerContext context) {
        List<SObject> sobjects = context.isDelete ? context.oldList : context.newList;
        return sobjects.getSObjectType().getDescribe().getName();
    }

    private static List<Trigger_Handler__mdt> fetchAllActiveHandlerSettings(String sType) {
        // Custom Metadata query doesn't count towards governor limits!
        List<Trigger_Handler__mdt> settings = [SELECT Id, MasterLabel, DeveloperName, Order__c, sType__c, Active__c FROM Trigger_Handler__mdt WHERE sType__c = :sType AND Active__c = true ORDER BY Order__c ASC];
       // System.debug('Found active settings: ' + settings);
        return settings;
    }

    private static List<TriggerHandler> instantiateHandlers(String sType) {
        List<TriggerHandler> handlers = new List<TriggerHandler>();
        for (Trigger_Handler__mdt setting : fetchAllActiveHandlerSettings(sType)) {
            try {
                Type handlerType = Type.forName(setting.DeveloperName);
                if (handlerType <> null) {
                    System.debug('Instantiating ' + setting.MasterLabel + '(' + setting.DeveloperName + ')');
                    handlers.add((TriggerHandler) handlerType.newInstance());
                } else {
                    System.debug(LoggingLevel.ERROR, 'TriggerService::onTrigger can\'t instantiate handler for setting: ' + setting);
                }
            } catch (Exception exp) {
                System.debug(LoggingLevel.ERROR, 'TriggerService::onTrigger exception instantiating handler for setting: ' + setting + ' Exception: ' + exp.getMessage());
            }
        }
        return handlers;
    }
 
    /**
    * @description Exception from the trigger functionality 
    */
    private class TriggerServiceException extends Exception {
    }

}