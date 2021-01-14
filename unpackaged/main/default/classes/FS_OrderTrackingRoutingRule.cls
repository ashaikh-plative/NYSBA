global with sharing class FS_OrderTrackingRoutingRule extends Framework.Domain {
    
    public FS_OrderTrackingRoutingRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_OrderTrackingRoutingRule(sObjectList);
        }
    }
    
    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_OrderTrackingRoutingRule.class.getName(), 'after update');
        afterUpdate(records, existingRecords);
        Framework.Log.pop();
    }
    
    public static void afterUpdate(List<OrderApi__Sales_Order__c> salesOrders, Map<Id, SObject> existingRecords){
        Set<Id> soIds = new Set<Id>();     
        
        //Creating a set with SO Ids which posting status is changed and the new posting status is posted
        for(OrderApi__Sales_Order__c salesOrder : salesOrders){
            OrderApi__Sales_Order__c oldSO = (OrderApi__Sales_Order__c)existingRecords.get(salesOrder.Id);
            if(oldSO != null && salesOrder.OrderApi__Posting_Status__c != oldSO.OrderApi__Posting_Status__c
               && salesOrder.OrderApi__Posting_Status__c == 'Posted'){
                   soIds.add(salesOrder.Id);
               }
        }
        //Retrieving the Sales order lines
        List<OrderApi__Sales_Order_Line__c> solList =  [SELECT Id,OrderApi__Sales_Order__c, OrderApi__Item__c,OrderApi__Quantity__c
                                                        FROM OrderApi__Sales_Order_Line__c
                                                        WHERE OrderApi__Sales_Order__c IN : soIds  AND 
                                                        OrderApi__Item__r.OrderApi__Require_Shipping__c = TRUE];
        List<FS_Order_Tracking__c> orderTrackingList=new List<FS_Order_Tracking__c>();
        
        for(OrderApi__Sales_Order_Line__c sol : solList){
            orderTrackingList.add(createOrderTracking(sol));
        }
        if(!orderTrackingList.isEmpty()){
            //Inserting OrderTracking records
            insert orderTrackingList;
        }
    }
    private  static FS_Order_Tracking__c createOrderTracking(OrderApi__Sales_Order_Line__c sol){
        FS_Order_Tracking__c orderTrack=new FS_Order_Tracking__c();
        orderTrack.FS_Quantity__c=String.valueOf(sol.OrderApi__Quantity__c);
        orderTrack.FS_Sales_Order__c=sol.OrderApi__Sales_Order__c;
        orderTrack.FS_Sales_Order_Line__c=sol.Id;
        return orderTrack;
    }
}