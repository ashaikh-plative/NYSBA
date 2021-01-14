/**
 * Created by Krishna on 23-09-2020.
 */
@IsTest
private class FS_SustainingMemberSORRuleTest {

    @TestSetup
    private static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_SustainingMemberSORoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule.executionOrder = 26;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Contact conObj = new Contact();
        conObj.LastName = 'Test Con';
        insert conObj;
    }

    @IsTest
    private static void SalesOrderTest() {
        Contact conObj = [SELECT Id,LastName FROM Contact WHERE LastName = :'Test Con'];

        OrderApi__Sales_Order__c fsOrder = new OrderApi__Sales_Order__c();
        fsOrder.OrderApi__Contact__c = conObj.Id;
        fsOrder.OrderApi__Status__c = FS_Constant.SALES_ORDER_OPEN;
        insert fsOrder;

        OrderApi__Item_Class__c itemClassObj = new OrderApi__Item_Class__c();
        itemClassObj.Name = 'TestItemClass';
        itemClassObj.OrderApi__Is_Active__c = true;
        insert itemClassObj;

        OrderApi__Item__c ItemObj = new OrderApi__Item__c();
        ItemObj.Name = 'Sustaining Member';
        ItemObj.OrderApi__Item_Class__c = itemClassObj.Id;
        insert ItemObj;

        OrderApi__Sales_Order_Line__c orderLineObj = new OrderApi__Sales_Order_Line__c();
        orderLineObj.OrderApi__Sales_Order__c = fsOrder.Id;
        orderLineObj.OrderApi__Item__c = ItemObj.Id;
        insert orderLineObj;

        fsOrder.OrderApi__Status__c = FS_Constant.SALES_ORDER_CLOSED;
        fsOrder.OrderApi__Posting_Status__c = FS_Constant.SALES_ORDER_POSTED;
        update fsOrder;

        Contact con = [SELECT Id,LastName,FS_Sustaining_Member__c FROM Contact WHERE Id = :conObj.Id];
        System.assertEquals(true, con.FS_Sustaining_Member__c);
    }

    @IsTest
    private static void SalesOrderNegativeTest() {
        Contact conObj = [SELECT Id,LastName FROM Contact WHERE LastName = :'Test Con'];

        OrderApi__Sales_Order__c fsOrder = new OrderApi__Sales_Order__c();
        fsOrder.OrderApi__Contact__c = conObj.Id;
        fsOrder.OrderApi__Status__c = FS_Constant.SALES_ORDER_OPEN;
        insert fsOrder;

        OrderApi__Item_Class__c itemClassObj = new OrderApi__Item_Class__c();
        itemClassObj.Name = 'TestItem Class';
        itemClassObj.OrderApi__Is_Active__c = true;
        insert itemClassObj;

        OrderApi__Item__c ItemObj = new OrderApi__Item__c();
        ItemObj.Name = 'Test Item';
        ItemObj.OrderApi__Item_Class__c = itemClassObj.Id;
        insert ItemObj;

        OrderApi__Sales_Order_Line__c orderLineObj = new OrderApi__Sales_Order_Line__c();
        orderLineObj.OrderApi__Sales_Order__c = fsOrder.Id;
        orderLineObj.OrderApi__Item__c = ItemObj.Id;
        insert orderLineObj;

        fsOrder.OrderApi__Status__c = FS_Constant.SALES_ORDER_CLOSED;
        fsOrder.OrderApi__Posting_Status__c = FS_Constant.SALES_ORDER_PENDING;
        update fsOrder;

        Contact con = [SELECT Id,LastName,FS_Sustaining_Member__c FROM Contact WHERE Id = :conObj.Id];
        System.assertEquals(false, con.FS_Sustaining_Member__c);
    }
}