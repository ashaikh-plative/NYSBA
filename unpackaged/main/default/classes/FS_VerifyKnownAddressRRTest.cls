/**
 * Created by dfitzgerald on 11/5/19.
 */
@IsTest
global without sharing class FS_VerifyKnownAddressRRTest {

    @TestSetup
    static void testSetup() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        /* RoutingRule information*/
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_VerifyKnownAddressRoutingRule.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Known_Address__c';
        routingRule.executionOrder = 15;
        rules.add(routingRule);
        Framework.Config.push(rules);

    }

    private static final String SYS_ADMIN_ID =
            [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1].Id;

    private static Account createAccount(String str) {
        Account newAccount = new Account(
                Name=str+'orgName',
                Sic='None',
                BillingCountryCode='US',
                BillingStreet='12147 Rockville Pike',
                BillingCity='Rockville',
                BillingStateCode='MD',
                BillingPostalCode='20852',
                ShippingCountryCode='US',
                ShippingStreet='12147 Rockville Pike',
                ShippingCity='Rockville',
                ShippingStateCode='MD',
                ShippingPostalCode='20852',
                OwnerId=SYS_ADMIN_ID
        );
        return newAccount;
    }

    private static Contact createContact(String str, String accountId, String countryCode, String street, String city,
            String state) {
        Contact newContact = new Contact(
                FirstName=str+'FirstName',
                LastName=str+'LastName',
                Email=str+'@email.com',
                AccountId=accountId,
                MailingCountryCode = countryCode,
                MailingStreet = street,
                MailingCity = city,
                MailingState = state,
                smartystreets__Mailing_Verified__c = true,
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                smartystreets__Mailing_Last_Verified__c = Datetime.now(),
                FS_API_Mailing_County__c = 'Montgomery',

                OtherCountryCode = countryCode,
                OtherStreet = street,
                OtherCity = city,
                OtherState = state,
                smartystreets__Other_Verified__c = true,
                smartystreets__Other_Return_Code__c = 'Confirmed',
                smartystreets__Other_Last_Verified__c = Datetime.now(),
                FS_API_Other_County__c = 'Montgomery'
        );
        return newContact;
    }

    private static Contact quickCreateContact(String str) {
        Account testAccount = createAccount(str);
        insert testAccount;

        Contact testContact = createContact(str, testAccount.Id, 'US',
                '12147 Rockville Pike', 'Rockville', 'Maryland');
        insert testContact;

        return testContact;
    }

    private static OrderApi__Known_Address__c createMatchingKnownAddress(Contact contact) {
        OrderApi__Known_Address__c testKnownAddress = new OrderApi__Known_Address__c(
                OrderApi__Name__c = contact.Name+'MatchingKnownAddress',
                OrderApi__Contact__c = contact.Id,
                OrderApi__Country__c = contact.MailingCountry,
                OrderApi__Street__c = contact.MailingStreet,
                OrderApi__City__c = contact.MailingCity,
                OrderApi__Province__c = contact.MailingState,
                OrderApi__Type__c = 'Test type'
        );
        insert testKnownAddress;
        return testKnownAddress;
    }

    private static OrderApi__Known_Address__c createNonmatchingKnownAddress(Contact contact) {
        OrderApi__Known_Address__c testKnownAddress = new OrderApi__Known_Address__c(
                OrderApi__Name__c = contact.Name+'NonmatchingKnownAddress',
                OrderApi__Contact__c = contact.Id,
                OrderApi__Country__c = contact.MailingCountry,
                OrderApi__Street__c = '12300 Twinbrook Pkwy Ste 440',
                OrderApi__City__c = contact.MailingCity,
                OrderApi__Province__c = contact.MailingState,
                OrderApi__Type__c = 'Test type'
        );
        insert testKnownAddress;
        return testKnownAddress;
    }


    @IsTest
    private static void testMatchingAddressInsert() {
        Contact c1 = quickCreateContact('test1');

        Test.startTest();
        OrderApi__Known_Address__c ka1 = createMatchingKnownAddress(c1);
        OrderApi__Known_Address__c ka2 = [
                SELECT Id, OrderApi__Contact__c, FS_Verified__c, FS_County__c
                FROM OrderApi__Known_Address__c
                WHERE Id = :ka1.Id
                LIMIT 1][0];
        System.assertEquals(c1.Id, ka2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, ka2.FS_Verified__c);

        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, ka2.FS_County__c);
        Test.stopTest();
    }

    @IsTest
    private static void testNonMatchingAddressInsert() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test2');

        Test.startTest();
        OrderApi__Known_Address__c ka1 = createNonmatchingKnownAddress(c1);
        Test.stopTest();

        OrderApi__Known_Address__c ka2 = [
                SELECT Id, OrderApi__Contact__c, FS_Verified__c, FS_County__c
                FROM OrderApi__Known_Address__c
                WHERE Id = :ka1.Id
                LIMIT 1][0];

        System.assertEquals(c1.Id, ka2.OrderApi__Contact__c);
        System.assertEquals(false, ka2.FS_Verified__c);
        System.assertEquals('Out of State', ka2.FS_County__c);
    }

    @IsTest
    private static void testMatchingAddressUpdate() {
        Contact c1 = quickCreateContact('test3');

        Test.startTest();
        OrderApi__Known_Address__c ka1 = createMatchingKnownAddress(c1);
        ka1.OrderApi__Name__c = 'newKAName';
        update ka1;

        OrderApi__Known_Address__c ka2 = [
                SELECT Id, OrderApi__Contact__c, FS_Verified__c, FS_County__c
                FROM OrderApi__Known_Address__c
                WHERE Id = :ka1.Id
                LIMIT 1][0];
        System.assertEquals(c1.Id, ka2.OrderApi__Contact__c);
        System.assertEquals(c1.smartystreets__Mailing_Verified__c, ka2.FS_Verified__c);
        Contact c1_update = [SELECT FS_Mailing_County__c FROM Contact WHERE Id = :c1.Id];
        System.assertEquals(c1_update.FS_Mailing_County__c, ka2.FS_County__c);
        Test.stopTest();
    }

    @IsTest
    private static void testNonmatchingAddressUpdate() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact c1 = quickCreateContact('test4');

        Test.startTest();
        OrderApi__Known_Address__c ka1 = createMatchingKnownAddress(c1);
        ka1.OrderApi__Street__c = '12300 Twinbrook Pkwy Ste 440';
        update ka1;
        Test.stopTest();

        OrderApi__Known_Address__c ka2 = [
                SELECT Id, OrderApi__Contact__c, FS_Verified__c, FS_County__c
                FROM OrderApi__Known_Address__c
                WHERE Id = :ka1.Id
                LIMIT 1][0];

        System.assertEquals(c1.Id, ka2.OrderApi__Contact__c);
        System.assertEquals(false, ka2.FS_Verified__c);
        System.assertEquals('Out of State', ka2.FS_County__c);
    }

    global class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        global HttpResponse respond(HttpRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method.
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                    '{'+
                        '"input_id": "0",'+
                        '"input_index": 0,'+
                        '"candidate_index": 0,'+
                        '"delivery_line_1": "12300 Twinbrook Pkwy Ste 440",'+
                        '"last_line": "Rockville MD 20852-1650",'+
                        '"delivery_point_barcode": "208521650155",'+
                        '"components": {'+
                            '"primary_number": "12300",'+
                            '"street_name": "Twinbrook",'+
                            '"street_suffix": "Pkwy",'+
                            '"secondary_number": "440",'+
                            '"secondary_designator": "Ste",'+
                            '"city_name": "Rockville",'+
                            '"default_city_name": "Rockville",'+
                            '"state_abbreviation": "MD",'+
                            '"zipcode": "20852",'+
                            '"plus4_code": "1650",'+
                            '"delivery_point": "15",'+
                            '"delivery_point_check_digit": "5"'+
                        '},'+
                        '"metadata": {'+
                            '"record_type": "H",'+
                            '"zip_type": "Standard",'+
                            '"county_fips": "24031",'+
                            '"county_name": "Montgomery",'+
                            '"carrier_route": "C083",'+
                            '"congressional_district": "08",'+
                            '"rdi": "Commercial",'+
                            '"elot_sequence": "0024",'+
                            '"elot_sort": "A",'+
                            '"latitude": 39.0589,'+
                            '"longitude": -77.12134,'+
                            '"precision": "Zip9",'+
                            '"time_zone": "Eastern",'+
                            '"utc_offset": -5,'+
                            '"dst": true'+
                        '},'+
                        '"analysis": {'+
                            '"dpv_match_code": "Y",'+
                            '"dpv_footnotes": "AABB",'+
                            '"dpv_cmra": "N",'+
                            '"dpv_vacant": "N",'+
                            '"active": "Y",'+
                            '"footnotes": "N#"'+
                        '}'+
                    '}');
            res.setStatusCode(200);
            return res;
        }
    }
}