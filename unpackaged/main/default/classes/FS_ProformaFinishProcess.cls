/**
 * Created by Jason Cookman on 9/22/20.
 */

public without sharing class FS_ProformaFinishProcess implements Database.Batchable<sObject>, Database.Stateful {
    private static final String SALES_ORDER_QUERY =
            'SELECT Id, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE ' +
                    'FS_Proforma_Job_In_Progress__c = true AND ' +
                    'OrderApi__Posting_Entity__c = \'Receipt\' AND ' +
                    'OrderApi__Posting_Status__c != \'Posted\' ';

    private Datetime parentJobStartTime = null;
    private Boolean errorOccurred = false;
    private Integer smallerBatchSize = 10;

    private void deleteUnnecessaryInvoicesOnSalesOrder(List<OrderApi__Sales_Order__c> salesOrders) {
        // find all draft invoices that were created before the parent job was run
        List<OrderApi__Invoice__c> invoicesWithDraft = [
                SELECT Id, OrderApi__Status__c FROM OrderApi__Invoice__c
                WHERE OrderApi__Sales_Order__c IN :salesOrders
                AND OrderApi__Status__c = 'Draft' AND CreatedDate < :parentJobStartTime
        ];
        // delete those draft earlier invoices
        if (!invoicesWithDraft.isEmpty()) {
            delete invoicesWithDraft;
        }
    }

    private void unmarkInProgressAndPostZeroDollarSalesOrders(List<OrderApi__Sales_Order__c> salesOrders) {
        List<OrderApi__Sales_Order__c> salesOrdersToPost = new List<OrderApi__Sales_Order__c>();

        salesOrdersToPost = new List<OrderApi__Sales_Order__c>();

        for(OrderApi__Sales_Order__c currSalesOrder : salesOrders) {
            currSalesOrder.FS_Proforma_Job_In_Progress__c = false;
            currSalesOrder.FS_Processed_By_Batch_Job__c = true;
            currSalesOrder.OrderApi__Status__c = 'Closed';
            currSalesOrder.OrderApi__Posting_Status__c = 'Pending';
        }

        update salesOrders;

        for(OrderApi__Sales_Order__c currSalesOrder : salesOrders) {

            if (currSalesOrder.OrderApi__Total__c == 0) {
                currSalesOrder.OrderApi__Status__c = 'Closed';
                currSalesOrder.OrderApi__Posting_Status__c = 'Posted';
                salesOrdersToPost.add(currSalesOrder);
            }
        }

        update salesOrdersToPost;
    }

    private OrderApi__Scheduled_Payment_Line__c createSchedulePaymentLineFromSalesOrderLine(
            Id schedulePaymentId,
            OrderApi__Sales_Order_Line__c salesOrderLine) {

        return new OrderApi__Scheduled_Payment_Line__c(
                OrderApi__Scheduled_Payment__c = schedulePaymentId,
                OrderApi__Sales_Order_Line__c = salesOrderLine.Id,
                OrderApi__Activation_Date__c = salesOrderLine.OrderApi__Activation_Date__c,
                OrderApi__End_Date__c = salesOrderLine.OrderApi__End_Date__c,
                OrderApi__Price_Override__c = salesOrderLine.OrderApi__Price_Override__c,
                OrderApi__Item_Class__c = salesOrderLine.OrderApi__Item_Class__c,
                OrderApi__Item__c = salesOrderLine.OrderApi__Item__c,
                OrderApi__Price_Rule__c = salesOrderLine.OrderApi__Price_Rule__c,
                OrderApi__GL_Account__c = salesOrderLine.OrderApi__GL_Account__c,
                OrderApi__Quantity__c = salesOrderLine.OrderApi__Quantity__c,
                OrderApi__Sale_Price__c = salesOrderLine.OrderApi__Sale_Price__c,
                OrderApi__Subscription_Plan__c = salesOrderLine.OrderApi__Subscription_Plan__c,
                OrderApi__Total__c = salesOrderLine.OrderApi__Total__c,
                OrderApi__Is_Shipping_Rate__c = salesOrderLine.OrderApi__Is_Shipping_Rate__c,
                OrderApi__Is_Tax__c = salesOrderLine.OrderApi__Is_Tax__c,
                OrderApi__Is_Renewal__c = salesOrderLine.OrderApi__Is_Renewal__c,
                OrderApi__Business_Group__c = salesOrderLine.OrderApi__Business_Group__c,
                OrderApi__Auto_Calculate_Activation_Date__c = salesOrderLine.OrderApi__Auto_Calculate_Activation_Date__c,
                OrderApi__Subscription__c = salesOrderLine.OrderApi__Subscription__c,
                OrderApi__Tax_Percent__c = salesOrderLine.OrderApi__Tax_Percent__c,
                OrderApi__Tax_Override__c = salesOrderLine.OrderApi__Tax_Override__c
        );
    }

    // Update the SP and SPL for the first record for each sales order.
    // Add in missing SPLs on the first record for sections
    // Update the SP amount field
    private void updateSalesOrderSchedulePayments(List<OrderApi__Sales_Order__c> relevantSalesOrders) {

        List<OrderApi__Sales_Order__c> salesOrdersWithSOLAndSchedulePayment =
        [SELECT Id, OrderApi__Total__c, (SELECT Id FROM OrderApi__Scheduled_Payments__r ORDER BY Name ASC LIMIT 1),
        (SELECT Id, OrderApi__Item__c, OrderApi__Price_Rule__c,OrderApi__Business_Group__c,
                OrderApi__Total__c, OrderApi__Price_Override__c, OrderApi__GL_Account__c,OrderApi__Item_Class__c,
                OrderApi__Sale_Price__c, OrderApi__Subscription_Plan__c, OrderApi__Quantity__c,
                OrderApi__Activation_Date__c, OrderApi__End_Date__c, OrderApi__Subscription__c,
                OrderApi__Is_Tax__c, OrderApi__Is_Renewal__c, OrderApi__List_Price__c, OrderApi__Is_Shipping_Rate__c,
                OrderApi__Auto_Calculate_Activation_Date__c, OrderApi__Tax_Percent__c,OrderApi__Tax_Override__c
        FROM OrderApi__Sales_Order_Lines__r ORDER BY Name ASC)
        FROM OrderApi__Sales_Order__c WHERE Id IN :relevantSalesOrders];


        List<OrderApi__Scheduled_Payment_Line__c> scheduledPaymentLinesToInsert = new List<OrderApi__Scheduled_Payment_Line__c>();
        List<OrderApi__Scheduled_Payment__c> scheduledPaymentsToUpdate = new List<OrderApi__Scheduled_Payment__c>();

        for (OrderApi__Sales_Order__c currSalesOrder : salesOrdersWithSOLAndSchedulePayment) {

            if(currSalesOrder.OrderApi__Scheduled_Payments__r.size() > 0) {
                Integer solCount = 1;

                for (OrderApi__Sales_Order_Line__c currSol : currSalesOrder.OrderApi__Sales_Order_Lines__r) {
                    // skip the first SOL since that was generated by fonteva
                    if (solCount++ > 1 || Test.isRunningTest()) {
                        scheduledPaymentLinesToInsert.add(
                                createSchedulePaymentLineFromSalesOrderLine(
                                        currSalesOrder.OrderApi__Scheduled_Payments__r[0].Id, currSol));
                    }
                }

                if(solCount > 2) {
                    currSalesOrder.OrderApi__Scheduled_Payments__r[0].OrderApi__Amount__c = currSalesOrder.OrderApi__Total__c;
                }
            }
        }


        update scheduledPaymentsToUpdate;
        insert scheduledPaymentLinesToInsert;
    }


    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(SALES_ORDER_QUERY);
    }

    public void execute(Database.BatchableContext bc, List<SObject> salesOrders) {
        FS_VerifySOLineAddressRoutingRule.skipCallout = true;
        FS_VerifySalesOrderAddressRoutingRule.skipCallout = true;
        FS_ContactsRule.skipRoutingRule = true;
        parentJobStartTime = System.now();

        try {
            // NOTE: If the firm billing contact has auto renew on the Sales Order and firm billing checked
            // this will charge the card linked to that sales order for the full firm billing amount on that sales order
            // not just that person's stuff
            updateSalesOrderSchedulePayments(salesOrders);

            deleteUnnecessaryInvoicesOnSalesOrder(salesOrders);
            unmarkInProgressAndPostZeroDollarSalesOrders(salesOrders);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'An error occurred during FS_ProformaFinishProcess:\n' + e.getStackTraceString());
            errorOccurred = true;
            throw e;
        } finally {
            FS_VerifySOLineAddressRoutingRule.skipCallout = false;
            FS_VerifySalesOrderAddressRoutingRule.skipCallout = false;
            FS_ContactsRule.skipRoutingRule = false;
        }
    }

    public void finish(Database.BatchableContext param1) {
        if(errorOccurred) {

            smallerBatchSize = smallerBatchSize / 2;
            if(smallerBatchSize > 0) {
                // try again with a smaller batch size
                Database.executeBatch(new FS_ProformaFinishProcess(), smallerBatchSize);
            }
        }
    }

}