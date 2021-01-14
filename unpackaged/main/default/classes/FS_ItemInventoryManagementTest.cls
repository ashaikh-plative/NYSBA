/**
 * Created by Gopi on 08-11-2019.
 */
@isTest
private without sharing class  FS_ItemInventoryManagementTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule1 = new Framework.RoutingRule();
        routingRule1.apexClass = FS_ItemInventoryManagement.class.getName();
        routingRule1.namespace = '';
        routingRule1.isEnabled = TRUE;
        routingRule1.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule1.executionOrder = 50;
        rules.add(routingRule1);
        Framework.Config.push(rules);

        Account acc = new Account();
        acc.Name = 'Testin23asd12ga asdg';
        insert acc;
//Inserting Contact
        Contact con = FS_TestUtils.createContact('asdg2Test', 'testgz223asd@gmail.com');
        insert con;
    }

    static testMethod void inventoryTest() {
        test.startTest();
//Inserting Account
        Account acc = [SELECT Id FROM Account WHERE Name = 'Testin23asd12ga asdg'][0];

        Contact con = [SELECT Id FROM Contact WHERE LastName = 'asdg2Test'][0];
//Inserting salesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(con.Id, acc.Id, 'Receipt', 'open');
        insert salesOrder;
//Inserting Itemclass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Programs');
        insert itemClass;
//Inserting Item
        OrderApi__Item__c item = FS_TestUtils.createItem('CAP Program Item', itemClass.Id);
        item.FS_Track_Inventory__c = TRUE;
        insert item;
        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine);
        OrderApi__Sales_Order_Line__c salesOrderLine2 = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Quantity__c = 9,
                OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine2);

        insert solList;
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        salesOrder.OrderApi__Status__c = 'closed';
        update salesOrder;
        test.stopTest();
    }
}