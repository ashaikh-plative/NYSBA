/**
* Created by Gopi on 08-11-2019.
*/

global without sharing class FS_ItemInventoryRRuleonSOLine extends Framework.Domain {
    public FS_ItemInventoryRRuleonSOLine(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ItemInventoryRRuleonSOLine(sObjectList);
        }
    }
    
    public override void afterInsert() {
        Framework.Log.push(FS_ItemInventoryRRuleonSOLine.class.getName(), 'After Insert');
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = (List<OrderApi__Sales_Order_Line__c>) records;
        itemInventoryManagement(salesOrderLineList,FALSE);
        Framework.Log.pop();
    }
    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ItemInventoryRRuleonSOLine.class.getName(), 'before update');
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = (List<OrderApi__Sales_Order_Line__c>) records;
        itemInventorySOLineUpdate(salesOrderLineList, existingRecords);
        Framework.Log.pop ();
    }
    
    
    public override void beforeDelete() {
        Framework.Log.push(FS_ItemInventoryRRuleonSOLine.class.getName(), 'Before delete');
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = (List<OrderApi__Sales_Order_Line__c>) records;
        itemInventoryManagement(salesOrderLineList,TRUE);
        Framework.Log.pop();
    }
    
    /*This method is for Insert and Delete operations*/
    private static void itemInventoryManagement(List<OrderApi__Sales_Order_Line__c> salesOrderLineList, Boolean isDelete) {
        Set<Id> soId = new Set<Id>();
        Set <Id> itemSet = new Set<Id>();
        for (OrderApi__Sales_Order_Line__c sol : salesOrderLineList) {
            soId.add(sol.OrderApi__Sales_Order__c);
            itemSet.add(sol.OrderApi__Item__c);
        }
        Map<Id, OrderApi__Sales_Order__c> soMap = new Map<Id, OrderApi__Sales_Order__c>([SELECT Id,OrderApi__Posting_Status__c,OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id = :soId AND OrderApi__Posting_Status__c != 'Posted']);
        Map<Id, OrderApi__Item__c> itemMap = new Map<Id, OrderApi__Item__c> ([SELECT Id,FS_Items_in_Cart__c,OrderApi__Inventory__c,FS_Items_in_Warehouse__c,FS_Track_Inventory__c FROM OrderApi__Item__c WHERE Id IN :itemSet AND FS_Track_Inventory__c = TRUE]);
        List<OrderApi__Item__c> itemsList = new List<OrderApi__Item__c>();
        for (OrderApi__Sales_Order_Line__c soLine : salesOrderLineList) {
            if (soMap.containsKey(soLine.OrderApi__Sales_Order__c)
                && itemMap.containsKey(soLine.OrderApi__Item__c)) {
                    OrderApi__Item__c item = itemMap.get(soLine.OrderApi__Item__c);
                    if (isDelete == FALSE) {
                        item.FS_Items_in_Cart__c = String.isBlank(String.valueOf(item.FS_Items_in_Cart__c)) ? 0 + soLine.OrderApi__Quantity__c : item.FS_Items_in_Cart__c + soLine.OrderApi__Quantity__c;
                    } else {
                        if(item.FS_Items_in_Cart__c == null || item.FS_Items_in_Cart__c - soLine.OrderApi__Quantity__c <= 0){
                            item.FS_Items_in_Cart__c = 0;
                        }else{
                            item.FS_Items_in_Cart__c = item.FS_Items_in_Cart__c - soLine.OrderApi__Quantity__c;
                        }
                    }
                    itemsList.add(item);
                    itemMap.putAll(itemsList);
                }
        }
        update itemMap.values();
    }
    
    public static void itemInventorySOLineUpdate(List<OrderApi__Sales_Order_Line__c> salesOrderLineList, Map<Id, SObject> existingRecords) {
        Set <Id> soId = new Set<Id>();
        Set <Id> allItemIdSet = new Set<Id>();
        
        for (OrderApi__Sales_Order_Line__c sol : salesOrderLineList) {
            OrderApi__Sales_Order_Line__c oldSOL = (OrderApi__Sales_Order_Line__c) existingRecords.get(sol.Id);
            if ((sol.OrderApi__Quantity__c != oldSOL.OrderApi__Quantity__c) || (sol.OrderApi__Item__c != oldSOL.OrderApi__Item__c)) {
                soId.add(sol.OrderApi__Sales_Order__c);
                allItemIdSet.add(sol.OrderApi__Item__c);
                allItemIdSet.add(oldSOL.OrderApi__Item__c);
            }
        }
        
        Map<Id, OrderApi__Sales_Order__c> soMap = new Map<Id, OrderApi__Sales_Order__c>([SELECT Id,OrderApi__Posting_Status__c,OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id = :soId AND OrderApi__Posting_Status__c != 'Posted']);
        Map<Id, OrderApi__Item__c> itemMap = new Map<Id, OrderApi__Item__c> ([SELECT Id,FS_Items_in_Cart__c,OrderApi__Inventory__c,FS_Items_in_Warehouse__c,FS_Track_Inventory__c FROM OrderApi__Item__c WHERE Id IN :allItemIdSet AND FS_Track_Inventory__c = TRUE]);
        
        for (OrderApi__Sales_Order_Line__c soLine : salesOrderLineList) {
            OrderApi__Sales_Order_Line__c oldSOL2 = (OrderApi__Sales_Order_Line__c) existingRecords.get(soLine.Id);
            
            if (soMap.containsKey(soLine.OrderApi__Sales_Order__c)){  

                Decimal newQuantity = soLine.OrderApi__Quantity__c == null ? 0 : soLine.OrderApi__Quantity__c;
                Decimal oldQuantity = oldSOL2.OrderApi__Quantity__c == null ? 0 : oldSOL2.OrderApi__Quantity__c;

                OrderApi__Item__c item = itemMap.get(soLine.OrderApi__Item__c);
                OrderApi__Item__c oldItem = itemMap.get(oldSOL2.OrderApi__Item__c);
                
                if(soLine.OrderApi__Item__c != oldSOL2.OrderApi__Item__c){
                    if(item != null){
                        item.FS_Items_in_Cart__c = (item.FS_Items_in_Cart__c == null ? 0 : item.FS_Items_in_Cart__c )+ newQuantity;
                    }
                    if(oldItem != null){
                        oldItem.FS_Items_in_Cart__c = (oldItem.FS_Items_in_Cart__c == null ? 0 : oldItem.FS_Items_in_Cart__c )- oldQuantity;
                    }
                }else if(item != null && newQuantity != oldQuantity){
                    item.FS_Items_in_Cart__c = (item.FS_Items_in_Cart__c == null ? 0 : item.FS_Items_in_Cart__c ) + newQuantity - oldQuantity ;
                }
            } 
        }
        update itemMap.values();
    }
}