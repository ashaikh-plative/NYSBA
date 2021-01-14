/**
 * Created by cloudwebsolutions on 13-01-2020.
 */

@IsTest
private class FS_AutoPopulateOrderDetailsTest {

    private static final Integer QUANTITY = 3;

    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule populateOrderFields = new Framework.RoutingRule();
        populateOrderFields.apexClass = FS_AutoPopulateOrderDetails.class.getName();
        populateOrderFields.namespace = '';
        populateOrderFields.isEnabled = true;
        populateOrderFields.sObjectName = 'FS_Order_Fulfillment__c';
        populateOrderFields.executionOrder = 30;
        rules.add(populateOrderFields);
        Framework.Config.push(rules);

        Account account = FS_TestUtils.createAccount('TestAadasd21sccount123asd');
        insert account;

        //Insert contact
        Contact contact = FS_TestUtils.createContact('TestConsdqfq23asdtact', 'te123stdasd12@gmail.com');
        insert contact;
    }

    @IsTest
    static void testBehavior() {

        //Insert account
        Account account = [SELECT Id FROM Account WHERE Name='TestAadasd21sccount123asd'][0];


        //Insert contact
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'TestConsdqfq23asdtact'][0];

        //Insert SalesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.id, account.id, 'Receipt', 'Open');
        insert salesOrder;

        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Test');
        insert itemClass;

        //Insert Item
        OrderApi__Item__c item = FS_TestUtils.createItem('TestItem', itemClass.id);
        insert item;

        //Insert SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = FS_TestUtils.createSalesOrderLine(item.id, salesOrder.id, contact.id, account.id);
        insert salesOrderLine;
        salesOrder.OrderApi__Status__c = 'posted';
        update salesOrder;

        //Insert OrderTracking
        List<FS_Order_Tracking__c> orderTrackings = new List<FS_Order_Tracking__c>();
        FS_Order_Tracking__c orderTracking = new FS_Order_Tracking__c();
        orderTracking.FS_Quantity__c = String.valueOf(QUANTITY);
        orderTracking.FS_Sales_Order_Line__c = salesOrderLine.id;
        orderTracking.FS_Sales_Order__c = salesOrder.id;
        orderTrackings.add(orderTracking);
        insert orderTrackings;

        //Insert OrderFulfillment
        List<FS_Order_Fulfillment__c> fulfillments = new List<FS_Order_Fulfillment__c>();
        FS_Order_Fulfillment__c orderFulfillment = new FS_Order_Fulfillment__c();
        orderFulfillment.FS_Order_Tracking__c = orderTrackings[0].id;
        orderFulfillment.FS_Quantity_Shipped__c = QUANTITY;
        orderFulfillment.FS_Order__c = salesOrder.id;
        orderFulfillment.FS_Order_Line__c = salesOrderLine.id;
        fulfillments.add(orderFulfillment);
        insert fulfillments;

        Test.startTest();
        FS_AutoPopulateOrderDetails programGoalsRoutingRule = new FS_AutoPopulateOrderDetails(fulfillments);
        FS_AutoPopulateOrderDetails.Constructor fscc = new FS_AutoPopulateOrderDetails.Constructor();
        fscc.construct(fulfillments);
        programGoalsRoutingRule.beforeInsert();
        Test.stopTest();
    }
}