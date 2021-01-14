/**
 * Created by dfitzgerald on 11/7/19.
 */

@IsTest
global without sharing class FS_VerifySalesOrderAddressRRTest {
    final static String TEST_ADDRESS_STREET = '1 Elk Street';
    final static String TEST_COUNTY = 'Albany';

    @TestSetup
    static void testSetup() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        /* RoutingRule information*/
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_VerifySalesOrderAddressRoutingRule.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule.executionOrder = 15;
        rules.add(routingRule);
        Framework.Config.push(rules);



        Account newAccount = new Account(
                Name = 'test orgName',
                Sic = 'None',
                BillingCountryCode = 'US',
                BillingStreet = '24 Eagle Street',
                BillingCity = 'Albany',
                BillingStateCode = 'NY',
                BillingPostalCode = '12207',
                ShippingCountryCode = 'US',
                ShippingStreet = '24 Eagle Street',
                ShippingCity = 'Albany',
                ShippingStateCode = 'NY',
                ShippingPostalCode = '12207',
                OwnerId = SYS_ADMIN_ID
        );
        insert newAccount;

        String str = 'test';
        String countryCode = 'US';
        String street = '24 Eagle Street';
        String stateCode = 'NY';
        Contact newContact = new Contact(
                FirstName = str + 'FirstName',
                LastName = str + 'LastName',
                Email = str + '@email.com',
                AccountId = newAccount.Id,
                MailingCountryCode = countryCode,
                MailingStreet = street,
                MailingCity = 'Albany',
                MailingStateCode = stateCode,
                MailingPostalCode = '12207',
                smartystreets__Mailing_Verified__c = true,
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                smartystreets__Mailing_Last_Verified__c = Datetime.now(),
                FS_API_Mailing_County__c = 'Albany',
                FS_Preferred_Billing_Address__c = 'Work/School',
                FS_Preferred_Mailing_Address__c = 'Work/School'
        );
        insert newContact;

        insert new Contact(
                FirstName = str + 'NameFirst1',
                LastName = str + 'NameLast1',
                Email = str + '@email.com',
                AccountId = newAccount.Id,
                MailingCountryCode = countryCode,
                MailingStreet = street,
                MailingCity = 'Albany',
                MailingPostalCode = '12207',
                MailingStateCode = stateCode,
                smartystreets__Mailing_Verified__c = true,
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                smartystreets__Mailing_Last_Verified__c = Datetime.now(),
                FS_API_Mailing_County__c = 'Albany',
                FS_Preferred_Billing_Address__c = 'Home',
                FS_Preferred_Mailing_Address__c = 'Home'
        );

        insert new OrderApi__Known_Address__c(
                OrderApi__Contact__c = newContact.Id,
                OrderApi__City__c = 'New York',
                OrderApi__Postal_Code__c = '12207'
        );
    }

    private static final String SYS_ADMIN_ID =
            [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1].Id;

    private static Account createAccount(String str) {
        Account newAccount = new Account(
                Name = str + 'orgName'
//                Sic = 'None',
//                BillingCountryCode = 'US',
//                BillingStreet = '24 Eagle Street',
//                BillingCity = 'Albany',
//                BillingStateCode = 'NY',
//                BillingPostalCode = '12207',
//                ShippingCountryCode = 'US',
//                ShippingStreet = '24 Eagle Street',
//                ShippingCity = 'Albany',
//                ShippingStateCode = 'NY',
//                ShippingPostalCode = '12207',
//                OwnerId = SYS_ADMIN_ID
        );
        return newAccount;
    }

    private static Contact createContact(String str, String accountId, String countryCode, String street, String city,
            String stateCode) {
        Contact newContact = new Contact(
                FirstName = str + 'FirstName',
                LastName = str + 'LastName',
                Email = str + '@email.com',
                AccountId = accountId,
                MailingCountryCode = countryCode,
                MailingStreet = street,
                MailingCity = city,
                MailingStateCode = stateCode,
                smartystreets__Mailing_Verified__c = true,
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                smartystreets__Mailing_Last_Verified__c = Datetime.now(),
                FS_API_Mailing_County__c = 'Albany',
                FS_Preferred_Billing_Address__c = 'Work/School',
                FS_Preferred_Mailing_Address__c = 'Work/School'
        );
        return newContact;
    }

    private static Contact quickCreateContact(String str) {
//        Account testAccount = createAccount(str);
//        insert testAccount;
//
//        Contact testContact = createContact(str, testAccount.Id, 'US',
//                '24 Eagle Street', 'Albany', 'NY');
//        insert testContact;

        return [SELECT Id, FirstName, LastName,
                Email,
                AccountId,
                MailingCountryCode,
                MailingStreet,
                MailingCity,
                MailingStateCode,
                MailingCountry,
                MailingState,
                MailingPostalCode,
                smartystreets__Mailing_Verified__c,
                smartystreets__Mailing_Return_Code__c,
                smartystreets__Mailing_Last_Verified__c,
                FS_API_Mailing_County__c,
                FS_Preferred_Billing_Address__c,
                FS_Preferred_Mailing_Address__c FROM Contact WHERE FirstName = 'testFirstName' LIMIT 1];
    }

    private static Contact quickCreateContact1(String str) {
//        Account testAccount = createAccount(str);
//        insert testAccount;
//
//        Contact testContact = createContact(str, testAccount.Id, 'US',
//                '24 Eagle Street', 'Albany', 'NY');
//        insert testContact;

        return [SELECT Id, FirstName, LastName,
                Email,
                AccountId,
                MailingCountryCode,
                MailingStreet,
                MailingCity,
                MailingStateCode,
                MailingCountry,
                MailingState,
                MailingPostalCode,
                smartystreets__Mailing_Verified__c,
                smartystreets__Mailing_Return_Code__c,
                smartystreets__Mailing_Last_Verified__c,
                FS_API_Mailing_County__c,
                FS_Preferred_Billing_Address__c,
                FS_Preferred_Mailing_Address__c FROM Contact WHERE FirstName = 'testNameFirst1' LIMIT 1];
    }

    private static OrderApi__Sales_Order__c createMatchingSalesOrder(Contact contact) {
        OrderApi__Sales_Order__c testSalesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Calculate_Billing_Details__c = false,
                OrderApi__Billing_Country__c = contact.MailingCountry,
                OrderApi__Billing_Street__c = contact.MailingStreet,
                OrderApi__Billing_City__c = contact.MailingCity,
                OrderApi__Billing_State__c = contact.MailingStateCode,
                OrderApi__Billing_Postal_Code__c = contact.MailingPostalCode,
                OrderApi__Calculate_Shipping_Details__c = false,
                OrderApi__Shipping_Country__c = contact.MailingCountry,
                OrderApi__Shipping_Street__c = contact.MailingStreet,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingStateCode,
                OrderApi__Shipping_Postal_Code__c = contact.MailingPostalCode
        );
        insert testSalesOrder;
        return testSalesOrder;
    }

    private static OrderApi__Sales_Order__c createMatchingBillingSalesOrder(Contact contact) {
        OrderApi__Sales_Order__c testSalesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Calculate_Billing_Details__c = false,
                OrderApi__Billing_Country__c = contact.MailingCountry,
                OrderApi__Billing_Street__c = contact.MailingStreet,
                OrderApi__Billing_City__c = contact.MailingCity,
                OrderApi__Billing_State__c = contact.MailingStateCode,
                OrderApi__Calculate_Shipping_Details__c = false,
                OrderApi__Shipping_Country__c = contact.MailingCountry,
                OrderApi__Shipping_Street__c = TEST_ADDRESS_STREET,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingStateCode
        );
        insert testSalesOrder;
        return testSalesOrder;
    }

    private static OrderApi__Sales_Order__c createMatchingShippingSalesOrder(Contact contact) {
        OrderApi__Sales_Order__c testSalesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Calculate_Billing_Details__c = false,
                OrderApi__Billing_Country__c = contact.MailingCountry,
                OrderApi__Billing_Street__c = TEST_ADDRESS_STREET,
                OrderApi__Billing_City__c = contact.MailingCity,
                OrderApi__Billing_State__c = contact.MailingStateCode,
                OrderApi__Calculate_Shipping_Details__c = false,
                OrderApi__Shipping_Country__c = contact.MailingCountry,
                OrderApi__Shipping_Street__c = contact.MailingStreet,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingStateCode
        );
        insert testSalesOrder;
        return testSalesOrder;
    }

    private static OrderApi__Sales_Order__c createNonmatchingSalesOrder(Contact contact) {
        OrderApi__Sales_Order__c testSalesOrder = new OrderApi__Sales_Order__c(
                // OrderApi__Contact__c = contact.Id,
                OrderApi__Calculate_Billing_Details__c = false,
                OrderApi__Billing_Country__c = contact.MailingCountry,
                OrderApi__Billing_Street__c = TEST_ADDRESS_STREET,
                OrderApi__Billing_City__c = contact.MailingCity,
                OrderApi__Billing_State__c = contact.MailingStateCode,
                OrderApi__Calculate_Shipping_Details__c = false,
                OrderApi__Shipping_Country__c = contact.MailingCountry,
                OrderApi__Shipping_Street__c = TEST_ADDRESS_STREET,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingStateCode
        );
        insert testSalesOrder;
        return testSalesOrder;
    }


    @IsTest
    private static void testMatchingAddressInsert() {
        Contact c1 = quickCreateContact('test1');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingSalesOrder(c1);
        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Billing_Address_Verified__c, FS_Billing_County__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];
        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Shipping_County__c);
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Billing_County__c);
        Test.stopTest();
    }

    @IsTest
    private static void testMatchingBillingAddressInsert() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingBillingSalesOrder(c1);
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Billing_Address_Verified__c, FS_Billing_County__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];

        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        System.assertEquals(TEST_COUNTY, so2.FS_Shipping_County__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Billing_County__c);
    }

    @IsTest
    private static void testMatchingShippingAddressInsert() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingShippingSalesOrder(c1);
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Billing_Address_Verified__c, FS_Billing_County__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];

        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Shipping_County__c);
        System.assertEquals(TEST_COUNTY, so2.FS_Billing_County__c);
    }

    @IsTest
    private static void testNonmatchingAddressInsert() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createNonmatchingSalesOrder(c1);
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Billing_Address_Verified__c, FS_Billing_County__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];
    }

    @IsTest
    private static void testMatchingAddressUpdate() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingSalesOrder(c1);
        so1.OrderApi__Customer_Reference_Number__c = '12345';
        update so1;
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Shipping_Address_Last_Verified__c, FS_Billing_Address_Verified__c, FS_Billing_County__c,
                        FS_Billing_Address_Last_Verified__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];

        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Shipping_County__c);
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Billing_County__c);
        //System.assertEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Billing_Address_Last_Verified__c);
        //System.assertEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Shipping_Address_Last_Verified__c);
    }

    @IsTest
    private static void testMatchingBillingAddressUpdate() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingSalesOrder(c1);
        so1.OrderApi__Shipping_Street__c = TEST_ADDRESS_STREET;
        update so1;
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Shipping_Address_Last_Verified__c, FS_Billing_Address_Verified__c, FS_Billing_County__c,
                        FS_Billing_Address_Last_Verified__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];

        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        System.assertEquals(TEST_COUNTY, so2.FS_Shipping_County__c);

        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Billing_County__c);
        //System.assertEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Billing_Address_Last_Verified__c);
        System.assertNotEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Shipping_Address_Last_Verified__c);
    }

    @IsTest
    private static void testMatchingShippingAddressUpdate() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingSalesOrder(c1);
        so1.OrderApi__Billing_Street__c = TEST_ADDRESS_STREET;
        update so1;
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Shipping_Address_Last_Verified__c, FS_Billing_Address_Verified__c, FS_Billing_County__c,
                        FS_Billing_Address_Last_Verified__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];

        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        System.assertEquals(TEST_COUNTY, so2.FS_Billing_County__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, so2.FS_Shipping_County__c);
        System.assertNotEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Billing_Address_Last_Verified__c);
        //System.assertEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Shipping_Address_Last_Verified__c);
    }

    @IsTest
    private static void testNonmatchingAddressUpdate() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact1('test2');

        Test.startTest();
        OrderApi__Sales_Order__c so1 = createMatchingSalesOrder(c1);
        so1.OrderApi__Billing_Street__c = TEST_ADDRESS_STREET;
        so1.OrderApi__Shipping_Street__c = TEST_ADDRESS_STREET;
        update so1;
        Test.stopTest();

        OrderApi__Sales_Order__c so2 = [
                SELECT Id, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c,
                        FS_Shipping_Address_Last_Verified__c, FS_Billing_Address_Verified__c, FS_Billing_County__c,
                        FS_Billing_Address_Last_Verified__c
                FROM OrderApi__Sales_Order__c
                WHERE Id = :so1.Id
                LIMIT 1
        ][0];

        System.assertEquals(c1.Id, so2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Shipping_Address_Verified__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, so2.FS_Billing_Address_Verified__c);
        System.assertEquals(TEST_COUNTY, so2.FS_Billing_County__c);
        System.assertEquals(TEST_COUNTY, so2.FS_Shipping_County__c);
        System.assertNotEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Billing_Address_Last_Verified__c);
        System.assertNotEquals(c1.smartystreets__Mailing_Last_Verified__c, so2.FS_Shipping_Address_Last_Verified__c);
    }

