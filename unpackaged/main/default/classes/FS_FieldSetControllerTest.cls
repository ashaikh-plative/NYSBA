/**
 * Created by daweima on 2019-07-11.
 */
@IsTest
public with sharing class FS_FieldSetControllerTest {

    private static testMethod void testGetResults1() {
        Test.startTest();
        final String STR = 'testGetId';
        Contact testContact = new Contact(FirstName='test',LastName='test', Email='test@test.com', OrderApi__Preferred_Email_Type__c='Work', OrderApi__Work_Email__c='test@test.com');
        Account testAccount = new Account(Name='testAccount');

        insert testAccount;
        testContact.AccountId = testAccount.Id;
        insert testContact;
        User user = createUser(STR, testContact);
        user.Email = 'test1@test.com';
        insert user;
        FS_FieldSetController.FieldSetForm f = FS_FieldSetController.getForm(testContact.Id, 'Contact', 'Communication_Information', 'Contact');
        List<String> s = new List<String>{'OrderApi__Personal_Email__c'};
        System.runAs(user) {
            FS_FieldSetController.updateUser(f.Record, s);
            f.Record.Id = null;
            FS_FieldSetController.upsertRecord(f.Record, s);
        }

        f = FS_FieldSetController.getForm(testContact.Id, 'Contact', 'Address_Information', 'Contact');
        s = new List<String>();
        System.runAs(user) {
            FS_FieldSetController.upsertRecord(f.Record, s);
        }

        testContact.OrderApi__Preferred_Email_Type__c = 'Personal';
        testContact.OrderApi__Personal_Email__c = 'test2@test.com';
        update testContact;
        f = FS_FieldSetController.getForm(testContact.Id, 'Contact', 'Communication_Information', 'Contact');
        s = new List<String>();
        System.runAs(user) {
            FS_FieldSetController.updateUser(f.Record, s);
            FS_FieldSetController.upsertRecord(f.Record, s);
        }
        String label = FS_FieldSetController.getFieldSetLabel(testContact.Id,'Contact', 'Communication_Information');
        String label2 = FS_FieldSetController.getFieldSetLabel(null,'Contact', 'Communication_Information');
        SObject lookup = FS_FieldSetController.getLookup('Account',testAccount.Id);
        Test.stopTest();
    }

    //adding test to reach 75% coverage
    private static final String COMMUNITY_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1].id;
    private static Account createAccount(String str) {
        Account newOrg = new Account(
                Name=str+'orgName',
                Sic='None',
                BillingStreet=str+'orgStreet',
                BillingCity=str+'orgCity',
                BillingPostalCode='12345'
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
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = COMMUNITY_PROFILE_ID,
                LanguageLocaleKey = 'en_US',
                ContactId = contact.Id,
                IsActive = true
        );
        return newUser;
    }

    private static testMethod void testGetId() {
        Test.startTest();

        final String STR = 'testGetId';
        Account account = createAccount(STR);
        insert account;
        Contact contact = createContact(STR, account.Id);
        insert contact;
        User user = createUser(STR, contact);
        insert user;

        System.runAs(user) {
            System.assertEquals(user.ContactId, FS_FieldSetController.getUserId());
        }
        Test.stopTest();
    }

}