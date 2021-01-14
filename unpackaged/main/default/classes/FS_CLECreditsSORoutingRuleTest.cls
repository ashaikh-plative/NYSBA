/**
 * Created by santhosh on 18-09-2020.
 */

@IsTest
private class FS_CLECreditsSORoutingRuleTest {

    private static final String ACCOUNT_NAME = 'TestAccount';
    private static final String CONTACT_LAST_NAME = 'TestContact';
    private static final String BUSINESS_GROUP_NAME_STRING = 'NYSBA';

    @TestSetup
    private static void testSetup(){
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_CLECreditsSORoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule.executionOrder = 35;
        rules.add(routingRule);
        Framework.Config.push(rules);

        createAccount(ACCOUNT_NAME);
        createContact('Testing', CONTACT_LAST_NAME);
    }

    @IsTest
    private static void soDeleteTest(){
        Test.startTest();
        Account acc = getAccount(ACCOUNT_NAME);
        Contact con = getContact(CONTACT_LAST_NAME);
        con.FS_Credits_Consumed__c = 9;
        con.FS_Credits_Gained__c = 13;
        update con;

        OrderApi__Business_Group__c busGroup = createBusinessGroup();
        OrderApi__Subscription_Plan__c subscriptionPlan = createSubscriptionPlan(busGroup);

        List<OrderApi__Item_Class__c> itemClasses = new List<OrderApi__Item_Class__c>();
        OrderApi__Item_Class__c subItemClass = createItemClass(busGroup, 'TestMembershipCLass', true);
        itemClasses.add(subItemClass);
        OrderApi__Item_Class__c itemClass = createItemClass(busGroup, 'TestItemCLass', false);
        itemClasses.add(itemClass);
        insert itemClasses;

        List<OrderApi__Item__c> itemsList = new List<OrderApi__Item__c>();
        OrderApi__Item__c subItem1 = createItem(busGroup, subItemClass, 'TestSub1', 125.66, false, null, true);
        itemsList.add(subItem1);
        OrderApi__Item__c subItem2 = createItem(busGroup, subItemClass, 'TestSub2', 465.66, false, null, true);
        itemsList.add(subItem2);
        OrderApi__Item__c testItem1 = createItem(busGroup, itemClass, 'TestItem1', 5250, true, 15, false);
        itemsList.add(testItem1);
        OrderApi__Item__c testItem2 = createItem(busGroup, itemClass, 'TestItem2', 466, false, null, false);
        itemsList.add(testItem2);
        insert itemsList;

        List<OrderApi__Subscription__c> subsList = new List<OrderApi__Subscription__c>();
        OrderApi__Subscription__c subscription1 =  createSubscription(subItem1.Id, subscriptionPlan.Id, acc.Id, con.Id, null);
        subsList.add(subscription1);
        OrderApi__Subscription__c subscription2 =  createSubscription(subItem2.Id, subscriptionPlan.Id, acc.Id, con.Id, null);
        subsList.add(subscription2);
        insert subsList;

        List<OrderApi__Renewal__c> termList = new List<OrderApi__Renewal__c>();
        OrderApi__Renewal__c term1 = createTermForTesting(con, subItem1, subscription1.Id, 300, 6, 3);
        termList.add(term1);
        OrderApi__Renewal__c term2 = createTermForTesting(con, subItem2, subscription2.Id, 200, 6, 6);
        termList.add(term2);
        insert termList;

        String creditsString = '{"termCredits":{"'+term1.Id+'":3,"'+term2.Id+'":6},"originalSalesPrice":5250.00,"originalPriceOverride":true}';

        List<OrderApi__Sales_Order__c> records = new List<OrderApi__Sales_Order__c>();
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        records.add(salesOrder);
        insert records;


        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = testItem1.OrderApi__Item_Class__c,
                OrderApi__Item__c = testItem1.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Sale_Price__c = 2100,
                FS_Additional_Data__c = creditsString,
                FS_CLE_Credits_Applied__c = 9,
                OrderApi__Price_Override__c = true
        );
        insert orderLine;
        delete records;

        Test.stopTest();

