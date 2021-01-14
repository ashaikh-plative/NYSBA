/**
* Description : Handler class to call utility methods based on trigger DML event.
*				Also contains methods to check criteria to call helper methods
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
public class Plative_AccountTriggerHandler extends Plative_TriggerHandler{
	public static boolean runTrigger = true;
    public static Map<Id,Account> newMap;

	//Constructor
    public Plative_AccountTriggerHandler(Map<Id,SObject> triggerNewMap){
        newMap = (Map<Id,Account>)triggerNewMap;
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
		Map<Id, Account> mapAccountToSync = new Map<Id, Account>();
		for(Account newAcc : (List<Account>)Trigger.newMap.values()){
			Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);
			//if trigger flag set to true from false
			if(newAcc.Trigger_Sync_To_Netsuite__c && !oldAcc.Trigger_Sync_To_Netsuite__c){
			    mapAccountToSync.put(newAcc.Id, newAcc);
			}
		}

		if(!mapAccountToSync.isEmpty()){
			Plative_SFToNSSyncUtility.processForRealTimeSync('Account', mapAccountToSync);
		}
	}
}