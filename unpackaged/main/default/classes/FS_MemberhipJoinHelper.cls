/**
 * @author          cubiascaceres
 * @created_date:   2020.06.22
 */
public without sharing class FS_MemberhipJoinHelper {

    @TestVisible
    private static final String INVOICE_STATUS_DRAFT = 'Draft';

    public static void reopenSalesOrder(OrderApi__Sales_Order__c salesOrder) {
        salesOrder.OrderApi__Status__c = 'Open';
        salesOrder.OrderApi__Posting_Status__c = '';
        update salesOrder;

        List<OrderApi__Invoice__c> invoiceList = [SELECT Id 
                                                  FROM OrderApi__Invoice__c 
                                                  WHERE OrderApi__Status__c = :INVOICE_STATUS_DRAFT
                                                  AND OrderApi__Sales_Order__c = :salesOrder.Id];
        if (!invoiceList.isEmpty()) {
            delete invoiceList;
        }
    }
}