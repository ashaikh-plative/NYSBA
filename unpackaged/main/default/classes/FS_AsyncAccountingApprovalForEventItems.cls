/**
 * Created by Nikhil on 11-03-2020.
 */

global class FS_AsyncAccountingApprovalForEventItems implements Schedulable {
    Set<Id> itemIdSet;
    global FS_AsyncAccountingApprovalForEventItems(Set<Id> itemIdSet) {
        this.itemIdSet = itemIdSet;
    }

    global void execute(SchedulableContext SC) {
        //limiting to the particular records in After insert trigger
        List<OrderApi__Item__c> itemToUpdate = new List<OrderApi__Item__c>();
        List<OrderApi__Item__c> itemList = [SELECT Id,OrderApi__Is_Active__c,FS_Accounting_Approval__c FROM OrderApi__Item__c WHERE Id IN :itemIdSet AND OrderApi__Is_Active__c = True
									AND FS_Accounting_Approval__c != 'Approved'];
        if(!itemList.isEmpty()){
        	for(OrderApi__Item__c currItem : itemList) {
            	currItem.OrderApi__Is_Active__c = false;
            	currItem.FS_Accounting_Approval__c = 'Request Approval';
                itemToUpdate.add(currItem);
        	}
		}

        if (!itemToUpdate.isEmpty()) {
            update itemToUpdate;
        }

        //deleting the scheduled job after the record gets updated.
        Id cronTriggerId = SC.getTriggerId();
        System.abortJob(cronTriggerId);
    }
}