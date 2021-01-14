/**
 * Created by santhosh on 04-04-2020.
 */

@RestResource(urlMapping='/eventsLastModified/*')
global without sharing class FS_EventsLastModifiedRestService {

    private static final Date START_DATE = Date.newInstance(2017, 1, 1);
    private static final String BUSINESS_GROUP_NAME = 'NYSBA';

    @HttpGet
    global static List<EventApi__Event__c> getEventsList() {
        List<EventApi__Event__c> eventIdsList = new List<EventApi__Event__c>();
        try{
            Set<Id> eventIdsSet = new Set<Id>();
            Date modifiedDate = System.today();
            RestRequest req = RestContext.request;
            try{
                modifiedDate = System.today() - Integer.valueOf(req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
            }catch (Exception e){
                RestResponse response = RestContext.response;
                response.statusCode = 400;
                System.debug(LoggingLevel.ERROR, 'eventsLastModified API Request URL:'+req.requestURI);
                System.debug(LoggingLevel.ERROR, e.getStackTraceString()+' : '+ e.getMessage());
                return eventIdsList;
            }

            //Modified Event related Schedule Items
            getModifiedScheduleItemEventIds(eventIdsSet, modifiedDate);

            //Modified Event related Ticket Types
            getModifiedTicketTypeEventIds(eventIdsSet, modifiedDate);

            //Modified Event related items
            getModifiedItemEventIds(eventIdsSet, modifiedDate);

            //Modified Event related Speakers
            getModifiedSpeakerEventIds(eventIdsSet, modifiedDate);

            //Modified Event related Venues
            getModifiedVenueEventIds(eventIdsSet, modifiedDate);

            //Modified Event related sponsoring community group
            getModifiedSponsoringCommunityGroup(eventIdsSet, modifiedDate);


            eventIdsList = getListOfEvents(eventIdsSet, modifiedDate);
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getStackTraceString()+' : '+ e.getMessage());
        }
        return eventIdsList;
    }

    private static List<EventApi__Event__c> getListOfEvents(Set<Id> eventIds, Date modifiedDate){
        return [SELECT Id, Name, EventApi__Status__c, EventApi__Start_Date__c,
                EventApi__End_Date__c, CreatedDate, LastModifiedDate
        FROM EventApi__Event__c WHERE  Id IN :eventIds OR ( LastModifiedDate >= :modifiedDate
        AND EventApi__Start_Date__c >= :START_DATE
        AND EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME )];
    }

    private static void getModifiedScheduleItemEventIds(Set<Id> eventIdsSet, Date modifiedDate){
        for(EventApi__Schedule_Item__c scheduleItem : [SELECT Id, EventApi__Event__c FROM EventApi__Schedule_Item__c WHERE  EventApi__Event__c != NULL
        AND EventApi__Event__r.EventApi__Start_Date__c >= :START_DATE AND LastModifiedDate >= :modifiedDate
        AND EventApi__Event__r.EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME]){
            eventIdsSet.add(scheduleItem.EventApi__Event__c);
        }
    }

    private static void getModifiedTicketTypeEventIds(Set<Id> eventIdsSet, Date modifiedDate){
        for(EventApi__Ticket_Type__c ticketType : [SELECT Id, EventApi__Event__c FROM EventApi__Ticket_Type__c WHERE  EventApi__Event__c != NULL
        AND EventApi__Event__r.EventApi__Start_Date__c >= :START_DATE AND LastModifiedDate >= :modifiedDate
        AND EventApi__Event__r.EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME]){
            eventIdsSet.add(ticketType.EventApi__Event__c);
        }
    }

    private static void getModifiedItemEventIds(Set<Id> eventIdsSet, Date modifiedDate){
        for(OrderApi__Item__c item : [SELECT Id, EventApi__Event__c FROM OrderApi__Item__c WHERE OrderApi__Is_Event__c = TRUE AND EventApi__Event__c != NULL AND
        EventApi__Event__r.EventApi__Start_Date__c >= :START_DATE AND LastModifiedDate >= :modifiedDate
        AND EventApi__Event__r.EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME]){
            eventIdsSet.add(item.EventApi__Event__c);
        }
    }

    private static void getModifiedSpeakerEventIds(Set<Id> eventIdsSet, Date modifiedDate){
        for(EventApi__Speaker__c speaker : [SELECT Id, EventApi__Event__c FROM EventApi__Speaker__c WHERE  EventApi__Event__c != NULL
        AND EventApi__Event__r.EventApi__Start_Date__c >= :START_DATE AND LastModifiedDate >= :modifiedDate
        AND EventApi__Event__r.EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME]){
            eventIdsSet.add(speaker.EventApi__Event__c); 
        }
    }

    private static void getModifiedVenueEventIds(Set<Id> eventIdsSet, Date modifiedDate){
        for(EventApi__Venue__c venue : [SELECT Id, EventApi__Event__c FROM EventApi__Venue__c WHERE  EventApi__Event__c != NULL
        AND EventApi__Event__r.EventApi__Start_Date__c >= :START_DATE AND LastModifiedDate >= :modifiedDate
        AND EventApi__Event__r.EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME]){
            eventIdsSet.add(venue.EventApi__Event__c);
        }
    }


    //Added by seshu for NYSBA - 708
    private static void getModifiedSponsoringCommunityGroup(Set<Id> eventIdsSet, Date modifiedDate) {
        for (FS_Sponsoring_Community_Groups__c sponsoringCGM : [SELECT Id,Event__c FROM FS_Sponsoring_Community_Groups__c WHERE Event__c != NULL
        AND Event__r.EventApi__Start_Date__c >= :START_DATE AND LastModifiedDate >= :modifiedDate
        AND Event__r.EventApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME]) {
            eventIdsSet.add(sponsoringCGM.Event__c);
        }
    }
}