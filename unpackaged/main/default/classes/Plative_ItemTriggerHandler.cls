/**
* Description : Handler class to call utility methods based on trigger DML event.
*				Also contains methods to check criteria to call helper methods
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
public class Plative_ItemTriggerHandler extends Plative_TriggerHandler{
	public static boolean runTrigger = true;
    public static Map<Id,OrderApi__Item__c> newMap;

	//Constructor
    public Plative_ItemTriggerHandler(Map<Id,SObject> triggerNewMap){
        newMap = (Map<Id,OrderApi__Item__c>)triggerNewMap;
    }

	/*
	* Description : Runs for before Update trigger context
	*/
    public override void beforeUpdate(){
          checkIfApprovedOrModified();
    }

	/*
	* Description : Runs for after Update trigger context
	*/
    public override void afterUpdate(){
          checkIfToBeSyncedToNetSuite();
    }

	/*
	* Description : Check if item approved or changed after sync to NetSuite
	*/
	public void checkIfApprovedOrModified(){
		for(OrderApi__Item__c newItem : (List<OrderApi__Item__c>)Trigger.newMap.values()){
			OrderApi__Item__c oldItem = (OrderApi__Item__c)Trigger.oldMap.get(newItem.Id);
			//if Accounting has approved
			if(newItem.FS_Accounting_Approval__c == 'Approved' && 
			   (oldItem.FS_Accounting_Approval__c != newItem.FS_Accounting_Approval__c)){
			    newItem.Trigger_Sync_To_Netsuite__c = true;
			}
		}
	}

	/*
	* Description : Check if item has to be synced to NetSuite
	*/
	public void checkIfToBeSyncedToNetSuite(){
		Map<Id, OrderApi__Item__c> mapItemsToSync = new Map<Id, OrderApi__Item__c>();
		for(OrderApi__Item__c newItem : (List<OrderApi__Item__c>)Trigger.newMap.values()){
			OrderApi__Item__c oldItem = (OrderApi__Item__c)Trigger.oldMap.get(newItem.Id);
			//if trigger flag set to true from false
			if(newItem.Trigger_Sync_To_Netsuite__c && !oldItem.Trigger_Sync_To_Netsuite__c){
			    mapItemsToSync.put(newItem.Id, newItem);
			}
		}
		if(!mapItemsToSync.isEmpty()){
			Plative_SFToNSSyncUtility.processForRealTimeSync('OrderApi__Item__c', mapItemsToSync);
		}
		Plative_SFToNSSyncUtility.triggerJobsInQueue();
	}
}