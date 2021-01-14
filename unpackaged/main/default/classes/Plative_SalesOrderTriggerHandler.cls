/**
* Description : Handler class to call utility methods based on trigger DML event.
*				Also contains methods to check criteria to call helper methods
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
public class Plative_SalesOrderTriggerHandler  extends Plative_TriggerHandler{
	public static boolean runTrigger = true;
    public static Map<Id,OrderApi__Sales_Order__c> newMap;

	//Constructor
    public Plative_SalesOrderTriggerHandler(Map<Id,SObject> triggerNewMap){
        newMap = (Map<Id,OrderApi__Sales_Order__c>)triggerNewMap;
    }


	/*
	* Description : Runs for after Update trigger context
	*/
    public override void beforeUpdate(){
          checkIfPosted();
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
		Map<Id, OrderApi__Sales_Order__c> mapOrderToSync = new Map<Id, OrderApi__Sales_Order__c>();
		for(OrderApi__Sales_Order__c newOrder : (List<OrderApi__Sales_Order__c>)Trigger.newMap.values()){
			OrderApi__Sales_Order__c oldOrder = (OrderApi__Sales_Order__c)Trigger.oldMap.get(newOrder.Id);
			//if trigger flag set to true from false
			if(newOrder.Trigger_Sync_To_Netsuite__c && !oldOrder.Trigger_Sync_To_Netsuite__c){
			    mapOrderToSync.put(newOrder.Id, newOrder);
			}
		}
		if(!mapOrderToSync.isEmpty()){
			//Plative_SFToNSSyncUtility.processForRealTimeSync('OrderApi__Sales_Order__c', mapOrderToSync);
			//At this point, queue will have payload for Contact, Organization and Sales Order
			Plative_SFToNSSyncUtility.triggerJobsInQueue();
		}
	}

	/*
	* Description : Checks if Sales Order is posted, if yes marks for sync to NetSuite
	*/
	public void checkIfPosted(){
		Map<Id, OrderApi__Sales_Order__c> mapPostedOrders = new Map<Id, OrderApi__Sales_Order__c>();
		Set<Id> setContactIds = new Set<Id>();
		for(OrderApi__Sales_Order__c newOrder : (List<OrderApi__Sales_Order__c>)Trigger.newMap.values()){
			OrderApi__Sales_Order__c oldOrder = (OrderApi__Sales_Order__c)Trigger.oldMap.get(newOrder.Id);
			//if Status or Posting Status changed to meet criteria
			if((newOrder.OrderApi__Status__c == 'Closed' && newOrder.OrderApi__Posting_Status__c == 'Posted') &&
			   ((newOrder.OrderApi__Status__c != oldOrder.OrderApi__Status__c) ||
			   (newOrder.OrderApi__Posting_Status__c != oldOrder.OrderApi__Posting_Status__c))){
			    mapPostedOrders.put(newOrder.Id, newOrder);
				newOrder.Trigger_Sync_To_Netsuite__c = true;
				setContactIds.add(newOrder.OrderApi__Contact__c);
			}
		}
		//Before creating a Sales Order we have to create the Customer in NetSuite
		if(!setContactIds.isEmpty())Plative_SalesOrderHelper.markContactsForSync(setContactIds);
	}
}