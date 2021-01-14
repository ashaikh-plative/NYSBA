/**
 * Created by archanapatel on 10/21/19.
 */

@IsTest
public class FS_DeleteProformaSalesOrderBatchTest {

    @IsTest
    private static void testDeleteProformaSalesOrders() {
        Account account = new Account(Name = 'Test');
        insert account;
        Contact contact1 = new Contact(FirstName = 'Test1', LastName = 'Test1', AccountId = account.Id);
        insert contact1;

        Contact contact2 = new Contact(FirstName = 'Test2', LastName = 'Test2', AccountId = account.Id);
        insert contact2;

        Contact contact3 = new Contact(FirstName = 'Test3', LastName = 'Test3', AccountId = account.Id);
        insert contact3;

        Contact contact4 = new Contact(FirstName = 'Test4', LastName = 'Test4', AccountId = account.Id);
        insert contact4;

        OrderApi__Item_Class__c oItemClass = new OrderApi__Item_Class__c(Name = 'Membership');
        insert oItemClass;

        OrderApi__Item__c item1 = new OrderApi__Item__c(Name = 'TestItem1', OrderApi__Item_Class__c = oItemClass.Id,
                OrderApi__Price__c = 50, OrderApi__Is_Active__c = true);
        insert item1;

        OrderApi__Item__c item2 = new OrderApi__Item__c(Name = 'TestItem2', OrderApi__Item_Class__c = oItemClass.Id,
                OrderApi__Price__c = 50, OrderApi__Is_Active__c = true);
        insert item2;

        OrderApi__Item__c item3 = new OrderApi__Item__c(Name = 'TestItem3', OrderApi__Item_Class__c = oItemClass.Id,
                OrderApi__Price__c = 50, OrderApi__Is_Active__c = true);
        insert item3;
        OrderApi__Item__c item4 = new OrderApi__Item__c(Name = 'TestItem4', OrderApi__Item_Class__c = oItemClass.Id,
                OrderApi__Price__c = 50, OrderApi__Is_Active__c = true);
        insert item4;

        DateTime dt = DateTime.now();
        String monthName = dt.format('MMMMM');
        item1.FS_Proforma_Deletion_Month__c = monthName;
        item1.FS_Proforma_Deletion_Day__c = System.today().day();

        item4.FS_Proforma_Deletion_Month__c = monthName;
        item4.FS_Proforma_Deletion_Day__c = System.today().day();

        item2.FS_Proforma_Deletion_Month__c = monthName;
        //System.debug('date.....'+Integer.valueOf(dt.addDays(5)));
        item2.FS_Proforma_Deletion_Day__c = 6;

        update item1;
        update item2;

        //valid scenarios where item have today's date.
        OrderApi__Sales_Order__c salesOrder1 = new OrderApi__Sales_Order__c(OrderApi__Account__c = account.Id,
                OrderApi__Contact__c = contact1.Id, OrderApi__Posting_Entity__c = 'Receipt', OrderApi__Entity__c = 'Contact');
        insert salesOrder1;


        OrderApi__Sales_Order_Line__c salesOrderLine1 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder1.Id,
                OrderApi__Item__c = item1.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine1;

        salesOrder1.OrderApi__Status__c = 'Closed';
        salesOrder1.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder1;

// salesorder with date doesn't match with today's date
        OrderApi__Sales_Order__c salesOrder2 = new OrderApi__Sales_Order__c(OrderApi__Account__c = account.Id,
                OrderApi__Contact__c = contact2.Id, OrderApi__Posting_Entity__c = 'Receipt', OrderApi__Entity__c = 'Contact');
        insert salesOrder2;


        OrderApi__Sales_Order_Line__c salesOrderLine2 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder2.Id,
                OrderApi__Item__c = item2.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine2;

        salesOrder2.OrderApi__Status__c = 'Closed';
        salesOrder2.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder2;

// salesorder with closed and posted with different entity
        OrderApi__Sales_Order__c salesOrder3 = new OrderApi__Sales_Order__c(OrderApi__Account__c = account.Id,
                OrderApi__Contact__c = contact3.Id, OrderApi__Posting_Entity__c = 'Invoice', OrderApi__Entity__c = 'Contact');
        insert salesOrder3;

        OrderApi__Sales_Order_Line__c salesOrderLine3 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder3.Id,
                OrderApi__Item__c = item1.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine3;

        salesOrder3.OrderApi__Status__c = 'Closed';
        salesOrder3.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder3;
        salesOrder3.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder3;

//salesorder with two salesorder lines 1. with date on item 2. without matching date on item
        OrderApi__Sales_Order__c salesOrder4 = new OrderApi__Sales_Order__c(OrderApi__Account__c = account.Id,
                OrderApi__Contact__c = contact3.Id, OrderApi__Posting_Entity__c = 'Receipt', OrderApi__Entity__c = 'Contact');
        insert salesOrder4;

        OrderApi__Sales_Order_Line__c salesOrderLine4 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder4.Id,
                OrderApi__Item__c = item1.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine4;


        OrderApi__Sales_Order_Line__c salesOrderLine5 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder4.Id,
                OrderApi__Item__c = item2.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine5;

        salesOrder4.OrderApi__Status__c = 'Closed';
        salesOrder4.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder4;

        //salesorder with closed & pending status but salesorder line item doesn't have today's date.
        OrderApi__Sales_Order__c salesOrder5 = new OrderApi__Sales_Order__c(OrderApi__Account__c = account.Id,
                OrderApi__Contact__c = contact3.Id, OrderApi__Posting_Entity__c = 'Invoice', OrderApi__Entity__c = 'Contact');
        insert salesOrder5;

        OrderApi__Sales_Order_Line__c salesOrderLine6 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder5.Id,
                OrderApi__Item__c = item3.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine6;

        salesOrder5.OrderApi__Status__c = 'Closed';
        salesOrder5.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder5;
        //SalesOrders with receipts

        OrderApi__Sales_Order__c salesOrder6 = new OrderApi__Sales_Order__c(OrderApi__Account__c = account.Id,
                OrderApi__Contact__c = contact4.Id, OrderApi__Posting_Entity__c = 'Receipt', OrderApi__Entity__c = 'Contact');
        insert salesOrder6;


        OrderApi__Sales_Order_Line__c salesOrderLine7 = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder6.Id,
                OrderApi__Item__c = item4.Id, OrderApi__Total__c = 50.00, OrderApi__Is_Renewal__c = true);
        insert salesOrderLine7;

