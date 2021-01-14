/**
 * Created by jzhou on 11/8/19.
 */

@IsTest
private class FS_SalesOrderRoutingRuleTest {

    @TestSetup
    static void install() {
        Framework.Installer.install();
//        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
//        EventApi.PackageScripts.install();
//        ROEApi.PackageScripts.install();
//        CPBase.PackageScripts.install();
//        LTE.PackageScripts.install();
//        FDService.BUPackageScripts.install();
//        DonorApi.PackageScripts.install();
//        joinapi.PackageScripts.install();
//        ProgramApi.PackageScripts.install();
//        PriceApi.PackageScripts.install();
//        DRCTS.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_SalesOrderRoutingRule.class.getName();
        routingRule.namespace = 'OrderApi';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule.executionOrder = 30;
        rules.add(routingRule);
        Framework.Config.push(rules);

        OrderApi__Business_Group__c businessGroup = new OrderApi__Business_Group__c(Name='test');
        insert businessGroup;

        Account acc = new Account(Name='Test');
        insert acc;

        Contact con = new Contact(FirstName='Contact',LastName='Test', Email='test@fusionspan.com',AccountId=acc.Id);
        insert con;

        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c(Name='Test Group',
                PagesApi__Type__c='Section');
        insert communityGroup;

        PagesApi__Community_Group__c communityGroup2 = new PagesApi__Community_Group__c(Name='Test Sub Group',
                PagesApi__Type__c='Section',FS_Parent_Section__c=communityGroup.Id);
        insert communityGroup2;

        // Contact must have an active membership to purchase sections
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name='Test Item Class',OrderApi__Is_Subscription__c=true,FS_Is_Membership__c=true);
        insert itemClass;
        OrderApi__Item__c item = new OrderApi__Item__c(
                Name='Test Item',OrderApi__Item_Class__c=itemClass.Id,OrderApi__Is_Subscription__c=true,OrderApi__Price__c=1,OrderApi__Business_Group__c=businessGroup.Id);
        insert item;

        OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c(Name='Test Sub Plan',OrderApi__Type__c = 'Termed',
                OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12,
                OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec',
                OrderApi__Invoice_Days_Variable__c= 31,
                OrderApi__Bill_Cycle__c = 'AUTO', OrderApi__Business_Group__c = businessGroup.Id,OrderApi__Is_Active__c=true);
        insert subPlan;
        OrderApi__Item_Subscription_Plan__c itemSubPlan = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Item__c=item.Id,OrderApi__Subscription_Plan__c=subPlan.Id,OrderApi__Is_Default__c=true);
        insert itemSubPlan;

        item.OrderApi__Is_Active__c = true;
        update item;

        // Now create item for the section the contact will purchase
        OrderApi__Item_Class__c itemClass2 = new OrderApi__Item_Class__c(Name='Section Dues');
        insert itemClass2;
        OrderApi__Item__c item2 = new OrderApi__Item__c(Name='Test Membership Section',OrderApi__Item_Class__c=itemClass2.Id,
                FS_Linked_Community_Group__c=communityGroup.Id,OrderApi__Is_Active__c=true,OrderApi__Business_Group__c=businessGroup.Id);
        insert item2;

    }

    @IsTest
    static void testProcessingSectionSalesOrder_ExpectCGMCreated() {

        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@fusionspan.com' LIMIT 1];
        OrderApi__Item_Subscription_Plan__c itemSubPlan = [SELECT Id,OrderApi__Item__c,OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c LIMIT 1];


        Test.startTest();

        OrderApi__Subscription__c sub = new OrderApi__Subscription__c(
                OrderApi__Item__c=itemSubPlan.OrderApi__Item__c,OrderApi__Is_Active__c=true,OrderApi__Contact__c=con.Id,OrderApi__Entity__c='Contact',
                OrderApi__Subscription_Plan__c=itemSubPlan.OrderApi__Subscription_Plan__c,OrderApi__Status__c='Active');
        insert sub;

        OrderApi__Renewal__c termToUse = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c=System.today(),OrderApi__Term_End_Date__c=System.today().addYears(1),OrderApi__Grace_Period_End_Date__c=System.today().addYears(1).addMonths(3),
                OrderApi__Entity__c='Contact',OrderApi__Item__c=itemSubPlan.OrderApi__Item__c,OrderApi__Subscription_Plan__c=itemSubPlan.OrderApi__Subscription_Plan__c,
                OrderApi__Subscription__c=sub.Id,OrderApi__Contact__c=con.Id,OrderApi__Is_Active__c=true
        );
        insert termToUse;

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c=con.Id,OrderApi__Entity__c='Contact',OrderApi__Status__c='Open');
        insert so;

        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c=[SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test Membership Section'].Id,OrderApi__Sales_Order__c=so.Id,
                FS_Additional_Data__c='{\"sectionCommittees\":[\"' + [SELECT Id FROM PagesApi__Community_Group__c WHERE Name = 'Test Sub Group'].Id + '\"]}');
        insert soLine;

        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Pending';
        update so;

        so.OrderApi__Posting_Status__c = 'Posted';
        update so;

        Test.stopTest();

        System.assertNotEquals(0, [SELECT Id FROM PagesApi__Community_Group_Member__c].size());
    }

    @IsTest
    static void testProcessingSectionSalesOrderWithExistingCGM_ExpectCGMUpdated() {

        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@fusionspan.com' LIMIT 1];
        OrderApi__Item_Subscription_Plan__c itemSubPlan = [SELECT Id,OrderApi__Item__c,OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c LIMIT 1];

        Test.startTest();

        PagesApi__Community_Group_Member__c member = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c=[SELECT Id FROM PagesApi__Community_Group__c WHERE Name='Test Group'].Id,PagesApi__Contact__c=con.Id,PagesApi__Is_Active__c=false,
                FS_Term_Start_Date__c=System.today().addYears(-2),FS_Term_End_Date__c=System.today().addYears(-1),FS_Grace_Period_End_Date__c=System.today().addMonths(-9)
        );
        insert member;

        OrderApi__Subscription__c sub = new OrderApi__Subscription__c(
                OrderApi__Item__c=itemSubPlan.OrderApi__Item__c,OrderApi__Is_Active__c=true,OrderApi__Contact__c=con.Id,OrderApi__Entity__c='Contact',
                OrderApi__Subscription_Plan__c=itemSubPlan.OrderApi__Subscription_Plan__c,OrderApi__Status__c='Active');
        insert sub;

        OrderApi__Renewal__c termToUse = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c=System.today(),OrderApi__Term_End_Date__c=System.today().addYears(1),OrderApi__Grace_Period_End_Date__c=System.today().addYears(1).addMonths(3),
                OrderApi__Entity__c='Contact',OrderApi__Item__c=itemSubPlan.OrderApi__Item__c,OrderApi__Subscription_Plan__c=itemSubPlan.OrderApi__Subscription_Plan__c,
                OrderApi__Subscription__c=sub.Id,OrderApi__Contact__c=con.Id,OrderApi__Is_Active__c=true
        );
        insert termToUse;

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c=con.Id,OrderApi__Entity__c='Contact',OrderApi__Status__c='Open');
        insert so;

        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c=[SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test Membership Section'].Id,OrderApi__Sales_Order__c=so.Id,
                FS_Additional_Data__c='{\"sectionCommittees\":[\"' + [SELECT Id FROM PagesApi__Community_Group__c WHERE Name = 'Test Sub Group'].Id + '\"]}');
        insert soLine;

        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Pending';
        update so;

        so.OrderApi__Posting_Status__c = 'Posted';
        update so;

        Test.stopTest();

        List<PagesApi__Community_Group_Member__c> members = [SELECT Id,PagesApi__Is_Active__c FROM PagesApi__Community_Group_Member__c];

        System.assert(members.size() > 1, 'Not enough members created from Sales Order');
        for (PagesApi__Community_Group_Member__c member2 : members) {
//            System.assertEquals(true, member2.PagesApi__Is_Active__c);
        }
    }
}