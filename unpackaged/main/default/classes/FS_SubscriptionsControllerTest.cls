@IsTest
public with sharing class FS_SubscriptionsControllerTest {

    private static void createData() {

        Account parentAccount = new Account(Name = 'Test Parent Account', ShippingCountry = 'United States');
        insert parentAccount;

        Account childAccount = new Account(Name = 'Test Child Account', ShippingCountry = 'United States');
        childAccount.ParentId = parentAccount.Id;
        insert childAccount;

        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact1';
        con1.AccountId = childAccount.Id;

        insert con1;

        Contact con2 = new Contact();
        con2.FirstName = 'Test';
        con2.LastName = 'Contact2';
        con2.AccountId = childAccount.Id;

        insert con2;

        childAccount.OrderApi__Primary_Contact__c = con1.Id;
        update childAccount;


        OrderApi__Business_Group__c businessGroup = new OrderApi__Business_Group__c(Name = 'Test Business Group');
        insert businessGroup;


        OrderApi__Payment_Terms__c paymentTerms = new OrderApi__Payment_Terms__c(Name = 'Due on Receipt',
                OrderApi__Display_Name__c = 'Due at the time of Receipt',
                OrderApi__Display_Message__c = 'Please remit payment upon receipt of this invoice.',
                OrderApi__Variable__c = 0);
        insert paymentTerms;


        OrderApi__Subscription_Plan__c SubscriptionPlan = new OrderApi__Subscription_Plan__c(Name = 'Test Sub Plan',
                OrderApi__Type__c = 'Calendar', OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12, OrderApi__Advanced_Calendar_Days__c = 60,
                OrderApi__Advanced_Calendar_Free_Paid__c = 'Paid', OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec', OrderApi__Enable_Proration__c = true,
                OrderApi__Proration_Rule__c = 'Bi-Annuanlly', OrderApi__Invoice_Days_Variable__c = 31,
                OrderApi__Auto_Renew_Option__c = 'Enabled', OrderApi__Payment_Terms__c = paymentTerms.Id,
                OrderApi__Bill_Cycle__c = 'AUTO', OrderApi__Business_Group__c = businessGroup.Id,
                OrderApi__Is_Active__c = true
        );
        insert SubscriptionPlan;


        OrderApi__Item_Class__c ItemClass = new OrderApi__Item_Class__c(Name = 'Memberships',
                OrderApi__Business_Group__c = businessGroup.Id, OrderApi__Is_Subscription__c = true);
        insert ItemClass;


        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();


        OrderApi__Item__c ContactItem = new OrderApi__Item__c(Name = 'Personal Membership', OrderApi__Business_Group__c = businessGroup.Id,
                OrderApi__Item_Class__c = ItemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0);
        itemList.add(ContactItem);

        OrderApi__Item__c CompanyItem = new OrderApi__Item__c(Name = 'Company Membership', OrderApi__Business_Group__c = businessGroup.Id,
                OrderApi__Item_Class__c = ItemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0,
                FSP_FonMPP__Account_Subscriptions_Visible__c = 'Primary Contact;Account Contacts;Child Account Contacts');
        itemList.add(CompanyItem);


        insert itemList;


        List<OrderApi__Item_Subscription_Plan__c> itemLinks = new List<OrderApi__Item_Subscription_Plan__c>();

        OrderApi__Item_Subscription_Plan__c ContactSubscriptionPlanLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Subscription_Plan__c = SubscriptionPlan.Id,
                OrderApi__Item__c = ContactItem.Id, OrderApi__Is_Default__c = true
        );
        itemLinks.add(ContactSubscriptionPlanLink);

        OrderApi__Item_Subscription_Plan__c CompanySubscriptionPlanLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Subscription_Plan__c = SubscriptionPlan.Id,
                OrderApi__Item__c = CompanyItem.Id, OrderApi__Is_Default__c = true
        );
        itemLinks.add(CompanySubscriptionPlanLink);

        insert itemLinks;

        CompanyItem.OrderApi__Is_Active__c = true;
        ContactItem.OrderApi__Is_Active__c = true;


        update CompanyItem;
        update ContactItem;

        List<OrderApi__Subscription__c> subscriptionList = new List<OrderApi__Subscription__c>();

        OrderApi__Subscription__c ParentCompanySubscription = new OrderApi__Subscription__c(OrderApi__Business_Group__c = businessGroup.Id,
                OrderApi__Account__c = parentAccount.Id, OrderApi__Entity__c = 'Account', OrderApi__Subscription_Plan__c = SubscriptionPlan.Id,
                OrderApi__Activated_Date__c = System.today(),
                OrderApi__Item__c = CompanyItem.Id, OrderApi__Is_Active__c = true);
        subscriptionList.add(ParentCompanySubscription);


        OrderApi__Subscription__c ChildCompanySubscription = new OrderApi__Subscription__c(OrderApi__Business_Group__c = businessGroup.Id,
                OrderApi__Account__c = childAccount.Id, OrderApi__Entity__c = 'Account', OrderApi__Subscription_Plan__c = SubscriptionPlan.Id,
                OrderApi__Activated_Date__c = System.today(),
                OrderApi__Item__c = CompanyItem.Id, OrderApi__Is_Active__c = true);
        subscriptionList.add(ChildCompanySubscription);

        OrderApi__Subscription__c ChildContactSubscription = new OrderApi__Subscription__c(OrderApi__Business_Group__c = businessGroup.Id,
                OrderApi__Contact__c = con1.Id, OrderApi__Entity__c = 'Contact', OrderApi__Subscription_Plan__c = SubscriptionPlan.Id,
                OrderApi__Activated_Date__c = System.today(),
                OrderApi__Item__c = ContactItem.Id, OrderApi__Is_Active__c = true);
        subscriptionList.add(ChildContactSubscription);

        insert subscriptionList;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'];

        List<User> userList = new List<User>();

        User primUser = new User(Alias = 'TestCon1', Email = 'standarduser98@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Contact1', FirstName = 'Test', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id, CommunityNickname = 'Test1',
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUser1@testorg.com', ContactId = con1.Id);
        userList.add(primUser);

        User user2 = new User(Alias = 'TestCon2', Email = 'standarduser98@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Contact2', FirstName = 'Test', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id, CommunityNickname = 'Test2',
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUser2@testorg.com', ContactId = con2.Id);
        userList.add(user2);

        insert userList;

    }


    @IsTest
    static void testAllSubscriptions() {

        createData();

        User user1 = [SELECT Name, Id, ContactId FROM User WHERE Name = 'Test Contact1'];
        System.runAs(user1) {
            FS_SubscriptionsController.getAllSubscriptions();
            FS_SubscriptionsController.getProformaURL('');
            FS_SubscriptionsController.getSubInstruction('');

        }

    }
}