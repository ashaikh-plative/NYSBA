@IsTest
public class FS_StudentExtensionControllerTest{
    private static final String ACTIVE_STRING = 'Active';
    private static final String LAW_STUDENT = 'Law Student Section';

    static testMethod void renewStudentMembership() {
        Account a = new Account(Name='Test Account Name');
        insert a;

        Contact con = new Contact(AccountId = a.Id);
        con.LastName = 'Test Contact';
        con.FS_Graduation_Date__c = System.today() + 10;
        insert con;

        User user = new User();
        user.ProfileId = [SELECT Id FROM Profile WHERE Name='Fonteva Customer Community Login User'].get(0).Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@domain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = con.Id;

        insert user;

        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test');
        insert busGroup;

        OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c(
                Name = 'TestSubPlan', OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Invoice_Days_Variable__c = 90,OrderApi__Grace_Period__c = 120);
        insert subPlan;

        //Inserting Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name = 'Test item', OrderApi__Business_Group__c = busGroup.Id);
        insert itemClass;

        //Inserting Item
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Item__c item = new OrderApi__Item__c(Name = LAW_STUDENT,
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id);
        insert item;
        itemList.add(item);


        OrderApi__Subscription__c subscription = new OrderApi__Subscription__c(
                OrderApi__Contact__c = con.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Status__c = ACTIVE_STRING,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Days_To_Lapse__c = 50);
        insert subscription;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = con.Id,
                OrderApi__Posting_Status__c = 'Pending',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Posting_Entity__c = 'Receipt');
        insert salesOrder;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Sale_Price__c = 0
        );
        insert salesOrderLine;

        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c(Name = 'TestCommunityGroup');
        insert communityGroup;

        OrderApi__Item__c lawRenew = new OrderApi__Item__c(
                Name = 'Law Student Section - Renewal',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Linked_Community_Group__c = communityGroup.Id,
                OrderApi__Price__c = 0);
        insert lawRenew;

        OrderApi__Item__c sectionItem = new OrderApi__Item__c(
                Name = 'Test Section',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Linked_Community_Group__c = communityGroup.Id,
                OrderApi__Price__c = 0);
        insert sectionItem;

        OrderApi__Item__c sectionItem2 = new OrderApi__Item__c(
                Name = 'Test 2 Section',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Linked_Community_Group__c = communityGroup.Id,
                OrderApi__Price__c = 0);
        insert sectionItem2;

        OrderApi__Item__c sectionItem3 = new OrderApi__Item__c(
                Name = 'Test Section - Renewal',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Linked_Community_Group__c = communityGroup.Id,
                OrderApi__Price__c = 0);
        insert sectionItem3;

        OrderApi__Item__c sectionItem4 = new OrderApi__Item__c(
                Name = 'Test 2 Section - Renewal',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Linked_Community_Group__c = communityGroup.Id,
                OrderApi__Price__c = 0);
        insert sectionItem4;

        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = sectionItem.OrderApi__Item_Class__c,
                OrderApi__Item__c = sectionItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Sale_Price__c = 0
        );
        insert sol;

        OrderApi__Sales_Order_Line__c sol2 = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = sectionItem2.OrderApi__Item_Class__c,
                OrderApi__Item__c = sectionItem2.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Sale_Price__c = 0
        );
        insert sol2;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c = subscription.Id,
                OrderApi__Contact__c = con.Id, OrderApi__Is_Active__c = true, OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Item__c = item.Id, OrderApi__Term_End_Date__c = System.today() +1,
                OrderApi__Grace_Period_End_Date__c = System.today() + 10);
        insert term;

        PagesApi__Community_Group_Member__c communityGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = communityGroup.Id,
                PagesApi__Contact__c = con.Id,
                PagesApi__Status__c = 'Active'
        );
        insert communityGroupMember;

        FS_Community_Group_Member_Term__c cgmTerm = new FS_Community_Group_Member_Term__c(
                FS_Community_Group_Member__c = communityGroupMember.Id, FS_Term__c = term.Id,
                FS_Term_Start_Date__c = System.today(), FS_Term_End_Date__c = System.today() +10,
                FS_Sales_Order_Line__c = salesOrderLine.Id);
        FS_Community_Group_Member_Term__c cgmTerm2 = new FS_Community_Group_Member_Term__c(
                FS_Community_Group_Member__c = communityGroupMember.Id, FS_Term__c = term.Id,
                FS_Term_Start_Date__c = System.today(), FS_Term_End_Date__c = System.today() +10,
                FS_Sales_Order_Line__c = sol2.Id);
        FS_Community_Group_Member_Term__c cgmTerm3 = new FS_Community_Group_Member_Term__c(
                FS_Community_Group_Member__c = communityGroupMember.Id, FS_Term__c = term.Id,
                FS_Term_Start_Date__c = System.today(), FS_Term_End_Date__c = System.today() +10,
                FS_Sales_Order_Line__c = sol.Id);

        insert cgmTerm;
        insert cgmTerm2;
        insert cgmTerm3;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;

        Test.startTest();
        System.runAs(user) {
            FS_StudentExtensionController.updateContact(con);
            System.assertEquals('Test Contact',FS_StudentExtensionController.getDisplayInfo().LastName);
            FS_StudentExtensionButton.showButton();
            FS_StudentExtensionController.checkPageDisplay();
            FS_StudentExtensionController.createSalesOrder(subPlan.Id,item.Id);
        }

        Test.stopTest();
    }
