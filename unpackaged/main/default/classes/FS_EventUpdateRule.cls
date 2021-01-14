/**
 * Created by Nikhil on 04-04-2020.
 */

global without sharing class FS_EventUpdateRule extends Framework.Domain {
    private static final String ACTIVE_STRING = 'Active';
    private static final String APPROVED_STRING = 'Approved';
    public FS_EventUpdateRule(List<EventApi__Event__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_EventUpdateRule(sObjectList);
        }
    }
    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_EventUpdateRule.class.getName(), 'beforeUpdate');
        throwExceptionOnEventIfNotApproved((List<EventApi__Event__c>) records, (Map<Id, EventApi__Event__c>) existingRecords);
        Framework.Log.pop();
    }
    public static void throwExceptionOnEventIfNotApproved(List<EventApi__Event__c> records, Map<Id, EventApi__Event__c> oldMap) {
        Set<Id> eventIds = new Set<Id>();
        for (EventApi__Event__c event : records) {
            EventApi__Event__c oldEvent = (EventApi__Event__c) oldMap.get(event.Id);
            if ((event.EventApi__Status__c != oldEvent.EventApi__Status__c || event.FS_Accounting_Approval__c != oldEvent.FS_Accounting_Approval__c) && event.EventApi__Status__c == ACTIVE_STRING) { 
                if (event.FS_Accounting_Approval__c != APPROVED_STRING) {
                    event.addError('You cannot make an event active if accounting approval is not set to Approved');
                }
                if (event.FS_Accounting_Approval__c == APPROVED_STRING) {
                    eventIds.add(event.Id);
                }
            }
        }
        if(!eventIds.isEmpty()){
            List<EventApi__Event__c> eventList = [
                    SELECT Id,EventApi__Status__c, (
                            SELECT Id
                            FROM EventApi__Ticket_Types__r
                            WHERE
                            EventApi__Is_Active__c = TRUE AND FS_Is_Primary__c = TRUE
                    )
                    FROM EventApi__Event__c
                    WHERE Id = :eventIds
            ];

            for (EventApi__Event__c event : eventList) {
                if (event.EventApi__Ticket_Types__r.size() == 0) {
                    Trigger.newMap.get(event.Id).addError('You cannot make an event active without Primary ticket type Active ');
                }

            }
        }
    }
}