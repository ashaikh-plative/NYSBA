/**
 * Created by Seshu on 14-09-2020.
 */

@IsTest
private class FS_UpdateCLEWhenTermExpiredTest {
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
        Framework.RoutingRule membershipRule = new Framework.RoutingRule();
        membershipRule.apexClass = FS_UpdateCLEWhenTermExpired.class.getName();
        membershipRule.namespace = ' ';
        membershipRule.isEnabled = true;
        membershipRule.sObjectName = SObjectType.OrderApi__Subscription__c.getName();
        membershipRule.executionOrder = 20;
        rules.add(membershipRule);
        Framework.Config.push(rules);

        //Contact
        Contact contact = FS_TestUtils.createContact('TestContact','test@gmail.com');
        insert contact;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.Id,null,'Receipt','Open');
        insert salesOrder;

        //ItemClass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('TestItemClass');
        itemClass.OrderApi__Is_Subscription__c = true;
        insert itemClass;

        //item
        OrderApi__Item__c item = FS_TestUtils.createItem('TestItem',itemClass.Id);
        item.FS_CLE_Credits_For_Curr_Year_Membership__c = 5;
        item.FS_CLE_Credits_For_Next_Year_Membership__c = 5;
        item.OrderApi__Is_Subscription__c = true;

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
    private static void updateContactCLEFieldsWhenTermExpired(){
        Test.startTest();
        Contact contact = [SELECT Id,LastName FROM Contact WHERE LastName ='TestContact' LIMIT 1];
        OrderApi__Sales_Order__c salesOrder = [SELECT Id,OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:contact.Id LIMIT 1];
        OrderApi__Sales_Order_Line__c salesOrderLine = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =:salesOrder.Id LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'TestItem' LIMIT 1];
        OrderApi__Subscription_Plan__c subscriptionPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name = 'Test plan' LIMIT 1];
        salesOrder.OrderApi__Status__c = 'Posted';
        update salesOrder;

        //subscription
        OrderApi__Subscription__c subscription = FS_TestUtils.createSubscription(item.Id,subscriptionPlan.Id,null,contact.Id,salesOrderLine.Id);
        insert subscription;

        subscription.OrderApi__Status__c = 'Cancelled';
        update subscription;
        OrderApi__Renewal__c updatedRenewal = [
                SELECT Id,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,
                        OrderApi__Is_Active__c,FS_Term_Credits_Gained__c,FS_Term_Credits_Expired__c
                FROM OrderApi__Renewal__c
        ];
        Contact updatedContact = [SELECT Id,FS_Credits_Expired__c FROM Contact WHERE Id=:contact.Id LIMIT 1];
        System.assertEquals(5,updatedRenewal.FS_Term_Credits_Expired__c);
        System.assertEquals(5,updatedContact.FS_Credits_Expired__c);
        Test.stopTest();
    }
}