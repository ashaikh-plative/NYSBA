/**
 * Created by Nikhil on 07-04-2020.
 */

global without sharing class FS_RestrictTicketTypeIfItemIsNotActive extends Framework.Domain {
    public FS_RestrictTicketTypeIfItemIsNotActive(List<EventApi__Ticket_Type__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_RestrictTicketTypeIfItemIsNotActive(sObjectList);
        }
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_AccountingApprovalRule.class.getName(), 'beforeUpdate');
        throwExceptionIfItemIsNotActive((List<EventApi__Ticket_Type__c>) records, (Map<Id, EventApi__Ticket_Type__c>) oldMap);
        Framework.Log.pop();
    }
    private static void throwExceptionIfItemIsNotActive(List<EventApi__Ticket_Type__c> ticketTypes, Map<Id, EventApi__Ticket_Type__c> existingticketTypes) {
        Set<String> itemName = new Set<String>();
        for(EventApi__Ticket_Type__c ticketType : ticketTypes){
            EventApi__Ticket_Type__c oldTicketType = (EventApi__Ticket_Type__c)existingticketTypes.get(ticketType.Id);
            if(ticketType.EventApi__Is_Active__c != oldTicketType.EventApi__Is_Active__c && ticketType.EventApi__Is_Active__c){
                itemName.add(ticketType.Name);
            }
        }
        List<OrderApi__Item__c> item = [SELECT Id,Name,EventApi__Ticket_Type__c FROM OrderApi__Item__c WHERE Name=:itemName AND OrderApi__Is_Active__c = FALSE LIMIT 1];
        if(!item.isEmpty()){
            if(item[0].EventApi__Ticket_Type__c != null){
                if (Trigger.newMap.containsKey(item[0].EventApi__Ticket_Type__c)) {
                    Trigger.newMap.get(item[0].EventApi__Ticket_Type__c).addError('You cannot activate the ticket Type if Item is not set to Active');
                }
            }
        }
    }
}