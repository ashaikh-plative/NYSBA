/**
 * Created by Nikhil on 2/26/2020.
 * Created by Seshu on 2/26/2020.
 * Created by Jason Cookman on 2/27/20.
 */
@IsTest
    public without sharing class FS_ProformaBatchJobTest {
    private static final String SECTION_TYPE_STRING = 'Section';
    private static final String SECTION_COMMITTEE_STRING = 'Section Committee';
    private static final String ATTORNEY_STRING = 'Attorney';
    private static final String ONEYEAR_SUBSCRIPTION_PLAN = '1 Year Calendar';
    private static final String ONEYEAR_STUDENT_SUBSCRIPTION_PLAN = '1 Year Student Calendar';
    private static final String MONTHLY_SUBSCRIPTION_PLAN = '1 Year Calendar - Monthly Auto Renew';
    private static final String MEMBER_GROUP = 'Member Group';
    private static final String WORKING_GROUP = 'Working Group';
    private static final String SECTION_DUES_STRING = 'Section Dues';
    private static final String GEN_CONTRIBUTION_STRING = 'General Contribution';
    private static final String NYSBA_Ind_SubItemClass_STRING = 'NYSBA Individual Subscription';
    private static final String LAW_STUDENT = 'Law Student';
    private static final String SECTION_RENEWAL_DUES_STRING = 'Section Renewal Dues';
    private static OrderApi__Business_Group__c busGroup = null;
    private static PagesApi__Community_Group__c oCommunityGroup = null;
    private static PagesApi__Community_Group__c oCommunityGroupSecCommittee = null;
    private static OrderApi__Subscription_Plan__c subPlan = null;
    private static OrderApi__Item__c  itemAttorney = null;
    private static OrderApi__Item_Class__c itemClass= null;
    private static OrderApi__Item__c  sectionItem = null;
    private static OrderApi__Item__c  generalContributionItem = null;
    private static OrderApi__Item_Class__c sectionItemClass= null;
    private static OrderApi__Item_Class__c itemClassStudent = null;
    private static OrderApi__Item__c  studentItem = null;


    @TestSetup
    private static void install() {

        /* Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();*/

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(LastName = 'Test', FirstName = 'Nikhil');
        con.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        insert con;

    }

    private static void setupProformaBatchJobEnv(Id sectionRenewalDuesId, Id lawStudentId, Id generalContributionId) {
        FS_ProformaBatchJob.BATCH_SIZE = 50;
        FS_ProformaBatchJob.SECTION_RENEWAL_DUES_ID = sectionRenewalDuesId;
        FS_ProformaBatchJob.LAW_STUDENT_IDS = lawStudentId;
        FS_ProformaBatchJob.GENERAL_CONTRIBUTION_ID = generalContributionId;
    }

    @IsTest
    private static void renewalWithSameSections(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id,LastName,Email FROM Contact WHERE LastName = 'Test' LIMIT 1];

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'TestBusGroup');
        insert busGroup;

        OrderApi__Subscription_Plan__c subPlan = FS_TestUtils.createSubsPlan(ONEYEAR_SUBSCRIPTION_PLAN);
        insert subPlan;

        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = 'Test Item Class',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert itemClass;

        OrderApi__Item__c  itemAttorney = new OrderApi__Item__c(Name=ATTORNEY_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 275);
        insert itemAttorney;

        OrderApi__Subscription__c membership = new OrderApi__Subscription__c(OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c='Active');
        insert membership;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=membership.Id,OrderApi__Contact__c=con.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        PagesApi__Community_Group__c oCommunityGroup = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING,PagesApi__Is_Published__c = true);
        insert oCommunityGroup;

        PagesApi__Community_Group__c oCommunityGroupSecCommittee = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_COMMITTEE_STRING,PagesApi__Is_Published__c = true,FS_Parent_Section__c=oCommunityGroup.Id);
        insert oCommunityGroupSecCommittee;


        PagesApi__Community_Group_Member__c cGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember;

        PagesApi__Community_Group_Member__c cGroupMemberSecCommittee = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroupSecCommittee.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMemberSecCommittee;

        OrderApi__Item_Class__c sectionItemClass= new OrderApi__Item_Class__c(Name = SECTION_RENEWAL_DUES_STRING,
                OrderApi__Business_Group__c = busGroup.Id,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert sectionItemClass;

        OrderApi__Item__c  sectionItem = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert sectionItem;


        OrderApi__Item_Class__c  generalContributionItemClass = new OrderApi__Item_Class__c(Name='Donations',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Active__c = true);
        insert generalContributionItemClass;

        OrderApi__Item__c  generalContributionItem = new OrderApi__Item__c(Name=GEN_CONTRIBUTION_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = generalContributionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert generalContributionItem;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Processed_By_Batch_Job__c=false);
        insert salesOrder;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;
        System.debug('==**priceRule'+priceRule);

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Account__c = acc.Id);
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        OrderApi__Subscription_Plan__c studentPlan = FS_TestUtils.createSubsPlan(ONEYEAR_STUDENT_SUBSCRIPTION_PLAN);
        insert studentPlan;

        OrderApi__Item__c studentItem = new OrderApi__Item__c(
                Name = LAW_STUDENT,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false,
                OrderApi__Item_Class__c = itemClass.Id);
        insert studentItem;

        OrderApi__Item_Subscription_Plan__c studentLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Item__c = studentItem.Id,
                OrderApi__Subscription_Plan__c = studentPlan.Id,
                OrderApi__Is_Default__c = true);

        insert studentLink;

        studentItem.OrderApi__Is_Active__c = true;
        update studentItem;


        setupProformaBatchJobEnv(sectionItemClass.Id, studentItem.Id, generalContributionItem.Id);
        FS_ProformaBatchJob.initializeCGRenewalMap();

        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> salesOrders = [SELECT Id,FS_Processed_By_Batch_Job__c,OrderApi__Posting_Status__c,
        (SELECT Id,FS_Additional_Data__c, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];
        List<OrderApi__Sales_Order_Line__c> sol = [SELECT Id FROM OrderApi__Sales_Order_Line__c];
        System.assertEquals(salesOrders[0].OrderApi__Sales_Order_Lines__r.size(), 2);
        System.assertEquals(salesOrders[0].FS_Processed_By_Batch_Job__c, true);

        System.debug('Additional Data Fields');
        System.debug(salesOrders[0].OrderApi__Sales_Order_Lines__r[0].OrderApi__Item__r.Name);
        System.debug(salesOrders[0].OrderApi__Sales_Order_Lines__r[0].FS_Additional_Data__c);
        System.debug(salesOrders[0].OrderApi__Sales_Order_Lines__r[1].OrderApi__Item__r.Name);
        System.debug(salesOrders[0].OrderApi__Sales_Order_Lines__r[1].FS_Additional_Data__c);

        Boolean hasGenItem = false;
        Boolean hasMemItem = false;
        Boolean hasSectionWithSubSection = false;

        for(OrderApi__Sales_Order_Line__c currSOL : salesOrders[0].OrderApi__Sales_Order_Lines__r) {
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                hasGenItem = true;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                hasMemItem = true;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id
                    && !String.isBlank(currSOL.FS_Additional_Data__c)
                    && currSOL.FS_Additional_Data__c != '{}') {
                hasSectionWithSubSection = true;
            }
        }

      //  System.assert(hasGenItem, 'No general contribution item found on sales order');
      //  System.assert(hasMemItem, 'No membership item found on sales order');
      //  System.assert(hasSectionWithSubSection, 'No section item or subsection found on sales order');

     //   System.assertEquals(salesOrders[0].OrderApi__Posting_Status__c, 'Pending');
     //   System.assert(sectionItem.FS_Linked_Community_Group__c != null);
    }

    private static void setupEnv() {

        busGroup = new OrderApi__Business_Group__c(Name = 'TestBusGroup');
        insert busGroup;

        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);

        OrderApi__Subscription_Plan__c studentPlan = FS_TestUtils.createSubsPlan(ONEYEAR_STUDENT_SUBSCRIPTION_PLAN);
        studentPlan.OrderApi__Type__c = 'Termed';
        studentPlan.OrderApi__Initial_Term_Months__c = 12;
        studentPlan.OrderApi__Renewal_Term_Months__c = 12;
        studentPlan.OrderApi__Is_Active__c = true;
        studentPlan.OrderApi__Grace_Period__c = 0;
        studentPlan.OrderApi__Business_Group__c = busGroup.Id;
        insert studentPlan;
        System.debug('==**student Plan'+studentPlan);

        itemClassStudent = new OrderApi__Item_Class__c(Name = NYSBA_Ind_SubItemClass_STRING,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert itemClassStudent;

        studentItem = new OrderApi__Item__c(Name=LAW_STUDENT,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClassStudent.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Price__c = 0);
        insert studentItem;

        OrderApi__Item_Subscription_Plan__c studentLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Item__c = studentItem.Id,
                OrderApi__Subscription_Plan__c = studentPlan.Id,
                OrderApi__Is_Default__c = true);
        insert studentLink;

        sectionItemClass= new OrderApi__Item_Class__c(Name = SECTION_RENEWAL_DUES_STRING,
                OrderApi__Business_Group__c = busGroup.Id,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert sectionItemClass;

        oCommunityGroup = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING,PagesApi__Is_Published__c = true,PagesApi__Site__c = site.Id);
        insert oCommunityGroup;

        oCommunityGroupSecCommittee = new PagesApi__Community_Group__c(Name='Test Group2',
                PagesApi__Type__c = SECTION_COMMITTEE_STRING,PagesApi__Is_Published__c = true,FS_Parent_Section__c=oCommunityGroup.Id,PagesApi__Site__c = site.Id);
        insert oCommunityGroupSecCommittee;

        sectionItem = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert sectionItem;

        OrderApi__Item_Class__c  generalContributionItemClass = new OrderApi__Item_Class__c(Name='Donations',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Active__c = true);
        insert generalContributionItemClass;

        generalContributionItem = new OrderApi__Item__c(Name=GEN_CONTRIBUTION_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = generalContributionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert generalContributionItem;

        subPlan = FS_TestUtils.createSubsPlan(ONEYEAR_SUBSCRIPTION_PLAN);
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Grace_Period__c = 0;
        subPlan.OrderApi__Business_Group__c = busGroup.Id;
        insert subPlan;

        itemClass= new OrderApi__Item_Class__c(Name = 'Test Item Class',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert itemClass;

        itemAttorney = new OrderApi__Item__c(Name=ATTORNEY_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = true,//OrderApi__Is_Active__c = true,
                 OrderApi__Price__c = 275);
        insert itemAttorney;

        setupProformaBatchJobEnv(sectionItemClass.Id, studentItem.Id, generalContributionItem.Id);
        FS_ProformaBatchJob.initializeCGRenewalMap();
    }

    @IsTest
    private static void renewalWithSameSections1(){
        setupEnv();

        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id,LastName FROM Contact WHERE LastName = 'Test' LIMIT 1];
        con.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        update con;

        OrderApi__Subscription__c membership = new OrderApi__Subscription__c(OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c='Active');
        insert membership;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=membership.Id,OrderApi__Contact__c=con.Id,
                OrderApi__Term_Start_Date__c = System.today()- 150,OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        PagesApi__Community_Group_Member__c cGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember;

        PagesApi__Community_Group_Member__c cGroupMemberSecCommittee = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroupSecCommittee.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMemberSecCommittee;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Processed_By_Batch_Job__c=false);
        insert salesOrder;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Account__c = acc.Id);
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> salesOrders = [SELECT Id,FS_Processed_By_Batch_Job__c,OrderApi__Posting_Status__c,
        (SELECT Id,FS_Additional_Data__c, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];
        List<OrderApi__Sales_Order_Line__c> sol = [SELECT Id FROM OrderApi__Sales_Order_Line__c];
        System.assertEquals(salesOrders[0].OrderApi__Sales_Order_Lines__r.size(), 2);
        System.assertEquals(salesOrders[0].FS_Processed_By_Batch_Job__c, true);

        Boolean hasGenItem = false;
        Boolean hasMemItem = false;
        Boolean hasSectionWithSubSection = false;

        for(OrderApi__Sales_Order_Line__c currSOL : salesOrders[0].OrderApi__Sales_Order_Lines__r) {
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                hasGenItem = true;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                hasMemItem = true;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id
                    && !String.isBlank(currSOL.FS_Additional_Data__c)
                    && currSOL.FS_Additional_Data__c != '{}') {
                hasSectionWithSubSection = true;
            }
        }

     //   System.assert(hasGenItem, 'No general contribution item found on sales order');
     //   System.assert(hasMemItem, 'No membership item found on sales order');
     //   System.assert(hasSectionWithSubSection, 'No section item or subsection found on sales order');

     //   System.assertEquals(salesOrders[0].OrderApi__Posting_Status__c, 'Pending');
     //   System.assert(sectionItem.FS_Linked_Community_Group__c != null);
    }

    /*************** 2nd method Renewal with Different Sections ************************/

    @IsTest
    private static void renewalWithDifferentSections(){
        setupEnv();
        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id,LastName FROM Contact WHERE LastName = 'Test' LIMIT 1];
        con.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        update con;

        OrderApi__Subscription__c membership = new OrderApi__Subscription__c(OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c='Active');
        insert membership;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=membership.Id,OrderApi__Contact__c=con.Id,
                OrderApi__Term_Start_Date__c = System.today()- 150, OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        PagesApi__Community_Group__c oDeactivatedCommunityGroup = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING);
        insert oDeactivatedCommunityGroup;

        PagesApi__Community_Group_Member__c deactivatedcGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oDeactivatedCommunityGroup.Id,
                PagesApi__Is_Active__c=false,FS_Term_Start_Date__c = System.today()-250,FS_Term_End_Date__c=System.today()-1);
        insert deactivatedcGroupMember;

        FS_Community_Group_Member_Term__c inactiveCGMTerm = new FS_Community_Group_Member_Term__c(
                FS_Community_Group_Member__c=deactivatedcGroupMember.Id,
                FS_Term_Start_Date__c=System.today()-250,FS_Term_End_Date__c=system.today()-1,FS_Deactivated_Manually__c=true);
        insert inactiveCGMTerm;

        OrderApi__Item__c  deactvtdSectionItem = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oDeactivatedCommunityGroup.Id);
        insert deactvtdSectionItem;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Processed_By_Batch_Job__c=false);
        insert salesOrder;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Account__c = acc.Id);
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> salesOrders = [SELECT Id,FS_Processed_By_Batch_Job__c,OrderApi__Posting_Status__c,
        (SELECT Id,OrderApi__Item__c FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];

        Boolean hasGenItem = false;
        Boolean hasMemItem = false;
        Boolean hasSectionWithSubSection = false;

        for(OrderApi__Sales_Order_Line__c currSOL : salesOrders[0].OrderApi__Sales_Order_Lines__r) {
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                hasGenItem = true;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                hasMemItem = true;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id
                    && !String.isBlank(currSOL.FS_Additional_Data__c)
                    && currSOL.FS_Additional_Data__c != '{}') {
                hasSectionWithSubSection = true;
            }
        }

        System.assertEquals(salesOrders[0].OrderApi__Posting_Status__c, 'Posted');
        System.assert(sectionItem.FS_Linked_Community_Group__c != null);

        List<OrderApi__Sales_Order_Line__c> sol = [SELECT Id FROM OrderApi__Sales_Order_Line__c];
       // System.assertEquals(salesOrders[0].OrderApi__Sales_Order_Lines__r.size(), 1);
        System.assertEquals(salesOrders[0].FS_Processed_By_Batch_Job__c, true);
       // System.assertEquals(salesOrders[0].OrderApi__Posting_Status__c, 'Pending');
        System.assert(sectionItem.FS_Linked_Community_Group__c != null);

    }

    /*************** 3rd method for student renewal with Free sections *****************/

    @IsTest
    private static void studentRenewalWithFreeSections(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id,LastName FROM Contact WHERE LastName = 'Test' LIMIT 1];
        con.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        update con;

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'TestBusGroup');
        insert busGroup;

        OrderApi__Subscription_Plan__c subPlan = FS_TestUtils.createSubsPlan(ONEYEAR_SUBSCRIPTION_PLAN);
        insert subPlan;

        OrderApi__Item_Class__c itemClassStudent = new OrderApi__Item_Class__c(Name = NYSBA_Ind_SubItemClass_STRING,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert itemClassStudent;

        OrderApi__Item__c  studentItem = new OrderApi__Item__c(Name=LAW_STUDENT,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClassStudent.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 0);
        insert studentItem;

        OrderApi__Subscription__c membership = new OrderApi__Subscription__c(OrderApi__Item__c = studentItem.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c='Active');
        insert membership;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=membership.Id,OrderApi__Contact__c=con.Id,
                OrderApi__Term_Start_Date__c = System.today()- 150, OrderApi__Is_Active__c=true, OrderApi__Item__c=studentItem.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        PagesApi__Community_Group__c oCommunityGroup = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING,PagesApi__Is_Published__c = true);
        insert oCommunityGroup;

        PagesApi__Community_Group_Member__c cGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true);
        insert cGroupMember;

        FS_Community_Group_Member_Term__c cgmTerm = new FS_Community_Group_Member_Term__c(
                FS_Term__c = term.Id,FS_Term_Start_Date__c=System.today()-180,FS_Term_End_Date__c=System.today()+180,
                FS_Community_Group_Member__c=cGroupMember.Id);
        insert cgmTerm;

        OrderApi__Item_Class__c sectionItemClass= new OrderApi__Item_Class__c(Name = SECTION_RENEWAL_DUES_STRING,
                OrderApi__Business_Group__c = busGroup.Id,OrderApi__Is_Active__c = true);
        insert sectionItemClass;

        OrderApi__Item__c  sectionItem = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Is_Active__c = true,OrderApi__Price__c=20,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert sectionItem;

        OrderApi__Item_Class__c  generalContributionItemClass = new OrderApi__Item_Class__c(Name='Donations',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Active__c = true);
        insert generalContributionItemClass;

        OrderApi__Item__c  generalContributionItem = new OrderApi__Item__c(Name=GEN_CONTRIBUTION_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = generalContributionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert generalContributionItem;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Processed_By_Batch_Job__c=false);
        insert salesOrder;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClassStudent.Id,
                OrderApi__Item__c = studentItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = studentItem.OrderApi__Price__c,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Is_Renewal__c=true);
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;


        OrderApi__Subscription_Plan__c studentPlan = FS_TestUtils.createSubsPlan(ONEYEAR_STUDENT_SUBSCRIPTION_PLAN);
        insert studentPlan;

        OrderApi__Item__c studentItem1 = new OrderApi__Item__c(Name = LAW_STUDENT, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = true);
        insert studentItem1;
        OrderApi__Item_Subscription_Plan__c studentLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Item__c = studentItem.Id,
                OrderApi__Subscription_Plan__c = studentPlan.Id,
                OrderApi__Is_Default__c = true);
        insert studentLink;

        setupProformaBatchJobEnv(sectionItemClass.Id, studentItem1.Id, generalContributionItem.Id);
        FS_ProformaBatchJob.initializeCGRenewalMap();

        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> salesOrderList = [SELECT Id,FS_Processed_By_Batch_Job__c,OrderApi__Posting_Status__c,
        (SELECT Id FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];

        System.assertEquals(salesOrderList[0].OrderApi__Posting_Status__c, 'Posted');
        System.assertEquals(salesOrderList[0].FS_Processed_By_Batch_Job__c, true);
       // System.assertEquals(salesOrderList[0].OrderApi__Sales_Order_Lines__r.size(), 2);
    }


    /***************** 4th method ******************/
    @IsTest
    private static void studentRenewalWithFreeAndPaidSections(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id,LastName FROM Contact WHERE LastName = 'Test' LIMIT 1];
        con.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        update con;

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'TestBusGroup');
        insert busGroup;

        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);

        OrderApi__Subscription_Plan__c subPlan = FS_TestUtils.createSubsPlan(ONEYEAR_SUBSCRIPTION_PLAN);
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Grace_Period__c = 0;
        subPlan.OrderApi__Business_Group__c = busGroup.Id;
        insert subPlan;

        OrderApi__Item_Class__c itemClassStudent = new OrderApi__Item_Class__c(Name = NYSBA_Ind_SubItemClass_STRING,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert itemClassStudent;

        OrderApi__Item__c  studentItem = new OrderApi__Item__c(Name=LAW_STUDENT,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClassStudent.Id, OrderApi__Is_Subscription__c = true,//OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 0);
        insert studentItem;

        OrderApi__Subscription__c membership = new OrderApi__Subscription__c(OrderApi__Item__c = studentItem.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c='Active');
        insert membership;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=membership.Id,OrderApi__Contact__c=con.Id,
                OrderApi__Term_Start_Date__c = System.today()- 150, OrderApi__Is_Active__c=true, OrderApi__Item__c=studentItem.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        //community group 1
        PagesApi__Community_Group__c oCommunityGroup = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING,PagesApi__Is_Published__c = true,PagesApi__Site__c = site.Id
        );
        insert oCommunityGroup;

        PagesApi__Community_Group__c oCommunityGroupSecCommittee = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_COMMITTEE_STRING,PagesApi__Is_Published__c = true,FS_Parent_Section__c=oCommunityGroup.Id);
        insert oCommunityGroupSecCommittee;

        PagesApi__Community_Group_Member__c cGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true);
        insert cGroupMember;

        //community group 2
        PagesApi__Community_Group__c oCommunityGroup2 = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING,PagesApi__Is_Published__c = true);
        insert oCommunityGroup2;

        PagesApi__Community_Group_Member__c cGroupMember2 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroup2.Id,
                PagesApi__Is_Active__c=true);
        insert cGroupMember2;

        OrderApi__Item_Class__c sectionItemClass= new OrderApi__Item_Class__c(Name = SECTION_RENEWAL_DUES_STRING,
                OrderApi__Business_Group__c = busGroup.Id,OrderApi__Is_Active__c = true);
        insert sectionItemClass;

        //Free section Item: is with oCommunityGroup
        OrderApi__Item__c  sectionItemFree = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Is_Active__c = true,OrderApi__Price__c=0,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert sectionItemFree;

        OrderApi__Item_Class__c  generalContributionItemClass = new OrderApi__Item_Class__c(Name='Donations',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Active__c = true);
        insert generalContributionItemClass;

        OrderApi__Item__c  generalContributionItem = new OrderApi__Item__c(Name=GEN_CONTRIBUTION_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = generalContributionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert generalContributionItem;

        //Paid Section Item : is with oCommunityGroup2
        OrderApi__Item__c  sectionItemPaid = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Is_Active__c = true,OrderApi__Price__c=20,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert sectionItemPaid;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Processed_By_Batch_Job__c=false);
        insert salesOrder;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClassStudent.Id,
                OrderApi__Item__c = studentItem.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = 0,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Is_Renewal__c=true);
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        OrderApi__Subscription_Plan__c studentPlan = FS_TestUtils.createSubsPlan(ONEYEAR_STUDENT_SUBSCRIPTION_PLAN);
        insert studentPlan;

        OrderApi__Item__c studentItem1 = new OrderApi__Item__c(Name = LAW_STUDENT, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = true);
        insert studentItem1;
        OrderApi__Item_Subscription_Plan__c studentLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Item__c = studentItem1.Id,
                OrderApi__Subscription_Plan__c = studentPlan.Id,
                OrderApi__Is_Default__c = true);
        insert studentLink;

        setupProformaBatchJobEnv(sectionItemClass.Id, studentItem1.Id, generalContributionItem.Id);
        FS_ProformaBatchJob.initializeCGRenewalMap();

        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> salesOrders = [SELECT Id,FS_Processed_By_Batch_Job__c,OrderApi__Posting_Status__c,
        (SELECT Id,FS_Additional_Data__c, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];
        List<OrderApi__Sales_Order_Line__c> sol = [SELECT Id FROM OrderApi__Sales_Order_Line__c];
        System.assertEquals(salesOrders[0].OrderApi__Sales_Order_Lines__r.size(), 2);
        System.assertEquals(salesOrders[0].FS_Processed_By_Batch_Job__c, true);

        Boolean hasGenItem = false;
        Boolean hasMemItem = false;
        Boolean hasSectionWithSubSection = false;

        for(OrderApi__Sales_Order_Line__c currSOL : salesOrders[0].OrderApi__Sales_Order_Lines__r) {
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                hasGenItem = true;
            }

            if(currSOL.OrderApi__Item__c == studentItem.Id) {
                hasMemItem = true;
            }

            if(currSOL.OrderApi__Item__c == sectionItemFree.Id
                    && !String.isBlank(currSOL.FS_Additional_Data__c)
                    && currSOL.FS_Additional_Data__c != '{}') {
                hasSectionWithSubSection = true;
            }
        }
    }

    /*****************************FirmBill Scenario*********************************/

    @IsTest
    private static void oneFirmBillingContact2AffiliatedContacts_Expect1SalesOrder() {
        setupEnv();
        //Account
        Account account = FS_TestUtils.createAccount('PrimaryAccount');
        //insert account;
        Account account1 = FS_TestUtils.createAccount('TestAccount');
        //insert account1;
        Account account2 = FS_TestUtils.createAccount('TestAccount');
        //insert account2;
        Account account3 = FS_TestUtils.createAccount('TestAccount');
        insert new List<Account>{account, account1, account2, account3};

        //Contacts
        Contact contact1 = FS_TestUtils.createContact('TestContact1','TestContact1@gmail.com');
        contact1.AccountId = account1.Id;
        contact1.FS_Primary_Affiliation__c = account.Id;
        contact1.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        
        Contact contact2 = FS_TestUtils.createContact('TestContact2','TestContact2@gmail.com');
        contact2.AccountId = account2.Id;
        contact2.FS_Primary_Affiliation__c = account.Id;
        contact2.OrderApi__Work_Email__c = 'TestContact2@gmail.com';
        
        Contact contact3 = FS_TestUtils.createContact('TestContact3','TestContact3@gmail.com');
        contact3.AccountId = account3.Id;
        contact3.FS_Primary_Affiliation__c = account.Id;
        contact3.OrderApi__Work_Email__c = 'TestContact3@gmail.com';
        
        List<Contact> contacts = new List<Contact>{contact1,contact2,contact3};
        insert contacts;

        //Primary affiliations
        FS_Affiliation__c affiliation1 = new FS_Affiliation__c();
        affiliation1.FS_Parent_Account__c = account.Id;
        affiliation1.FS_Child_Contact__c = contact1.Id;
        affiliation1.FS_Primary_Affiliation__c = true;
        affiliation1.FS_Status__c = 'Active';
        affiliation1.FS_Firm_Bill__c = true;
        affiliation1.FS_PrimaryContact__c = true;
        FS_Affiliation__c affiliation2 = new FS_Affiliation__c();
        affiliation2.FS_Parent_Account__c = account.Id;
        affiliation2.FS_Child_Contact__c = contact2.Id;
        affiliation2.FS_Primary_Affiliation__c = true;
        affiliation2.FS_Status__c = 'Active';
        affiliation2.FS_Firm_Bill__c = true;
        FS_Affiliation__c affiliation3 = new FS_Affiliation__c();
        affiliation3.FS_Parent_Account__c = account.Id;
        affiliation3.FS_Child_Contact__c = contact3.Id;
        affiliation3.FS_Primary_Affiliation__c = true;
        affiliation3.FS_Firm_Bill__c = true;
        affiliation3.FS_Status__c = 'Active';
        List<FS_Affiliation__c> affiliations = new List<FS_Affiliation__c>{affiliation1,affiliation2,affiliation3};
        insert affiliations;

        account.OrderApi__Primary_Contact__c = contact1.Id;
        update account;

        PagesApi__Community_Group_Member__c cGroupMember1 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact1.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember1;

        PagesApi__Community_Group_Member__c cGroupMember2 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact2.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember2;

        PagesApi__Community_Group_Member__c cGroupMember3 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact3.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember3;


         //For first contact
        //SalesOrder
        OrderApi__Sales_Order__c salesOrder1 = FS_TestUtils.createSalesOrder(contact1.Id,account1.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder2 = FS_TestUtils.createSalesOrder(contact2.Id,account2.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder3 = FS_TestUtils.createSalesOrder(contact3.Id,account3.Id,'Receipt','Open');
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>{salesOrder1,salesOrder2,salesOrder3};
        insert salesOrders;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;

        //salesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine1 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder1.Id,contact1.Id,account1.Id);
        salesOrderLine1.OrderApi__Contact__c = contact1.Id;
        salesOrderLine1.OrderApi__Account__c = account1.Id;
        salesOrderLine1.OrderApi__Is_Subscription__c = true;
        salesOrderLine1.OrderApi__Price_Rule__c = priceRule.Id;
        OrderApi__Sales_Order_Line__c salesOrderLine2 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder2.Id,contact2.Id,account2.Id);
        salesOrderLine2.OrderApi__Is_Subscription__c = true;
        salesOrderLine2.OrderApi__Contact__c = contact2.Id;
        salesOrderLine2.OrderApi__Account__c = account2.Id;
        salesOrderLine2.OrderApi__Price_Rule__c = priceRule.Id;
        OrderApi__Sales_Order_Line__c salesOrderLine3 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder3.Id,contact3.Id,account3.Id);
        salesOrderLine3.OrderApi__Contact__c = contact3.Id;
        salesOrderLine3.OrderApi__Account__c = account3.Id;
        salesOrderLine3.OrderApi__Is_Subscription__c = true;
        salesOrderLine3.OrderApi__Price_Rule__c = priceRule.Id;
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>{salesOrderLine1,salesOrderLine2,salesOrderLine3};
        insert salesOrderLines;
        salesOrders[0].OrderApi__Status__c = 'Closed';
        salesOrders[0].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[1].OrderApi__Status__c = 'Closed';
        salesOrders[1].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[2].OrderApi__Status__c = 'Closed';
        salesOrders[2].OrderApi__Posting_Status__c = 'Pending';
        update salesOrders;


        //Membership
        OrderApi__Subscription__c subscription1 = new OrderApi__Subscription__c();
        subscription1.OrderApi__Item__c = itemAttorney.Id;
        subscription1.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription1.OrderApi__Account__c = account1.Id;
        subscription1.OrderApi__Contact__c = contact1.Id;
        OrderApi__Subscription__c subscription2 = new OrderApi__Subscription__c();
        subscription2.OrderApi__Item__c = itemAttorney.Id;
        subscription2.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription2.OrderApi__Account__c = account2.Id;
        subscription2.OrderApi__Contact__c = contact2.Id;
        OrderApi__Subscription__c subscription3 = new OrderApi__Subscription__c();
        subscription3.OrderApi__Item__c = itemAttorney.Id;
        subscription3.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription3.OrderApi__Account__c = account3.Id;
        subscription3.OrderApi__Contact__c = contact3.Id;
        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>{subscription1,subscription2,subscription3};
        insert subscriptions;

        OrderApi__Renewal__c term1 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription1.Id,OrderApi__Contact__c=contact1.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term2 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription2.Id,OrderApi__Contact__c=contact2.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term3 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription3.Id,OrderApi__Contact__c=contact3.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        List<OrderApi__Renewal__c> terms = new List<OrderApi__Renewal__c>{term1,term2,term3};
        insert terms;

        List<FS_Affiliation__c> fsAffiliations = [SELECT Id,FS_Status__c FROM FS_Affiliation__c];
        List<FS_Affiliation__c> affiliationsWithFirmBilling = [SELECT Id,
                FS_Child_Contact__r.FS_Primary_Affiliation__r.OrderApi__Primary_Contact__c
        FROM FS_Affiliation__c
        WHERE FS_Firm_Bill__c = TRUE AND FS_Primary_Affiliation__c  = TRUE
        AND FS_Status__c = 'Active' AND
        FS_Parent_Account__c =: account.id];

        test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        test.stopTest();

        List<OrderApi__Sales_Order__c> solsOrders = [SELECT Id FROM OrderApi__Sales_Order__c];
        Id soId = solsOrders[0].id;
        System.assertEquals(1, solsOrders.size());
        List<OrderApi__Sales_Order__c> soList = [SELECT Id,(SELECT Id, OrderApi__Item__r.name, OrderApi__Total__c
        FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id=:soId];
        System.assertEquals(7,soList[0].OrderApi__Sales_Order_Lines__r.size());

        Integer genItemCount = 0;
        Integer memItemCount = 0;
        Integer sectionItemCount = 0;

        for(OrderApi__Sales_Order_Line__c currSOL : soList[0].OrderApi__Sales_Order_Lines__r) {//salesOrders[0].OrderApi__Sales_Order_Lines__r
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                genItemCount++;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                memItemCount++;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id) {
                sectionItemCount++;
            }
        }
        System.assertEquals(1, solsOrders.size());
        System.assertEquals(1, genItemCount);
        System.assertEquals(3, memItemCount);
        System.assertEquals(3, sectionItemCount);
    }

    //fourth scenario
    @IsTest
    private static void primaryContactWithoutSO() {

        setupEnv();
        //Account
        Account account = FS_TestUtils.createAccount('PrimaryAccount');
        //insert account;
        Account account1 = FS_TestUtils.createAccount('TestAccount');
        //insert account1;
        Account account2 = FS_TestUtils.createAccount('TestAccount');
        //insert account2;
        Account account3 = FS_TestUtils.createAccount('TestAccount');
        insert new List<Account>{account, account1, account2, account3};

        //Contacts
        Contact contact1 = FS_TestUtils.createContact('TestContact1','TestContact1@gmail.com');
        contact1.AccountId = account1.Id;
        contact1.FS_Primary_Affiliation__c = account.Id;
        contact1.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        
        Contact contact2 = FS_TestUtils.createContact('TestContact2','TestContact2@gmail.com');
        contact2.AccountId = account2.Id;
        contact2.FS_Primary_Affiliation__c = account.Id;
        contact2.OrderApi__Work_Email__c = 'TestContact2@gmail.com';
        
        Contact contact3 = FS_TestUtils.createContact('TestContact3','TestContact3@gmail.com');
        contact3.AccountId = account3.Id;
        contact3.FS_Primary_Affiliation__c = account.Id;
        contact3.OrderApi__Work_Email__c = 'TestContact3@gmail.com';
        
        List<Contact> contacts = new List<Contact>{contact1,contact2,contact3};
        insert contacts;

        //Primary affiliations
        FS_Affiliation__c affiliation1 = new FS_Affiliation__c();
        affiliation1.FS_Parent_Account__c = account.Id;
        affiliation1.FS_Child_Contact__c = contact1.Id;
        affiliation1.FS_Primary_Affiliation__c = true;
        affiliation1.FS_Status__c = 'Active';
        affiliation1.FS_Firm_Bill__c = true;//seshu
        affiliation1.FS_PrimaryContact__c = true;
        FS_Affiliation__c affiliation2 = new FS_Affiliation__c();
        affiliation2.FS_Parent_Account__c = account.Id;
        affiliation2.FS_Child_Contact__c = contact2.Id;
        affiliation2.FS_Primary_Affiliation__c = true;
        affiliation2.FS_Status__c = 'Active';
        affiliation2.FS_Firm_Bill__c = true;
        FS_Affiliation__c affiliation3 = new FS_Affiliation__c();
        affiliation3.FS_Parent_Account__c = account.Id;
        affiliation3.FS_Child_Contact__c = contact3.Id;
        affiliation3.FS_Primary_Affiliation__c = true;
        affiliation3.FS_Firm_Bill__c = true;
        affiliation3.FS_Status__c = 'Active';
        List<FS_Affiliation__c> affiliations = new List<FS_Affiliation__c>{affiliation1,affiliation2,affiliation3};
        insert affiliations;

        account.OrderApi__Primary_Contact__c = contact1.Id;
        update account;

        PagesApi__Community_Group_Member__c cGroupMember1 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact1.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember1;

        PagesApi__Community_Group_Member__c cGroupMember2 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact2.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember2;

        PagesApi__Community_Group_Member__c cGroupMember3 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact3.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember3;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder2 = FS_TestUtils.createSalesOrder(contact2.Id,account2.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder3 = FS_TestUtils.createSalesOrder(contact3.Id,account3.Id,'Receipt','Open');
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>{salesOrder2,salesOrder3};//salesOrder1,
        insert salesOrders;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = itemAttorney.Id;
        insert priceRule;
        System.debug('==**priceRule'+priceRule.OrderApi__Item__c);
        System.debug('==**priceRule'+priceRule);



        //Membership
        OrderApi__Subscription__c subscription1 = new OrderApi__Subscription__c();
        subscription1.OrderApi__Item__c = itemAttorney.Id;
        subscription1.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription1.OrderApi__Account__c = account1.Id;
        subscription1.OrderApi__Contact__c = contact1.Id;
        OrderApi__Subscription__c subscription2 = new OrderApi__Subscription__c();
        subscription2.OrderApi__Item__c = itemAttorney.Id;
        subscription2.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription2.OrderApi__Account__c = account2.Id;
        subscription2.OrderApi__Contact__c = contact2.Id;
        OrderApi__Subscription__c subscription3 = new OrderApi__Subscription__c();
        subscription3.OrderApi__Item__c = itemAttorney.Id;
        subscription3.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription3.OrderApi__Account__c = account3.Id;
        subscription3.OrderApi__Contact__c = contact3.Id;
        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>{subscription1,subscription2,subscription3};
        insert subscriptions;


        //salesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine2 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder2.Id,contact2.Id,account2.Id);//This util class has an issue Not assigning account or contact
        salesOrderLine2.OrderApi__Account__c = account2.Id;
        salesOrderLine2.OrderApi__Contact__c = contact2.Id;

        salesOrderLine2.OrderApi__Is_Subscription__c = true;
        salesOrderLine2.OrderApi__Price_Rule__c = priceRule.Id;
        salesOrderLine2.OrderApi__Subscription__c = subscription2.Id;
        OrderApi__Sales_Order_Line__c salesOrderLine3 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder3.Id,contact3.Id,account3.Id);
        salesOrderLine3.OrderApi__Is_Subscription__c = true;
        salesOrderLine3.OrderApi__Price_Rule__c = priceRule.Id;
        salesOrderLine3.OrderApi__Subscription__c = subscription3.Id;
        salesOrderLine3.OrderApi__Account__c = account3.Id;
        salesOrderLine3.OrderApi__Contact__c = contact3.Id;
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>{salesOrderLine2,salesOrderLine3};//salesOrderLine1,
        insert salesOrderLines;
        salesOrders[0].OrderApi__Status__c = 'Closed';
        salesOrders[0].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[1].OrderApi__Status__c = 'Closed';
        salesOrders[1].OrderApi__Posting_Status__c = 'Pending';
        update salesOrders;

        OrderApi__Renewal__c term1 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription1.Id,OrderApi__Contact__c=contact1.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term2 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription2.Id,OrderApi__Contact__c=contact2.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term3 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription3.Id,OrderApi__Contact__c=contact3.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        List<OrderApi__Renewal__c> terms = new List<OrderApi__Renewal__c>{term1,term2,term3};
        insert terms;

        List<FS_Affiliation__c> fsAffiliations = [SELECT Id,FS_Status__c FROM FS_Affiliation__c];
        List<FS_Affiliation__c> affiliationsWithFirmBilling = [SELECT Id,
                FS_Child_Contact__r.FS_Primary_Affiliation__r.OrderApi__Primary_Contact__c
        FROM FS_Affiliation__c
        WHERE FS_Firm_Bill__c = TRUE AND FS_Primary_Affiliation__c  = TRUE
        AND FS_Status__c = 'Active' AND
        FS_Parent_Account__c =: account.Id];

        System.debug('==**salesOrdersize before job runs '+[SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =:contact1.Id].size());
        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> solsOrders = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =:contact1.Id];
        System.debug('==**sorders'+solsOrders);
        Id soId = solsOrders[0].Id;
        System.debug('==**soId'+soId);
        System.assertEquals(1, solsOrders.size());
        List<OrderApi__Sales_Order__c> soList = [SELECT Id,(SELECT Id, OrderApi__Item__r.Name, OrderApi__Total__c,
        OrderApi__Price_Rule__c FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id=:soId];
        System.assertEquals(5,soList[0].OrderApi__Sales_Order_Lines__r.size());
        System.debug('==**salesOrderLine'+soList[0].OrderApi__Sales_Order_Lines__r);
        Integer genItemCount = 0;
        Integer memItemCount = 0;
        Integer sectionItemCount = 0;

        for(OrderApi__Sales_Order_Line__c currSOL : soList[0].OrderApi__Sales_Order_Lines__r) {//salesOrders[0].OrderApi__Sales_Order_Lines__r
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                genItemCount++;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                memItemCount++;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id) {
                sectionItemCount++;
            }
        }
        System.assertEquals(1, solsOrders.size());
        System.assertEquals(1, genItemCount);
        System.assertEquals(2, memItemCount);
        System.assertEquals(2, sectionItemCount);
    }

    //fifth scenario
    @IsTest
    private static void primaryContactWithFirmBillUncheck() {

        setupEnv();
        //Account
        Account account = FS_TestUtils.createAccount('PrimaryAccount');
        //insert account;
        Account account1 = FS_TestUtils.createAccount('TestAccount');
        //insert account1;
        Account account2 = FS_TestUtils.createAccount('TestAccount');
        //insert account2;
        Account account3 = FS_TestUtils.createAccount('TestAccount');
        insert new List<Account>{account, account1, account2, account3};

        //Contacts
        Contact contact1 = FS_TestUtils.createContact('TestContact1','TestContact1@gmail.com');
        contact1.AccountId = account1.Id;
        contact1.FS_Primary_Affiliation__c = account.Id;
        contact1.OrderApi__Work_Email__c = 'TestContact1@gmail.com';

        Contact contact2 = FS_TestUtils.createContact('TestContact2','TestContact2@gmail.com');
        contact2.AccountId = account2.Id;
        contact2.FS_Primary_Affiliation__c = account.Id;
        contact2.OrderApi__Work_Email__c = 'TestContact2@gmail.com';
        
        Contact contact3 = FS_TestUtils.createContact('TestContact3','TestContact3@gmail.com');
        contact3.AccountId = account3.Id;
        contact3.FS_Primary_Affiliation__c = account.Id;
        contact3.OrderApi__Work_Email__c = 'TestContact3@gmail.com';
        
        List<Contact> contacts = new List<Contact>{contact1,contact2,contact3};
        insert contacts;

        //Primary affiliations
        FS_Affiliation__c affiliation1 = new FS_Affiliation__c();
        affiliation1.FS_Parent_Account__c = account.Id;
        affiliation1.FS_Child_Contact__c = contact1.Id;
        affiliation1.FS_Primary_Affiliation__c = true;
        affiliation1.FS_Status__c = 'Active';
        affiliation1.FS_Firm_Bill__c = false;//Making firm bill as uncheck
        affiliation1.FS_PrimaryContact__c = true;
        FS_Affiliation__c affiliation2 = new FS_Affiliation__c();
        affiliation2.FS_Parent_Account__c = account.Id;
        affiliation2.FS_Child_Contact__c = contact2.Id;
        affiliation2.FS_Primary_Affiliation__c = true;
        affiliation2.FS_Status__c = 'Active';
        affiliation2.FS_Firm_Bill__c = true;
        FS_Affiliation__c affiliation3 = new FS_Affiliation__c();
        affiliation3.FS_Parent_Account__c = account.Id;
        affiliation3.FS_Child_Contact__c = contact3.Id;
        affiliation3.FS_Primary_Affiliation__c = true;
        affiliation3.FS_Firm_Bill__c = true;
        affiliation3.FS_Status__c = 'Active';
        List<FS_Affiliation__c> affiliations = new List<FS_Affiliation__c>{affiliation1,affiliation2,affiliation3};
        insert affiliations;

        account.OrderApi__Primary_Contact__c = contact1.Id;
        update account;


        PagesApi__Community_Group_Member__c cGroupMember1 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact1.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember1;

        PagesApi__Community_Group_Member__c cGroupMember2 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact2.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember2;

        PagesApi__Community_Group_Member__c cGroupMember3 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact3.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember3;


        //SalesOrder
        OrderApi__Sales_Order__c salesOrder1 = FS_TestUtils.createSalesOrder(contact1.Id,account1.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder2 = FS_TestUtils.createSalesOrder(contact2.Id,account2.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder3 = FS_TestUtils.createSalesOrder(contact3.Id,account3.Id,'Receipt','Open');
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>{salesOrder1,salesOrder2,salesOrder3};
        insert salesOrders;


        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = generalContributionItem.Id;
        insert priceRule;

        //salesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine1 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder1.Id,contact1.Id,account1.Id);
        salesOrderLine1.OrderApi__Is_Subscription__c = true;
        salesOrderLine1.OrderApi__Price_Rule__c = priceRule.Id;
        OrderApi__Sales_Order_Line__c salesOrderLine2 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder2.Id,contact2.Id,account2.Id);
        salesOrderLine2.OrderApi__Is_Subscription__c = true;
        salesOrderLine2.OrderApi__Price_Rule__c = priceRule.Id;
//        salesOrderLine2.OrderApi__Is_Subscription__c = true;
        OrderApi__Sales_Order_Line__c salesOrderLine3 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder3.Id,contact3.Id,account3.Id);
        salesOrderLine3.OrderApi__Is_Subscription__c = true;
        salesOrderLine3.OrderApi__Price_Rule__c = priceRule.Id;
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>{salesOrderLine1,salesOrderLine2,salesOrderLine3};
        insert salesOrderLines;
        salesOrders[0].OrderApi__Status__c = 'Closed';
        salesOrders[0].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[1].OrderApi__Status__c = 'Closed';
        salesOrders[1].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[2].OrderApi__Status__c = 'Closed';
        salesOrders[2].OrderApi__Posting_Status__c = 'Pending';
        update salesOrders;

        //Membership
        OrderApi__Subscription__c subscription1 = new OrderApi__Subscription__c();
        subscription1.OrderApi__Item__c = itemAttorney.Id;
        subscription1.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription1.OrderApi__Account__c = account1.Id;
        subscription1.OrderApi__Contact__c = contact1.Id;
        OrderApi__Subscription__c subscription2 = new OrderApi__Subscription__c();
        subscription2.OrderApi__Item__c = itemAttorney.Id;
        subscription2.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription2.OrderApi__Account__c = account2.Id;
        subscription2.OrderApi__Contact__c = contact2.Id;
        OrderApi__Subscription__c subscription3 = new OrderApi__Subscription__c();
        subscription3.OrderApi__Item__c = itemAttorney.Id;
        subscription3.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription3.OrderApi__Account__c = account3.Id;
        subscription3.OrderApi__Contact__c = contact3.Id;
        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>{subscription1,subscription2,subscription3};
        insert subscriptions;

        OrderApi__Renewal__c term1 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription1.Id,OrderApi__Contact__c=contact1.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term2 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription2.Id,OrderApi__Contact__c=contact2.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term3 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription3.Id,OrderApi__Contact__c=contact3.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        List<OrderApi__Renewal__c> terms = new List<OrderApi__Renewal__c>{term1,term2,term3};
        insert terms;


        setupProformaBatchJobEnv(sectionItemClass.Id, studentItem.Id, generalContributionItem.Id);
        FS_ProformaBatchJob.initializeCGRenewalMap();

        List<FS_Affiliation__c> fsAffiliations = [SELECT Id,FS_Status__c FROM FS_Affiliation__c];
        List<FS_Affiliation__c> affiliationsWithFirmBilling = [SELECT Id,
                FS_Child_Contact__r.FS_Primary_Affiliation__r.OrderApi__Primary_Contact__c
        FROM FS_Affiliation__c
        WHERE FS_Firm_Bill__c = TRUE AND FS_Primary_Affiliation__c  = TRUE
        AND FS_Status__c = 'Active' AND
        FS_Parent_Account__c =: account.Id];

        test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        test.stopTest();

        List<OrderApi__Sales_Order__c> solsOrders = [SELECT Id FROM OrderApi__Sales_Order__c];
        //System.assertEquals(2, solsOrders.size());
        List<OrderApi__Sales_Order__c> soList1 = [SELECT Id,(SELECT Id, OrderApi__Item__r.name, OrderApi__Total__c
        FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id=:solsOrders[0].id];
        //System.assertEquals(3,soList1[0].OrderApi__Sales_Order_Lines__r.size());

        List<OrderApi__Sales_Order__c> soList2 = [SELECT Id,(SELECT Id, OrderApi__Item__r.name, OrderApi__Total__c
        FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id=:solsOrders[1].id];
        //System.assertEquals(5,soList2[0].OrderApi__Sales_Order_Lines__r.size());

        Integer genItemCount = 0;
        Integer memItemCount = 0;
        Integer sectionItemCount = 0;

        for(OrderApi__Sales_Order_Line__c currSOL : soList1[0].OrderApi__Sales_Order_Lines__r) {
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                genItemCount++;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                memItemCount++;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id) {
                sectionItemCount++;
            }
        }
        //System.assertEquals(2, solsOrders.size());
        //System.assertEquals(1, genItemCount);
        //System.assertEquals(1, memItemCount);
        //System.assertEquals(1, sectionItemCount);
    }

    @IsTest
    private static void contactWithDifferentSections() {

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'TestBusGroup');
        insert busGroup;

        PagesApi__Site__c site = FS_TestUtils.createCommunitySite(busGroup);

        //Account
        Account account = FS_TestUtils.createAccount('PrimaryAccount');
        Account account1 = FS_TestUtils.createAccount('TestAccount');
        Account account2 = FS_TestUtils.createAccount('TestAccount');
        Account account3 = FS_TestUtils.createAccount('TestAccount');
        insert new List<Account>{account, account1, account2, account3};

        //Contacts
        Contact contact1 = FS_TestUtils.createContact('TestContact1','TestContact1@gmail.com');
        contact1.AccountId = account1.Id;
        contact1.FS_Primary_Affiliation__c = account.Id;
        contact1.OrderApi__Work_Email__c = 'TestContact1@gmail.com';
        
        Contact contact2 = FS_TestUtils.createContact('TestContact2','TestContact2@gmail.com');
        contact2.AccountId = account2.Id;
        contact2.FS_Primary_Affiliation__c = account.Id;
        contact2.OrderApi__Work_Email__c = 'TestContact2@gmail.com';
        
        Contact contact3 = FS_TestUtils.createContact('TestContact3','TestContact3@gmail.com');
        contact3.AccountId = account3.Id;
        contact3.FS_Primary_Affiliation__c = account.Id;
        contact3.OrderApi__Work_Email__c = 'TestContact3@gmail.com';
        
        List<Contact> contacts = new List<Contact>{contact1,contact2,contact3};
        insert contacts;

        //Primary affiliations
        FS_Affiliation__c affiliation1 = new FS_Affiliation__c();
        affiliation1.FS_Parent_Account__c = account.Id;
        affiliation1.FS_Child_Contact__c = contact1.Id;
        affiliation1.FS_Primary_Affiliation__c = true;
        affiliation1.FS_Status__c = 'Active';
        affiliation1.FS_Firm_Bill__c = true;
        affiliation1.FS_PrimaryContact__c = true;
        FS_Affiliation__c affiliation2 = new FS_Affiliation__c();
        affiliation2.FS_Parent_Account__c = account.Id;
        affiliation2.FS_Child_Contact__c = contact2.Id;
        affiliation2.FS_Primary_Affiliation__c = true;
        affiliation2.FS_Status__c = 'Active';
        affiliation2.FS_Firm_Bill__c = true;
        FS_Affiliation__c affiliation3 = new FS_Affiliation__c();
        affiliation3.FS_Parent_Account__c = account.Id;
        affiliation3.FS_Child_Contact__c = contact3.Id;
        affiliation3.FS_Primary_Affiliation__c = true;
        affiliation3.FS_Firm_Bill__c = true;
        affiliation3.FS_Status__c = 'Active';
        List<FS_Affiliation__c> affiliations = new List<FS_Affiliation__c>{affiliation1,affiliation2,affiliation3};
        insert affiliations;

        account.OrderApi__Primary_Contact__c = contact1.Id;
        update account;

        OrderApi__Subscription_Plan__c subPlan = FS_TestUtils.createSubsPlan(ONEYEAR_SUBSCRIPTION_PLAN);
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Grace_Period__c = 0;
        subPlan.OrderApi__Business_Group__c = busGroup.Id;
        insert subPlan;

        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = 'Test Item Class',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert itemClass;

        OrderApi__Item__c  itemAttorney = new OrderApi__Item__c(Name=ATTORNEY_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Price__c = 275);//OrderApi__Is_Active__c = true,
        insert itemAttorney;

        //first communityGroup
        PagesApi__Community_Group__c oCommunityGroup = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_TYPE_STRING,PagesApi__Is_Published__c = true,PagesApi__Site__c = site.Id);
        insert oCommunityGroup;

        PagesApi__Community_Group__c oCommunityGroupSecCommittee = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = SECTION_COMMITTEE_STRING,PagesApi__Is_Published__c = true,FS_Parent_Section__c=oCommunityGroup.Id);
        insert oCommunityGroupSecCommittee;

        //second communityGroup
        PagesApi__Community_Group__c oCommunityGroup1 = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = MEMBER_GROUP,PagesApi__Is_Published__c = true);
        insert oCommunityGroup1;

        PagesApi__Community_Group__c oCommunityGroupSecCommittee1 = new PagesApi__Community_Group__c(Name='Test Group1',
                PagesApi__Type__c = WORKING_GROUP,PagesApi__Is_Published__c = true,FS_Parent_Section__c=oCommunityGroup1.Id);
        insert oCommunityGroupSecCommittee1;

        PagesApi__Community_Group_Member__c cGroupMember1 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact1.Id,PagesApi__Community_Group__c=oCommunityGroup1.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember1;

        PagesApi__Community_Group_Member__c cGroupMember2 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact2.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember2;

        PagesApi__Community_Group_Member__c cGroupMember3 = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = contact3.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember3;

        OrderApi__Item_Class__c sectionItemClass= new OrderApi__Item_Class__c(Name = SECTION_RENEWAL_DUES_STRING,
                OrderApi__Business_Group__c = busGroup.Id,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert sectionItemClass;

        OrderApi__Item__c  sectionItem = new OrderApi__Item__c(Name='Section Item',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert sectionItem;

        //Item class for different section
        OrderApi__Item_Class__c sectionItemClass1= new OrderApi__Item_Class__c(Name = SECTION_DUES_STRING,
                OrderApi__Business_Group__c = busGroup.Id,OrderApi__Is_Active__c = true,
                FS_Is_Membership__c=true);
        insert sectionItemClass1;

        OrderApi__Item__c  sectionItem1 = new OrderApi__Item__c(Name='Section Item1',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = sectionItemClass1.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup1.Id);
        insert sectionItem1;


        OrderApi__Item_Class__c  generalContributionItemClass = new OrderApi__Item_Class__c(Name='Donations',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Active__c = true);
        insert generalContributionItemClass;

        OrderApi__Item__c  generalContributionItem = new OrderApi__Item__c(Name=GEN_CONTRIBUTION_STRING,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = generalContributionItemClass.Id,
                OrderApi__Is_Active__c = true, OrderApi__Price__c = 30,FS_Linked_Community_Group__c=oCommunityGroup.Id);
        insert generalContributionItem;

        OrderApi__Subscription_Plan__c studentPlan = FS_TestUtils.createSubsPlan(ONEYEAR_STUDENT_SUBSCRIPTION_PLAN);
        insert studentPlan;

        OrderApi__Item__c studentItem = new OrderApi__Item__c(Name = LAW_STUDENT, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = true);
        insert studentItem;
        OrderApi__Item_Subscription_Plan__c studentLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Item__c = studentItem.Id,
                OrderApi__Subscription_Plan__c = studentPlan.Id,
                OrderApi__Is_Default__c = true);
        insert studentLink;


         //For first contact
        //SalesOrder
        OrderApi__Sales_Order__c salesOrder1 = FS_TestUtils.createSalesOrder(contact1.Id,account1.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder2 = FS_TestUtils.createSalesOrder(contact2.Id,account2.Id,'Receipt','Open');
        OrderApi__Sales_Order__c salesOrder3 = FS_TestUtils.createSalesOrder(contact3.Id,account3.Id,'Receipt','Open');
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>{salesOrder1,salesOrder2,salesOrder3};
        insert salesOrders;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = itemAttorney.Id;
        insert priceRule;

        //salesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine1 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder1.Id,contact1.Id,account1.Id);
        salesOrderLine1.OrderApi__Is_Subscription__c = true;
        salesOrderLine1.OrderApi__Price_Rule__c = priceRule.Id;
        OrderApi__Sales_Order_Line__c salesOrderLine2 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder2.Id,contact2.Id,account2.Id);
        salesOrderLine2.OrderApi__Is_Subscription__c = true;
        salesOrderLine2.OrderApi__Price_Rule__c = priceRule.Id;
        OrderApi__Sales_Order_Line__c salesOrderLine3 = FS_TestUtils.createSalesOrderLine(itemAttorney.Id,salesOrder3.Id,contact3.Id,account3.Id);
        salesOrderLine3.OrderApi__Is_Subscription__c = true;
        salesOrderLine3.OrderApi__Price_Rule__c = priceRule.Id;
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>{salesOrderLine1,salesOrderLine2,salesOrderLine3};
        insert salesOrderLines;
        salesOrders[0].OrderApi__Status__c = 'Closed';
        salesOrders[0].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[1].OrderApi__Status__c = 'Closed';
        salesOrders[1].OrderApi__Posting_Status__c = 'Pending';
        salesOrders[2].OrderApi__Status__c = 'Closed';
        salesOrders[2].OrderApi__Posting_Status__c = 'Pending';
        update salesOrders;

        //Membership
        OrderApi__Subscription__c subscription1 = new OrderApi__Subscription__c();
        subscription1.OrderApi__Item__c = itemAttorney.Id;
        subscription1.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription1.OrderApi__Account__c = account1.Id;
        subscription1.OrderApi__Contact__c = contact1.Id;
        OrderApi__Subscription__c subscription2 = new OrderApi__Subscription__c();
        subscription2.OrderApi__Item__c = itemAttorney.Id;
        subscription2.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription2.OrderApi__Account__c = account2.Id;
        subscription2.OrderApi__Contact__c = contact2.Id;
        OrderApi__Subscription__c subscription3 = new OrderApi__Subscription__c();
        subscription3.OrderApi__Item__c = itemAttorney.Id;
        subscription3.OrderApi__Subscription_Plan__c = subPlan.Id;
        subscription3.OrderApi__Account__c = account3.Id;
        subscription3.OrderApi__Contact__c = contact3.Id;
        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>{subscription1,subscription2,subscription3};
        insert subscriptions;

        OrderApi__Renewal__c term1 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription1.Id,OrderApi__Contact__c=contact1.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term2 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription2.Id,OrderApi__Contact__c=contact2.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        OrderApi__Renewal__c term3 = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription3.Id,OrderApi__Contact__c=contact3.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        List<OrderApi__Renewal__c> terms = new List<OrderApi__Renewal__c>{term1,term2,term3};
        insert terms;


        setupProformaBatchJobEnv(sectionItemClass.Id, studentItem.Id, generalContributionItem.Id);
        FS_ProformaBatchJob.initializeCGRenewalMap();
//        FS_ProformaBatchJob.initializeCGRenewalMap();

        List<FS_Affiliation__c> fsAffiliations = [SELECT Id,FS_Status__c FROM FS_Affiliation__c];
        List<FS_Affiliation__c> affiliationsWithFirmBilling = [SELECT Id,
                FS_Child_Contact__r.FS_Primary_Affiliation__r.OrderApi__Primary_Contact__c
        FROM FS_Affiliation__c
        WHERE FS_Firm_Bill__c = TRUE AND FS_Primary_Affiliation__c  = TRUE
        AND FS_Status__c = 'Active' AND
        FS_Parent_Account__c =: account.id];

        test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        test.stopTest();

        List<OrderApi__Sales_Order__c> solsOrders = [SELECT Id FROM OrderApi__Sales_Order__c];
        Id soId = solsOrders[0].id;
        //System.assertEquals(1, solsOrders.size());
        List<OrderApi__Sales_Order__c> soList = [SELECT Id,(SELECT Id, OrderApi__Item__r.name, OrderApi__Total__c
        FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id=:soId];

        Integer genItemCount = 0;
        Integer memItemCount = 0;
        Integer sectionItemCount = 0;

        for(OrderApi__Sales_Order_Line__c currSOL : soList[0].OrderApi__Sales_Order_Lines__r) {
            if(currSOL.OrderApi__Item__c == generalContributionItem.Id) {
                genItemCount++;
            }

            if(currSOL.OrderApi__Item__c == itemAttorney.Id) {
                memItemCount++;
            }

            if(currSOL.OrderApi__Item__c == sectionItem.Id) {
                sectionItemCount++;
            }
        }
       // System.assertEquals(1, solsOrders.size());
       // System.assertEquals(1, genItemCount);
       // System.assertEquals(3, memItemCount);
       // System.assertEquals(2, sectionItemCount);
    }

    @IsTest
    private static void updatedSubscriptionPlan(){

        setupEnv();

        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id,LastName FROM Contact WHERE LastName = 'Test' LIMIT 1];
        con.OrderApi__Work_Email__c = 'TestingContact1@gmail.com';

        OrderApi__Subscription_Plan__c subPlan1 = FS_TestUtils.createSubsPlan(MONTHLY_SUBSCRIPTION_PLAN);
        insert subPlan1;

        OrderApi__Subscription__c membership = new OrderApi__Subscription__c(OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c='Active');
        insert membership;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=membership.Id,OrderApi__Contact__c=con.Id,
                OrderApi__Term_Start_Date__c = System.today()- 150,OrderApi__Is_Active__c=true, OrderApi__Item__c=itemAttorney.Id,
                OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        PagesApi__Community_Group_Member__c cGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroup.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMember;

        PagesApi__Community_Group_Member__c cGroupMemberSecCommittee = new PagesApi__Community_Group_Member__c(
                PagesApi__Contact__c = con.Id,PagesApi__Community_Group__c=oCommunityGroupSecCommittee.Id,
                PagesApi__Is_Active__c=true,FS_Term_Start_Date__c = System.today(), PagesApi__Status__c = 'Active');
        insert cGroupMemberSecCommittee;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c (OrderApi__Account__c = acc.Id,
                OrderApi__Contact__c = con.Id,
                OrderApi__Status__c = 'Open',
                OrderApi__Is_Posted__c  = false,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c = 'Receipt',
                OrderApi__Business_Group__c = busGroup.Id,
                FS_Processed_By_Batch_Job__c=false);
        insert salesOrder;

        OrderApi__Price_Rule__c priceRule = new OrderApi__Price_Rule__c();
        priceRule.OrderApi__Price__c = 100;
        priceRule.OrderApi__Item__c = itemAttorney.Id;
        insert priceRule;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = itemAttorney.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Sale_Price__c = itemAttorney.OrderApi__Price__c,
                OrderApi__Subscription__c = membership.Id,
                OrderApi__Subscription_Plan__c = subPlan1.Id,
                OrderApi__Is_Subscription__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Price_Rule__c = priceRule.Id,
                OrderApi__Account__c = acc.Id);
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        Test.startTest();
        Database.executeBatch(new FS_ProformaBatchJob());
        Test.stopTest();

        List<OrderApi__Sales_Order__c> salesOrders = [SELECT Id,FS_Processed_By_Batch_Job__c,OrderApi__Posting_Status__c,
        (SELECT Id,FS_Additional_Data__c, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];
        List<OrderApi__Sales_Order_Line__c> sol = [SELECT Id FROM OrderApi__Sales_Order_Line__c];
        System.assertEquals(salesOrders[0].OrderApi__Sales_Order_Lines__r.size(), 3);
        System.assertEquals(salesOrders[0].FS_Processed_By_Batch_Job__c, true);

        System.assertEquals(salesOrders[0].OrderApi__Posting_Status__c, 'Pending');
        System.assert(sectionItem.FS_Linked_Community_Group__c != null);
    }
}