/**
 * Created by daweima on 6/12/20.
 */

global without sharing class FS_InvoiceDateRoutingRule extends Framework.Domain{
    public FS_InvoiceDateRoutingRule(List<OrderApi__Invoice__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_InvoiceDateRoutingRule(sObjectList);
        }
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_InvoiceDateRoutingRule.class.getName(), 'beforeUpdate');
        setInvoiceDate((List<OrderApi__Invoice__c>) records, oldMap);
        Framework.Log.pop();
    }

    private static void setInvoiceDate(List<OrderApi__Invoice__c> records, Map<Id, SObject> oldMap) {
        Map<Id,Id> scheduledPaymentIdToInvoiceIds = new Map<Id,Id>();
        Map<Id,OrderApi__Invoice__c> invoiceMap = new Map<Id,OrderApi__Invoice__c>();
        for (OrderApi__Invoice__c currInvoice : records) {
            OrderApi__Invoice__c oldInvoice = oldMap == null ? null : (OrderApi__Invoice__c)oldMap.get(currInvoice.Id);
            if ((currInvoice.OrderApi__Paid_Date__c == null ||
                    (currInvoice.OrderApi__Paid_Date__c != null && oldInvoice != null && oldInvoice.OrderApi__Paid_Date__c == null &&
                    currInvoice.OrderApi__Paid_Date__c != System.today()))
                    && currInvoice.OrderApi__Status__c == 'Paid' && currInvoice.OrderApi__Scheduled_Payment__c != null){
                scheduledPaymentIdToInvoiceIds.put(currInvoice.OrderApi__Scheduled_Payment__c,currInvoice.Id);
                invoiceMap.put(currInvoice.Id, currInvoice);
            }
        }

        // update records
        for (OrderApi__Invoice__c curInvoice : records) {
            if (invoiceMap.containsKey(curInvoice.Id)) {
                if (curInvoice.OrderApi__Paid_Date__c == null || curInvoice.OrderApi__Paid_Date__c < System.today()) {
                    curInvoice.OrderApi__Paid_Date__c = System.today();
                }
            }
        }

        // If there's record that match the above condition
        if (!invoiceMap.isEmpty()) {
            List<Id> relatedReceiptsId = new List<Id>();
            List<OrderApi__Receipt_Line__c> relatedReceiptLines = [
                    SELECT Id, OrderApi__Receipt__r.Id
                    FROM OrderApi__Receipt_Line__c WHERE OrderApi__Invoice__c IN :invoiceMap.keySet() AND CreatedDate = TODAY];

            for (OrderApi__Receipt_Line__c currReceiptLine : relatedReceiptLines) {
                relatedReceiptsId.add(currReceiptLine.OrderApi__Receipt__r.Id);
            }

            // Select receipt object, transaction, and transaction line, add create date to make sure it's not past receipt
            List<OrderApi__Receipt__c> relatedReceipts = [
                    SELECT Id, OrderApi__Date__c, (SELECT Id, OrderApi__Date__c, CreatedDate FROM OrderApi__Transactions__r WHERE CreatedDate = TODAY)
                    FROM OrderApi__Receipt__c
                    WHERE Id IN :relatedReceiptsId AND CreatedDate = TODAY
            ];

            List<OrderApi__Transaction__c> transactionsToUpdate = new List<OrderApi__Transaction__c>();
            for (OrderApi__Receipt__c curReceipt : relatedReceipts) {
                // Set transaction date
                for (OrderApi__Transaction__c curTransaction : curReceipt.OrderApi__Transactions__r) {
                    if (curTransaction.OrderApi__Date__c < System.today()) {
                        curTransaction.OrderApi__Date__c = curReceipt.OrderApi__Date__c;
                        transactionsToUpdate.add(curTransaction);
                    }
                }
            }

            if (!transactionsToUpdate.isEmpty()) {
                update transactionsToUpdate;
            }
        }
    }
}