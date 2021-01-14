/**
 * Created by Nikhil on 12-03-2020.
 */
@IsTest
public with sharing class FS_AccountingApprovalTest {
    private static final String APPROVED_STRING = 'Approved';
    private static final String REQ_APPROVAL_STRING = 'Request Approval';
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        ROEApi.PackageScripts.install();
        CPBase.PackageScripts.install();
        LTE.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule accountJoinDateUpdate = new Framework.RoutingRule();
        accountJoinDateUpdate.apexClass = FS_AccountingApprovalRule.class.getName();
        accountJoinDateUpdate.namespace = '';
        accountJoinDateUpdate.isEnabled = true;
        accountJoinDateUpdate.sObjectName = 'OrderApi__Item__c';
        accountJoinDateUpdate.executionOrder = 0;
        rules.add(accountJoinDateUpdate);
        Framework.Config.push(rules);
    }
    @IsTest
    private static void nonEventItemTest() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('NonEvent Item Class');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        itemClass.OrderApi__Is_Active__c = false;
        insert itemClass;
        OrderApi__Item__c item = FS_TestUtils.createItem('Non Event Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Accounting_Approval__c = 'None';
        item.OrderApi__Is_Event__c = false;
        item.OrderApi__Is_Active__c = false;
        insert item;
        item.FS_Accounting_Approval__c = APPROVED_STRING;
        item.OrderApi__Is_Active__c = true;
        update item;
    }
    @IsTest
    private static void eventItemTest() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        EventApi__Event_Category__c eventCategory = new EventApi__Event_Category__c(
                Name='Test Event Category',
                EventApi__Business_Group__c =busGroup.Id);
        insert eventCategory;
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Event Item Class');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(Name = 'Test GL Account',
					OrderApi__Business_Group__c = busGroup.id);
        insert glAcc;
        OrderApi__GL_Account__c glAcc2 = new OrderApi__GL_Account__c(Name = 'GL Account',
					OrderApi__Business_Group__c = busGroup.id);
        insert glAcc2;
        EventApi__Event__c event = new EventApi__Event__c(
                EventApi__Event_Category__c=eventCategory.Id,
                EventApi__Display_Name__c='Test Event',
                EventApi__Business_Group__c=busGroup.Id,
                FS_Accounting_Approval__c=REQ_APPROVAL_STRING,
                EventApi__Status__c ='Planned',
                EventApi__Event_Key__c='VX4FFH5',
                EventApi__Start_Time__c='08:00AM',
                EventApi__End_Time__c='09:00PM');
        insert event;
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
            EventApi__Event__c = event.Id,
            Name='Test TicketType',
            EventApi__Is_Active__c=true,
            EventApi__Income_Account__c=glAcc.Id,
        	FS_Product_Code__c='1234');
        insert ticketType;
        EventApi__Schedule_Item__c scheduleItem = new EventApi__Schedule_Item__c(
        	Name='Test schedule Item',
            EventApi__Event__c=event.Id,
            EventApi__Is_Active__c=true,
            EventApi__Income_Account__c=glAcc.Id,
        	EventApi__Session_Start_Time__c='08:00AM',
        	EventApi__Session_End_Time__c='10:00PM');
        insert scheduleItem;
        EventApi__Sponsor_Package__c sponsorPackage = new EventApi__Sponsor_Package__c(
        	Name='Test sponsor Package',
        	EventApi__Event__c=event.Id,
        	EventApi__Is_Active__c=true,
        	EventApi__Income_Account__c=glAcc.Id,
        	EventApi__Price__c=100);
        insert sponsorPackage;
        Set<Id> itemIdSet = new Set<Id>();
        OrderApi__Item__c item = FS_TestUtils.createItem('Event Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Accounting_Approval__c = APPROVED_STRING;
        item.OrderApi__Is_Event__c = true;
        item.OrderApi__Is_Active__c = true;
        item.EventApi__Event__c = event.Id;
        item.EventApi__Ticket_Type__c = ticketType.Id;
        item.EventApi__Schedule_Item__c = scheduleItem.Id;
        item.EventApi__Sponsor_Package__c = sponsorPackage.Id;
        item.OrderApi__Income_Account__c = glAcc.Id;
        item.OrderApi__Refund_Account__c = glAcc.Id;
        item.OrderApi__AR_Account__c = glAcc.Id;
        item.OrderApi__Discount_Account__c = glAcc.Id;
        item.OrderApi__Adjustment_Account__c = glAcc.Id;
        insert item;
        itemIdSet.add(item.Id);

        Test.startTest();
        FS_AsyncAccountingApprovalForEventItems sc = new FS_AsyncAccountingApprovalForEventItems(itemIdSet);
        String jobId = System.schedule('FS Event Item Update Job', CRON_EXP, sc);
        Test.stopTest();

//        List<OrderApi__Item__c> items = [
//                SELECT Id,OrderApi__Is_Active__c,OrderApi__Is_Event__c,FS_Accounting_Approval__c
//                FROM OrderApi__Item__c WHERE Id=:item.Id];
//
//        item.OrderApi__Income_Account__c = glAcc2.Id;
//        update item;
//
//        System.assertEquals(true, items[0].OrderApi__Is_Active__c);
//        System.assertEquals(APPROVED_STRING, items[0].FS_Accounting_Approval__c);
    }
}