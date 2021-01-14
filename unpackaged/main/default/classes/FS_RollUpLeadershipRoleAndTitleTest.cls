@isTest
private class FS_RollUpLeadershipRoleAndTitleTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_RollUpLeadershipAndTitleRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'FS_Leadership_Role_and_Title__c';
        routingRule.executionOrder = 20;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Contact con = new Contact();
        con.LastName = 'thisLastNameUniqueNoBodyCare';
        insert con;

        Account ac = new Account();
        ac.Name = 'txczxc0est acasf12gcount';
        ac.OrderApi__Primary_Contact__c = con.Id;
        insert ac;
    }

    @IsTest
    private static void addOrUpdateRolesAndTitlesTest() {
        Test.startTest();
        Account ac = [SELECT Id FROM Account WHERE Name ='txczxc0est acasf12gcount'][0];
        Contact con = [SELECT Id FROM Contact WHERE LastName='thisLastNameUniqueNoBodyCare'][0];
        
        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c();
        communityGroup.Name = 'Test Group1';
        communityGroup.PagesApi__Type__c = 'Committe';
        communityGroup.PagesApi__Member_Entity_Type__c = 'Contact';
        communityGroup.PagesApi__Enable_Members__c = true;
        communityGroup.PagesApi__Enable_Community_Feed__c = true;
        communityGroup.PagesApi__Enable_Events__c = true;
        communityGroup.PagesApi__Privacy_Setting__c = 'Public';
        insert communityGroup;
        
        List<PagesApi__Community_Group_Member__c> cgmList = new List<PagesApi__Community_Group_Member__c>();
        PagesApi__Community_Group_Member__c cgm1 = new PagesApi__Community_Group_Member__c();
        cgm1.PagesApi__Community_Group__c = communityGroup.Id;
        cgm1.PagesApi__Status__c = 'Active';
        cgm1.PagesApi__Role__c = 'member';
        cgm1.PagesApi__Activated_Date__c = System.today() - 1;
        cgm1.PagesApi__Contact__c = con.Id;
        cgmList.add(cgm1);
        insert cgmList;
        
        List<FS_Leadership_Role_and_Title__c> roleAndTitleList = new List<FS_Leadership_Role_and_Title__c>();
        FS_Leadership_Role_and_Title__c roleAndtitle1 = new FS_Leadership_Role_and_Title__c();
        roleAndtitle1.FS_Leadership_Role__c = '010 - President';
        roleAndtitle1.FS_Leadership_Title__c = 'president test';
        roleAndtitle1.FS_Start_Date__c = System.today() - 10;
        roleAndtitle1.FS_End_Date__c = System.today() + 355;
        roleAndtitle1.FS_Community_Group_Member__c = cgm1.Id;
        roleAndTitleList.add(roleAndtitle1);

        FS_Leadership_Role_and_Title__c roleAndtitle2 = new FS_Leadership_Role_and_Title__c();
        roleAndtitle2.FS_Leadership_Role__c = '020 - Chair';
        roleAndtitle2.FS_Leadership_Title__c = 'chair test';
        roleAndtitle2.FS_Start_Date__c = System.today() - 10;
        roleAndtitle2.FS_End_Date__c = System.today() + 355;
        roleAndtitle2.FS_Community_Group_Member__c = cgm1.Id;
        roleAndTitleList.add(roleAndtitle2);
        insert roleAndTitleList;
        
        FS_RollUpLeadershipAndTitleRoutingRule roleTitleRoutingRule= new FS_RollUpLeadershipAndTitleRoutingRule(roleAndTitleList);
        FS_RollUpLeadershipAndTitleRoutingRule.Constructor fscc = new FS_RollUpLeadershipAndTitleRoutingRule.Constructor();
        fscc.construct(roleAndTitleList);
        roleTitleRoutingRule.afterInsert();
        Map<Id, FS_Leadership_Role_and_Title__c> oldMap = new Map<Id, FS_Leadership_Role_and_Title__c>([SELECT Id, FS_Leadership_Role__c, FS_Is_Active__c, 
                                                            FS_Leadership_Title__c, FS_Start_Date__c, FS_End_Date__c, FS_Community_Group_Member__c
															FROM FS_Leadership_Role_and_Title__c WHERE Id IN: roleAndTitleList]);
       	roleAndtitle2.FS_End_Date__c = System.today() -1;
        roleAndtitle2.FS_Leadership_Title__c = 'update test';
        update roleAndTitleList;
        roleTitleRoutingRule= new FS_RollUpLeadershipAndTitleRoutingRule(roleAndTitleList);
        fscc = new FS_RollUpLeadershipAndTitleRoutingRule.Constructor();
        fscc.construct(roleAndTitleList);
        roleTitleRoutingRule.afterUpdate(oldMap);
        delete roleAndtitle1;
        roleTitleRoutingRule.afterDelete();
        Test.stopTest();
    }

    @isTest static void schedulerTest(){
        Account ac = [SELECT Id FROM Account WHERE Name ='txczxc0est acasf12gcount'][0];
        Contact con = [SELECT Id FROM Contact WHERE LastName='thisLastNameUniqueNoBodyCare'][0];
        
        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c();
        communityGroup.Name = 'Test Group1';
        communityGroup.PagesApi__Type__c = 'Committe';
        communityGroup.PagesApi__Member_Entity_Type__c = 'Contact';
        communityGroup.PagesApi__Enable_Members__c = true;
        communityGroup.PagesApi__Enable_Community_Feed__c = true;
        communityGroup.PagesApi__Enable_Events__c = true;
        communityGroup.PagesApi__Privacy_Setting__c = 'Public';
        insert communityGroup;
        
        List<PagesApi__Community_Group_Member__c> cgmList = new List<PagesApi__Community_Group_Member__c>();
        PagesApi__Community_Group_Member__c cgm1 = new PagesApi__Community_Group_Member__c();
        cgm1.PagesApi__Community_Group__c = communityGroup.Id;
        cgm1.PagesApi__Status__c = 'Active';
        cgm1.PagesApi__Role__c = 'Chair';
        cgm1.PagesApi__Activated_Date__c = System.today() - 1;
        cgm1.PagesApi__Contact__c = con.Id;
        cgmList.add(cgm1);
        insert cgmList;

        
        List<FS_Leadership_Role_and_Title__c> roleAndTitleList = new List<FS_Leadership_Role_and_Title__c>();
        List<String> rolesListTest = new List<String>();
        List<String> titlesListTest = new List<String>();
        FS_Leadership_Role_and_Title__c roleAndtitle = new FS_Leadership_Role_and_Title__c();
        roleAndtitle.FS_Leadership_Role__c = '010 - President';
        roleAndtitle.FS_Leadership_Title__c = 'president test';
        roleAndtitle.FS_Start_Date__c = System.today() - 1;
        roleAndtitle.FS_End_Date__c = System.today() + 365;
        roleAndtitle.FS_Community_Group_Member__c = cgm1.Id;
        roleAndTitleList.add(roleAndtitle);

        FS_Leadership_Role_and_Title__c roleAndtitle2 = new FS_Leadership_Role_and_Title__c();
        roleAndtitle2.FS_Leadership_Role__c = '020 - Chair';
        roleAndtitle2.FS_Leadership_Title__c = 'chair test';
        roleAndtitle2.FS_Start_Date__c = System.today() - 1;
        roleAndtitle2.FS_End_Date__c = System.today() + 365;
        roleAndtitle2.FS_Community_Group_Member__c = cgm1.Id;
        roleAndTitleList.add(roleAndtitle2);
        
        FS_Leadership_Role_and_Title__c roleAndtitle3 = new FS_Leadership_Role_and_Title__c();
        roleAndtitle3.FS_Leadership_Role__c = '080 - Delegate';
        roleAndtitle3.FS_Leadership_Title__c = 'Delegate test';
        roleAndtitle3.FS_Start_Date__c = System.today() - 200;
        roleAndtitle3.FS_End_Date__c = System.today() - 1;
        roleAndtitle3.FS_Community_Group_Member__c = cgm1.Id;
        roleAndTitleList.add(roleAndtitle3);

        insert roleAndTitleList;
        for(FS_Leadership_Role_and_Title__c roleAndTitleInLoop : roleAndTitleList){
            rolesListTest.add(roleAndTitleInLoop.FS_Leadership_Role__c);
            titlesListTest.add(roleAndTitleInLoop.FS_Leadership_Title__c);
        }
            String CRON_EXP = '0 0 0 15 3 ? *';
            Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new FS_RollUpLeadershipAndTitleBatch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}