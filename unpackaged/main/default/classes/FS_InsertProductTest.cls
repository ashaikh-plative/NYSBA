/**
 * Created by santhosh on 03-10-2019.
 */

@IsTest
private without sharing class FS_InsertProductTest {

    @TestSetup
    private static void beforeUpdate(){

        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        /* RoutingRule information*/
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_InsertProductRule.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Item__c';
        routingRule.executionOrder = 40;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    private static void productTest(){
        Pricebook2 pb = new Pricebook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive=true;
        update pb;

        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name='Test Class';
        insert itemClass;

        List<OrderApi__Item__c> items = new List<OrderApi__Item__c>();
        OrderApi__Item__c item = new OrderApi__Item__c();
        item.Name='Test item';
        item.OrderApi__Item_Class__c=itemClass.Id;
        item.OrderApi__Line_Description__c='Test item';
        item.FS_Sold_By_Sales_Team__c=false;
        item.OrderApi__Price__c=999;
        item.OrderApi__Is_Active__c = true;
        items.add(item);
        insert items;

        List<OrderApi__Item__c> insertItems = new List<OrderApi__Item__c>();
        OrderApi__Item__c item2 = new OrderApi__Item__c();
        item2.Name='Test item';
        item2.OrderApi__Item_Class__c=itemClass.Id;
        item2.OrderApi__Line_Description__c='Test item';
        item2.FS_Sold_By_Sales_Team__c=true;
        item2.OrderApi__Price__c=999;
        item2.OrderApi__Is_Active__c = true;
        insertItems.add(item2);
        insert insertItems;

        Test.startTest();
        FS_InsertProductRule productInsertRoutingRule = new FS_InsertProductRule(insertItems);
        FS_InsertProductRule.Constructor fsccInsert = new FS_InsertProductRule.Constructor();
        fsccInsert.construct(insertItems);
        productInsertRoutingRule.afterInsert();

        Map<Id,OrderApi__Item__c> mapItem = new Map<Id,OrderApi__Item__c>(
        [SELECT Id, FS_Sold_By_Sales_Team__c, Name,OrderApi__Line_Description__c,OrderApi__Price__c  FROM OrderApi__Item__c WHERE Id = :items]);
        items[0].FS_Sold_By_Sales_Team__c=true;

        FS_InsertProductRule productRoutingRule = new FS_InsertProductRule(items);
        FS_InsertProductRule.Constructor fscc = new FS_InsertProductRule.Constructor();
        fscc.construct(items);
        productRoutingRule.beforeUpdate(mapItem);

        List<Product2> products = [SELECT Id,Name,Description,(SELECT Id,UnitPrice,Product2Id FROM PricebookEntries) FROM Product2 WHERE Id = :items[0].FS_Linked_Product__c ];
        System.assertEquals(products.size(), 1);
        update items;

        mapItem = new Map<Id,OrderApi__Item__c>(
        [SELECT Id, FS_Sold_By_Sales_Team__c, Name,OrderApi__Line_Description__c,OrderApi__Price__c  FROM OrderApi__Item__c WHERE Id = :items]);
        items[0].Name = 'Edited';
        items[0].OrderApi__Line_Description__c = 'Edited Desc';
        items[0].OrderApi__Price__c = 11;
        items[0].OrderApi__Is_Active__c = false;
        productRoutingRule.beforeUpdate(mapItem);

        products = [SELECT Id,Name,Description,(SELECT Id,UnitPrice,Product2Id FROM PricebookEntries) FROM Product2 WHERE Id = :items[0].FS_Linked_Product__c];
        System.assertEquals(products.size(), 1);
        System.assertEquals(products[0].Name, 'Edited');
        System.assertEquals(products[0].Description, 'Edited Desc');
        System.assertEquals(products[0].PricebookEntries.size(), 1);
        System.assertEquals(products[0].PricebookEntries[0].UnitPrice, 11);
        update items;

        Test.stopTest();
    }
}