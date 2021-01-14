/**
 *	@author:	cubiascaceres
 *	@date:		2019.Nov.11
 *	@desc:		Test Class for FS_ContactAddressRoutingRule
 */
@IsTest
public class FS_ContactAddressRoutingRuleTest {

    @TestSetup
    static void setupFramework() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_ContactAddressRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'Contact';
        routingRule.executionOrder = 1;
        rules.add(routingRule);       
        Framework.Config.push(rules);
    }

    @IsTest
    static void afterUpdateTest() {
        Contact contact = new Contact(LastName = 'Clint Eastwood');
        contact.OtherStreet = '327 W 42nd St';
        contact.OtherCity = 'New York';
        contact.OtherStateCode = 'NY';
        contact.OtherPostalCode = '10036';
        contact.OtherCountryCode = 'US';
        contact.MailingStreet = '191 Chappie James Blvd Sw Bolling';
        contact.MailingCity = 'Washington';
        contact.MailingStateCode = 'DC';
        contact.MailingPostalCode = '20032';
        contact.MailingCountryCode = 'US';
        insert contact;
        
        Test.startTest();
        contact.OtherStreet = '3 W 2nd St';
        contact.OtherCity = 'New York';
        contact.OtherStateCode = 'NY';
        contact.OtherPostalCode = '10030';
        contact.OtherCountryCode = 'US';
        contact.MailingStreet = '1 Chappie James Blvd Sw Bolling';
        contact.MailingCity = 'Washington';
        contact.MailingStateCode = 'DC';
        contact.MailingPostalCode = '20030';
        contact.MailingCountryCode = 'US';
        update contact;
        Test.stopTest();
        List<OrderApi__Known_Address__c> contactKnownAddressList = [SELECT Id, OrderApi__Type__c, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, 
                                       OrderApi__Postal_Code__c, OrderApi__Country__c 
                                   FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c = :contact.Id];
        System.assertEquals(2, contactKnownAddressList.size(), '[After Update] Two Known Address records should have been created.');
        for(OrderApi__Known_Address__c contactKnownAddress : contactKnownAddressList) {
            if (contactKnownAddress.OrderApi__Type__c == 'Home') {
                System.assertEquals(contact.OtherStreet, contactKnownAddress.OrderApi__Street__c, '[After Update] Home Street does not match');
                System.assertEquals(contact.OtherCity, contactKnownAddress.OrderApi__City__c, '[After Update] Home City does not match');
                System.assertEquals(contact.OtherStateCode, contactKnownAddress.OrderApi__Province__c, '[After Update] Home State/Province does not match');
                System.assertEquals(contact.OtherPostalCode, contactKnownAddress.OrderApi__Postal_Code__c, '[After Update] Home Postal Code does not match');
                System.assertEquals(contact.OtherCountryCode, contactKnownAddress.OrderApi__Country__c, '[After Update] Home Country does not match');
            }
            if (contactKnownAddress.OrderApi__Type__c == 'Work') {
                System.assertEquals(contact.MailingStreet, contactKnownAddress.OrderApi__Street__c, '[After Update] Work Street does not match');
                System.assertEquals(contact.MailingCity, contactKnownAddress.OrderApi__City__c, '[After Update] Work City does not match');
                System.assertEquals(contact.MailingStateCode, contactKnownAddress.OrderApi__Province__c, '[After Update] Work State/Province does not match');
                System.assertEquals(contact.MailingPostalCode, contactKnownAddress.OrderApi__Postal_Code__c, '[After Update] Work Postal Code does not match');
                System.assertEquals(contact.MailingCountryCode, contactKnownAddress.OrderApi__Country__c, '[After Update] Work Country does not match');
            }
        }
    }
    
    @IsTest
    static void afterUpdateTestNewAddressesTest() {
        Contact contact = new Contact(LastName = 'Clint Eastwood');
        insert contact;
        Test.startTest();
        contact.OtherStreet = '3 W 2nd St';
        contact.OtherCity = 'New York';
        contact.OtherStateCode = 'NY';
        contact.OtherPostalCode = '10030';
        contact.OtherCountryCode = 'US';
        contact.MailingStreet = '1 Chappie James Blvd Sw Bolling';
        contact.MailingCity = 'Washington';
        contact.MailingStateCode = 'DC';
        contact.MailingPostalCode = '20030';
        contact.MailingCountryCode = 'US';
        update contact;
        Test.stopTest();
        List<OrderApi__Known_Address__c> contactKnownAddressList = [SELECT Id, OrderApi__Type__c, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, 
                                       OrderApi__Postal_Code__c, OrderApi__Country__c 
                                   FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c = :contact.Id];
        System.assertEquals(2, contactKnownAddressList.size(), '[After Update] Two Known Address records should have been created.');
        for(OrderApi__Known_Address__c contactKnownAddress : contactKnownAddressList) {
            if (contactKnownAddress.OrderApi__Type__c == 'Home') {
                System.assertEquals(contact.OtherStreet, contactKnownAddress.OrderApi__Street__c, '[After Update] Home Street does not match');
                System.assertEquals(contact.OtherCity, contactKnownAddress.OrderApi__City__c, '[After Update] Home City does not match');
                System.assertEquals(contact.OtherStateCode, contactKnownAddress.OrderApi__Province__c, '[After Update] Home State/Province does not match');
                System.assertEquals(contact.OtherPostalCode, contactKnownAddress.OrderApi__Postal_Code__c, '[After Update] Home Postal Code does not match');
                System.assertEquals(contact.OtherCountryCode, contactKnownAddress.OrderApi__Country__c, '[After Update] Home Country does not match');
            }
            if (contactKnownAddress.OrderApi__Type__c == 'Work') {
                System.assertEquals(contact.MailingStreet, contactKnownAddress.OrderApi__Street__c, '[After Update] Work Street does not match');
                System.assertEquals(contact.MailingCity, contactKnownAddress.OrderApi__City__c, '[After Update] Work City does not match');
                System.assertEquals(contact.MailingStateCode, contactKnownAddress.OrderApi__Province__c, '[After Update] Work State/Province does not match');
                System.assertEquals(contact.MailingPostalCode, contactKnownAddress.OrderApi__Postal_Code__c, '[After Update] Work Postal Code does not match');
                System.assertEquals(contact.MailingCountryCode, contactKnownAddress.OrderApi__Country__c, '[After Update] Work Country does not match');
            }
        }
    }
    
    @IsTest
    static void afterUpdateDeleteAddressTest() {        
        Contact contact = new Contact(LastName = 'Clint Eastwood');
        contact.OtherStreet = '327 W 42nd St';
        contact.OtherCity = 'New York';
        contact.OtherStateCode = 'NY';
        contact.OtherPostalCode = '10036';
        contact.OtherCountryCode = 'US';
        contact.MailingStreet = '191 Chappie James Blvd Sw Bolling';
        contact.MailingCity = 'Washington';
        contact.MailingStateCode = 'DC';
        contact.MailingPostalCode = '20032';
        contact.MailingCountryCode = 'US';
        insert contact;
        
        Test.startTest();
        contact.OtherStreet = '';
        contact.OtherCity = '';
        contact.OtherStateCode = '';
        contact.OtherPostalCode = '';
        contact.OtherCountryCode = '';
        contact.MailingStreet = '';
        contact.MailingCity = '';
        contact.MailingStateCode = '';
        contact.MailingPostalCode = '';
        contact.MailingCountryCode = '';
        update contact;
        Test.stopTest();
        List<OrderApi__Known_Address__c> contactKnownAddressList = [SELECT Id FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c = :contact.Id];
        System.assertEquals(0, contactKnownAddressList.size(), 'Both addresses were cleaned, Known Address records must have been deleted');
    }
}