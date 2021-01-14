/**
 * Created by dfitzgerald on 1/8/20.
 */
@IsTest
public with sharing class FS_SubscribeFormControllerTest {

    private static final String SYS_ADMIN_ID =
            [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1].Id;
    //static final String USER_ID = '0051U000004F7lAQAS';

    @TestSetup
    private static void setup() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
    }

    @IsTest
    private static void testGetCountries() {
        Test.startTest();
        List<Map<String, String>> countryInfo = (List<Map<String, String>>) FS_SubscribeFormController.getJSONCountries();
        System.debug('dsf4 --- '+countryInfo[0]);
        Test.stopTest();

        System.assertEquals('United States',countryInfo[0].get('label'));
    }

    @IsTest
    private static void testProcessSubscriptionSimple() {
        String first = 'firstFSSFCT';
        String last = 'lastFSSFCT';
        String email = 'test123@FSSFCT.com';
        Map<String, String> result = (Map<String, String>)FS_SubscribeFormController.processSubscription(first, last, email, 'US', SYS_ADMIN_ID);
        List<Contact> contacts = [SELECT Id, FirstName FROM Contact WHERE OrderApi__Preferred_Email__c = :email];
        System.assertEquals(1, contacts.size());
        System.assertEquals(first, contacts[0].FirstName);
        System.assertNotEquals('', result.get('contactId'));
        System.assertEquals('false', result.get('isGDPRCountry'));
        System.assertEquals('false', result.get('userExists'));
    }

    @IsTest
    private static void testProcessSubscriptionDuplicate() {
        String first = 'firstFSSFCT';
        String last = 'lastFSSFCT';
        String email = 'test1@FSSFCT.com';
        Map<String, String> result1 = (Map<String, String>)FS_SubscribeFormController.processSubscription(first, last, email, 'US', SYS_ADMIN_ID);
        Map<String, String> result2 = (Map<String, String>)FS_SubscribeFormController.processSubscription(first, last, email, 'US', SYS_ADMIN_ID);
        List<Contact> contacts = [SELECT Id, FirstName FROM Contact WHERE OrderApi__Preferred_Email__c = :email];
        System.assertEquals(1, contacts.size());
        System.assertEquals(first, contacts[0].FirstName);

        System.assertNotEquals('', result1.get('contactId'));
        System.assertEquals('false', result1.get('isGDPRCountry'));
        System.assertEquals('false', result1.get('userExists'));

        System.assertEquals('', result2.get('contactId'));
        System.assertEquals('false', result2.get('isGDPRCountry'));
        System.assertEquals('false', result2.get('userExists'));
    }

    @IsTest
    private static void testProcessSubscriptionGDPR() {
        String first = 'firstFSSFCT';
        String last = 'lastFSSFCT';
        String email = 'test123@FSSFCT.com';
        Map<String, String> result = (Map<String, String>)FS_SubscribeFormController.processSubscription(first, last, email, 'DE', SYS_ADMIN_ID);

        System.assertNotEquals('', result.get('contactId'));
        System.assertEquals('true', result.get('isGDPRCountry'));
        System.assertEquals('false', result.get('userExists'));

        FS_SubscribeFormController.optInGDPR(result.get('contactId'));

        List<Contact> contacts = [SELECT Id, FirstName, FS_GDPR_OptIn__c, FS_GDPR_Country__c FROM Contact WHERE OrderApi__Preferred_Email__c = :email];

        System.assertEquals(1, contacts.size());
        System.assertEquals(first, contacts[0].FirstName);
        System.assertEquals(true, contacts[0].FS_GDPR_Country__c);
        System.assertEquals(true, contacts[0].FS_GDPR_OptIn__c);
    }

    //@IsTest
    private static void testProcessSubscriptionExistingUser() {
        String first = 'firstFSSFCT';
        String last = 'lastFSSFCT';
        String email = 'test123@FSSFCT.com';


        Contact contact = new Contact(FirstName = first, LastName = last, Email = email);
        insert contact;

        //Username, LastName, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey
        User user = new User(
                email = email,
                ContactId = contact.Id,
                Username = email,
                LastName = last,
                Alias = 'flastFSS',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = '00e1U000002KnscQAC',
                LanguageLocaleKey = 'en_US');
        insert user;

        Map<String, String> result = (Map<String, String>) FS_SubscribeFormController.processSubscription(first, last, email, 'US', SYS_ADMIN_ID);

        System.assertEquals('', result.get('contactId'));
        System.assertEquals('false', result.get('isGDPRCountry'));
        System.assertEquals('true', result.get('userExists'));
    }
}