/**
 * @author          cubiascaceres
 * @created_date:   2020.06.23
 */
@IsTest
public class FS_MemberhipJoinHelperTest {

    @IsTest
    static void reopenSalesOrderTest() {
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        insert salesOrder;

        // create an invoice for the recently created sales order
        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c(
            OrderApi__Status__c = FS_MemberhipJoinHelper.INVOICE_STATUS_DRAFT,
            OrderApi__Sales_Order__c = salesOrder.Id
        );
        insert invoice;

        FS_MemberhipJoinHelper.reopenSalesOrder(salesOrder);

        List<OrderApi__Invoice__c> invoiceList = [SELECT Id FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c = :salesOrder.Id];
        System.assert(invoiceList.isEmpty());
    }
}