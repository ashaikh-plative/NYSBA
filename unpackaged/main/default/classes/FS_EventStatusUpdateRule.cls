/**
 * Created by Nikhil on 08-04-2020.
 */
global class FS_EventStatusUpdateRule extends Framework.Domain {
    private static final String ACTIVE_STRING = 'Active';
    private static final String PLANNED_STRING = 'Planned';
    public FS_EventStatusUpdateRule(List<EventApi__Event_Status__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_EventStatusUpdateRule(sObjectList);
        }
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_EventStatusUpdateRule.class.getName(), 'beforeUpdate');
        System.debug('david im called');
        updateEventStatusesWhenEventUpdated((List<EventApi__Event_Status__c>) records, (Map<Id, EventApi__Event_Status__c>) oldMap);
        System.debug('david im called is done');
        Framework.Log.pop();
    }

    private static void updateEventStatusesWhenEventUpdated(List<EventApi__Event_Status__c> records,Map<Id,EventApi__Event_Status__c> oldMap) {
        List<Id> eventIds = new List<Id>();
        List<Id> eventIdChanged = new List<Id>();
        Map<Id, EventApi__Event__c> eventIdToObj = new Map<Id, EventApi__Event__c>();
        System.debug('recordsize: ' + records.size());

        for (EventApi__Event_Status__c eStatus : records) {
            eventIds.add(eStatus.EventApi__Event__c);
            System.debug('currrent one: ' + records);
        }

        for (EventApi__Event__c event : [SELECT Id, EventApi__Status__c, FS_Accounting_Approval__c FROM EventApi__Event__c
                                        WHERE Id IN :eventIds]) {
            eventIdToObj.put(event.Id, event);
        }

        for(EventApi__Event_Status__c eventStatus : records){
            EventApi__Event_Status__c oldEventStatus = (EventApi__Event_Status__c)oldMap.get(eventStatus.Id);
            System.debug('old records: ' + oldEventStatus);
            if(eventStatus.Name == 'Active' && eventStatus.EventApi__Is_Current_Status_for_Event__c != oldEventStatus.EventApi__Is_Current_Status_for_Event__c
                    && eventStatus.EventApi__Is_Current_Status_for_Event__c) {
                EventApi__Event__c matchedEvent = eventIdToObj.get(eventStatus.EventApi__Event__c);
                if (matchedEvent.EventApi__Status__c != ACTIVE_STRING && matchedEvent.FS_Accounting_Approval__c == 'Request Approval') {
                    System.debug('im in the deep');
                    eventStatus.EventApi__Is_Current_Status_for_Event__c = false;
                    eventIdChanged.add(eventStatus.EventApi__Event__c);
                }
            }

            if(eventStatus.Name != 'Active' && eventStatus.EventApi__Is_Current_Status_for_Event__c != oldEventStatus.EventApi__Is_Current_Status_for_Event__c
                    && !eventStatus.EventApi__Is_Current_Status_for_Event__c) {
                EventApi__Event__c matchedEvent = eventIdToObj.get(eventStatus.EventApi__Event__c);
                if (matchedEvent.EventApi__Status__c != ACTIVE_STRING && matchedEvent.FS_Accounting_Approval__c == 'Request Approval') {
                    System.debug('im in the deep 2');
                    eventStatus.EventApi__Is_Current_Status_for_Event__c = true;
                    eventIdChanged.add(eventStatus.EventApi__Event__c);
                }
            }
        }
        System.debug('eventIdChanged: ' + eventIdChanged);
        for (EventApi__Event_Status__c eventStatus : [SELECT Name, EventApi__Event__c,Id, EventApi__Is_Current_Status_for_Event__c
                                                    FROM EventApi__Event_Status__c WHERE EventApi__Event__c IN :eventIdChanged]) {
            EventApi__Event__c matchedEvent = eventIdToObj.get(eventStatus.EventApi__Event__c);
            if (eventStatus.Name == matchedEvent.EventApi__Status__c) {
                eventStatus.EventApi__Is_Current_Status_for_Event__c = true;
                records.add(eventStatus);
            }
        }
//        Map<Id,List<Id>> eventIdToEventStatus = new Map<Id,List<Id>>();
//        List<EventApi__Event_Status__c> statusNeedToModify = new List<EventApi__Event_Status__c>();
//        List<Id> eventIds = new List<Id>();
//        Map<Id, EventApi__Event_Status__c> statusIdToObj = new Map<Id, EventApi__Event_Status__c>();
//        System.debug('david checkpoint 1');
//        System.debug('records: ' + records);
//        for(EventApi__Event_Status__c eventStatus : records){
//            EventApi__Event_Status__c oldEventStatus = (EventApi__Event_Status__c)oldMap.get(eventStatus.Id);
//            System.debug('old records: ' + oldEventStatus);
//            if(eventStatus.EventApi__Is_Current_Status_for_Event__c != oldEventStatus.EventApi__Is_Current_Status_for_Event__c){
//                System.debug('david im in: ' +  eventStatus.EventApi__Event__c);
//                if (eventStatus.EventApi__Event__c != null && !eventIds.contains(eventStatus.EventApi__Event__c)) {
//                    eventIds.add(eventStatus.EventApi__Event__c);
//                }
////                eventIdToEventStatus.put(eventStatus.EventApi__Event__c,eventStatus);
//            }
//        }
//        System.debug('david checkpoint 2');
//        System.debug('eventIds: ' + eventIds);
//        if (eventIds != null) {
//            for (EventApi__Event_Status__c eStatus : [SELECT Name, EventApi__Event__c,EventApi__Is_Current_Status_for_Event__c
//            FROM EventApi__Event_Status__c WHERE EventApi__Event__c IN :eventIds]) {
//                List<Id> statusList;
//                System.debug('david checkpoint 2.1');
//                if (eventIdToEventStatus.containsKey(eStatus.EventApi__Event__c)) {
//                    statusList = eventIdToEventStatus.get(eStatus.EventApi__Event__c);
//                } else {
//                    // first id as planned, second is active, third is closed
//                    statusList = new Id[3];
//                }
//                System.debug('david checkpoint 2.2');
//                if (eStatus.Name == 'Planned') {
//                    statusList[0] = eStatus.Id;
//                } else if (eStatus.Name == 'Active') {
//                    statusList[1] = eStatus.Id;
//                } else if (eStatus.Name == 'Closed') {
//                    statusList[2] = eStatus.Id;
//                } else {
//                    //do nothing
//                }
//
//                System.debug('david checkpoint 2.3');
//                eventIdToEventStatus.put(eStatus.EventApi__Event__c, statusList);
//                statusIdToObj.put(eStatus.Id, eStatus);
//                System.debug('david checkpoint 2.4');
//            }
//        }
//
//        System.debug('david checkpoint 3');
//
//
//        for (EventApi__Event__c event : [SELECT Id,EventApi__Status__c,FS_Accounting_Approval__c  FROM EventApi__Event__c WHERE Id IN :eventIdToEventStatus.keySet()]) {
//            if (event.FS_Accounting_Approval__c == 'Request Approval') {
//                Id matchedId;
//                if (event.EventApi__Status__c == 'Planned' || event.EventApi__Status__c == 'Active') {
//                    matchedId = eventIdToEventStatus.get(event.Id)[0];
//                } else if (event.EventApi__Status__c == 'Closed') {
//                    matchedId = eventIdToEventStatus.get(event.Id)[2];
//                }
//
//                EventApi__Event_Status__c matchedObj = statusIdToObj.get(matchedId);
//                matchedObj.EventApi__Is_Current_Status_for_Event__c = true;
//                statusNeedToModify.add(matchedObj);
//            }
//        }
//        System.debug('david checkpoint 4');
    }
}