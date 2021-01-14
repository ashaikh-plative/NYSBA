/**
 * Created by dfitzgerald on 1/22/20.
 */
@IsTest
public with sharing class FS_ContactVerifyStatusRoutingRuleTest {

    @testSetup
    static void setupFramework() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();

        Framework.RoutingRule routingRule2 = new Framework.RoutingRule();
        routingRule2.apexClass = FS_ContactVerifyStatusRoutingRule.class.getName();
        routingRule2.namespace = ' ';
        routingRule2.isEnabled = true;
        routingRule2.sObjectName = 'Contact';
        routingRule2.executionOrder = 20;
        rules.add(routingRule2);

        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_ContactAddressRoutingRule.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'Contact';
        routingRule.executionOrder = 30;
        rules.add(routingRule);

        Framework.Config.push(rules);
    }

    @IsTest
    static void test1() {

        //initial insert
        Contact contact = new Contact(
                FirstName = 'testFirst1',
                LastName = 'testLast1',
                MailingStreet = '123 test street',
                MailingCity = 'testCity1',
                MailingStateCode = 'NY',
                MailingCountryCode = 'US',
                smartystreets__Mailing_Return_Code__c = 'Confirmed',
                OtherStreet = '456 test street',
                OtherCity = 'testCity2',
                OtherStateCode = 'NY',
                OtherCountryCode = 'US',
                smartystreets__Other_Return_Code__c = 'Confirmed'
        );

        insert contact;

        List<OrderApi__Known_Address__c> knownAddresses1 = [SELECT Id, OrderApi__Street__c FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c = :contact.Id ORDER BY OrderApi__Street__c];
        System.assert(knownAddresses1.size() == 2);
        System.assertEquals(contact.MailingStreet, knownAddresses1[0].OrderApi__Street__c);
        System.assertEquals(contact.OtherStreet, knownAddresses1[1].OrderApi__Street__c);

        FS_ContactVerifyStatusRoutingRule.contactAddressChanged = false;
        //update before SmartyStreets callout
        Contact contact1 = [SELECT Id, MailingStreet, OtherStreet, smartystreets__Mailing_Return_Code__c FROM Contact WHERE Contact.Id = :contact.Id][0];
        contact1.MailingStreet = '1234 test street';
        contact1.smartystreets__Mailing_Return_Code__c = 'Changed';
        contact1.smartystreets__Other_Return_Code__c = 'Confirmed';
        update contact1;

        List<OrderApi__Known_Address__c> knownAddresses2 = [SELECT Id, OrderApi__Street__c FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c = :contact.Id ORDER BY OrderApi__Street__c];
        System.assert(knownAddresses2.size() == 2);
        System.assertNotEquals(contact1.MailingStreet, knownAddresses2[0].OrderApi__Street__c);
        System.assertEquals(contact1.OtherStreet, knownAddresses2[1].OrderApi__Street__c);


        FS_ContactVerifyStatusRoutingRule.contactAddressChanged = false;
        //update after SmartyStreets callout
        contact1.MailingStreet = '12345 test street';
        contact1.smartystreets__Mailing_Return_Code__c = 'Confirmed';
        contact1.smartystreets__Other_Return_Code__c = 'Confirmed';
        update contact1;

        List<OrderApi__Known_Address__c> knownAddresses3 = [SELECT Id, OrderApi__Street__c FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c = :contact.Id ORDER BY OrderApi__Street__c];
        System.assert(knownAddresses3.size() == 2);
        System.assertEquals(contact1.MailingStreet, knownAddresses3[0].OrderApi__Street__c);
        System.assertEquals(contact1.OtherStreet, knownAddresses3[1].OrderApi__Street__c);
    }


}