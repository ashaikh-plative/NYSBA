@IsTest
public class FS_LawSchoolLookupControllerTest {

    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_TermRoutingRule.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Renewal__c';
        routingRule.executionOrder = 50;
        rules.add(routingRule);
        Framework.Config.push(rules);


    }

    @IsTest
    public static void FS_LawSchoolLookupControllerTest() {
        Account a = new Account(Name='Test Account Name');
        a.RecordTypeId='0121U000000WtUHQA0';
        a.FS_Accredited__c=true;
        a.FS_School_Type__c='Law School';
        insert a;

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.id);
        insert c;

        User user = new User();
        user.ProfileId = [SELECT Id FROM Profile WHERE Name='Fonteva Customer Community Login User'].get(0).Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';

        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@domain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = c.Id;

        insert user;

        Test.startTest();
        System.runAs(user) {
            FS_LawSchoolLookupController.getRecord(a.Id);
            List<Account> results = FS_LawSchoolLookupController.fetchLookUpValues('Columbia', 'Account');
//            System.assertEquals('0121U000000WtUHQA0', results[0].recordTypeId);

            
        }

        Test.stopTest();
    }

    
}