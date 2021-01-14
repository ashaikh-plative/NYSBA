/**
 * Created by cmudd on 2020-01-17.
 */

@IsTest
public without sharing class FS_UpdateUserFormulaFieldsTest {

    private static final String PROFILE = 'Fonteva 	Customer Community Login User';
    private static final String LIVE_PROFILE = 'Fonteva Customer Community Login User';
    public static Boolean runCallOut = false;

    @IsTest
    private static void testUpdatingContact_ExpectUserUpdated() {
        runCallOut = false;
        Profile p;
        Account acc = new Account(Name = 'Test fusionSpan Account Test1');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Fusionspan Test1', AccountId = acc.Id, Email='test1@example.com');
        insert con;

        try {
            p = [SELECT Id FROM Profile WHERE Name = :PROFILE];

        } catch (Exception e) {
            p = [SELECT Id FROM Profile WHERE Name = :LIVE_PROFILE];
        }

        User testUser = new User(
                FirstName = 'Test 1',
                LastName = 'fusionSpan',
                Email = 'test1@example.com',
                Username = 'test1@example.com',
                Alias = 'test1',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                ContactId = con.Id
        );
        insert testUser;

        con.Email = 'test234@example.com';
        update con;

        Test.startTest();
        //    Database.executeBatch(new FS_UpdateUserFormulaFields());
        FS_UpdateUserFormulaFields sched = new FS_UpdateUserFormulaFields();
        FS_UpdateUserFormulaFields.fieldMappings = null;
        String cron = '0 0 23 * * ?';
        System.schedule('Test Sched', cron, sched);
        sched.execute(null);
        Test.stopTest();

        User usr = [SELECT Id,Email FROM User WHERE Id = :testUser.Id];
        // System.assertEquals(con.Email, usr.Email);

    }

    @IsTest
    private static void testRemovingContactMembership_ExpectUserUpdated() {
        runCallOut = false;
        Profile p;
        Account acc = new Account(Name = 'Test fusionSpan Account Test2');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Fusionspan Test2', AccountId = acc.Id, Email='test1@example.com');
        insert con;

        try {
            p = [SELECT Id FROM Profile WHERE Name = :PROFILE];

        } catch (Exception e) {
            p = [SELECT Id FROM Profile WHERE Name = :LIVE_PROFILE];
        }

        User testUser = new User(
                FirstName = 'Test2',
                LastName = 'fusionSpan2',
                Email = 'test2@example.com',
                Username = 'test2@example.com',
                Alias = 'test2',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                ContactId = con.Id
        );
        insert testUser;

        con.FirstName = 'fusionSpan';
        con.LastName = 'Test';
        update con;

        Test.startTest();
        //    Database.executeBatch(new FS_UpdateUserFormulaFields());
        FS_UpdateUserFormulaFields sched = new FS_UpdateUserFormulaFields();
        FS_UpdateUserFormulaFields.fieldMappings = null;
        String cron = '0 0 23 * * ?';
        System.schedule('Test Sched', cron, sched);
        sched.execute(null);
        Test.stopTest();

        User usr = [SELECT Id,FirstName,LastName FROM User WHERE Id = :testUser.Id];
        System.assertEquals(con.FirstName, usr.FirstName);
        System.assertEquals(con.LastName, usr.LastName);
    }

}