/**
 * Created by cmudd on 2019-10-17.
 */
@IsTest
public without sharing class FS_CommunityGroupMemberDropTest {
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
        routingRule.apexClass = FS_CommunityGroupMemberDrop.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'Contact';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    private static void testDroppingMembership_ExpectCommMembersDeactivated() {
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(FirstName='Test',LastName='Fusionspan', FS_Membership_Expiry_Date__c = System.today()+5,FS_Member_Status__c='Active');
        conList.add(con);
        insert conList;

        PagesApi__Community_Group__c communityGroup=new PagesApi__Community_Group__c(Name='Test Group');
        insert communityGroup;

        PagesApi__Community_Group_Member__c communityGroupMember = new PagesApi__Community_Group_Member__c(PagesApi__Contact__c=con.Id,
                PagesApi__Is_Active__c=true,FS_Grace_Period_End_Date__c=null,FS_Paid_Through_Date__c=System.today().addDays(5),PagesApi__Community_Group__c=communityGroup.Id);
        insert communityGroupMember;

        FS_Community_Group_Member_Term__c communityGroupMemberTerm = new FS_Community_Group_Member_Term__c(FS_Term_Start_Date__c=System.today().addYears(-1),FS_Term_End_Date__c=System.today().addDays(5),
                FS_Term_Grace_Period_End_Date__c=null,FS_Deactivated_Manually__c=false,FS_Community_Group_Member__c=communityGroupMember.Id);
        insert communityGroupMemberTerm;

        Test.startTest();
        con.FS_Member_Status__c = 'Inactive';
        update con;
        Test.stopTest();

        communityGroupMember.PagesApi__Is_Active__c = false;
        communityGroupMember.FS_Paid_Through_Date__c = System.today();
        update communityGroupMember;

        communityGroupMemberTerm.FS_Deactivated_Manually__c=true;
        communityGroupMemberTerm.FS_Term_End_Date__c=System.today();
        update communityGroupMemberTerm;

//        Map<Id,Contact> contactMapMap = new Map<Id,Contact>([SELECT Id,FS_Contact_Member_Status__c FROM Contact WHERE Id=:conList]);

        System.assertEquals(0, [SELECT Id FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Is_Active__c = TRUE].size());

//        FS_CommunityGroupMemberDrop cGroupMemDrop = new FS_CommunityGroupMemberDrop(conList);
//        FS_CommunityGroupMemberDrop.Constructor constructor = new FS_CommunityGroupMemberDrop.Constructor();
//        constructor.construct(conList);
//        cGroupMemDrop.afterUpdate(contactMapMap);
    }
}