        salesOrder6.OrderApi__Status__c = 'Closed';
        salesOrder6.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder6;

        //Receipt
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Contact__c = contact4.Id;
        receipt.OrderApi__Account__c = account.Id;
        receipt.OrderApi__Sales_Order__c = salesOrder6.Id;
        insert receipt;


        String CRON_EXP = '0 0 0 24 10 ? 2049';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new FS_DeleteProformaSalesOrderBatch());
        Database.executeBatch(new FS_DeleteProformaSalesOrderBatch());
        //Database.executeBatch(new FS_DeleteOldSalesOrderBatch());
        Test.stopTest();
        List<OrderApi__Sales_Order__c> so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder1.Id];
        System.assertEquals(0, so.size(), 'sales order not deleted through batch job');
        List<OrderApi__Sales_Order__c> so2 = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder2.Id];
        System.assertEquals(0, so2.size(), 'sales order not deleted through batch job');
        List<OrderApi__Sales_Order__c> so3 = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder3.Id];
        System.assertEquals(1, so3.size(), 'sales order not deleted through batch job');
        List<OrderApi__Sales_Order__c> so4 = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder4.Id];
        System.assertEquals(0, so4.size(), 'sales order not deleted through batch job');
        List<OrderApi__Sales_Order__c> so5 = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder5.Id];
        System.assertEquals(1, so5.size(), 'sales order not deleted through batch job');
        List<OrderApi__Sales_Order__c> so6 = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder6.Id];
        System.assertEquals(1, so6.size(), 'sales order not deleted through batch job');
    }
}