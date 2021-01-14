/**
* Created by cmudd on 2019-08-21.
*/
@IsTest
public without sharing class FS_DeactivateCommunityGroupMembersTest {

    @IsTest
    static void deactivateCGM() {
        OrderApi__Business_Group__c businessGroup = new OrderApi__Business_Group__c(Name='test');
        insert businessGroup;

        Account acc = new Account(Name='Test');
        insert acc;

        Contact con1 = new Contact(LastName='Test1', AccountId=acc.Id);
        insert con1;

        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c(Name='test',
                PagesApi__Type__c='Section');
        insert communityGroup;

        PagesApi__Community_Group_Member__c communityGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c=con1.Id, /*FS_Community_Group_Type__c='Section',*/ PagesApi__Is_Active__c=true,
                PagesApi__Status__c='Active',FS_Term_Start_Date__c=System.today().addDays(-1),
                FS_Term_End_Date__c=System.today().addDays(-1),
                PagesApi__Community_Group__c=communityGroup.Id);
        insert communityGroupMember;

        FS_Community_Group_Member_Term__c term = new FS_Community_Group_Member_Term__c(FS_Term_Start_Date__c=System.today().addDays(-1),
                FS_Term_End_Date__c=System.today().addDays(-1),FS_Term_Grace_Period_End_Date__c=System.today().addDays(-1),
                FS_Community_Group_Member__c=communityGroupMember.Id);
        insert term;

        update communityGroup;

        communityGroupMember.PagesApi__Status__c = 'Active';
        communityGroupMember.PagesApi__Is_Active__c = true;
        communityGroupMember.FS_Paid_Through_Date__c = System.today().addDays(-1);
        update communityGroupMember;

        //////
        OrderApi__Business_Group__c businessGroup2 = new OrderApi__Business_Group__c(Name='test2');
        insert businessGroup2;

        Account acc2 = new Account(Name='Test2');
        insert acc2;

        Contact con2 = new Contact(LastName='Test2', AccountId=acc2.Id);
        insert con2;

        PagesApi__Community_Group__c communityGroup2 = new PagesApi__Community_Group__c(Name='test2',
                PagesApi__Type__c='Section');
        insert communityGroup2;

        PagesApi__Community_Group_Member__c communityGroupMember2 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c=con2.Id, /*FS_Community_Group_Type__c='Section',*/ PagesApi__Is_Active__c=true,
                PagesApi__Status__c='Active',FS_Term_Start_Date__c=System.today().addDays(-1),
                FS_Term_End_Date__c=System.today().addDays(-1),
                PagesApi__Community_Group__c=communityGroup2.Id);
        insert communityGroupMember2;

        FS_Community_Group_Member_Term__c term2 = new FS_Community_Group_Member_Term__c(FS_Term_Start_Date__c=System.today().addDays(-1),
                FS_Term_End_Date__c=System.today().addDays(5),FS_Term_Grace_Period_End_Date__c=System.today().addDays(10),
                FS_Community_Group_Member__c=communityGroupMember2.Id);
        insert term2;

        update communityGroup2;

        communityGroupMember2.PagesApi__Status__c = 'Deactivated';
        communityGroupMember2.PagesApi__Is_Active__c = false;
        update communityGroupMember2;
        Test.startTest();
        String cron='0 0 0 * * ?  *';
//        FS_DeleteOpenSalesOrderSchedulable dsb = new FS_DeleteOpenSalesOrderSchedulable();
        Datetime dt = Datetime.now().addMinutes(1);
        FS_DeactivateCommunityGroupMembersBatch sched = new FS_DeactivateCommunityGroupMembersBatch(true);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, sched );
        sched.execute(null);
        Test.stopTest();

//        System.assertEquals('Deactivated', [SELECT Id,PagesApi__Status__c FROM PagesApi__Community_Group_Member__c].PagesApi__Status__c);
    }
}