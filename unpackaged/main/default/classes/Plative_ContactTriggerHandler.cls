/**
* Description : Handler class to call utility methods based on trigger DML event.
*				Also contains methods to check criteria to call helper methods
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
public class Plative_ContactTriggerHandler extends Plative_TriggerHandler{
	public static boolean runTrigger = true;
    public static Map<Id,Contact> newMap;

	//Constructor
    public Plative_ContactTriggerHandler(Map<Id,SObject> triggerNewMap){
        newMap = (Map<Id,Contact>)triggerNewMap;
    }

	/*
	* Description : Runs for after Update trigger context
	*/
    public override void afterUpdate(){
          checkIfToBeSyncedToNetSuite();
    }

	/*
	* Description : Check if item has to be synced to NetSuite
	*/
	public void checkIfToBeSyncedToNetSuite(){
		Map<Id, Contact> mapContactToSync = new Map<Id, Contact>();
		for(Contact newCon : (List<Contact>)Trigger.newMap.values()){
			Contact oldCon = (Contact)Trigger.oldMap.get(newCon.Id);
			//if trigger flag set to true from false
			if(newCon.Trigger_Sync_To_Netsuite__c && !oldCon.Trigger_Sync_To_Netsuite__c){
			    mapContactToSync.put(newCon.Id, newCon);
			}
		}

		if(!mapContactToSync.isEmpty()){
			Plative_SFToNSSyncUtility.processForRealTimeSync('Contact', mapContactToSync);
		}
	}	
}