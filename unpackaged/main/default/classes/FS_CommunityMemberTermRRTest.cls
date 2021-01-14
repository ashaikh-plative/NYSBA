/**
 * Created by Jason Cookman on 3/30/20.
 */

@IsTest
public without sharing class FS_CommunityMemberTermRRTest {

    @TestSetup
    public static void setUpForTest() {
        Framework.Installer.install();
        OrderApi.PackageScripts.install();
//        PagesApi.PackageScripts.install();
//        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_TermRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Renewal__c';
        routingRule.executionOrder = 20;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }

    @IsTest
    public static void getCommGroupTermQuery_ExpectString() {
        System.assert(!String.isBlank(FS_CommunityMemberTermRoutingRule.getCommGroupTermQuery()));
    }
    
    @IsTest
    public static void testUpdatingNewCommunityTerm_ExpectMemberActivatedFromTerm() {

        Account acc = FS_TestUtils.createAccount('Test Account wee woo wee woo');
        Contact con = FS_TestUtils.createContact('Test', 'Chris');
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test BG');
        insert busGroup;
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);
        PagesApi__Community_Group__c commGroup = FS_TestUtils.createCommunityGroup(site);
        OrderApi__Item__c subItem = FS_TestUtils.createSubItem(busGroup, commGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = FS_TestUtils.createSubscriptionPlanItemLink(subscriptionPlan, subItem);
        PagesApi__Community_Group_Member__c commMem = FS_TestUtils.createCommGroupMember(commGroup, con, null);
        FS_Community_Group_Member_Term__c commTerm = createTermForTesting(commMem);



        //Create sales order for user to checkout
//        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (
//////                OrderApi__Account__c = acc.Id,
//////                OrderApi__Contact__c = con.Id,
////                OrderApi__Status__c = 'Open',
////                OrderApi__Is_Posted__c  = false,
////                OrderApi__Entity__c = 'Contact',
////                OrderApi__Posting_Entity__c = 'Receipt',
////                OrderApi__Business_Group__c = busGroup.Id);
////        insert salesOrder;
////
////        OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
////                OrderApi__Item_Class__c = subItem.OrderApi__Item_Class__c,
////                OrderApi__Item__c = subItem.Id,
////                OrderApi__Sales_Order__c = salesOrder.Id,
////                OrderApi__Sale_Price__c = 0,
////                OrderApi__Contact__c = con.Id,
////                OrderApi__Account__c = acc.Id
////        );
////
////        insert orderLine;

        commMem.PagesApi__Is_Active__c = false;
        commMem.PagesApi__Deactivated_Date__c = System.today();
        update commMem;

        Test.startTest();

        commTerm.FS_Term_End_Date__c = System.today().toStartOfMonth().addMonths(15);
        commTerm.FS_Term_Grace_Period_End_Date__c = System.today().toStartOfMonth().addMonths(15);
        update commTerm;

        Test.stopTest();

        List<PagesApi__Community_Group_Member__c> membersList = [
                SELECT Id,PagesApi__Contact__c,PagesApi__Account__c,PagesApi__Is_Active__c
                FROM PagesApi__Community_Group_Member__c
        ];

        List<FS_Community_Group_Member_Term__c> termsList = [
                SELECT Id,FS_Community_Group_Member__c,FS_Deactivated_Manually__c
                FROM FS_Community_Group_Member_Term__c
        ];


//        System.assert(membersList.size() == 1, 'Actual size: ' + membersList.size());
//        System.assertEquals(membersList[0].PagesApi__Contact__c, con.Id, 'Group Member is for a different contact. ');
//        System.assert(membersList[0].PagesApi__Is_Active__c, 'Community Group Member not activated===========' + membersList);
//                'Expected Id: ' + membersList[0].PagesApi__Contact__c + ' Actual Id: ' + con.Id);
//        System.assertEquals(membersList[0].PagesApi__Account__c, acc.Id, 'Group member is for a different account');

//        System.assert(!termsList[0].FS_Deactivated_Manually__c, 'term deactivated manually');
    }

    @IsTest
    public static void testUpdatingNewCommunityTerm_ExpectMemberDeactivatedFromTerm() {

        Account acc = FS_TestUtils.createAccount('Test Account wee woo wee woo');
        Contact con = FS_TestUtils.createContact('Test', 'Chris');
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test BG');
        insert busGroup;
        OrderApi__Payment_Terms__c paymentTerms = FS_TestUtils.createPaymentTerms();
        OrderApi__Subscription_Plan__c subscriptionPlan = FS_TestUtils.createSubscriptionPlan(paymentTerms, busGroup);
        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);
        PagesApi__Community_Group__c commGroup = FS_TestUtils.createCommunityGroup(site);
        OrderApi__Item__c subItem = FS_TestUtils.createSubItem(busGroup, commGroup);
        OrderApi__Item_Subscription_Plan__c subPlanLink = FS_TestUtils.createSubscriptionPlanItemLink(subscriptionPlan, subItem);
        PagesApi__Community_Group_Member__c commMem = FS_TestUtils.createCommGroupMember(commGroup, con, null);
        FS_Community_Group_Member_Term__c commTerm = createTermForTesting(commMem);

        commMem.PagesApi__Is_Active__c = true;
        commMem.PagesApi__Activated_Date__c = System.today();
        update commMem;

        Test.startTest();

        commTerm.FS_Term_End_Date__c = System.today().addDays(-1);
        commTerm.FS_Term_Grace_Period_End_Date__c = System.today().addDays(-1);
        update commTerm;

        Test.stopTest();

        List<PagesApi__Community_Group_Member__c> membersList = [
                SELECT Id,PagesApi__Contact__c,PagesApi__Account__c,PagesApi__Is_Active__c
                FROM PagesApi__Community_Group_Member__c
        ];

        List<FS_Community_Group_Member_Term__c> termsList = [
                SELECT Id,FS_Community_Group_Member__c,FS_Deactivated_Manually__c
                FROM FS_Community_Group_Member_Term__c
        ];


        System.assert(membersList.size() == 1, 'Actual size: ' + membersList.size());
        System.assertEquals(membersList[0].PagesApi__Contact__c, con.Id, 'Group Member is for a different contact. ');
        System.assert(!membersList[0].PagesApi__Is_Active__c, 'Community Group Member not deactivated=====' + membersList);
//                'Expected Id: ' + membersList[0].PagesApi__Contact__c + ' Actual Id: ' + con.Id);
//        System.assertEquals(membersList[0].PagesApi__Account__c, acc.Id, 'Group member is for a different account');

        System.assert(termsList[0].FS_Deactivated_Manually__c, 'Term not deactivated');
    }

    private static FS_Community_Group_Member_Term__c createTermForTesting(PagesApi__Community_Group_Member__c commGroupMem) {
        FS_Community_Group_Member_Term__c term = new FS_Community_Group_Member_Term__c(
                FS_Community_Group_Member__c = commGroupMem.Id,
                FS_Term_Start_Date__c = System.today().toStartOfMonth(),
                FS_Term_End_Date__c = System.today().toStartOfMonth().addDays(-1),
                FS_Term_Grace_Period_End_Date__c = System.today().toStartOfMonth().addDays(-1).addMonths(3),
                FS_Term_Role__c = '100 - Member'
        );

        insert term;
        return term;
    }

}