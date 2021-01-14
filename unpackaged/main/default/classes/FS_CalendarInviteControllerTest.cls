/**
 * Created by Anvesh on 09-Dec-20.
 */
@IsTest
private class FS_CalendarInviteControllerTest {

    @IsTest
    private static void testEvent(){
        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name='test');
        insert busGroup;

        // Inserting Event Category
        EventApi__Event_Category__c eCategory = new EventApi__Event_Category__c(
                Name='My Meeting',
                EventApi__Business_Group__c=busGroup.Id
        );
        insert eCategory;

        // Inserting EVent
        EventApi__Event__c event = new EventApi__Event__c(
                EventApi__Event_Category__c = eCategory.Id,
                Name = 'My Summit Meeting',
                EventApi__Status__c = 'Active',
                EventApi__Business_Group__c = busGroup.Id,
                EventApi__Event_Key__c = '15506a-b170ac-1',
                EventApi__Start_Date_Time__c = Datetime.now().addDays(25),
                EventApi__End_Date_Time__c = Datetime.now().addDays(30)
        );
        insert event;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(event.Id));
        FS_CalendarInviteController cInvite = new FS_CalendarInviteController();
        String eventSummary = cInvite.getSummary();
        String eventEndDate = cInvite.getEndDate();
        String eventStartDate = cInvite.getStartDate();
        Test.stopTest();

        System.assertEquals(event.EventApi__Start_Date_Time__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''),eventStartDate);
        System.assertEquals(event.EventApi__End_Date_Time__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''),eventEndDate);
        System.assertEquals(event.Name,eventSummary);

    }
}