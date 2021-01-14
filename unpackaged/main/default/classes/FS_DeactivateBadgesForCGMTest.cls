/**
 * @author Christopher Mudd from fusionSpan
 * @date 01/28/20
 *
 * @description test class for FS_DeactivateBadgesForCGM
 */

@IsTest
private class FS_DeactivateBadgesForCGMTest {

    private static final String EMAIL = 'test@fusionspan.com';

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
        DRCTS.PackageScripts.install();

        OrderApi__Business_Group__c businessGroup = new OrderApi__Business_Group__c(Name='test');
        insert businessGroup;

        Account acc = new Account(Name='Test');
        insert acc;

        Contact con = new Contact(FirstName='Contact',LastName='Test', Email=EMAIL,AccountId=acc.Id);
        insert con;

        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c(Name='Test Group',
                PagesApi__Type__c='Section');
        insert communityGroup;

//        PagesApi__Community_Group__c communityGroup2 = new PagesApi__Community_Group__c(Name='Test Sub Group',
//                PagesApi__Type__c='Section',FS_Parent_Section__c=communityGroup.Id);
//        insert communityGroup2;

        // Contact must have an active membership to purchase sections
//        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name='Test Item Class',OrderApi__Is_Subscription__c=true,FS_Is_Membership__c=true);
//        insert itemClass;
//        OrderApi__Item__c item = new OrderApi__Item__c(
//                Name='Test Item',OrderApi__Item_Class__c=itemClass.Id,OrderApi__Is_Subscription__c=true,
//                OrderApi__Price__c=1,OrderApi__Business_Group__c=businessGroup.Id);
//        insert item;
//
//        OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c(Name='Test Sub Plan',OrderApi__Type__c = 'Termed',
//                OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
//                OrderApi__Renewal_Term_Months__c = 12,
//                OrderApi__Calendar_End_Day__c = '31',
//                OrderApi__Calendar_End_Month__c = '12-Dec',
//                OrderApi__Invoice_Days_Variable__c= 31,
//                OrderApi__Bill_Cycle__c = 'AUTO', OrderApi__Business_Group__c = businessGroup.Id,OrderApi__Is_Active__c=true);
//        insert subPlan;
//        OrderApi__Item_Subscription_Plan__c itemSubPlan = new OrderApi__Item_Subscription_Plan__c(
//                OrderApi__Item__c=item.Id,OrderApi__Subscription_Plan__c=subPlan.Id,OrderApi__Is_Default__c=true);
//        insert itemSubPlan;
//
//        item.OrderApi__Is_Active__c = true;
//        update item;

        // Now create item for the section the contact will purchase
        OrderApi__Item_Class__c itemClass2 = new OrderApi__Item_Class__c(Name='Section Dues');
        insert itemClass2;
        OrderApi__Item__c item2 = new OrderApi__Item__c(Name='Test Membership Section',OrderApi__Item_Class__c=itemClass2.Id,
                FS_Linked_Community_Group__c=communityGroup.Id,OrderApi__Is_Active__c=true,OrderApi__Business_Group__c=businessGroup.Id);
        insert item2;

    }

    @IsTest
    static void testDeactivatingCommunityGroupMember_ExpectBadgeDeactivated() {

        Contact con = [SELECT Id FROM Contact WHERE Email = :EMAIL];
        PagesApi__Community_Group__c commGroup = [SELECT Id FROM PagesApi__Community_Group__c LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];

        PagesApi__Community_Group_Member__c commMem = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c=con.Id,PagesApi__Community_Group__c=commGroup.Id,PagesApi__Status__c='Active',
                PagesApi__Is_Active__c=true, FS_Term_Start_Date__c=System.today().addDays(-7),
                FS_Term_End_Date__c=System.today().addDays(7), FS_Grace_Period_End_Date__c=System.today().addDays(37),
                FS_Paid_Through_Date__c=System.today().addDays(7)
        );
        insert commMem;

        OrderApi__Badge__c badge = new OrderApi__Badge__c(
                OrderApi__Contact__c = con.Id,
                OrderApi__Is_Active__c = true,
                OrderApi__Item__c=item.Id
        );
        insert badge;

        Test.startTest();

        commMem.PagesApi__Is_Active__c = false;
        commMem.PagesApi__Status__c = 'Deactivated';
        commMem.PagesApi__Deactivated_Date__c = System.today().addDays(-1);
        update commMem;

        Datetime dt = Datetime.now().addMinutes(1);
        FS_DeactivateBadgesForCGM sched = new FS_DeactivateBadgesForCGM();
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, sched );
        sched.execute(null);

        Test.stopTest();

        List<OrderApi__Badge__c> deactivatedBadges = [SELECT Id FROM OrderApi__Badge__c WHERE OrderApi__Is_Active__c = FALSE];

        System.assertNotEquals(0, deactivatedBadges.size());
    }
}