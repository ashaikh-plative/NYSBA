/**
 * Created by cmudd on 2019-10-17.
 */
@IsTest
public with sharing class FS_CommunityGroupParentMemberDropTest {

    @TestSetup
    public static void install() {
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
        DRCTS.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_CommunityGroupParentMemberDrop.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'PagesApi__Community_Group_Member__c';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    private static void testDroppingMembership_ExpectCommMembersDeactivated() {
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(FirstName='Test',LastName='Fusionspan', FS_Membership_Expiry_Date__c = System.today().addDays(5),FS_Member_Status__c='Active');
        conList.add(con);
        insert conList;

        PagesApi__Community_Group__c communityGroup=new PagesApi__Community_Group__c(Name='Test Group',PagesApi__Type__c='Section');
        insert communityGroup;

        PagesApi__Community_Group__c communityGroup2 = new PagesApi__Community_Group__c(Name='Test Group 2',PagesApi__Type__c='Section',FS_Parent_Section__c=communityGroup.Id);
        insert communityGroup2;



        PagesApi__Community_Group_Member__c communityGroupMember = new PagesApi__Community_Group_Member__c(PagesApi__Contact__c=con.Id,
                FS_Term_Start_Date__c=System.today().addDays(-5),FS_Term_End_Date__c=System.today().addDays(5),
                PagesApi__Is_Active__c=true,FS_Grace_Period_End_Date__c=System.today().addDays(5),FS_Paid_Through_Date__c=System.today().addDays(5),
                PagesApi__Community_Group__c=communityGroup.Id);
        insert communityGroupMember;

        FS_Community_Group_Member_Term__c communityGroupMemberTerm = new FS_Community_Group_Member_Term__c(FS_Term_Start_Date__c=System.today(),
                FS_Term_End_Date__c=System.today().addDays(5),FS_Term_Grace_Period_End_Date__c=null,FS_Deactivated_Manually__c=false,FS_Community_Group_Member__c=communityGroupMember.Id);
        insert communityGroupMemberTerm;

        PagesApi__Community_Group_Member__c communityGroupMember2 = new PagesApi__Community_Group_Member__c(PagesApi__Contact__c=con.Id,FS_Term_Start_Date__c=System.today(),
                FS_Term_End_Date__c=System.today().addDays(5),PagesApi__Is_Active__c=true,FS_Grace_Period_End_Date__c=System.today().addDays(5),
                FS_Paid_Through_Date__c=System.today().addDays(5),PagesApi__Community_Group__c=communityGroup2.Id);
        insert communityGroupMember2;

        FS_Community_Group_Member_Term__c communityGroupMemberTerm2 = new FS_Community_Group_Member_Term__c(FS_Term_Start_Date__c=System.today(),
                FS_Term_End_Date__c=System.today().addDays(5), FS_Term_Grace_Period_End_Date__c=null,FS_Deactivated_Manually__c=false,FS_Community_Group_Member__c=communityGroupMember.Id);
        insert communityGroupMemberTerm2;

        Test.startTest();
        communityGroupMember.PagesApi__Is_Active__c = false;
        update communityGroupMember;
        Test.stopTest();

        communityGroupMember.PagesApi__Is_Active__c = false;
        communityGroupMember.FS_Paid_Through_Date__c = System.today();
        update communityGroupMember;

        communityGroupMemberTerm.FS_Deactivated_Manually__c=true;
        communityGroupMemberTerm.FS_Term_End_Date__c=System.today();
        update communityGroupMemberTerm;

        System.assertEquals(0, [SELECT Id FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Is_Active__c = TRUE].size());

//        Map<Id,Contact> contactMapMap = new Map<Id,Contact>([SELECT Id,FS_Contact_Member_Status__c FROM Contact WHERE Id=:conList]);

//        FS_CommunityGroupMemberDrop cGroupMemDrop = new FS_CommunityGroupMemberDrop(conList);
//        FS_CommunityGroupMemberDrop.Constructor constructor = new FS_CommunityGroupMemberDrop.Constructor();
//        constructor.construct(conList);
//        cGroupMemDrop.afterUpdate(contactMapMap);
    }
}