@IsTest
private without sharing class FS_JoinProcess_SecondStage_ConTest {
    @TestSetup
    private static void setup() {
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
                OrderApi__Preferred_Email_Type__c = 'Personal',
                FS_NYS_Admission_Date__c = Date.valueOf('2020-04-01')
        );
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
        OrderApi__Package_Item__c pkgItem = new OrderApi__Package_Item__c(
                OrderApi__Item__c = item2.Id,
                OrderApi__Package__c = item1.Id
        );
        insert pkgItem;
        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c(
                OrderApi__Item__c = item1.Id,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 50
        );
        insert priceRule;
        OrderApi__Price_Rule_Variable__c priceRuleVariable01 = new OrderApi__Price_Rule_Variable__c(
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Object__c = 'contact',
                OrderApi__Field__c = 'fs_sustaining_member__c',
                OrderApi__Operator__c = 'not equal to',
                OrderApi__Value__c = 'true'
        );
        insert priceRuleVariable01;
        OrderApi__Price_Rule_Variable__c priceRuleVariable02 = new OrderApi__Price_Rule_Variable__c(
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Object__c = 'contact',
                OrderApi__Field__c = 'fs_comp_member__c',
                OrderApi__Operator__c = 'equals',
                OrderApi__Value__c = 'true'
        );
        insert priceRuleVariable02;
        OrderApi__Price_Rule__c priceRule1 = new OrderApi__Price_Rule__c(
                OrderApi__Item__c = item1.Id,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 50
        );
        insert priceRule1;
        OrderApi__Price_Rule_Variable__c priceRuleVariable11 = new OrderApi__Price_Rule_Variable__c(
                OrderApi__Price_Rule__c = priceRule1.Id,
                OrderApi__Object__c = 'contact',
                OrderApi__Field__c = 'fs_first_admit_date__c',
                OrderApi__Operator__c = 'greater than',
                OrderApi__Value__c = '2020-04-01'
        );
        insert priceRuleVariable11;
        OrderApi__Price_Rule_Variable__c priceRuleVariable12 = new OrderApi__Price_Rule_Variable__c(
                OrderApi__Price_Rule__c = priceRule1.Id,
                OrderApi__Object__c = 'contact',
                OrderApi__Field__c = 'fs_years_since_admitted_to_bar__c',
                OrderApi__Operator__c = 'greater than',
                OrderApi__Value__c = '5'
        );
        insert priceRuleVariable12;
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
                Name = '1 Year Termed',
                OrderApi__Is_Active__c = true,
                OrderApi__Type__c = 'Termed',
                OrderApi__Initial_Term_Months__c = 12
        );
        insert subscriptionPlan;
    }

    @IsTest
    static void testGetMembershipItems() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId, OrderApi__Entity__c = 'Contact');
        insert so;
        FS_JoinProcess_SecondStage_Controller.getMembershipItems(contactId, item1Id, so.Id);
    }

    @IsTest
    static void testGetPackageItems() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        FS_JoinProcess_SecondStage_Controller.getPackageItems(contactId, item1Id, null, '');
    }

    @IsTest
    static void testCreateSO() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        FS_JoinProcess_SecondStage_Controller.createSO(contactId, item1Id);
    }

    @IsTest
    static void testUpdateSO() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId, OrderApi__Entity__c = 'Contact');
        insert so;
        FS_JoinProcess_SecondStage_Controller.updateSO(contactId, item1Id, item1Id, so.Id);
    }

    @IsTest
    static void testAddPackageItemSOL() {
        Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'][0].Id;
        Id item1Id = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test1'][0].Id;
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId, OrderApi__Entity__c = 'Contact');
        insert so;
        FS_JoinProcess_SecondStage_Controller.addPackageItemSOL(so.Id, new List<String>{[SELECT Id FROM OrderApi__Package_Item__c][0].Id}, new List<String>(), new List<String>(), '', '');
        FS_JoinProcess_SecondStage_Controller.testCoverage();
    }
}