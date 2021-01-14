/**
 * Created by Seshu on 11-03-2020.
 */

@IsTest
private class FS_HandlePreferredEmailChangeRuleTest {
    private static final String TEST_EMAIL = 'test@gmail.com';
    private static final String TEST_PERSONAL_EMAIL = 'testpersonal@gmail.com';
    private static final String TEST_OTHER_EMAIL = 'testother@gmail.com';
    private static final String TEST_ASSISTANT_EMAIL = 'testassistant@gmail.com';
    private static final String TEST_WORK_EMAIL = 'testwork@gmail.com';

    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule changePrefferedEmailType = new Framework.RoutingRule();
        changePrefferedEmailType.apexClass = FS_HandlePreferredEmailChangeRule.class.getName();
        changePrefferedEmailType.namespace = '';
        changePrefferedEmailType.isEnabled = true;
        changePrefferedEmailType.sObjectName = 'Contact';
        changePrefferedEmailType.executionOrder = 30;
        rules.add(changePrefferedEmailType);
        Framework.Config.push(rules);

        //Contact
        Contact contact = FS_TestUtils.createContact('test',TEST_EMAIL);
        contact.OrderApi__Personal_Email__c = TEST_PERSONAL_EMAIL;
        contact.OrderApi__Work_Email__c = TEST_WORK_EMAIL;
        insert contact;
        System.assertEquals(contact.email,TEST_EMAIL);
    }

    @IsTest
    static void workEmailType() {
        Contact contact = [SELECT Id FROM Contact WHERE Name='test' LIMIT 1];
        contact.HasOptedOutOfEmail = true;
        contact.OrderApi__Preferred_Email_Type__c = FS_HandlePreferredEmailChangeRule.WORK_TYPE;
        contact.OrderApi__Work_Email__c = TEST_WORK_EMAIL;
        update contact;
        Contact contactAfterUpdate = [SELECT Email,FS_Preferred_Email__c FROM Contact WHERE Id=:contact.Id LIMIT 1];
        System.assertEquals(contactAfterUpdate.Email,TEST_WORK_EMAIL);
        System.assertEquals(contactAfterUpdate.FS_Preferred_Email__c,TEST_WORK_EMAIL);

    }

    @IsTest
    static void personalEmailType() {
        Contact contact = [SELECT Id FROM Contact WHERE Name='test' LIMIT 1];
        contact.OrderApi__Assistant_Email_Opt_Out__c = true;
        contact.OrderApi__Preferred_Email_Type__c = FS_HandlePreferredEmailChangeRule.PERSONAL_TYPE;
        contact.OrderApi__Personal_Email__c = TEST_PERSONAL_EMAIL;
        update contact;
        Contact contactAfterUpdate = [SELECT Email,FS_Preferred_Email__c FROM Contact WHERE Id=:contact.Id LIMIT 1];
        System.assertEquals(contactAfterUpdate.Email,TEST_PERSONAL_EMAIL);
        System.assertEquals(contactAfterUpdate.FS_Preferred_Email__c,TEST_PERSONAL_EMAIL);

    }

    @IsTest
    static void otherEmailType() {
        Contact contact = [SELECT Id FROM Contact WHERE Name='test' LIMIT 1];
        contact.OrderApi__Work_Email_Opt_Out__c = true;
        contact.OrderApi__Preferred_Email_Type__c = FS_HandlePreferredEmailChangeRule.OTHER_TYPE;
        contact.OrderApi__Other_Email__c = TEST_OTHER_EMAIL;
        update contact;
        Contact contactAfterUpdate = [SELECT Email,FS_Preferred_Email__c FROM Contact WHERE Id=:contact.Id LIMIT 1];
        System.assertEquals(contactAfterUpdate.Email,TEST_OTHER_EMAIL);
        System.assertEquals(contactAfterUpdate.FS_Preferred_Email__c,TEST_OTHER_EMAIL);

    }

    @IsTest
    static void assistantEmailType() {
        Contact contact = [SELECT Id FROM Contact WHERE Name='test' LIMIT 1];
        contact.OrderApi__Other_Email_Opt_Out__c = true;
        contact.OrderApi__Preferred_Email_Type__c = FS_HandlePreferredEmailChangeRule.ASSISTANT_TYPE; 
        contact.OrderApi__Assistant_Email__c = TEST_ASSISTANT_EMAIL;
        update contact;
        Contact contactAfterUpdate = [SELECT Email,FS_Preferred_Email__c FROM Contact WHERE Id=:contact.Id LIMIT 1];
        System.assertEquals(contactAfterUpdate.Email,TEST_ASSISTANT_EMAIL);
        System.assertEquals(contactAfterUpdate.FS_Preferred_Email__c,TEST_ASSISTANT_EMAIL);
    }
}