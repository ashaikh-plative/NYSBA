/**
* Created by santhosh on 10-02-2020.
*/

@IsTest
private class FS_ContactCustomFieldsRoutingRuleTest {
    private static final Date TODAY_DATE = System.today();
    private static final String CONTACT_STRING = 'Contact';
    @TestSetup
    private static void install() {
        
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        ROEApi.PackageScripts.install();
        CPBase.PackageScripts.install();
        LTE.PackageScripts.install();
        FDService.BUPackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule accountJoinDateUpdate = new Framework.RoutingRule();
        accountJoinDateUpdate.apexClass = FS_ContactCustomFieldsRoutingRule.class.getName();
        accountJoinDateUpdate.namespace = '';
        accountJoinDateUpdate.isEnabled = true;
        accountJoinDateUpdate.sObjectName = 'OrderApi__Subscription__c';
        accountJoinDateUpdate.executionOrder = 45;
        rules.add(accountJoinDateUpdate);
        Framework.Config.push(rules);
        
        //Insert account
        Account account = FS_TestUtils.createAccount('TestAccount');
        insert account;
        
        //Insert contact
        List<Contact> contacts = new List<Contact>();
        Contact contact = FS_TestUtils.createContact('TestContact', 'test1@gmail.com');
        contact.FS_Membership_Expiry_Date__c = null;
        contacts.add(contact);
        Contact contact2 = FS_TestUtils.createContact('TestContact', 'test@gmail.com');
        contact2.FS_Original_Join_Date__c = TODAY_DATE - 354;
        contact2.FS_Membership_Expiry_Date__c = TODAY_DATE - 100;
        contacts.add(contact2);
        insert contacts;
    }
    
