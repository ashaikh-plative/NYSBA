/**
 * Created by dfitzgerald on 11/7/19.
 */

@IsTest
global without sharing class FS_VerifySOLineAddressRRTest {
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
        routingRule.executionOrder = 35;
        rules.add(routingRule);

        Framework.RoutingRule routingRule2 = new Framework.RoutingRule();
        routingRule2.apexClass = FS_VerifySOLineAddressRoutingRule.class.getName();
        routingRule2.namespace = ' ';
        routingRule2.isEnabled = true;
        routingRule2.sObjectName = 'OrderApi__Sales_Order_Line__c';
        routingRule2.executionOrder = 35;
        rules.add(routingRule2);
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
        insert new Contact(
                FirstName = str + 'FirstName',
                LastName = str + 'LastName',
                Email = str + '@email.com',
                AccountId = newAccount.Id,
                MailingCountryCode = countryCode,
                MailingStreet = street,
                MailingCity = 'Albany',
                MailingStateCode = stateCode,
                smartystreets__Mailing_Verified__c = true,
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                smartystreets__Mailing_Last_Verified__c = Datetime.now(),
                FS_API_Mailing_County__c = 'Albany',
                FS_Preferred_Billing_Address__c = 'Work/School',
                FS_Preferred_Mailing_Address__c = 'Work/School'
        );
    }

    private static final String SYS_ADMIN_ID =
            [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1].Id;

    private static Account createAccount(String str) {
        Account newAccount = new Account(
                Name = str + 'orgName'
//                Sic = 'None',
//                BillingCountryCode = 'US',
//                BillingStreet = TEST_ADDRESS_STREET,
//                BillingCity = 'Albany',
//                BillingStateCode = 'NY',
//                BillingPostalCode = '12207',
//                ShippingCountryCode = 'US',
//                ShippingStreet = TEST_ADDRESS_STREET,
//                ShippingCity = 'Albany',
//                ShippingStateCode = 'NY',
//                ShippingPostalCode = '12207',
//                OwnerId = SYS_ADMIN_ID
        );
        return newAccount;
    }

    private static Contact createContact(String str, String accountId, String countryCode, String street, String city,
            String state) {
        Contact newContact = new Contact(
                FirstName = str + 'FirstName',
                LastName = str + 'LastName',
                Email = str + '@email.com',
                AccountId = accountId,
                MailingCountryCode = countryCode,
                MailingStreet = street,
                MailingCity = city,
                MailingState = state,
                smartystreets__Mailing_Verified__c = true,
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                smartystreets__Mailing_Last_Verified__c = Datetime.now(),
                FS_API_Mailing_County__c = 'Albany',
              FS_Preferred_Mailing_Address__c = 'Work/School'
        );
        return newContact;
    }

    private static Contact quickCreateContact(String str) {
//        Account testAccount = createAccount(str);
//        insert testAccount;
//
//        Contact testContact = createContact(str, testAccountId, 'US',
//                TEST_ADDRESS_STREET, 'Albany', 'New York');
//        insert testContact;
//
//        return testContact;
        return [SELECT Id, FirstName, LastName,
                Email,
                AccountId,
                MailingCountryCode,
                MailingStreet,
                MailingCity,
                MailingStateCode,
                MailingCountry,
                MailingState,
                smartystreets__Mailing_Verified__c,
                smartystreets__Mailing_Return_Code__c,
                smartystreets__Mailing_Last_Verified__c,
                FS_API_Mailing_County__c,
                FS_Preferred_Billing_Address__c,
                FS_Preferred_Mailing_Address__c FROM Contact WHERE FirstName = 'testFirstName' LIMIT 1];
    }

    private static OrderApi__Sales_Order__c createSalesOrder(Contact contact) {
        OrderApi__Sales_Order__c testSalesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Calculate_Billing_Details__c = false,
                OrderApi__Billing_Country__c = contact.MailingCountry,
                OrderApi__Billing_Street__c = contact.MailingStreet,
                OrderApi__Billing_City__c = contact.MailingCity,
                OrderApi__Billing_State__c = contact.MailingState,
                OrderApi__Calculate_Shipping_Details__c = false,
                OrderApi__Shipping_Country__c = contact.MailingCountry,
                OrderApi__Shipping_Street__c = contact.MailingStreet,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingState
        );
        insert testSalesOrder;
        return testSalesOrder;
    }

    private static OrderApi__Sales_Order_Line__c createMatchingSalesOrderLine(Contact contact,
            OrderApi__Sales_Order__c salesOrder) {
        OrderApi__Sales_Order_Line__c testSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Account__c = contact.AccountId,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Calculate_Shipping_Details__c = false,
                 OrderApi__Shipping_Country__c = contact.MailingCountry,
                 OrderApi__Shipping_Street__c = contact.MailingStreet,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingState
        );
        System.debug('dsf4');
        System.debug(testSalesOrderLine.OrderApi__Shipping_City__c);
        insert testSalesOrderLine;
        return testSalesOrderLine;
    }
    
    private static OrderApi__Sales_Order_Line__c createNonMatchingSalesOrderLine(Contact contact,
            OrderApi__Sales_Order__c salesOrder) {
        OrderApi__Sales_Order_Line__c testSalesOrderLine1 = new OrderApi__Sales_Order_Line__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Account__c = contact.AccountId,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Calculate_Shipping_Details__c = false,
                OrderApi__Shipping_City__c = contact.MailingCity,
                OrderApi__Shipping_State__c = contact.MailingState
        );
        insert testSalesOrderLine1;
        return testSalesOrderLine1;
    }

    @IsTest
    private static void testMatchingAddressInsert() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        Contact c1 = quickCreateContact('testasdasda');

        OrderApi__Sales_Order__c so1 = createSalesOrder(c1);
        OrderApi__Sales_Order_Line__c sol1 = createMatchingSalesOrderLine(c1, so1);
        OrderApi__Sales_Order_Line__c sol3 = createMatchingSalesOrderLine(c1, so1);

        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        solList.add(sol1);
        FS_VerifySOLineAddressRoutingRule rr = new FS_VerifySOLineAddressRoutingRule(solList);
        rr.beforeInsert();
        test.stopTest();
        OrderApi__Sales_Order_Line__c sol2 = [
                SELECT Id, OrderApi__Sales_Order__c, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c
                FROM OrderApi__Sales_Order_Line__c
                WHERE Id = :sol1.Id
                LIMIT 1
        ][0];
        System.assertEquals(c1.Id, sol2.OrderApi__Contact__c);
        //System.assertEquals(c1.smartystreets__Mailing_Verified__c, sol2.FS_Shipping_Address_Verified__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, sol2.FS_Shipping_County__c);
    }

    @IsTest
    private static void testNonMatchingAddressInsert() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        Contact c1 = quickCreateContact('testasdasda');

        OrderApi__Sales_Order__c so1 = createSalesOrder(c1);
        OrderApi__Sales_Order_Line__c sol1 = createMatchingSalesOrderLine(c1, so1);
        OrderApi__Sales_Order_Line__c sol3 = createNonMatchingSalesOrderLine(c1, so1);

        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        solList.add(sol1);
        FS_VerifySOLineAddressRoutingRule rr = new FS_VerifySOLineAddressRoutingRule(solList);
        Map<Id, SObject> existingRecords = new Map<Id, SObject>();
        existingRecords.put(sol1.Id, sol3);
        rr.beforeUpdate(existingRecords);
        test.stopTest();
        OrderApi__Sales_Order_Line__c sol2 = [
                SELECT Id, OrderApi__Sales_Order__c, OrderApi__Contact__c, FS_Shipping_Address_Verified__c, FS_Shipping_County__c
                FROM OrderApi__Sales_Order_Line__c
                WHERE Id = :sol1.Id
                LIMIT 1
        ][0];
        System.assertEquals(c1.Id, sol2.OrderApi__Contact__c);
        //System.assertEquals(c1.smartystreets__Mailing_Verified__c, sol2.FS_Shipping_Address_Verified__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, sol2.FS_Shipping_County__c);
    }
        
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