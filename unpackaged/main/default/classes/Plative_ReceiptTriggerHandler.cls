/**
* Description : Handler class to call utility methods based on trigger DML event.
*				Also contains methods to check criteria to call helper methods
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
public class Plative_ReceiptTriggerHandler extends Plative_TriggerHandler{
	public static boolean runTrigger = true;
    public static Map<Id,OrderApi__Receipt__c> newMap;

	//Constructor
    public Plative_ReceiptTriggerHandler(Map<Id,SObject> triggerNewMap){
        newMap = (Map<Id,OrderApi__Receipt__c>)triggerNewMap;
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
		Map<Id, OrderApi__Receipt__c> mapReceiptToSync = new Map<Id, OrderApi__Receipt__c>();
		for(OrderApi__Receipt__c newReceipt : (List<OrderApi__Receipt__c>)Trigger.newMap.values()){
			OrderApi__Receipt__c oldReceipt = (OrderApi__Receipt__c)Trigger.oldMap.get(newReceipt.Id);
			//if trigger flag set to true from false
			if(newReceipt.Trigger_Sync_To_Netsuite__c && !oldReceipt.Trigger_Sync_To_Netsuite__c){
			    mapReceiptToSync.put(newReceipt.Id, newReceipt);
			}
		}

		if(!mapReceiptToSync.isEmpty()){
			Plative_SFToNSSyncUtility.processForRealTimeSync('OrderApi__Receipt__c', mapReceiptToSync);
		}

		Plative_SFToNSSyncUtility.triggerJobsInQueue();
	}
}