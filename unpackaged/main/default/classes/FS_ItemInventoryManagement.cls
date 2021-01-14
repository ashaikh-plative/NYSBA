/**
 * Created by Gopi on 07-11-2019.
 */

global without sharing class FS_ItemInventoryManagement extends Framework.Domain {
    public FS_ItemInventoryManagement(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ItemInventoryManagement(sObjectList);
        }
    }
    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ItemInventoryManagement.class.getName(), 'After update');
        ItemInventoryManagement((List<OrderApi__Sales_Order__c>) records, existingRecords);
        Framework.Log.pop();
    }
    public static void ItemInventoryManagement(List<OrderApi__Sales_Order__c> soList, Map<Id, SObject> existingRecords) {
        Set<Id> solID = new Set<Id>();
        for (OrderApi__Sales_Order__c saleOrder : soList) {
            OrderApi__Sales_Order__c oldSO = (OrderApi__Sales_Order__c) existingRecords.get(saleOrder.Id);
            if ((saleOrder.OrderApi__Status__c == 'closed' && saleOrder.OrderApi__Posting_Status__c == 'posted') &&
                    (oldSO.OrderApi__Posting_Status__c != 'posted')) {
                solID.add(saleOrder.Id);
            }
        }
        List<OrderApi__Sales_Order_Line__c> soLineList = [SELECT Id,OrderApi__Item__c,OrderApi__Account__c,OrderApi__Contact__c,OrderApi__Quantity__c,
                OrderApi__Item__r.Name,OrderApi__Sales_Order__r.OrderApi__Closed_Date__c,OrderApi__Item__r.FS_Track_Inventory__c
        FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c IN : solID AND OrderApi__Item__r.FS_Track_Inventory__c = TRUE];
        Set<Id> itmSet = new Set<Id>();
        for (OrderApi__Sales_Order_Line__c soLine : soLineList) {
            itmSet.add(soLine.OrderApi__Item__c);
        }

        Map<Id,OrderApi__Item__c> itemMap = new Map<Id,OrderApi__Item__c> ([SELECT Id,FS_Items_in_Cart__c,OrderApi__Inventory__c,FS_Items_in_Warehouse__c
        FROM OrderApi__Item__c WHERE Id IN : itmSet]);
        List<OrderApi__Item__c> itemsList = new List<OrderApi__Item__c>();
        for( OrderApi__Sales_Order_Line__c soLine : soLineList ){
            if(itemMap.containsKey(soLine.OrderApi__Item__c)){
                OrderApi__Item__c item = itemMap.get(soLine.OrderApi__Item__c);
                item.FS_Items_in_Warehouse__c = String.isBlank(String.valueOf(item.FS_Items_in_Warehouse__c)) ? 0 - soLine.OrderApi__Quantity__c
                        : item.FS_Items_in_Warehouse__c - soLine.OrderApi__Quantity__c;
                item.FS_Items_in_Cart__c = item.FS_Items_in_Cart__c - soLine.OrderApi__Quantity__c;
                itemsList.add(item);
                itemMap.putAll(itemsList);
            }
        }
        update itemMap.values();
    }
}