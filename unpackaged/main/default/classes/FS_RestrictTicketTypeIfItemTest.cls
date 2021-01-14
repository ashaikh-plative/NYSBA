/**
 * Created by Nikhil on 07-04-2020.
 */

@IsTest
private class FS_RestrictTicketTypeIfItemTest {
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
        Framework.RoutingRule accountJoinDateUpdate = new Framework.RoutingRule();
        accountJoinDateUpdate.apexClass = FS_RestrictTicketTypeIfItemIsNotActive.class.getName();
        accountJoinDateUpdate.namespace = '';
        accountJoinDateUpdate.isEnabled = true;
        accountJoinDateUpdate.sObjectName = 'EventApi__Ticket_Type__c';
        accountJoinDateUpdate.executionOrder = 0;
        rules.add(accountJoinDateUpdate);
        Framework.Config.push(rules);
    }
    @IsTest
    private static void restrictTicketTypeIfItemIsNotActive() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        EventApi__Event_Category__c eventCategory = new EventApi__Event_Category__c(
                Name='Test Event Category',
                EventApi__Business_Group__c =busGroup.Id);
        insert eventCategory;
        EventApi__Event__c event = new EventApi__Event__c(
                EventApi__Event_Category__c=eventCategory.Id,
                EventApi__Display_Name__c='Test Event',
                EventApi__Business_Group__c=busGroup.Id,
                FS_Accounting_Approval__c='Approved',
                EventApi__Status__c ='Active',
                EventApi__Event_Key__c='VX4FFH5',
                EventApi__Start_Time__c='08:00AM',
                EventApi__End_Time__c='09:00PM');
        insert event;
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
                EventApi__Event__c = event.Id,
                Name='Test TicketType',
                EventApi__Is_Active__c=true);
        insert ticketType;
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name='Event Item Class',
                    OrderApi__Business_Group__c = busGroup.Id);
        insert itemClass;
        OrderApi__Item__c item = new OrderApi__Item__c(Name='Event Item',
                OrderApi__Item_Class__c=itemClass.Id,
                EventApi__Event__c=event.Id,
                OrderApi__Is_Active__c=true,
                OrderApi__Business_Group__c = busGroup.Id,
                EventApi__Ticket_Type__c = ticketType.Id);
        insert item;

        item.OrderApi__Is_Active__c = false;
        update item;

        ticketType.EventApi__Is_Active__c=false;
        update ticketType;

        Test.startTest();
            try{
                ticketType.EventApi__Is_Active__c = true;
                update ticketType;
            }catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains('You cannot activate the ticket Type if Item is not set to Active') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
}