//    @IsTest
//    private static void testMatchingAddressUpdate() {
//        Contact c1 = quickCreateContact('test3');
//
//        Test.startTest();
//        OrderApi__Known_Address__c ka1 = createMatchingKnownAddress(c1);
//        ka1.OrderApi__Name__c = 'newKAName';
//        update ka1;
//
//        OrderApi__Known_Address__c ka2 = [
//                SELECT Id, OrderApi__Contact__c, FS_Verified__c, FS_County__c
//                FROM OrderApi__Known_Address__c
//                WHERE Id = :ka1.Id
//                LIMIT 1
//        ][0];
//        System.assertEquals(c1.Id, ka2.OrderApi__Contact__c);
//        System.assertEquals(c1.smartystreets__Mailing_Verified__c, ka2.FS_Verified__c);
//        System.assertEquals(c1.FS_Mailing_County__c, ka2.FS_County__c);
//        Test.stopTest();
//    }
//
//    @IsTest
//    private static void testNonmatchingAddressUpdate() {
//        // Set mock callout class
//        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
//
//        Contact c1 = quickCreateContact('test4');
//
//        Test.startTest();
//        OrderApi__Known_Address__c ka1 = createMatchingKnownAddress(c1);
//        ka1.OrderApi__Street__c = '12300 Twinbrook Pkwy Ste 440';
//        update ka1;
//        Test.stopTest();
//
//        OrderApi__Known_Address__c ka2 = [
//                SELECT Id, OrderApi__Contact__c, FS_Verified__c, FS_County__c
//                FROM OrderApi__Known_Address__c
//                WHERE Id = :ka1.Id
//                LIMIT 1
//        ][0];
//
//        System.assertEquals(c1.Id, ka2.OrderApi__Contact__c);
//        System.assertEquals(true, ka2.FS_Verified__c);
//        System.assertEquals('Montgomery', ka2.FS_County__c);
//    }

    global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global HttpResponse respond(HttpRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            //System.assertEquals('https://geo.fcc.gov/api/census', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                    '{' +
                            '"input_id": "0",' +
                            '"input_index": 0,' +
                            '"candidate_index": 0,' +
                            '"delivery_line_1": "1 Elk St",' +
                            '"last_line": "Albany NY 12207-1002",' +
                            '"delivery_point_barcode": "122071002014",' +
                            '"components": {' +
                            '"primary_number": "1",' +
                            '"street_name": "Elk",' +
                            '"street_suffix": "St",' +
                            '"city_name": "Albany",' +
                            '"default_city_name": "Albany",' +
                            '"state_abbreviation": "NY",' +
                            '"zipcode": "12207",' +
                            '"plus4_code": "1002",' +
                            '"delivery_point": "01",' +
                            '"delivery_point_check_digit": "4"' +
                            '},' +
                            '"metadata": {' +
                            '"record_type": "S",' +
                            '"zip_type": "Standard",' +
                            '"county_fips": "36001",' +
                            '"county_name": "Albany",' +
                            '"carrier_route": "C010",' +
                            '"congressional_district": "20",' +
                            '"rdi": "Commercial",' +
                            '"elot_sequence": "0133",' +
                            '"elot_sort": "A",' +
                            '"latitude": 42.65407,' +
                            '"longitude": -73.75555,' +
                            '"precision": "Zip9",' +
                            '"time_zone": "Eastern",' +
                            '"utc_offset": -5,' +
                            '"dst": true' +
                            '},' +
                            '"analysis": {' +
                            '"dpv_match_code": "Y",' +
                            '"dpv_footnotes": "AABB",' +
                            '"dpv_cmra": "N",' +
                            '"dpv_vacant": "N",' +
                            '"active": "Y"' +
                            '}' +
                            '}');
            res.setStatusCode(200);
            return res;
        }
    }
}