    @isTest
    private static void testBehaviorSubscriptionInsertion() {

        
        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Contact contact = [SELECT Id, FS_Contact_Member_Status__c FROM Contact WHERE Email = 'test1@gmail.com' LIMIT 1];
        Contact contact2 = [SELECT Id, FS_Contact_Member_Status__c FROM Contact WHERE Email = 'test@gmail.com' LIMIT 1];
        
        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup('Test');
        // insert busGroup;
        
        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Test');
        itemClass.OrderApi__Is_Subscription__c = true;
        itemClass.FS_Is_Membership__c = true;
        insert itemClass;
        
        //Insert Item
        OrderApi__Item__c item = FS_TestUtils.createItem('Test1', itemClass.Id);
        item.OrderApi__Display_Name__c = 'Law Student';
        item.OrderApi__Is_Subscription__c = true;
        insert item;
        
        OrderApi__Item__c item2 = FS_TestUtils.createItem('Test2', itemClass.Id);
        item2.OrderApi__Display_Name__c = 'Attorney';
        item2.OrderApi__Is_Subscription__c = true;
        insert item2;
        
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubsPlan('Test plan');
        subscriptionPlan.OrderApi__Type__c = 'Termed';
        subscriptionPlan.OrderApi__Initial_Term_Months__c = 12;
        subscriptionPlan.OrderApi__Renewal_Term_Months__c =12;
        subscriptionPlan.OrderApi__Is_Active__c = true;
        subscriptionPlan.OrderApi__Grace_Period__c = 0;
        insert subscriptionPlan;
        
        //Insert subscription
        List<OrderApi__Subscription__c> oSubList= new List<OrderApi__Subscription__c>();
        OrderApi__Subscription__c oSub= new OrderApi__Subscription__c(OrderApi__Contact__c=contact.Id ,OrderApi__Account__c= account.Id,
                                                                      OrderApi__Item__c = item.Id
                                                                     );
        oSub.OrderApi__Entity__c = CONTACT_STRING;
        oSub.OrderApi__Subscription_Plan__c = subscriptionPlan.Id;
        oSubList.add(oSub);
        OrderApi__Subscription__c oSub2= new OrderApi__Subscription__c(OrderApi__Contact__c=contact2.Id ,OrderApi__Account__c= account.Id,
                                                                       OrderApi__Item__c = item.Id,
                                                                       OrderApi__Business_Group__c= busGroup.Id);
        oSub2.OrderApi__Entity__c = CONTACT_STRING;
        oSub2.OrderApi__Subscription_Plan__c = subscriptionPlan.Id;
        oSubList.add(oSub2);
        insert oSubList;
        
        List<OrderApi__Renewal__c> termList= new List<OrderApi__Renewal__c>();
        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        term.OrderApi__Subscription__c = oSub.Id;
        term.OrderApi__Is_Active__c = true;
        term.OrderApi__Term_Start_Date__c = TODAY_DATE - 10;
        term.OrderApi__Term_End_Date__c = TODAY_DATE + 354;
        termList.add(term);
        OrderApi__Renewal__c term2 = new OrderApi__Renewal__c();
        term2.OrderApi__Subscription__c = oSub2.Id;
        term2.OrderApi__Is_Active__c = true;
        term2.OrderApi__Term_Start_Date__c = TODAY_DATE - 10;
        term2.OrderApi__Term_End_Date__c = TODAY_DATE + 354;
        termList.add(term2);
        insert termList;
        List<Contact> cont = [SELECT Id,FS_Membership_Type__c,FS_Active_Subscription__c FROM Contact WHERE Id  =:contact.Id LIMIT 1];
        System.assertEquals(cont[0].FS_Membership_Type__c, item.OrderApi__Display_Name__c );
        System.assertEquals(cont[0].FS_Active_Subscription__c, oSub.Id );
        
    }
    @IsTest
    private static void testBehaviorSubscriptionExpiration() {

        Account account = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Contact contact = [SELECT Id, FS_Active_Subscription__c FROM Contact WHERE Email = 'test1@gmail.com' LIMIT 1];
        
        OrderApi__Business_Group__c busGroup = FS_TestUtils.createBusinessGroup('Test');
        insert busGroup;
        
        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Test');
        itemClass.OrderApi__Is_Subscription__c = true;
        itemClass.FS_Is_Membership__c = true;
        insert itemClass;
        
        //Insert Item
        OrderApi__Item__c item = FS_TestUtils.createItem('Test', itemClass.Id);
        item.OrderApi__Display_Name__c = 'Attorney';
        item.OrderApi__Is_Subscription__c = true;
        insert item;
        
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubsPlan('Test plan');
        subscriptionPlan.OrderApi__Type__c = 'Termed';
        subscriptionPlan.OrderApi__Initial_Term_Months__c = 12;
        subscriptionPlan.OrderApi__Renewal_Term_Months__c =12;
        subscriptionPlan.OrderApi__Is_Active__c = true;
        subscriptionPlan.OrderApi__Grace_Period__c = 0;
        insert subscriptionPlan;
        
        //Insert subscription
        OrderApi__Subscription__c oSub= new OrderApi__Subscription__c(OrderApi__Contact__c=contact.Id ,OrderApi__Account__c= account.Id,
                                                                      OrderApi__Item__c = item.Id,
                                                                      OrderApi__Status__c = 'Active',
                                                                      OrderApi__Business_Group__c= busGroup.Id);
        
        oSub.OrderApi__Entity__c = CONTACT_STRING;
        oSub.OrderApi__Subscription_Plan__c = subscriptionPlan.Id;
        insert oSub; 
        
        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        term.OrderApi__Subscription__c = oSub.Id;
        term.OrderApi__Is_Active__c = true;
        term.OrderApi__Term_Start_Date__c = TODAY_DATE - 10;
        term.OrderApi__Term_End_Date__c = TODAY_DATE + 354;
        term.OrderApi__Contact__c = contact.Id;
        
        insert term;

        oSub.OrderApi__Status__c = 'Expired';
        oSub.OrderApi__Current_Term_Start_Date__c = TODAY_DATE - 400;
        oSub.OrderApi__Current_Term_End_Date__c =   TODAY_DATE - 100;
        update oSub;
        
        List<Contact> cont = [SELECT Id,FS_Membership_Type__c,FS_Active_Subscription__c FROM Contact WHERE Id  =:contact.Id LIMIT 1];
        System.assertEquals( null,cont[0].FS_Active_Subscription__c );
    }
}