        List<OrderApi__Renewal__c> termListRes = [SELECT Id, FS_Term_Credits_Consumed__c, OrderApi__Contact__c, OrderApi__Contact__r.FS_Credits_Consumed__c
        FROM OrderApi__Renewal__c WHERE Id = :term1.Id];
        System.assertEquals(1, termListRes.size());
        System.assertEquals(0, termListRes[0].FS_Term_Credits_Consumed__c);
        System.assertEquals(0, termListRes[0].OrderApi__Contact__r.FS_Credits_Consumed__c);

        termListRes = [SELECT Id, FS_Term_Credits_Consumed__c, OrderApi__Contact__c, OrderApi__Contact__r.FS_Credits_Consumed__c
        FROM OrderApi__Renewal__c WHERE Id = :term1.Id];
        System.assertEquals(1, termListRes.size());
        System.assertEquals(0, termListRes[0].FS_Term_Credits_Consumed__c);
        System.assertEquals(0, termListRes[0].OrderApi__Contact__r.FS_Credits_Consumed__c);
    }

    private static void createContact(String firstName, String lastName) {
        insert new Contact(FirstName=firstName, LastName=lastName);
    }

    private static Contact getContact(String lastName) {
        return [SELECT Id, LastName FROM Contact WHERE LastName = :lastName];
    }

    private static void createAccount(String nameString) {
        Account acc = new Account(Name=nameString);
        insert acc;
    }

    private static Account getAccount(String nameString) {
        return [SELECT Id, Name FROM Account WHERE Name = :nameString];
    }

    private static OrderApi__Business_Group__c createBusinessGroup() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = BUSINESS_GROUP_NAME_STRING);
        insert busGroup;
        return busGroup;
    }

    private static OrderApi__Subscription_Plan__c createSubscriptionPlan(OrderApi__Business_Group__c busGroup) {
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
                Name = '1 Year',
                OrderApi__Type__c = 'Termed', OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12,
                OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec',OrderApi__Enable_Proration__c = true,
                OrderApi__Proration_Rule__c = 'Bi-Annually',
                OrderApi__Invoice_Days_Variable__c= 31, OrderApi__Auto_Renew_Option__c = 'Enabled',
                OrderApi__Bill_Cycle__c = 'AUTO',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Active__c = true
        );
        insert subscriptionPlan;
        return subscriptionPlan;
    }

    private static OrderApi__Item_Class__c createItemClass(OrderApi__Business_Group__c busGroup, String itemClassName, Boolean isSubscription) {
        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = itemClassName,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = isSubscription);
        return itemClass;
    }

    private static OrderApi__Item__c createItem(OrderApi__Business_Group__c busGroup,
            OrderApi__Item_Class__c itemClass,
            String itemName, Decimal price,
            Boolean isClEItem, Decimal cleCredits,
            Boolean isSubscription) {
        OrderApi__Item__c  item = new OrderApi__Item__c(Name= itemName,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = isSubscription,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = price);
        if(isClEItem){
            item.FS_Allow_purchase_for_CLE_credits__c = true;
            item.FSAreas_of_Professional_Practice_Credits__c = cleCredits;
        }
        return item;
    }

    public static OrderApi__Subscription__c createSubscription(Id oItem,Id oSubsPlan, Id a, Id c, Id oSalesOrderLine){
        OrderApi__Subscription__c oSubscription = new OrderApi__Subscription__c();
        oSubscription.OrderApi__Subscription_Plan__c = oSubsPlan;
        oSubscription.OrderApi__Account__c = a;
        oSubscription.OrderApi__Contact__c = c;
        oSubscription.OrderApi__Item__c  = oItem;
        oSubscription.OrderApi__Status__c = 'Active';
        oSubscription.OrderApi__Is_Active__c = true;
        return oSubscription;
    }

    private static OrderApi__Renewal__c createTermForTesting(Contact con, OrderApi__Item__c item, Id subId, Integer days, Decimal gained, Decimal consumed) {
        OrderApi__Renewal__c term = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c = System.today() - 10,
                OrderApi__Term_End_Date__c = System.today() + days,
                OrderApi__Contact__c = con.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Subscription__c = subId,
                FS_Term_Credits_Gained__c = gained,
                FS_Term_Credits_Consumed__c = consumed,
                FS_Term_Credits_Expired__c = 0
        );
        return term;
    }
}