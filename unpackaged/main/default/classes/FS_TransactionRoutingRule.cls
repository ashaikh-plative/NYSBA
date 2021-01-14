/**
 * Created by daweima on 6/2/20.
 */

global without sharing class FS_TransactionRoutingRule extends Framework.Domain {
    public FS_TransactionRoutingRule(List<OrderApi__Transaction__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_TransactionRoutingRule(sObjectList);
        }
    }
    public override void afterInsert() {
        Framework.Log.push(FS_TransactionRoutingRule.class.getName(), 'afterInsert');
        setDateAfterInsert(records, false);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_TransactionRoutingRule.class.getName(), 'beforeUpdate');
        setDateAfterInsert(records, true);
        Framework.Log.pop();
    }

    private void setDateAfterInsert(List<OrderApi__Transaction__c> records, Boolean beforeUpdate) {
        Set<Id> relativeReceiptId = new Set<Id>();
        Map<Id, OrderApi__Transaction__c> transactionToUpdate = new Map<Id, OrderApi__Transaction__c>();
        Map<Id, Id> ReceiptEPaymentIdToTransactionId = new Map<Id, Id>();
        Map<Id, Id> EPaymentsEPaymentIdToTransactionId = new Map<Id, Id>();
        Map<Id, OrderApi__Transaction__c> transactionIdToObj = new Map<Id, OrderApi__Transaction__c>();
        Map<Id, OrderApi__Transaction__c> transactionByReceiptIds = new Map<Id, OrderApi__Transaction__c>();
        Map<Id, Date> transactionIdToDate = new Map<Id, Date>();

        for (OrderApi__Transaction__c currTransaction : records) {
            relativeReceiptId.add(currTransaction.OrderApi__Receipt__c);
            transactionIdToObj.put(currTransaction.Id, currTransaction);
            transactionByReceiptIds.put(currTransaction.OrderApi__Receipt__c,currTransaction);
        }
        for (OrderApi__Receipt__c currReceipt : [SELECT Id, OrderApi__EPayment__c FROM OrderApi__Receipt__c WHERE Id IN :relativeReceiptId]) {
            ReceiptEPaymentIdToTransactionId.put(currReceipt.OrderApi__EPayment__c, currReceipt.Id);
        }
        for (OrderApi__EPayment__c currPayment : [SELECT Id, OrderApi__Date__c, OrderApi__Transaction_Type__c,OrderApi__EPayment__c FROM OrderApi__EPayment__c WHERE Id IN :ReceiptEPaymentIdToTransactionId.keySet()]) {
            OrderApi__Transaction__c relatedTransaction = transactionByReceiptIds.get(ReceiptEPaymentIdToTransactionId.get(currPayment.Id));

            if (currPayment.OrderApi__Transaction_Type__c == 'Capture' &&
                    relatedTransaction.OrderApi__Date__c != currPayment.OrderApi__Date__c) {
                EPaymentsEPaymentIdToTransactionId.put(currPayment.OrderApi__EPayment__c, relatedTransaction.Id);
                // add date for future use
                transactionIdToDate.put(relatedTransaction.Id, currPayment.OrderApi__Date__c); 
            }
        }
        for (OrderApi__EPayment__c currPayment : [SELECT Id, OrderApi__Transaction_Type__c FROM OrderApi__EPayment__c WHERE Id IN :EPaymentsEPaymentIdToTransactionId.keySet()]) {
            if (currPayment.OrderApi__Transaction_Type__c == 'Authorization' || currPayment.OrderApi__Transaction_Type__c == '') {
                OrderApi__Transaction__c relatedTransaction = transactionIdToObj.get(EPaymentsEPaymentIdToTransactionId.get(currPayment.Id));
                transactionToUpdate.put(relatedTransaction.Id, new OrderApi__Transaction__c(Id = relatedTransaction.Id,OrderApi__Date__c = transactionIdToDate.get(relatedTransaction.Id)));
            }
        }

        if (beforeUpdate) {
            for (OrderApi__Transaction__c currTransaction : records) {
                if (transactionToUpdate.containsKey(currTransaction.Id)) {
                    OrderApi__Transaction__c updatedTransaction = transactionToUpdate.get(currTransaction.Id);
                    currTransaction.OrderApi__Date__c = updatedTransaction.OrderApi__Date__c;
                }
            }
        } else {
            if (!transactionToUpdate.isEmpty()) {
                update transactionToUpdate.values();
            }
        }
    }
}