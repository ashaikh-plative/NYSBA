/**
 * Created by Seshu on 10-09-2020.
 */

@IsTest
private class FS_UpdateCLEOnContactRuleTest {

    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install(); 
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule renewalRule = new Framework.RoutingRule();
        renewalRule.apexClass = FS_UpdateCLEOnContactRule.class.getName();
        renewalRule.namespace = ' ';
        renewalRule.isEnabled = true;
        renewalRule.sObjectName = SObjectType.OrderApi__Renewal__c.getName();
        renewalRule.executionOrder = 20;
        rules.add(renewalRule);
        Framework.Config.push(rules);

        //Contact
        Contact contact = FS_TestUtils.createContact('TestContact','test@gmail.com');
        insert contact;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.Id,null,'Receipt','Open');
        insert salesOrder;

        //Item class
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('TestItemClass');
        itemClass.OrderApi__Is_Subscription__c = true;
        insert itemClass;

        //item
        OrderApi__Item__c item = FS_TestUtils.createItem('TestItem',itemClass.Id);
        item.OrderApi__Is_Subscription__c = true;
        item.FS_CLE_Credits_For_Curr_Year_Membership__c = 5;
        item.FS_CLE_Credits_For_Next_Year_Membership__c = 5;
        insert item;

        //Insert SubscriptionPlan
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c ();
        subscriptionPlan.Name = 'Test plan';
        subscriptionPlan.OrderApi__Type__c = 'Termed';
        subscriptionPlan.OrderApi__Initial_Term_Months__c = 12;
        subscriptionPlan.OrderApi__Renewal_Term_Months__c =12;
        subscriptionPlan.OrderApi__Is_Active__c = true;
        subscriptionPlan.OrderApi__Grace_Period__c = 0;
        insert subscriptionPlan;

        //salesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = FS_TestUtils.createSalesOrderLine(item.Id,salesOrder.Id,contact.Id,null);
        salesOrderLine.OrderApi__Subscription_Plan__c = subscriptionPlan.Id;
        insert salesOrderLine;
    }

    @IsTest
    private static void updatingCLEFieldsWhenTermInserted(){
        Test.startTest();
        Contact contact = [SELECT Id,LastName FROM Contact WHERE LastName ='TestContact' LIMIT 1];
        OrderApi__Sales_Order__c salesOrder = [SELECT Id,OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:contact.Id LIMIT 1];
        OrderApi__Sales_Order_Line__c salesOrderLine = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =:salesOrder.Id LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'TestItem' LIMIT 1];
        OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name = 'TestItemClass' LIMIT 1];
        OrderApi__Subscription_Plan__c subscriptionPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name = 'Test plan' LIMIT 1];
        salesOrder.OrderApi__Status__c = 'Posted';
        update salesOrder;

        //subscription
        OrderApi__Subscription__c subscription = FS_TestUtils.createSubscription(item.Id,subscriptionPlan.Id,null,contact.Id,salesOrderLine.Id);
        insert subscription;
        OrderApi__Renewal__c renewal = [SELECT Id,FS_Term_Credits_Formula__c,FS_Term_Credits_Gained__c,FS_Term_Credits_Consumed__c,
        FS_Term_Credits_Expired__c,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,OrderApi__Grace_Period_End_Date__c,OrderApi__Contact__c
        FROM OrderApi__Renewal__c WHERE OrderApi__Subscription__c=:subscription.Id LIMIT 1];

        List<OrderApi__Renewal__c> renewals = new List<OrderApi__Renewal__c>();
        OrderApi__Renewal__c secondRenewal = new OrderApi__Renewal__c();
        secondRenewal.OrderApi__Term_Start_Date__c = renewal.OrderApi__Term_End_Date__c;
        secondRenewal.OrderApi__Term_End_Date__c = renewal.OrderApi__Term_End_Date__c.addYears(1);
        secondRenewal.OrderApi__Grace_Period_End_Date__c = renewal.OrderApi__Term_End_Date__c.addYears(1).addMonths(1);
        secondRenewal.OrderApi__Subscription__c = subscription.Id;
        secondRenewal.OrderApi__Contact__c = contact.Id;
        renewals.add(secondRenewal); 
        insert renewals;

        System.assertEquals(renewal.FS_Term_Credits_Gained__c,renewal.FS_Term_Credits_Formula__c);
        System.assertEquals(0,renewal.FS_Term_Credits_Consumed__c);
        System.assertEquals(0,renewal.FS_Term_Credits_Expired__c);
        Contact contactDetail = [SELECT Id,FS_Credits_Gained__c FROM Contact WHERE Id =:contact.Id LIMIT 1];
        System.assert(contactDetail != null);
        System.assertEquals(10,contactDetail.FS_Credits_Gained__c);
        Test.stopTest();
    }

    @IsTest
    private static void updatingCLEFieldsWhenTermUpdated(){
        Test.startTest();
        Contact contact = [SELECT Id,LastName FROM Contact WHERE LastName ='TestContact' LIMIT 1];
        OrderApi__Sales_Order__c salesOrder = [SELECT Id,OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:contact.Id LIMIT 1];
        OrderApi__Sales_Order_Line__c salesOrderLine = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =:salesOrder.Id LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'TestItem' LIMIT 1];
        OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name = 'TestItemClass' LIMIT 1];
        OrderApi__Subscription_Plan__c subscriptionPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name = 'Test plan' LIMIT 1];
        salesOrder.OrderApi__Status__c = 'Posted';
        update salesOrder;

        //subscription
        OrderApi__Subscription__c subscription = FS_TestUtils.createSubscription(item.Id,subscriptionPlan.Id,null,contact.Id,salesOrderLine.Id);
        insert subscription;


        OrderApi__Renewal__c renewal = [SELECT Id,FS_Term_Credits_Formula__c,FS_Term_Credits_Gained__c,FS_Term_Credits_Consumed__c,
        OrderApi__Is_Active__c,FS_Term_Credits_Expired__c,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,OrderApi__Grace_Period_End_Date__c
        FROM OrderApi__Renewal__c WHERE OrderApi__Subscription__c=:subscription.Id LIMIT 1];
        renewal.OrderApi__Term_End_Date__c = System.today().addMonths(-2);
        renewal.OrderApi__Grace_Period_End_Date__c = System.today().addDays(-1);
        update renewal;
        OrderApi__Renewal__c updatedRenewal = [SELECT Id,OrderApi__Contact__c,FS_Term_Credits_Expired__c FROM OrderApi__Renewal__c WHERE Id=:renewal.Id LIMIT 1];
        System.assertEquals(5,updatedRenewal.FS_Term_Credits_Expired__c);
        Contact updatedContact = [SELECT Id,FS_Credits_Expired__c FROM Contact WHERE Id=:contact.Id LIMIT 1];
        System.assertEquals(5,updatedContact.FS_Credits_Expired__c);
        Test.stopTest();
    }
}