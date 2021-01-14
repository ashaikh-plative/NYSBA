/**
 * Created by Anvesh on 03-Sep-20.
 */
@IsTest
private class FS_EventBundleRoutingRuleTest {
    @TestSetup
    private static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_EventBundleRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order_Line__c';
        routingRule.executionOrder = 25;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(LastName = 'Test',Email = 'test1@gmail.com',AccountId = acc.Id);
        insert con;
    }


    @IsTest
    private static void testSolInsertion(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name='test',OrderApi__Type__c = 'Testing');
        insert busGroup;


        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.OrderApi__Is_Event__c = true;
        insert itemClass;

        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Parent Item';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        item1.OrderApi__Is_Event__c = true;
        itemList.add(item1);

        OrderApi__Item__c item2 = new OrderApi__Item__c();
        item2.Name = 'Child Item';
        item2.OrderApi__Is_Active__c = true;
        item2.OrderApi__Item_Class__c = itemClass.Id;
        item2.OrderApi__Is_Event__c = true;
        itemList.add(item2);
        insert itemList;

        FS_Event_Bundle__c eventBundle = new FS_Event_Bundle__c (FS_Parent_Item__c = item1.Id,FS_Child_Item__c = item2.Id );
        insert eventBundle;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        insert salesOrderLine;

        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = [SELECT Id,OrderApi__Item__c,OrderApi__Sales_Order__c FROM
                                                                    OrderApi__Sales_Order_Line__c];
        if(salesOrderLineList.size() > 0){
            System.assertEquals(salesOrderLineList.size(),2);
        }
    }
    @IsTest
    private static void testSolDeletion(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name='test',OrderApi__Type__c = 'Testing');
        insert busGroup;


        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.OrderApi__Is_Event__c = true;
        insert itemClass;

        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Parent Item 1';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        item1.OrderApi__Is_Event__c = true;
        itemList.add(item1);

        OrderApi__Item__c item2 = new OrderApi__Item__c();
        item2.Name = 'Child Item 1';
        item2.OrderApi__Is_Active__c = true;
        item2.OrderApi__Item_Class__c = itemClass.Id;
        item2.OrderApi__Is_Event__c = true;
        itemList.add(item2);
        insert itemList;

        //Event bundle Item
        FS_Event_Bundle__c eventBundle = new FS_Event_Bundle__c (FS_Parent_Item__c = item1.Id,FS_Child_Item__c = item2.Id );
        insert eventBundle;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        insert salesOrderLine;

        delete salesOrderLine;

        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = [SELECT Id,OrderApi__Item__c,OrderApi__Sales_Order__c FROM
                OrderApi__Sales_Order_Line__c];
        System.assertEquals(salesOrderLineList.size(),0);
    }
    @IsTest
    private static void updateSolItem(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name='test',OrderApi__Type__c = 'Testing');
        insert busGroup;


        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.OrderApi__Is_Event__c = true;
        insert itemClass;

        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Parent Item 1';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        item1.OrderApi__Is_Event__c = true;
        itemList.add(item1);

        OrderApi__Item__c item2 = new OrderApi__Item__c();
        item2.Name = 'Child Item 1';
        item2.OrderApi__Is_Active__c = true;
        item2.OrderApi__Item_Class__c = itemClass.Id;
        item2.OrderApi__Is_Event__c = true;
        itemList.add(item2);
        insert itemList;

        //Event bundle Item
        FS_Event_Bundle__c eventBundle = new FS_Event_Bundle__c (FS_Parent_Item__c = item1.Id,FS_Child_Item__c = item2.Id );
        insert eventBundle;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item2.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        insert salesOrderLine;

        salesOrderLine.OrderApi__Item__c = item1.Id;
        update salesOrderLine;

        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = [SELECT Id,OrderApi__Item__c,OrderApi__Sales_Order__c FROM
                OrderApi__Sales_Order_Line__c];
        System.assertEquals(salesOrderLineList.size(),2);
    }

}