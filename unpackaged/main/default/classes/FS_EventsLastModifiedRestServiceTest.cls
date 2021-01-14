/**
 * Created by santhosh on 06-04-2020.
 */

@IsTest
private class FS_EventsLastModifiedRestServiceTest {
    @IsTest
    private static void getLastModifiedEventsTest(){

        EventApi__Event__c event = createEvent();
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/eventsLastModified/10';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<EventApi__Event__c> eventsList = FS_EventsLastModifiedRestService.getEventsList();
        System.assert(eventsList != null);
        System.assertEquals(1, eventsList.size());
        System.assertEquals(event.Id, eventsList[0].Id);
        Test.stopTest();
    }

    @IsTest
    private static void getLastModifiedEventObjectsTest(){
        EventApi__Event__c event = createEvent();

        EventApi__Schedule_Item__c schedule = new EventApi__Schedule_Item__c(Name='Test Schedule Item', Is_Test_Data__c = true, EventApi__Event__c = event.Id);
        insert schedule;

        EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c(Name='Test Ticket Type', Is_Test_Data__c = true, EventApi__Event__c = event.Id, FS_Product_Code__c = 'Test');
        insert tt;

        EventApi__Speaker__c speaker = new EventApi__Speaker__c(Name='Test Speaker', Is_Test_Data__c = true, EventApi__Event__c = event.Id);
        insert speaker;

        EventApi__Venue__c ven = new EventApi__Venue__c(Name='Test Venue', Is_Test_Data__c = true, EventApi__Event__c = event.Id);
        insert ven;

        OrderApi__Item__c item = new OrderApi__Item__c(Name='Test Item', Is_Test_Data__c = true, EventApi__Event__c = event.Id, OrderApi__Is_Event__c = true);
        insert item;

        FS_Sponsoring_Community_Groups__c sponsoringCommunityGroup = new FS_Sponsoring_Community_Groups__c(Event__c = event.Id);
        insert sponsoringCommunityGroup;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/eventsLastModified/10';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<EventApi__Event__c> eventsList = FS_EventsLastModifiedRestService.getEventsList();
        System.assert(eventsList != null);
        System.assertEquals(1, eventsList.size());
        System.assertEquals(event.Id, eventsList[0].Id);
        Test.stopTest();
    }

    private static EventApi__Event__c createEvent(){
        OrderApi__Business_Group__c obusGroup = new OrderApi__Business_Group__c(Name = 'NYSBA', OrderApi__Type__c = 'test');
        insert obusGroup;

        EventApi__Event__c event = new EventApi__Event__c(Name='Test Event', EventApi__Event_Key__c = '123ews34567qw234', Is_Test_Data__c = true,
                FS_Accounting_Approval__c = 'Approved', EventApi__Status__c= 'Active', EventApi__Business_Group__c = obusGroup.Id);
        insert event;

        EventApi__Event_Status__c status = new EventApi__Event_Status__c(Name='Active', EventApi__Order__c = 123456, EventApi__Event__c = event.Id);
        insert status;
        return event;
    }

    @IsTest
    private static void invalidLastNDaysTest(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/eventsLastModified/text';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<EventApi__Event__c> eventsList = FS_EventsLastModifiedRestService.getEventsList();
        System.assert(eventsList != null);
        System.assertEquals(0, eventsList.size());
        System.assertEquals(400, res.statusCode);
        Test.stopTest();
    }

    @IsTest
    private static void invalidURLTest(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/eventsLastModified/10/';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<EventApi__Event__c> eventsList = FS_EventsLastModifiedRestService.getEventsList();
        System.assert(eventsList != null);
        System.assertEquals(0, eventsList.size());
        System.assertEquals(400, res.statusCode);
        Test.stopTest();
    }
}