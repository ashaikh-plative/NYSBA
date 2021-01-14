/**
 * Created by Nikhil on 06-04-2020.
 */
@IsTest
public with sharing class FS_EventUpdateTest {
    private static final String ACTIVE_STRING = 'Active';
    private static final String CLOSED_STRING = 'Closed';
    private static final String APPROVED_STRING = 'Approved';
    private static final String REQ_APPROVAL_STRING = 'Request Approval';
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

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule EventItemUpdateRule = new Framework.RoutingRule();
        EventItemUpdateRule.apexClass = FS_EventUpdateRule.class.getName();
        EventItemUpdateRule.namespace = '';
        EventItemUpdateRule.isEnabled = true;
        EventItemUpdateRule.sObjectName = 'EventApi__Event__c';
        EventItemUpdateRule.executionOrder = 0;
        rules.add(EventItemUpdateRule);
        Framework.Config.push(rules);
    }
    @IsTest
    public static void throwErrorIfEventNotApproved(){
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        EventApi__Event_Category__c eventCategory = new EventApi__Event_Category__c(
                Name='Test Event Category',
                EventApi__Business_Group__c =busGroup.Id);
        insert eventCategory;
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('NonEvent Item Class');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        OrderApi__Item__c item = FS_TestUtils.createItem('Event Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Accounting_Approval__c = 'None';
        item.OrderApi__Is_Event__c = true;
        item.OrderApi__Is_Active__c = true;
        insert item;
        EventApi__Event__c event = new EventApi__Event__c(
                EventApi__Event_Category__c=eventCategory.Id,
                EventApi__Display_Name__c='Test Event',
                EventApi__Business_Group__c=busGroup.Id,
                FS_Accounting_Approval__c=REQ_APPROVAL_STRING,
                EventApi__Status__c =CLOSED_STRING,
                EventApi__Event_Key__c='VX4FFH5',
            	EventApi__Start_Time__c='08:00AM',
                EventApi__End_Time__c='09:00PM');
        insert event;

        try{
        event.EventApi__Status__c = ACTIVE_STRING;
        update event;
        //throw new Exception('You cannot make an event active if accounting approval is not set to Approved');
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('You cannot make an event active if accounting approval is not set to Approved') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }

    }
    @IsTest
    public static void throwErrorIfEventApprovedNoPrimaryTT(){
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        EventApi__Event_Category__c eventCategory = new EventApi__Event_Category__c(
                Name='Test Event Category',
                EventApi__Business_Group__c =busGroup.Id);
        insert eventCategory;
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('NonEvent Item Class');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        OrderApi__Item__c item = FS_TestUtils.createItem('Event Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Accounting_Approval__c = 'None';
        item.OrderApi__Is_Event__c = true;
        item.OrderApi__Is_Active__c = true;
        insert item;
        EventApi__Event__c event = new EventApi__Event__c(
                EventApi__Event_Category__c=eventCategory.Id,
                EventApi__Display_Name__c='Test Event',
                EventApi__Business_Group__c=busGroup.Id,
                FS_Accounting_Approval__c='Approved',
                EventApi__Status__c ='Planned',
                EventApi__Event_Key__c='VX4FFH5',
            	EventApi__Start_Time__c='08:00AM',
                EventApi__End_Time__c='09:00PM');
        insert event;
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
                EventApi__Event__c = event.Id,
                Name='Test TicketType',
                EventApi__Is_Active__c=true,
        		FS_Is_Primary__c=false);
        insert ticketType;

        try{
        event.EventApi__Status__c = ACTIVE_STRING;
        update event;
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('You cannot make an event active without Primary ticket type Active ') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
        }
    }
}