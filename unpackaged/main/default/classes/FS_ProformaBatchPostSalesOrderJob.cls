/**
 * Created by daweima on 6/22/20.
 */

public without sharing class FS_ProformaBatchPostSalesOrderJob implements System.Schedulable ,Database.Stateful {
    List<OrderApi__Sales_Order__c> salesOrderToDeleteInvoice = new List<OrderApi__Sales_Order__c>();
    Set<Id> salesOrderIdToPost = new Set<Id>();
    Datetime executeTime = null;
    String query;

    public FS_ProformaBatchPostSalesOrderJob(Set<Id> salesOrderIdToPost, List<OrderApi__Sales_Order__c> salesOrderToDeleteInvoice, Datetime executeTime){
        this.salesOrderToDeleteInvoice = salesOrderToDeleteInvoice;
        this.executeTime = executeTime;
        this.salesOrderIdToPost = salesOrderIdToPost;
    }

    public void execute(SchedulableContext param1) {
        Set<Id> soIdNeedDeleteInvoice = new Set<Id>();
        for (OrderApi__Sales_Order__c currOrder : salesOrderToDeleteInvoice) {
            soIdNeedDeleteInvoice.add(currOrder.Id);
        }

        List<OrderApi__Invoice__c> invoicesWithDraft = [
                SELECT Id, OrderApi__Status__c FROM OrderApi__Invoice__c
                WHERE OrderApi__Sales_Order__c IN :soIdNeedDeleteInvoice
                AND OrderApi__Status__c = 'Draft' AND CreatedDate < :executeTime
        ];

        if (!invoicesWithDraft.isEmpty()) {
            delete invoicesWithDraft;
        }

        List<OrderApi__Sales_Order__c> relatedSalesOrders = [SELECT Id, OrderApi__Posting_Status__c,OrderApi__Total__c FROM
                OrderApi__Sales_Order__c WHERE Id IN :salesOrderIdToPost AND OrderApi__Total__c = 0];
          for (OrderApi__Sales_Order__c currSO : relatedSalesOrders) {
                  currSO.OrderApi__Posting_Status__c = 'Posted';
          }
          if (!relatedSalesOrders.isEmpty()){
              update relatedSalesOrders;
          }
    }
}