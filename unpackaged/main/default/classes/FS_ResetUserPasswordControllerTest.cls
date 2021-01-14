/**
 * Created by Jason Cookman on 2/9/20.
 */

@IsTest
public without sharing class FS_ResetUserPasswordControllerTest {

    private static final String COMMUNITY_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1].Id;
    private static final String OKTA_ID = FS_UserSyncRequestTest.OKTA_USER_ID;

    private static Account createAccount(String accountName) {
        Account newOrg = new Account(
                name=accountName+'orgName',
                sic='None',
                billingCountryCode='US',
                billingStreet=accountName+'orgStreet',
                billingCity=accountName+'orgCity',
                billingStateCode='MD',
                billingPostalCode='12345'
        );
        return newOrg;
    }

    private static Contact createContact(String contactName, String accountId) {
        Contact newContact = new Contact(
                FirstName= contactName +'FirstName',
                LastName= contactName +'LastName',
                Email= contactName +'@example.com',
                AccountId=accountId
        );
        return newContact;
    }

    private static User createCommunityUser(String usernameString, Contact contact) {
        User newUser = new User(
                LastName = contact.LastName,
                Username = usernameString+'@example.com',
                Email = usernameString+'@example.com',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = COMMUNITY_PROFILE_ID,
                LanguageLocaleKey = 'en_US',
                Okta_ID__c = OKTA_ID,
                ContactId = contact.Id,
                IsActive = true
        );
        return newUser;
    }


    @TestSetup
    private static void setupData() {
        Account acc = createAccount('Test Account ');
        insert acc;
        Contact con = createContact('TestContact', acc.Id);
        insert con;
        User usr = createCommunityUser('TestContact', con);
        insert usr;

    }





    @IsTest
    private static void resetPassword_GetOKTAIdOfContact() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        String contactOKTAID = FS_ResetUserPasswordController.getOKTAIdOfContact(con.Id);

        System.assertEquals(OKTA_ID, contactOKTAID);

    }

    @IsTest
    private static void resetPassword_ExpectSuccessCallout() {

        Test.setMock(HttpCalloutMock.class, new FS_UserSyncRequestTest.MockPasswordResetResponseGenerator());

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        String response = FS_ResetUserPasswordController.resetUserPassword(OKTA_ID);
        Test.stopTest();
        System.assertEquals(response, '');
    }
}