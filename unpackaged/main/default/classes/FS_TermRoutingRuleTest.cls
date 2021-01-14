/**
 * Test class for FS_TermRoutingRule
 * @author Christopher Mudd from fusionSpan
 * @date 2019-04-18
 */
@IsTest
public without sharing class FS_TermRoutingRuleTest {

    private static final String BUSINESS_GROUP_NAMESTRING = 'NYSBA';
    private static final String COMM_GROUP_NAMESTRING = 'fusionSpan Council';
    private static final String COMPANY_MEMBERSHIP_NAME = 'Company Membership';
    private static final String CORPORATE_MEMBERSHIP_NAME = 'Corporate Membership';
    private static final String CONTACT_LAST_NAME = 'TestContactFSTermRR';
    private static final String ACCOUNT_NAME = 'testAccountFSTermRR';


    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_TermRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Renewal__c';
        routingRule.executionOrder = 20;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Account acc = createAccount(ACCOUNT_NAME);
        Contact con = createContact('Testing', CONTACT_LAST_NAME);
    }

    @IsTest
    public static void testNewSubscription_ExpectCommGroupMemberAndTermCreated() {

        Account acc = getTestAccount();
        Contact con = getTestContact();
        OrderApi__Business_Group__c busGroup = createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = createCommunitySite(busGroup);
        PagesApi__Community_Group__c commGroup = createCommunityGroup(site);
        OrderApi__Item__c subItem = createSubItem(busGroup, commGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = createSubscriptionPlanItemLink(subscriptionPlan, subItem);



        //Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
//                OrderApi__Account__c = acc.Id,
//                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
                OrderApi__Item__c = subItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id
        );

        insert orderLine;

        Test.startTest();

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;

        Test.stopTest();

        List<PagesApi__Community_Group_Member__c> membersList = [
                SELECT Id,PagesApi__Contact__c,PagesApi__Account__c
                FROM PagesApi__Community_Group_Member__c
        ];

        List<FS_Community_Group_Member_Term__c> termsList = [
                SELECT Id,FS_Community_Group_Member__c
                FROM FS_Community_Group_Member_Term__c
        ];

        List<OrderApi__Renewal__c> termsShouldConvert = [
                SELECT Id
                FROM OrderApi__Renewal__c
        ];


        System.assert(termsShouldConvert.size() != 0, 'No Terms were created when sales order posted');

        System.assert(membersList.size() == 1, 'Actual size: ' + membersList.size());
        System.assertEquals(membersList[0].PagesApi__Contact__c, con.Id, 'Group Member is for a different contact. ');
//                'Expected Id: ' + membersList[0].PagesApi__Contact__c + ' Actual Id: ' + con.Id);
//        System.assertEquals(membersList[0].PagesApi__Account__c, acc.Id, 'Group member is for a different account');

        System.assert(termsList.size() != 0, 'No Comm. Group Member terms created');
        System.assertEquals(termsList[0].FS_Community_Group_Member__c,membersList[0].Id, 'Term is for a different member. ');
        //         'Expected Id: ' + termsList[0].FS_Community_Group_Member__c + ' Actual Id: ' + membersList[0].Id);

    }

    @IsTest
    public static void testNewSubscription_ExpectExistingMemberUpdated() {
        System.debug('This is a test');
        Account acc = getTestAccount();
        Contact con = getTestContact();
        System.debug('TEST123');
        OrderApi__Business_Group__c busGroup = createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = createCommunitySite(busGroup);
        PagesApi__Community_Group__c commGroup = createCommunityGroup(site);
        OrderApi__Item__c subItem = createSubItem(busGroup, commGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = createSubscriptionPlanItemLink(subscriptionPlan, subItem);
        System.debug('TEST123489');

        PagesApi__Community_Group_Member__c member = createCommGroupMember(commGroup, con, acc);

        System.debug('member: ' + member);

        //Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
//                OrderApi__Account__c = acc.Id,
//                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
                OrderApi__Item__c = subItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id
        );

        insert orderLine;

        Test.startTest();

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;

        Test.stopTest();

        // to call the method directly so that log size is not maxed out
//        OrderApi__Renewal__c term = createTermForTesting(con, subItem, orderLine);
//        List<OrderApi__Renewal__c> testingTerms = new List<OrderApi__Renewal__c>();
//        testingTerms.add(term);
//        FS_TermRoutingRule routingRule = new FS_TermRoutingRule((List<SObject>) testingTerms);
//        routingRule.afterInsert();



        List<PagesApi__Community_Group_Member__c> membersList = [
                SELECT Id,PagesApi__Contact__c,PagesApi__Account__c,PagesApi__Community_Group__c
                FROM PagesApi__Community_Group_Member__c
        ];

        List<FS_Community_Group_Member_Term__c> termsList = [
                SELECT Id,FS_Community_Group_Member__c
                FROM FS_Community_Group_Member_Term__c
        ];
        System.debug('termsList1111111111');

        System.assert(membersList.size() == 1, 'Actual size: ' + membersList.size() + '\n' + 'Members List: ' + membersList +
                '\n' + 'Term: ' + termsList);

        System.assert(membersList.size() == 1, 'Actual size: ' + membersList.size());
        System.assertEquals(membersList[0].PagesApi__Contact__c, con.Id, 'Group Member is for a different contact. ' +
                'Expected Id: ' + membersList[0].PagesApi__Contact__c + ' Actual Id: ' + con.Id);
        //        System.assertEquals(membersList[0].PagesApi__Account__c, acc.Id, 'Group member is for a different account');

        System.debug(termsList.size()+'termsList.size()');
        System.assert(termsList.size() != 0, 'No Comm. Group Member terms created');
        System.assertEquals(termsList[0].FS_Community_Group_Member__c,membersList[0].Id, 'Term is for a different member. ' +
                'Expected Id: ' + termsList[0].FS_Community_Group_Member__c + ' Actual Id: ' + membersList[0].Id);

    }

    @IsTest
    public static void testNewSubscription_ExpectEndDate() {
        System.debug('This is a test');
        Account acc = getTestAccount();
        Contact con = getTestContact();
        OrderApi__Business_Group__c busGroup = createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = createCommunitySite(busGroup);
        PagesApi__Community_Group__c commGroup = createCommunityGroup(site);
        OrderApi__Item__c subItem = createSubItem(busGroup, commGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = createSubscriptionPlanItemLink(subscriptionPlan, subItem);
        //PagesApi__Community_Group_Member__c member = createCommGroupMember(commGroup, con, acc);

        //System.debug('member: ' + member);

        //Create sales order for user to checkout
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
                OrderApi__Item__c = subItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id
        );

        insert orderLine;

        Test.startTest();

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;


        // to call the method directly so that log size is not maxed out
        /*OrderApi__Renewal__c term = createTermForTesting(con, subItem, orderLine);
        List<OrderApi__Renewal__c> testingTerms = new List<OrderApi__Renewal__c>();
        testingTerms.add(term);
        FS_TermRoutingRule routingRule = new FS_TermRoutingRule((List<SObject>) testingTerms);
        routingRule.beforeInsert();
*/
        Test.stopTest();

        List<OrderApi__Renewal__c> termList = [
                SELECT Id, OrderApi__Term_End_Date__c,OrderApi__Term_Start_Date__c,FS_Is_Continuous_Term__c,OrderApi__Grace_Period_End_Date__c
                FROM OrderApi__Renewal__c
        ];



        for (OrderApi__Renewal__c currTerm : (List<OrderApi__Renewal__c>) termList) {
            Date testEndDate = currTerm.OrderApi__Term_Start_Date__c.toStartOfMonth().addDays(-1).addYears(1);
            Date testGracePeriodDate = currTerm.OrderApi__Term_End_Date__c.addDays(90);
            if (currTerm.FS_Is_Continuous_Term__c == false) {
//                System.assertEquals(testEndDate, currTerm.OrderApi__Term_End_Date__c);
//                System.assertEquals(testGracePeriodDate, currTerm.OrderApi__Grace_Period_End_Date__c);
            }
        }
    }

    private static Contact createContact(String firstName, String lastName) {
        Contact con = new Contact(FirstName=firstName, LastName=lastName);
        insert con;
        return con;
    }

    private static Account createAccount(String nameString) {
        Account acc = new Account(Name=nameString);
        insert acc;
        return acc;
    }

    private static Account getTestAccount() {
        return [SELECT Id, Name FROM Account WHERE Name = :ACCOUNT_NAME];
    }

    private static Contact getTestContact() {
        return [SELECT Id, Name, FirstName, LastName FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
    }


    private static OrderApi__Business_Group__c createBusinessGroup() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = BUSINESS_GROUP_NAMESTRING);
        insert busGroup;
        return busGroup;
    }

    private static OrderApi__Payment_Terms__c createPaymentTerms() {
        OrderApi__Payment_Terms__c paymentTerms = new OrderApi__Payment_Terms__c(Name = 'Due on Receipt',
                OrderApi__Display_Name__c = 'Due at the time of Receipt',
                OrderApi__Display_Message__c = 'Please remit payment upon receipt of this invoice.',
                OrderApi__Variable__c = 0);
        insert paymentTerms;
        return paymentTerms;
    }

    private static OrderApi__Subscription_Plan__c createSubscriptionPlan(OrderApi__Payment_Terms__c paymentTerms, OrderApi__Business_Group__c busGroup) {
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
                Name = '1 Year',
                OrderApi__Type__c = 'Termed', OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12,
//                OrderApi__Advanced_Calendar_Days__c = 60, OrderApi__Advanced_Calendar_Free_Paid__c = 'Paid',
                OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec',OrderApi__Enable_Proration__c = true,
                OrderApi__Proration_Rule__c = 'Bi-Annually',
                OrderApi__Invoice_Days_Variable__c= 31, OrderApi__Auto_Renew_Option__c = 'Enabled',
                OrderApi__Payment_Terms__c = paymentTerms.Id ,OrderApi__Bill_Cycle__c = 'AUTO',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Active__c = true
        );
        insert subscriptionPlan;
        return subscriptionPlan;
    }

    private static OrderApi__Item__c createSubItem(OrderApi__Business_Group__c busGroup, PagesApi__Community_Group__c commGroup) {
        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = CORPORATE_MEMBERSHIP_NAME,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true);
        insert itemClass;
        OrderApi__Item__c  item = new OrderApi__Item__c(Name=COMPANY_MEMBERSHIP_NAME,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup.Id);
        insert item;
        return item;
    }

    private static OrderApi__Item_Subscription_Plan__c createSubscriptionPlanItemLink(OrderApi__Subscription_Plan__c subPlan, OrderApi__Item__c item) {

        OrderApi__Item_Subscription_Plan__c subPlanLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Item__c = item.Id, OrderApi__Is_Default__c = true
        );
        insert subPlanLink;
        item.OrderApi__Is_Active__c = true;
        update item;
        return subPlanLink;
    }

    private static PagesApi__Community_Group__c createCommunityGroup(PagesApi__Site__c site) {

        PagesApi__Community_Group__c commGroup = new PagesApi__Community_Group__c(
                Name = COMM_GROUP_NAMESTRING,
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id
        );
        insert commGroup;
        return commGroup;
    }

    private static PagesApi__Site__c createCommunitySite(OrderApi__Business_Group__c busGroup) {

        PagesApi__Site__c site = new PagesApi__Site__c(
                Name = 'Test Site',
                OrderApi__Business_Group__c=busGroup.Id
        );

        insert site;
        return site;
    }

    private static PagesApi__Community_Group_Member__c createCommGroupMember(PagesApi__Community_Group__c commGroup, Contact con, Account acc) {

        System.debug(con);

        PagesApi__Community_Group_Member__c commGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = commGroup.Id,
                PagesApi__Contact__c = con.Id
//                PagesApi__Account__c = acc.Id
        );
        insert commGroupMember;
        return commGroupMember;
    }

    private static OrderApi__Renewal__c createTermForTesting(Contact con, OrderApi__Item__c item, OrderApi__Sales_Order_Line__c line) {
        OrderApi__Renewal__c term = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c = System.today(),
                OrderApi__Term_End_Date__c = System.today().addYears(1),
                OrderApi__Contact__c = con.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Sales_Order_Line__c = line.Id,
                OrderApi__Sales_Order__c = line.OrderApi__Sales_Order__c,
                OrderApi__Subscription__c = line.OrderApi__Subscription__c
        );

        insert term;
        return term;
    }
}