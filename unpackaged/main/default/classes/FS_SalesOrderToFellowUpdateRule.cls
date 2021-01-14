/**
 * Created by cloudwebsolutions on 05-02-2020.
 * Description : This is to calculate the pledge balance on posting the SO.
 */

global without sharing class FS_SalesOrderToFellowUpdateRule extends Framework.Domain {

    private static final String POSTED = 'Posted';

    public FS_SalesOrderToFellowUpdateRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_SalesOrderToFellowUpdateRule(sObjectList);
        }
    }

    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_SalesOrderToFellowUpdateRule.class.getName(),'After update');
        updateFellowBasedOnSalesOrderPostingStatus((List<OrderApi__Sales_Order__c>) records, (Map<Id, OrderApi__Sales_Order__c>) existingRecords);
        Framework.Log.pop();
    }

     private static void updateFellowBasedOnSalesOrderPostingStatus(List<OrderApi__Sales_Order__c> salesOrders,Map<Id,OrderApi__Sales_Order__c> oldMap){

        Set<Id> salesOrderIds = new Set<Id>();
        Set<Id> fellowIds = new Set<Id>();

        for(OrderApi__Sales_Order__c salesOrder: salesOrders){
            if(salesOrder.OrderApi__Posting_Status__c == POSTED &&
                    oldMap.get(salesOrder.id).OrderApi__Posting_Status__c != POSTED){
                salesOrderIds.add(salesOrder.id);
            }
        }

        List<OrderApi__Sales_Order_Line__c> salesOrderLines = [SELECT Id,OrderApi__Sales_Order__c,FS_Fellow__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c IN: salesOrderIds];

        for(OrderApi__Sales_Order_Line__c relatedSalesOrderLine: salesOrderLines){
            if(relatedSalesOrderLine.FS_Fellow__c != NULL){
                fellowIds.add(relatedSalesOrderLine.FS_Fellow__c);
            }
        }

        FS_FellowsUtil.fellowPledgeAmountCalculations(fellowIds); 
    }
}