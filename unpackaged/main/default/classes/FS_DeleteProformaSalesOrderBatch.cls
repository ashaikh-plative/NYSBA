/**
 * Created by archanapatel on 10/21/19.
 */


global class FS_DeleteProformaSalesOrderBatch implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,(SELECT Id FROM OrderApi__Receipts__r LIMIT 1)FROM OrderApi__Sales_Order__c WHERE ' +
                       'OrderApi__Status__c = \'Closed\' AND OrderApi__Posting_Status__c = \'Pending\' AND OrderApi__Posting_Entity__c = \'Receipt\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<OrderApi__Sales_Order__c> salesOrders) {
        Integer days;
        String month ;
        List<Id> salesOrderToDelete = new List<Id>();
        Map<Id, Integer> soIdToReceiptsSizeMap = new Map<Id, Integer>();

        List<OrderApi__Sales_Order_Line__c> salesOrderLines = [SELECT Id, OrderApi__Is_Subscription__c,OrderApi__Item__r.FS_Proforma_Deletion_Day__c,
                                                                OrderApi__Sales_Order__c,OrderApi__Item__r.FS_Proforma_Deletion_Month__c
                                                                FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c IN: salesOrders];

        for(OrderApi__Sales_Order__c salesOrder:salesOrders){
            soIdToReceiptsSizeMap.put(salesOrder.Id,salesOrder.OrderApi__Receipts__r.size());
        }
        for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : salesOrderLines) {
            // checks if date & month fields on item is not blank
            if (tempSalesOrderLine.OrderApi__Item__r.FS_Proforma_Deletion_Month__c != null && tempSalesOrderLine.OrderApi__Item__r.FS_Proforma_Deletion_Day__c != null &&
                    soIdToReceiptsSizeMap.get(tempSalesOrderLine.OrderApi__Sales_Order__c) != null && soIdToReceiptsSizeMap.get(tempSalesOrderLine.OrderApi__Sales_Order__c) == 0) {
                Datetime dt = Datetime.now();
                // coverting current month into TEXT format- full month name (for example 2 as February , 5 as May)
                String monthName = dt.format('MMMMM');
                // checks if item on salesorder line matches the date as today. ( month and days )
                if (tempSalesOrderLine.OrderApi__Item__r.FS_Proforma_Deletion_Month__c == monthName && tempSalesOrderLine.OrderApi__Item__r.FS_Proforma_Deletion_Day__c == System.today().day()) {
                    if (!salesOrderToDelete.contains(tempSalesOrderLine.OrderApi__Sales_Order__c)) {
                        salesOrderToDelete.add(tempSalesOrderLine.OrderApi__Sales_Order__c);
                    }
                }
            }
        }
        if (!salesOrderToDelete.isEmpty()) {
            Database.delete(salesOrderToDelete);
        }
    }

    global void finish(Database.BatchableContext bc) {

    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new FS_DeleteProformaSalesOrderBatch());
    }

}