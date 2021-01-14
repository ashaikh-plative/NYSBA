@IsTest
private class FS_PrimaryAffiliationUpdateTest {

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
        joinapi.PackageScripts.install();
        ProgramApi.PackageScripts.install();
        PriceApi.PackageScripts.install();
        DRCTS.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_PrimaryAffiliationUpdateRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'FS_Affiliation__c';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Account acc = new Account(
                Name = 'Tadesasd1234aszt Aasd1fccount');
        insert acc;
        //Inserting Contact
        Contact con = new Contact(
                LastName = 'tesavzvt',
                FirstName = 'conxzcwq2tact',
                Title = 'Manager',
                AccountId = acc.Id);
        insert con;
    }
    @IsTest
    private static void testPrimaryAffiliationOnContact() {
        //Inserting Account
        Account acc = [SELECT Id FROM Account WHERE Name = 'Tadesasd1234aszt Aasd1fccount'][0];
        //Inserting Contact
        Contact con = [SELECT Id FROM Contact WHERE LastName='tesavzvt'][0];


        //Inserting Affiliation with Account and Contact
        List<FS_Affiliation__c> affiliationList = new List<FS_Affiliation__c>();
        FS_Affiliation__c affiliation = new FS_Affiliation__c(
                FS_Parent_Account__c = acc.Id,
                FS_Child_Contact__c = con.Id,
                FS_Primary_Affiliation__c = true,
                FS_Status__c = 'Active',
                FS_PrimaryContact__c = true);
        affiliationList.add(affiliation);
        FS_PrimaryAffiliationUpdateRule controller = new FS_PrimaryAffiliationUpdateRule(affiliationList);
        controller.beforeInsert();
        insert affiliationList;
        controller.afterInsert();

        Test.startTest();

        List<Account> parentAccount = [SELECT Id,OrderApi__Primary_Contact__c FROM Account WHERE Id = :affiliation.FS_Parent_Account__c LIMIT 1];
        List<Contact> childAccount = [SELECT Id,FS_Primary_Affiliation__c,FS_Primary_Affiliation_Record__c FROM Contact WHERE Id = :affiliation.FS_Child_Contact__c LIMIT 1];

        System.assertEquals(affiliation.FS_Parent_Account__c, childAccount[0].FS_Primary_Affiliation__c);
        System.assertEquals(affiliation.FS_Child_Contact__c, parentAccount[0].OrderApi__Primary_Contact__c);
        System.assertEquals(affiliation.Id, childAccount[0].FS_Primary_Affiliation_Record__c);

        affiliation.FS_Status__c = 'Inactive';
        controller.beforeUpdate(new Map<Id, FS_Affiliation__c>{
                affiliation.Id => affiliation
        });
        if (affiliation.FS_Primary_Affiliation__c) {
            affiliation.FS_Primary_Affiliation__c = false;
        }
        update affiliation;
        affiliation.FS_Status__c = 'Active';
        affiliation.FS_Primary_Affiliation__c = true;
        controller.afterUpdate(new Map<Id, FS_Affiliation__c>{
                affiliation.Id => affiliation
        });

        Test.stopTest();


        parentAccount = [SELECT Id,OrderApi__Primary_Contact__c FROM Account WHERE Id = :affiliation.FS_Parent_Account__c LIMIT 1];
        childAccount = [SELECT Id,FS_Primary_Affiliation__c,FS_Primary_Affiliation_Record__c FROM Contact WHERE Id = :affiliation.FS_Child_Contact__c LIMIT 1];

        System.assertEquals(null, childAccount[0].FS_Primary_Affiliation__c);
        System.assertEquals(null, parentAccount[0].OrderApi__Primary_Contact__c);
        System.assertEquals(null, childAccount[0].FS_Primary_Affiliation_Record__c);
    }
}