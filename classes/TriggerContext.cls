/**
 * Author: Naveen Gadicherla
 * Company: Accenture
 * Date: 07-March-2018
 * Contains all trigger context data.
 */
global without sharing class TriggerContext {

    global List<sObject> oldList { get; set; }
    global Map<Id, sObject> oldMap { get; set; }
    global List<sObject> newList { get; set; }
    global Map<Id, sObject> newMap { get; set; }
    global Boolean isBefore { get; set; }
    global Boolean isAfter { get; set; }
    global Boolean isInsert { get; set; }
    global Boolean isUpdate { get; set; }
    global Boolean isDelete { get; set; }
    global Boolean isUndelete { get; set; }

   
    /**
    * @description Constructor
    * @param oldList list of old values
    * @param oldMap map with old values
    * @param newList list of new values
    * @param newMap map with new values
    * @param isBefore indicates whether trigger is before
    * @param isAfter indicates whether trigger is after
    * @param isInsert indicates whether trigger is insert
    * @param isUpdate indicates whether trigger is update
    * @param isDelete indicates whether trigger is delete
    * @param isUndelete indicates whether trigger is undelete
    */
    global TriggerContext(List<sObject> oldList, Map<Id, sObject> oldMap, List<sObject> newList, Map<Id, sObject> newMap, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.oldList = oldList;
        this.oldMap = oldMap;
        this.newList = newList;
        this.newMap = newMap;
        this.isBefore = isBefore;
        this.isAfter = isAfter;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }

}