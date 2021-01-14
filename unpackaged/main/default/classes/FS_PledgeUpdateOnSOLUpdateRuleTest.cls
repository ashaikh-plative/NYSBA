/**
 * Created by cloudwebsolutions on 05-02-2020.
 * Description : This is testclass for all fellow scenarios
 */

@IsTest
private class FS_PledgeUpdateOnSOLUpdateRuleTest {

    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule solUpdate = new Framework.RoutingRule();
        solUpdate.apexClass = FS_PledgeUpdateOnSOLUpdateRule.class.getName();
        solUpdate.namespace = '';
        solUpdate.isEnabled = true;
        solUpdate.sObjectName = 'OrderApi__Sales_Order_Line__c';
        solUpdate.executionOrder = 30;
        rules.add(solUpdate);
        Framework.RoutingRule soUpdate = new Framework.RoutingRule();
        soUpdate.apexClass = FS_SalesOrderToFellowUpdateRule.class.getName();
        soUpdate.namespace = '';
        soUpdate.isEnabled = true;
        soUpdate.sObjectName = 'OrderApi__Sales_Order__c';
        soUpdate.executionOrder = 30;
        rules.add(soUpdate);
        Framework.RoutingRule receiptUpdate = new Framework.RoutingRule();
        receiptUpdate.apexClass = FS_ReceiptToPledgeAmountUpdateRule.class.getName();
        receiptUpdate.namespace = '';
        receiptUpdate.isEnabled = true;
        receiptUpdate.sObjectName = 'OrderApi__Receipt__c';
        receiptUpdate.executionOrder = 30;
        rules.add(receiptUpdate);
        Framework.RoutingRule fellowUpdate = new Framework.RoutingRule();
        fellowUpdate.apexClass = FS_FellowUpdatePledgeBalanceRule.class.getName();
        fellowUpdate.namespace = '';
        fellowUpdate.isEnabled = true;
        fellowUpdate.sObjectName = 'FS_Fellow__c';
        fellowUpdate.executionOrder = 30;
        Framework.Config.push(rules);

        Account account = FS_TestUtils.createAccount('Test');
        insert account;

        Contact contact = FS_TestUtils.createContact('Test', 'test@gmail.com');
        contact.accountId = account.id;
        insert contact;

        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.id, account.id, 'Receipt', 'Open');
        insert salesOrder;

        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Test');
        insert itemClass;

        OrderApi__Item__c item = FS_TestUtils.createItem('test', itemClass.id);
        insert item;

        OrderApi__Sales_Order_Line__c salesOrderLine = FS_TestUtils.createSalesOrderLine(item.id, salesOrder.id, contact.id, account.id);
        insert salesOrderLine;

        List<OrderApi__Receipt__c> receipts = new List<OrderApi__Receipt__c>();
        OrderApi__Receipt__c isPostedReceipt = new OrderApi__Receipt__c();
        isPostedReceipt.OrderApi__Sales_Order__c = salesOrder.id;
        isPostedReceipt.OrderApi__Posted_Date__c = System.today();
        isPostedReceipt.OrderApi__Is_Posted__c = true;
        isPostedReceipt.OrderApi__Is_Refund__c = false;
        receipts.add(isPostedReceipt);
        OrderApi__Receipt__c refundReceipt = new OrderApi__Receipt__c();
        refundReceipt.OrderApi__Sales_Order__c = salesOrder.id;
        refundReceipt.OrderApi__Posted_Date__c = System.today();
        refundReceipt.OrderApi__Is_Posted__c = true;
        refundReceipt.OrderApi__Is_Refund__c = true;
        receipts.add(refundReceipt);
        insert receipts;

        List<OrderApi__Receipt_Line__c> receiptLines = new List<OrderApi__Receipt_Line__c>();
        OrderApi__Receipt_Line__c isPostedreceiptLine = new OrderApi__Receipt_Line__c();
        isPostedreceiptLine.OrderApi__Total__c = 100;
        isPostedreceiptLine.OrderApi__Receipt__c = receipts[0].id;
        receiptLines.add(isPostedreceiptLine);
        OrderApi__Receipt_Line__c isRefundreceiptLine = new OrderApi__Receipt_Line__c();
        isRefundreceiptLine.OrderApi__Total__c = 100;
        isRefundreceiptLine.OrderApi__Receipt__c = receipts[1].id;
        receiptLines.add(isRefundreceiptLine);
        insert receiptLines;

        FS_Fellow__c fellow = new FS_Fellow__c();
        fellow.FS_Pledge_Amount__c = 1000;
        fellow.FS_Paid_Life__c = false;
        insert fellow;
    }

        @isTest
        static void firstScenarioTest(){

        OrderApi__Sales_Order__c salesOrder = [SELECT OrderApi__Status__c,OrderApi__Posting_Status__c,OrderApi__Posted_Date__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Status__c = 'Open'];
        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        salesOrder.OrderApi__Posted_Date__c = Date.newInstance(2020, 01, 01);
        update salesOrder;
        OrderApi__Sales_Order_Line__c salesOrderLine = [SELECT FS_Fellow__c FROM OrderApi__Sales_Order_Line__c];
        List<FS_Fellow__c> fellows = [SELECT Id,FS_Pledge_Amount__c,FS_Paid_Life__c FROM FS_Fellow__c WHERE FS_Pledge_Amount__c = 1000 LIMIT 1];
        salesOrderLine.FS_Fellow__c = fellows[0].id;
        fellows[0].FS_Paid_Life__c = true;
        update salesOrderLine;
        Map<Id,FS_Fellow__c> fellowMap = new Map<Id,FS_Fellow__c>([SELECT Id,FS_Pledge_Amount__c,FS_Paid_Life__c FROM FS_Fellow__c]);


        Test.startTest();
        FS_FellowUpdatePledgeBalanceRule fellowRule = new FS_FellowUpdatePledgeBalanceRule(fellows);
        FS_FellowUpdatePledgeBalanceRule.Constructor fscc = new FS_FellowUpdatePledgeBalanceRule.Constructor();
        fscc.construct(fellows);
        fellowRule.beforeInsert(); 
        fellowRule.beforeUpdate(fellowMap);
        Test.stopTest();
    }
}