//    @TestSetup
//    private static void install() {
//        Framework.Installer.install();
//        PagesApi.PackageScripts.install();
//        OrderApi.PackageScripts.install();
//        EventApi.PackageScripts.install();
//        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
//        Framework.RoutingRule routingRule = new Framework.RoutingRule();
//        routingRule.apexClass = FS_TermRoutingRule.class.getName();
//        routingRule.namespace = ' ';
//        routingRule.isEnabled = true;
//        routingRule.sObjectName = 'OrderApi__Renewal__c';
//        routingRule.executionOrder = 50;
//        rules.add(routingRule);
//        Framework.Config.push(rules);
//
//
//    }
//
//    @IsTest
//    public static void testUserContact() {
//        Account a = new Account(Name='Test Account Name');
//        insert a;
//
//        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.id);
//        insert c;
//
//        User user = new User();
//        user.ProfileId = [SELECT Id FROM Profile WHERE Name='Fonteva Customer Community Login User'].get(0).Id;
//        user.EmailEncodingKey = 'ISO-8859-1';
//        user.LanguageLocaleKey = 'en_US';
//        user.TimeZoneSidKey = 'America/New_York';
//        user.LocaleSidKey = 'en_US';
//        user.FirstName = 'first';
//        user.LastName = 'last';
//        user.Username = 'test@domain.com';
//        user.CommunityNickname = 'testUser123';
//        user.Alias = 't1';
//        user.Email = 'no@email.com';
//        user.IsActive = true;
//        user.ContactId = c.Id;
//
//        insert user;
//
//
//        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('test item class');
//        insert itemClass;
//        OrderApi__Item__c item = FS_TestUtils.createItem('test item', itemClass.Id);
//        insert item;
//        OrderApi__Sales_Order__c so = FS_TestUtils.createSalesOrder(c.Id,a.Id,'Pending', 'Open');
//        insert so;
//        OrderApi__Sales_Order__c so2 = FS_TestUtils.createSalesOrder(c.Id,a.Id,'Pending', 'Open');
////        insert so2;
//        OrderApi__Sales_Order_Line__c sol = FS_TestUtils.createSalesOrderLine(item.Id,so.Id,c.Id,a.Id);
//        insert sol;
//        OrderApi__Sales_Order_Line__c sol2 = FS_TestUtils.createSalesOrderLine(item.Id,so2.Id,c.Id,a.Id);
////        insert sol2;
//        OrderApi__Subscription_Plan__c subPlan = FS_TestUtils.createSubsPlan('test plan');
//        subPlan.OrderApi__Type__c = 'sectionCommittee';
//        subPlan.OrderApi__Is_Active__c = true;
//        insert subPlan;
//        OrderApi__Subscription__c sub = FS_TestUtils.createSubscription(item.Id, subPlan.Id, a.Id, c.Id, sol.Id);
//        insert sub;
//        sol.OrderApi__Is_Renewal__c = true;
//        sol.OrderApi__Subscription__c = sub.Id;
//        update sol;
//        so.OrderApi__Posting_Status__c = 'Posted';
//        so.OrderApi__Status__c = 'Closed';
//        so2.OrderApi__Status__c = 'Closed';
//        update so;
////        update so2;
//
//        Test.startTest();
//        System.runAs(user) {
//            FS_StudentExtensionController.updateContact(c);
//            System.assertEquals('Contact Last Name',FS_StudentExtensionController.getDisplayInfo().LastName);
//
//            FS_StudentExtensionController.createSalesOrder(subPlan.Id,item.Id);
//        }
//
//        Test.stopTest();
//    }
}