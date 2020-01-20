/**
 * Author: Naveen Gadicherla
 * Company:Accenture
 * Date:7-March-2018
 * Abstract class for all trigger handlers.
 */
global virtual without sharing class TriggerHandler {

    /* Map of number of times subclasses have been executed; to be indexed by class name */
	private static Map<String,Integer> execMap = new Map<String,Integer>();
    
    /**
    * @description Constructor 
    */
    global TriggerHandler() {

    }
    
    /**
    * @description this method will be executed before insert. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void beforeInsert(TriggerContext context) {

    }

    /**
    * @description this method will be executed after insert. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void afterInsert(TriggerContext context) {

    }

    /**
    * @description this method will be executed before update. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void beforeUpdate(TriggerContext context) {

    }

    /**
    * @description this method will be executed after update. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void afterUpdate(TriggerContext context) {

    }

    /**
    * @description this method will be executed before delete. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void beforeDelete(TriggerContext context) {

    }

    /**
    * @description this method will be executed after delete. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void afterDelete(TriggerContext context) {

    }

    /**
    * @description this method will be executed before undelete. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void beforeUndelete(TriggerContext context) {

    }

    /**
    * @description this method will be executed after undelete. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void afterUndelete(TriggerContext context) {

    }
    
    /**
    * @description this method will be executed in the end of trigger handler execution. Should be overriden if needed.
    * @param context Trigger Context instance with all trigger data 
    */
    global virtual void finish(TriggerContext context) {

    }
    
    /**
    * @description this method will be getting the Class Name that is Currently Executing.
    * @param context 
    */
	public String getClassName(){
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
	}
    
    /**
    * @description this method will Marks that a child class has been run.
    * @param context 
    */
	public void markRun(){
		String clsNm = this.getClassName();
		if(TriggerHandler.execMap.containsKey(clsNm)){
			TriggerHandler.execMap.put(clsNm,TriggerHandler.execMap.get(clsNm)+1);
		} else {
			TriggerHandler.execMap.put(clsNm,1);
		}
	}
    
    /**
    * @description this method Return the number of times a class has been run
    * @param context 
    */
	public Integer timesRun(){
		String clsNm = this.getClassName();
		if(TriggerHandler.execMap.containsKey(clsNm)){
			return TriggerHandler.execMap.get(clsNm);
		} else {
			return 0;
		}
	}
    
    /**
    * @description this method Return Whether the class has already Run or not
    * @param context 
    */
	public Boolean hasRun(){
		return this.timesRun() > 0;
	}
    
	/**
    * @description this method Resets hasRun count for this class
    * @param context 
    */
	public void resetHasRun(){
		TriggerHandler.execMap.put(this.getClassName(),0);
	}
    
    /**
    * @description this method Resets hasRun counts for all trigger action classes
    * @param context 
    */ 
	public static void resetAllHasRun(){
		TriggerHandler.execMap.clear();
	}

}