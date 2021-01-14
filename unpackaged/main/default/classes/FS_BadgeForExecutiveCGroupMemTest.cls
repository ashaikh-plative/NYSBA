/**
 * Created by Nikhil on 23-12-2019.
 */

@IsTest
public without sharing class FS_BadgeForExecutiveCGroupMemTest {
    private static final String ACTIVE_STRING = 'Active';
    private static final String DEACTIVATED_STRING = 'Deactivated';
    private static final String CONTACT_STRING = 'Contact';

    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_BadgeForExecutiveCommunityGroupMember.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'PagesApi__Community_Group_Member__c';
        routingRule.executionOrder = 40;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Account testAcc = new Account(Name='No duplica123123te Account');
        insert testAcc;
        Contact testContact = new Contact(FirstName='Te123asd', LastName='asdgawq2', AccountId=testAcc.Id
        );
        insert testContact;
    }

    @IsTest
    public static void testBadgeCreation_From_ComGroupMember(){
        Account testAcc = [SELECT Id FROM Account WHERE Name='No duplica123123te Account'][0];
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'asdgawq2'][0];
        OrderApi__Business_Group__c testBusGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert testBusGroup;
        PagesApi__Site__c testSite = new PagesApi__Site__c(
                Name = 'Test Site',
                OrderApi__Business_Group__c=testBusGroup.Id
        );
        insert testSite;

        PagesApi__Community_Group__c CommunityGroup = new PagesApi__Community_Group__c(
                Name='Executive community Group',
                PagesApi__Member_Entity_Type__c=CONTACT_STRING,
                FS_Business_Group__c=testBusGroup.Id,
                FS_Is_Executive__c = true,
                FS_Committee_Code__c = 'A001',
                PagesApi__Site__c = testSite.Id
        );
        insert new List<PagesApi__Community_Group__c>{CommunityGroup};

        PagesApi__Community_Group_Member__c communityGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = CommunityGroup.Id,
                PagesApi__Status__c = ACTIVE_STRING,
                PagesApi__Contact__c = testContact.Id
        );
        insert communityGroupMember;

        OrderApi__Badge__c badge = new OrderApi__Badge__c(
                OrderApi__Contact__c = testContact.Id,
                OrderApi__Is_Active__c = true,
                FS_Committee_Code__c = CommunityGroup.FS_Committee_Code__c
        );
        insert badge;

        communityGroupMember.PagesApi__Status__c = DEACTIVATED_STRING;
        update communityGroupMember;

        badge.OrderApi__Is_Active__c = false;
        update badge;

        delete communityGroupMember;
    }
}