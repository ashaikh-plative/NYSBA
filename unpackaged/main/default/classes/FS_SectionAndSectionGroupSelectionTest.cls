@IsTest
public with sharing class FS_SectionAndSectionGroupSelectionTest {
    
    @TestSetup 
    static void setup() {
        Framework.Installer.install();
        // PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        // EventApi.PackageScripts.install();

        Account a = new Account(
                Name = 'Test Account', 
                ShippingCountry = 'United States');
        insert a;

        Contact c = new Contact(
                FirstName = 'Test', 
                LastName = 'Contact', 
                AccountId = a.Id, 
                OrderApi__Personal_Email__c = 'fsemailupdatetest@example.com', 
                OrderApi__Preferred_Email_Type__c = 'Personal');
        insert c;

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test');
        insert busGroup;

        PagesApi__Site__c site = new PagesApi__Site__c(
                Name = 'Test Site',
                OrderApi__Business_Group__c=busGroup.Id
        );
        insert site;

        PagesApi__Community_Group__c commGroup = new PagesApi__Community_Group__c(
                Name = 'Senior Lawyers Section',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section'
        );
        insert commGroup;

        PagesApi__Community_Group__c commGroup1 = new PagesApi__Community_Group__c(
                Name = 'Young Lawyers Section',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section'
        );
        insert commGroup1;

        PagesApi__Community_Group__c commGroup2 = new PagesApi__Community_Group__c(
                Name = 'Test',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section'
        );
        insert commGroup2;

        PagesApi__Community_Group__c commGroup3 = new PagesApi__Community_Group__c(
                Name = 'Section',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section Committee',
                FS_Parent_Section__c = commGroup1.Id
        );
        insert commGroup3;

        PagesApi__Community_Group__c commGroup4 = new PagesApi__Community_Group__c(
                Name = 'Test123',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section Committee',
                FS_Parent_Section__c = commGroup3.Id
        );
        insert commGroup4;

        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(
                Name = 'Test',
                OrderApi__Business_Group__c = busGroup.Id, 
                OrderApi__Is_Subscription__c = false);
        insert itemClass;

        OrderApi__Item__c  item = new OrderApi__Item__c(
                Name='Test',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, 
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true, 
                OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup1.Id);
        OrderApi__Item__c  item1 = new OrderApi__Item__c(
                Name='Test1',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, 
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true, 
                OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup1.Id);
        OrderApi__Item__c  item2 = new OrderApi__Item__c(
                Name='Test2',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, 
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true, 
                OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup2.Id);
        insert new List<OrderApi__Item__c>{item, item1, item2};
		OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
            Name = '1 Year Termed',
            OrderApi__Is_Active__c = true,
            OrderApi__Type__c = 'Termed',
            OrderApi__Initial_Term_Months__c = 12
        );
        insert subscriptionPlan;
    }

    @IsTest 
    static void testSetup() {
        // Get Contact record
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        // Get Item 1
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        // Create Sales Order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Status__c = 'Open'
        );
        insert salesOrder;

        OrderApi__Sales_Order_Line__c tempSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Item__c = item1Id,
                OrderApi__Price_Override__c = true,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                FS_Additional_Data__c = '{"sectionCommittees":[]}'
        );
        insert tempSalesOrderLine;
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;
        FS_SectionAndSectionGroupSelectionCntrl.setup(true, true, contactId, true, salesOrder.Id, false);
    }

    @IsTest 
    static void testSetupTestNullOrder() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        FS_SectionAndSectionGroupSelectionCntrl.setup(true, true, contactId, true, null, false);
    }
    
    @IsTest
    static void filterOutExistingItemsTest() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        FS_SectionAndSectionGroupSelectionCntrl.setup(true, true, contactId, true, null, true);        
    }

    @IsTest 
    static void testNext() {
        // Get contact record
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        // Get Item 1
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        // Get Item 2
        Id item2Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test2'][0].Id;
        // Get subscription plan
        Id subPlanId = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name = '1 Year Termed'][0].Id;
        OrderApi__Subscription__c subscriptionPlan = new OrderApi__Subscription__c(
            OrderApi__Contact__c = contactId,
            OrderApi__Status__c = 'Active',
            OrderApi__Item__c = item2Id,
            OrderApi__Subscription_Plan__c = subPlanId
        );
        insert subscriptionPlan;
        
        
        // Create Sales Order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Status__c = 'Open'
        );
        insert salesOrder;

        OrderApi__Sales_Order_Line__c tempSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Item__c = item1Id,
                OrderApi__Price_Override__c = true,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                FS_Additional_Data__c = '{"sectionCommittees":[]}'
        );
        insert tempSalesOrderLine;
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;

        String testString = (String) FS_SectionAndSectionGroupSelectionCntrl.setup(true, true, contactId, true, salesOrder.Id, false).get('Items');
        testString = testString.replace('"checked":false', '"checked":true');
        Test.startTest();
        // FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, null);
        FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, salesOrder.Id, true, null, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        //FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, null, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        // FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, '');        
        //FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, item1Id, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        Test.stopTest();
    }

    @IsTest
    static void deleteMembershipItemFromOrderTest() {
        //  Get Contact ID
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        // Create Sales Order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Status__c = 'Open'
        );
        insert salesOrder;
        // 
        Id membershipItemId = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test2'][0].Id;
        OrderApi__Sales_Order_Line__c membershipOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c = membershipItemId,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Contact__c = contactId
        );
        insert membershipOrderLine;

        FS_SectionAndSectionGroupSelectionCntrl.deleteMembershipItemFromOrder(contactId, salesOrder.Id, membershipItemId, false);
    }

    @IsTest
    static void testNext1() {
        // Get contact record
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        // Get Item 1
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        // Get Item 2
        Id item2Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test2'][0].Id;
        // Get subscription plan
        Id subPlanId = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name = '1 Year Termed'][0].Id;
        OrderApi__Subscription__c subscriptionPlan = new OrderApi__Subscription__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Status__c = 'Active',
                OrderApi__Item__c = item2Id,
                OrderApi__Subscription_Plan__c = subPlanId
        );
        insert subscriptionPlan;


        // Create Sales Order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Status__c = 'Open'
        );
        insert salesOrder;

        OrderApi__Sales_Order_Line__c tempSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Item__c = item1Id,
                OrderApi__Price_Override__c = true,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                FS_Additional_Data__c = '{"sectionCommittees":[]}'
        );
        insert tempSalesOrderLine;
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;

        String testString = (String) FS_SectionAndSectionGroupSelectionCntrl.setup(true, true, contactId, true, salesOrder.Id, false).get('Items');
        testString = testString.replace('"checked":false', '"checked":true');
        Test.startTest();
        // FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, null);
        //FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, salesOrder.Id, true, null, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, null, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        // FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, '');
        //FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, item1Id, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        Test.stopTest();
    }

    @IsTest
    static void testNext2() {
        // Get contact record
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        // Get Item 1
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        // Get Item 2
        Id item2Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test2'][0].Id;
        // Get subscription plan
        Id subPlanId = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name = '1 Year Termed'][0].Id;
        OrderApi__Subscription__c subscriptionPlan = new OrderApi__Subscription__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Status__c = 'Active',
                OrderApi__Item__c = item2Id,
                OrderApi__Subscription_Plan__c = subPlanId
        );
        insert subscriptionPlan;


        // Create Sales Order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Status__c = 'Open'
        );
        insert salesOrder;

        OrderApi__Sales_Order_Line__c tempSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Item__c = item1Id,
                OrderApi__Price_Override__c = true,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Contact__c = contactId,
                OrderApi__Entity__c = 'Contact',
                FS_Additional_Data__c = '{"sectionCommittees":[]}'
        );
        insert tempSalesOrderLine;
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;

        String testString = (String) FS_SectionAndSectionGroupSelectionCntrl.setup(true, true, contactId, true, salesOrder.Id, false).get('Items');
        testString = testString.replace('"checked":false', '"checked":true');
        Test.startTest();
        // FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, null);
        //FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, salesOrder.Id, true, null, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        //FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, null, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        // FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, '');
        FS_SectionAndSectionGroupSelectionCntrl.nextController(testString, contactId, null, true, item1Id, 'FSP_FonMPP__Long_URL__c', false, item2Id);
        Test.stopTest();
    }
}