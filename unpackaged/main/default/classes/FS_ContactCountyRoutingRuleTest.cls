@IsTest
public class FS_ContactCountyRoutingRuleTest {
    private static final String NEW_YORK_STRING = 'New York';
    private static final String UNITED_STATES_STRING = 'United States';
    private static final String NEW_YORK_STATE_STRING ='New York State';
    private static final String CHANGED ='Changed';
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        ROEApi.PackageScripts.install();
        CPBase.PackageScripts.install();
        LTE.PackageScripts.install();
        FDService.BUPackageScripts.install();
        DonorApi.PackageScripts.install();
        JoinApi.PackageScripts.install();
        ProgramApi.PackageScripts.install();
        PriceApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule accountJoinDateUpdate = new Framework.RoutingRule();
        accountJoinDateUpdate.apexClass = FS_ContactCountyRoutingRule.class.getName();
        accountJoinDateUpdate.namespace = '';
        accountJoinDateUpdate.isEnabled = true;
        accountJoinDateUpdate.sObjectName = 'Contact';
        accountJoinDateUpdate.executionOrder = 26;
        rules.add(accountJoinDateUpdate);
        Framework.Config.push(rules);
        List<Contact> conList= new List<Contact>();
        Contact c =new Contact(LastName='Test', smartystreets__Mailing_Return_Code__c ='');
        conList.add(c);
        Contact c1 =new Contact(LastName='Test1',smartystreets__Mailing_Return_Code__c = CHANGED);
        conList.add(c1);
        Contact c2 =new Contact(LastName='Test2',smartystreets__Other_Return_Code__c='' );
        conList.add(c2);
        Contact c3 =new Contact(LastName='Test3',smartystreets__Other_Return_Code__c = CHANGED );
        conList.add(c3);
        insert conList;
    }
    @IsTest
    private static void testBehavior() {
        Contact con =[SELECT Id,FS_API_Mailing_County__c,smartystreets__Other_Return_Code__c FROM Contact WHERE LastName=:'Test'];
        System.assertEquals(con.FS_API_Mailing_County__c, null);
    }
    @IsTest
    private static void testBehaviorUpdate() {
        List<Contact> newContactList = new List<Contact>();
        Contact c1 =[SELECT Id,FS_API_Mailing_County__c,MailingState,MailingCountry,smartystreets__Mailing_Return_Code__c FROM Contact WHERE LastName=:'Test1' LIMIT 1];
        c1.MailingCountry = UNITED_STATES_STRING;
        c1.MailingState= NEW_YORK_STRING;
        c1.FS_API_Mailing_County__c = null;
        Test.startTest();
        update c1;
        Test.stopTest();
        Contact con =[SELECT Id,FS_API_Mailing_County__c,smartystreets__Other_Return_Code__c FROM Contact WHERE LastName=:'Test1' LIMIT 1];
        System.assertEquals(con.FS_API_Mailing_County__c, NEW_YORK_STATE_STRING);
    }
    @IsTest
    private static void testBehaviorUpdateForHomeNull(){
        Contact con = [SELECT Id,FS_API_Other_County__c,smartystreets__Other_Return_Code__c FROM Contact WHERE LastName =:'Test2' LIMIT 1];
        System.assertEquals(con.FS_API_Other_County__c, null);
    }
}