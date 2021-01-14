/**
* Created by Gopi on 08-11-2019.
*/
@isTest
private without sharing class  FS_ItemInventoryRRuleonSOLineTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_ItemInventoryRRuleonSOLine.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = TRUE;
        routingRule.sObjectName = 'OrderApi__Sales_Order_Line__c';
        routingRule.executionOrder = 50;
        rules.add(routingRule);
        Framework.Config.push(rules);

        //Inserting account
        Account acc = FS_TestUtils.createAccount('TestAccount');
        insert acc;

        //Inserting Contact
        List<Contact> contacts = new List<Contact>();
        Contact con1 = FS_TestUtils.createContact('Test', 'test1@gmail.com');
        contacts.add(con1);
        Contact con2 = FS_TestUtils.createContact('Test', 'test2@gmail.com');
        contacts.add(con2);
        insert contacts;        
    }
    
    static testMethod void inventoryTest() {
        test.startTest();

        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Email = 'test1@gmail.com' LIMIT 1];

        //Inserting salesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.Id, account.Id, 'Receipt', 'open');
        insert salesOrder;
        //Inserting Itemclass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Programs');
        insert itemClass;
        //Inserting Item
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Item__c item1 = FS_TestUtils.createItem('CAP Program Item', itemClass.Id);
        item1.FS_Track_Inventory__c = TRUE;
        item1.FS_Items_in_Cart__c = 0;
        item1.FS_Items_in_Warehouse__c = 100;
        itemList.add(item1);
        OrderApi__Item__c item2 = FS_TestUtils.createItem('HAT Program Item', itemClass.Id);
        item2.FS_Track_Inventory__c = TRUE;
        item2.FS_Items_in_Cart__c = 0;
        item2.FS_Items_in_Warehouse__c = 100;
        itemList.add(item2);
        
        insert itemList;
        
        //Inserting Salesorder lines
        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLine1 = new OrderApi__Sales_Order_Line__c(
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Item__c = item1.Id,
            OrderApi__Quantity__c = 2, 
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine1);
        
        OrderApi__Sales_Order_Line__c salesOrderLine2 = new OrderApi__Sales_Order_Line__c(
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Item__c = item2.Id,
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Quantity__c = 2,
            OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine2);
        
        insert solList;
        //updating sales order line 
        salesOrderLine1.OrderApi__Quantity__c = 1;
        
        update salesOrderLine1;
        delete salesOrderLine2;
        List<OrderApi__Item__c> itemListUpdated = [SELECT Id,FS_Items_in_Cart__c FROM OrderApi__Item__c WHERE Id IN :itemList];
        Decimal itemsCart1 = itemListUpdated[0].FS_Items_in_Cart__c;
        Decimal itemsCart2 = itemListUpdated[1].FS_Items_in_Cart__c;
        System.assertEquals(1, itemsCart1);
        System.assertEquals(0, itemsCart2);
        test.stopTest();
    }
    
    
    static testMethod void saleorderLineItemChanged_ExpectOldAndNewItemCorrect(){
        test.startTest();

        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Email = 'test2@gmail.com' LIMIT 1];

        //Inserting salesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.Id, account.Id, 'Receipt', 'open');
        insert salesOrder;
        //Inserting Itemclass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Programms');
        insert itemClass;
        //Inserting Item
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Item__c item1 = FS_TestUtils.createItem('Mobile Program Item', itemClass.Id);
        item1.FS_Track_Inventory__c = TRUE;
        item1.FS_Items_in_Cart__c = 0;
        item1.FS_Items_in_Warehouse__c = 100;
        itemList.add(item1);
        OrderApi__Item__c item2 = FS_TestUtils.createItem('Charger Program Item', itemClass.Id);
        item2.FS_Track_Inventory__c = TRUE;
        item2.FS_Items_in_Cart__c = 0;
        item2.FS_Items_in_Warehouse__c = 100;
        itemList.add(item2);
        OrderApi__Item__c item3 = FS_TestUtils.createItem('Non tracking inventory Item', itemClass.Id); 
        itemList.add(item3);
        
        insert itemList;
        
        //Inserting Salesorder lines
        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLine1 = new OrderApi__Sales_Order_Line__c(
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Item__c = item3.Id,
            OrderApi__Quantity__c = 1, 
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine1);
        
        OrderApi__Sales_Order_Line__c salesOrderLine2 = new OrderApi__Sales_Order_Line__c(
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Item__c = item2.Id,
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Quantity__c = 1,
            OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine2);
        
        insert solList;
        //updating sales order line 
        salesOrderLine1.OrderApi__Quantity__c = 2;
        salesOrderLine1.OrderApi__Item__c = item1.Id;
        
        salesOrderLine2.OrderApi__Item__c = item2.Id;
        
        update solList;
        
        List<OrderApi__Item__c> itemListUpdated = [SELECT Id,FS_Items_in_Cart__c FROM OrderApi__Item__c WHERE Id IN :itemList];
        Decimal itemsCart1 = itemListUpdated[0].FS_Items_in_Cart__c;
        Decimal itemsCart2 = itemListUpdated[1].FS_Items_in_Cart__c;
        System.assertEquals(2, itemsCart1);
        System.assertEquals(1, itemsCart2);
        test.stopTest();
    }
}