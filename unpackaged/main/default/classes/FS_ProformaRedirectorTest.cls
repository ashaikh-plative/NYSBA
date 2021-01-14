@IsTest
public with sharing class FS_ProformaRedirectorTest {

    private static final String COMPANY_MEMBERSHIP_NAME = 'Company Membership';
    private static final String CORPORATE_MEMBERSHIP_NAME = 'Corporate Membership';
    private static final String BUSINESS_GROUP_NAMESTRING = 'National Association of Independent Schools';


    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        FSP_FonMPP.InstallScripts mpp = new FSP_FonMPP.InstallScripts();
        mpp.onInstall(null);

//        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
//        Framework.RoutingRule mppRoutingRule = new Framework.RoutingRule();
//        mppRoutingRule.apexClass = FSP_FonMPP.SalesOrderRoutingRule.class.getName();
//        mppRoutingRule.namespace = 'FSP_FonMPP';
//        mppRoutingRule.isEnabled = true;
//        mppRoutingRule.sObjectName = SObjectType.OrderApi__Sales_Order__c.getName();
//        mppRoutingRule.executionOrder = 1;
//        rules.add(mppRoutingRule);
//        Framework.Config.push(rules);
    }

    @IsTest
    public static void testSalesOrderWithSimpleId_ExpectRedirect() {
        Account acc = new Account(Name = 'Test Account weirder name fvewibnuigenbunfwidsbgwiu');
        Contact con = new Contact(LastName = 'Test', FirstName = 'Chris');
        OrderApi__Business_Group__c busGroup = createBusinessGroup();
        OrderApi__Payment_Terms__c paymentTerms = createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = createSubscriptionPlan(paymentTerms, busGroup);
//        PagesApi__Site__c site = createCommunitySite(busGroup);
//        PagesApi__Community_Group__c commGroup = createCommunityGroup(site);
        OrderApi__Item__c subItem = createSubItem(busGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = createSubscriptionPlanItemLink(subscriptionPlan, subItem);

//        Create sales order for user to checkout
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
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        Test.stopTest();

        salesOrder = [SELECT Id, FSP_FonMPP__Long_URL__c, FSP_FonMPP__Long_URL_Lightning__c, FSP_FonMPP__Simple_Id__c
        FROM OrderApi__Sales_Order__c
        WHERE Id = :salesOrder.Id];
        //FS_ProformaRedirector x = new FS_ProformaRedirector();
        //x.redirectToRelevantPage();
        System.debug(salesOrder.FSP_FonMPP__Simple_Id__c);

//        salesOrder = [SELECT Id, FSP_FonMPP__Simple_Id__c
//        FROM OrderApi__Sales_Order__c];
        salesOrder.FSP_FonMPP__Long_URL_Lightning__c = 'test';
        salesOrder.FSP_FonMPP__Long_URL__c = 'long test url';
        update salesOrder;
        PageReference pageRef = Page.pfr;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('sid', salesOrder.FSP_FonMPP__Simple_Id__c);

        ApexPages.StandardController sc = new ApexPages.StandardController(salesOrder);
        FS_ProformaRedirector redirector = new FS_ProformaRedirector(sc);

        PageReference ref = redirector.redirectToRelevantPage();
//        System.assert(ref != null && ref.getUrl() == salesOrder.NAIS_Membership_Proforma_Invoice_URL__c);


//        acc = [
//                SELECT Id,FS_Re_Join_Date__c,FS_Paid_Through_Date__c
//                FROM Account
//                LIMIT 1
//        ];
//        OrderApi__Renewal__c term =  [
//                SELECT Id,OrderApi__Term_Start_Date__c
//                FROM OrderApi__Renewal__c
//                LIMIT 1
//        ];
//        OrderApi__Subscription__c sub = [
//                SELECT Id,OrderApi__Paid_Through_Date__c
//                FROM OrderApi__Subscription__c
//                LIMIT 1
//        ];
//
//        System.assertEquals(acc.FS_Paid_Through_Date__c, sub.OrderApi__Paid_Through_Date__c, 'Account Paid Through Date not correct ==== ');
//        System.assertEquals(acc.FS_Re_Join_Date__c, term.OrderApi__Term_Start_Date__c, 'Account Rejoin Date not correct ==== ');
    }


//    @IsTest
//    public static void testUpdatingSubscription_ExpectAccountUpdatedFromSubscription() {
//        Account acc = createAccount('Test Account weirder name fvewibnuigenbunfwidsbgwiu');
//        acc = updatePaidThroughDate(acc);
//        Contact con = createContact('Test', 'Contact');
//        OrderApi__Business_Group__c busGroup = createBusinessGroup();
//        OrderApi__Payment_Terms__c paymentTerms = createPaymentTerms();
//        OrderApi__Subscription_Plan__c subscriptionPlan = createSubscriptionPlan(paymentTerms, busGroup);
//        PagesApi__Site__c site = createCommunitySite(busGroup);
//        PagesApi__Community_Group__c commGroup = createCommunityGroup(site);
//        OrderApi__Item__c subItem = createSubItem(busGroup, commGroup);
//        OrderApi__Item_Subscription_Plan__c subPlanLink = createSubscriptionPlanItemLink(subscriptionPlan, subItem);
//
////        Create sales order for user to checkout
//        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
////                OrderApi__Account__c = acc.Id,
////                OrderApi__Contact__c = con.Id,
//                OrderApi__Status__c = 'Open',
//                OrderApi__Is_Posted__c  = false,
//                OrderApi__Entity__c = 'Contact',
//                OrderApi__Posting_Entity__c = 'Receipt',
//                OrderApi__Business_Group__c = busGroup.Id);
//        insert salesOrder;
//
//        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
//                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
//                OrderApi__Item__c = subItem.Id,
//                OrderApi__Sales_Order__c = salesOrder.Id,
//                OrderApi__Sale_Price__c = 0,
//                OrderApi__Contact__c = con.Id,
//                OrderApi__Account__c = acc.Id
//        );
//
//        insert orderLine;
//
//        Test.startTest();
//
//        salesOrder.OrderApi__Status__c = 'Closed';
//        salesOrder.OrderApi__Posting_Status__c = 'Posted';
//        update salesOrder;
//
//        Test.stopTest();
//
//        acc = [
//                SELECT Id,FS_Re_Join_Date__c,FS_Paid_Through_Date__c
//                FROM Account
//                LIMIT 1
//        ];
//        OrderApi__Renewal__c term =  [
//                SELECT Id,OrderApi__Term_Start_Date__c
//                FROM OrderApi__Renewal__c
//                LIMIT 1
//        ];
//        OrderApi__Subscription__c sub = [
//                SELECT Id,OrderApi__Paid_Through_Date__c
//                FROM OrderApi__Subscription__c
//                LIMIT 1
//        ];
//
//        System.assertEquals(acc.FS_Paid_Through_Date__c, sub.OrderApi__Paid_Through_Date__c, 'Account Paid Through Date not correct ==== ');
//        System.assertEquals(acc.FS_Re_Join_Date__c, term.OrderApi__Term_Start_Date__c, 'Account Rejoin Date not correct ==== ');
//    }

    // have to query for an existing contact. Not sure why this works,
    // but attempting to create contacts manually will throw an error
    private static Contact createContact(String firstName, String lastName) {
        Contact con = [SELECT Id,FirstName,LastName FROM Contact LIMIT 1];
//        Contact con = new Contact(FirstName=firstName, LastName=lastName,Use_Account_Address__c=false);
//        insert con;
        return con;
    }

    // have to query for an existing account. Not sure why this works,
    // but attempting to create accounts manually will throw an error
//    private static Account createAccount(String nameString) {
//        Account acc = [SELECT Id,Name,FS_Paid_Through_Date__c FROM Account LIMIT 1];
//        acc.FS_Paid_Through_Date__c = Date.newInstance(
//                System.today().addYears(-2).year(),
//                System.today().addMonths(3).month(),
//                System.today().toStartOfMonth().addDays(-1).day()
//        );
//        update acc;
////        Account acc = new Account(Name=nameString,Member_Type__c=MEMBER_STATUS_STRING);
////        insert acc;
//        return acc;
//    }

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

    private static OrderApi__Item__c createSubItem(OrderApi__Business_Group__c busGroup) {
        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = CORPORATE_MEMBERSHIP_NAME,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true);
        insert itemClass;
        OrderApi__Item__c  item = new OrderApi__Item__c(Name=COMPANY_MEMBERSHIP_NAME,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0);
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




//    PageReference pageRef = Page.yourPageName;


}