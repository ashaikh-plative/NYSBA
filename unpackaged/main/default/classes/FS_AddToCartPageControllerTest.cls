/**
 * Created by dfitzgerald on 2019-09-09.
 */
@IsTest
public with sharing class FS_AddToCartPageControllerTest {

    private static final String TEST_STRING = 'atcpc';
	private static final String PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'][0].Id;
    
    @TestSetup
    private static void setup() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
    }

    private static Account createAccount(String str) {
        Account newOrg = new Account(
                name=str+'orgName',
                sic='None',
                billingCountryCode='US',
                billingStreet=str+'orgStreet',
                billingCity=str+'orgCity',
                billingStateCode='MD',
                billingPostalCode='12345',
                FS_Created_By_Customer__c=true
        );
        return newOrg;
    }

    private static Contact createContact(String str, String accountId) {
        Contact newContact = new Contact(
                FirstName=str+'FirstName',
                LastName=str+'LastName',
                Email=str+'@email.com',
                AccountId=accountId
        );
        return newContact;
    }

    private static User createUser(String str, Contact contact) {
        User newUser = new User(
                LastName = contact.LastName,
                Username = str+'@email.com',
                Email = str+'@email.com',
                Alias = str,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = PROFILE_ID,
                LanguageLocaleKey = 'en_US',
                ContactId = contact.Id,
                IsActive = true
        );
        return newUser;
    }


    static testMethod void testGetContact() {
        Test.setCurrentPage(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('productId', '123');

        FS_AddToCartPageController controller = new FS_AddToCartPageController();
        System.assert(controller.parametersValid == False);
    }

    static testMethod void testGetContactId() {
        Test.startTest();
        Account account = createAccount(TEST_STRING);
        insert account;
        Contact contact = createContact(TEST_STRING, account.id);
        insert contact;
        User user = createUser(TEST_STRING, contact);
        insert user;

        System.runAs(user)
        {
            FS_AddToCartPageController controller = new FS_AddToCartPageController();
            System.assert(contact.id == controller.contactId);
        }
        Test.stopTest();
    }

    static testMethod void testValidateParameters() {
        Test.startTest();
        Account account = createAccount(TEST_STRING);
        insert account;
        Contact contact = createContact(TEST_STRING, account.id);
        insert contact;
        User user = createUser(TEST_STRING, contact);
        insert user;

        Test.setCurrentPage(new PageReference('Page.myPage'));

        System.runAs(user)
        {
            System.currentPageReference().getParameters().put('productId', '123');
            System.currentPageReference().getParameters().put('qty', '1a');
            System.currentPageReference().getParameters().put('redirectUrl', 'https://www.google.com');
            System.currentPageReference().getParameters().put('overrideUnitPrice', '2a');

            FS_AddToCartPageController controller1 = new FS_AddToCartPageController();
            System.assert(!controller1.parametersValid);

            System.currentPageReference().getParameters().put('productId', 'xxxxxxxxxxxxxxxxxx');

            FS_AddToCartPageController controller2 = new FS_AddToCartPageController();
            System.assert(!controller2.parametersValid);

            System.currentPageReference().getParameters().put('qty', '1');

            FS_AddToCartPageController controller3 = new FS_AddToCartPageController();
            System.assert(controller3.parametersValid);

        }
        Test.stopTest();
    }

    static testMethod void testGetSalesOrderId() {
        Test.startTest();
        Account account = createAccount(TEST_STRING);
        insert account;
        Contact contact = createContact(TEST_STRING, account.id);
        insert contact;
        User user = createUser(TEST_STRING, contact);
        insert user;


        Test.setCurrentPage(new PageReference('Page.myPage'));

        System.runAs(user)
        {
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = contact.Id);
            insert salesOrder;

            System.currentPageReference().getParameters().put('productId', 'xxxxxxxxxxxxxxxxxx');
            System.currentPageReference().getParameters().put('qty', '1');
            System.currentPageReference().getParameters().put('redirectUrl', 'https://www.google.com');
            System.currentPageReference().getParameters().put('overrideUnitPrice', '2');

            FS_AddToCartPageController controller1 = new FS_AddToCartPageController();
            System.assert(controller1.salesOrderId == salesOrder.Id);

        }
        Test.stopTest();
    }

    static testMethod void testRunDMLApex() {
        Test.startTest();
        Account account = createAccount(TEST_STRING);
        insert account;
        Contact contact = createContact(TEST_STRING, account.id);
        insert contact;
        User user = createUser(TEST_STRING, contact);
        insert user;
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name = 'testItemClass', OrderApi__Is_Active__c = True);
        insert itemClass;
        OrderApi__Item__c item = new OrderApi__Item__c(Name = 'testItem', OrderApi__Item_Class__c = itemClass.Id);
        insert item;

        Test.setCurrentPage(new PageReference('Page.myPage'));

        System.runAs(user)
        {
            System.currentPageReference().getParameters().put('productId', 'xxxxxxxxxxxxxxxxxx');
            System.currentPageReference().getParameters().put('qty', '1');
            System.currentPageReference().getParameters().put('redirectUrl', 'https://www.google.com');
            System.currentPageReference().getParameters().put('overrideUnitPrice', '2');

            FS_AddToCartPageController controller1 = new FS_AddToCartPageController();
            controller1.runDMLApex();

            System.assert(controller1.DMLRun == True);
            System.assert(controller1.numItemsInCart == 0);

            System.currentPageReference().getParameters().put('productId', item.Id);

            FS_AddToCartPageController controller2 = new FS_AddToCartPageController();
            controller2.runDMLApex();

            System.assert(controller2.DMLRun == True);

            System.debug('Relevant SOL');
            System.debug([SELECT Id, OrderApi__Display_Item__c FROM OrderApi__Sales_Order_Line__c
                                            WHERE OrderApi__Item__c = :item.Id]);

            System.assert(controller2.numItemsInCart == 1, 'Actual: ' + controller2.numItemsInCart
                                + ' Expected: 1');

        }
        Test.stopTest();
    }

    static testMethod void testRedirect() {
        Test.startTest();
        Account account = createAccount(TEST_STRING);
        insert account;
        Contact contact = createContact(TEST_STRING, account.id);
        insert contact;
        User user = createUser(TEST_STRING, contact);
        insert user;

        Test.setCurrentPage(new PageReference('Page.myPage'));

        System.runAs(user)
        {
            System.currentPageReference().getParameters().put('productId', 'xxxxxxxxxxxxxxxxxx');
            System.currentPageReference().getParameters().put('qty', '1');
            System.currentPageReference().getParameters().put('overrideUnitPrice', '2');

            FS_AddToCartPageController controller1 = new FS_AddToCartPageController();

            System.assert(controller1.redirectApex() == null);

            System.currentPageReference().getParameters().put('redirectUrl', 'https://www.google.com');

            FS_AddToCartPageController controller2 = new FS_AddToCartPageController();

            System.assert(controller2.redirectApex() != null);


        }
        Test.stopTest();
    }

}