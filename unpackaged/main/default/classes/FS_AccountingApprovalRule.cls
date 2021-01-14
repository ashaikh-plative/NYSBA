/**
 * Created by Nikhil on 11-03-2020.
 */


global without sharing class FS_AccountingApprovalRule extends Framework.Domain {
    private static final String APPROVED_STRING = 'Approved';
    private static final String JOB_NAME_STRING = 'FS Event Item Update';
    public FS_AccountingApprovalRule(List<OrderApi__Item__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_AccountingApprovalRule(sObjectList);
        }
    }
    public override void afterInsert() {
        Framework.Log.push(FS_AccountingApprovalRule.class.getName(), 'afterInsert');
        handleEventIsActiveItems((List<OrderApi__Item__c>) records);
        Framework.Log.pop();
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_AccountingApprovalRule.class.getName(), 'beforeInsert');
        handleIsActiveOnItem((List<OrderApi__Item__c>) records);
        Framework.Log.pop();
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_AccountingApprovalRule.class.getName(), 'beforeUpdate');
        handleIsActiveOnItemOnUpdate((List<OrderApi__Item__c>) records, (Map<Id, OrderApi__Item__c>) oldMap);
        Framework.Log.pop();
    }
    public override void afterUpdate(Map<Id,SObject> oldMap) {
        Framework.Log.push(FS_AccountingApprovalRule.class.getName(), 'afterUpdate');
        handleUpdateTicketTypeFromItem((List<OrderApi__Item__c>) records,(Map<Id,OrderApi__Item__c>) oldMap);
        Framework.Log.pop();
    }

    private static void handleIsActiveOnItem(List<OrderApi__Item__c> records) {
        for (OrderApi__Item__c item : records) {
            if (!item.OrderApi__Is_Event__c && item.OrderApi__Is_Active__c && item.FS_Accounting_Approval__c != APPROVED_STRING) {
                item.addError('This item is not approved by accounting. Please uncheck the Is Active flag to save');
            }
        }
    }

    private static void handleIsActiveOnItemOnUpdate(List<OrderApi__Item__c> records, Map<Id, OrderApi__Item__c> oldMap) {
        List<Id> classToActive = new List<Id>();
        if(Trigger.isUpdate && Trigger.isBefore){
            for (OrderApi__Item__c item : records) {
                OrderApi__Item__c oldItem = (OrderApi__Item__c) oldMap.get(item.Id);
                if ((item.OrderApi__Is_Active__c != oldItem.OrderApi__Is_Active__c || item.FS_Accounting_Approval__c != oldItem.FS_Accounting_Approval__c) && item.OrderApi__Is_Active__c) {
                    if (item.FS_Accounting_Approval__c != APPROVED_STRING) {
                        if(item.OrderApi__Is_Event__c == False){
                            item.addError('This item is not approved by accounting. Please uncheck the Is Active flag to save');
                        }

                        if(item.OrderApi__Is_Event__c == true && item.LastModifiedDate.addSeconds(-30) > item.CreatedDate){
                            item.addError('This item is not approved by accounting. Please uncheck the Is Active flag to save');
                        }
                    } else {
                        classToActive.add(item.OrderApi__Item_Class__c);
                    }
                }
            }
        }
        Datetime dtTimeNow=System.now().addSeconds(60);
        String cronExpression = '' + dtTimeNow.second() + ' ' + dtTimeNow.minute() + ' ' + dtTimeNow.hour() + ' ' + dtTimeNow.day() + ' ' + dtTimeNow.month() +
                ' ? ' + dtTimeNow.year();

        if (!classToActive.isEmpty()) {
            System.schedule(JOB_NAME_STRING + dtTimeNow,
                    cronExpression, new FS_ItemClassScheduledJob(classToActive));
        }
    }

    private static void handleEventIsActiveItems(List<OrderApi__Item__c> records) {
        Datetime dtTimeNow=System.now().addSeconds(120);
        String cronExpression = '' + dtTimeNow.second() + ' ' + dtTimeNow.minute() + ' ' + dtTimeNow.hour() + ' ' + dtTimeNow.day() + ' ' + dtTimeNow.month() +
                ' ? ' + dtTimeNow.year();

        Set<Id> itemIdsToChange = new Set<Id>();
        for (OrderApi__Item__c item : records) {
            if (item.OrderApi__Is_Event__c && item.FS_Accounting_Approval__c != APPROVED_STRING) {             
                itemIdsToChange.add(item.Id);
            }
        }

        if(!itemIdsToChange.isEmpty()) {
            System.schedule(JOB_NAME_STRING + dtTimeNow,
                    cronExpression, new FS_AsyncAccountingApprovalForEventItems(itemIdsToChange));
        }

    }
    private static void handleUpdateTicketTypeFromItem(List<OrderApi__Item__c> eventItems,Map<Id,OrderApi__Item__c> existingEventItems){
        Set<Id> ticketTypeIds = new Set<Id>();
        Set<Id> scheduleItemIds = new Set<Id>();
        Set<Id> sponsorPackageIds = new Set<Id>();
        List<OrderApi__Item__c> items = new List<OrderApi__Item__c>();
        List<EventApi__Ticket_Type__c> ticketTypeList = new List<EventApi__Ticket_Type__c>();
        List<EventApi__Schedule_Item__c> scheduleItems = new List<EventApi__Schedule_Item__c>();
        List<EventApi__Sponsor_Package__c> sponsorPackages = new List<EventApi__Sponsor_Package__c>();

        for(OrderApi__Item__c item : eventItems){
            OrderApi__Item__c oldItem = (OrderApi__Item__c)existingEventItems.get(item.Id);
            if((item.OrderApi__Is_Active__c != oldItem.OrderApi__Is_Active__c)  ||
                    (item.OrderApi__Income_Account__c != oldItem.OrderApi__Income_Account__c) ||
                    (item.OrderApi__Refund_Account__c != oldItem.OrderApi__Refund_Account__c) ||
                    (item.OrderApi__AR_Account__c != oldItem.OrderApi__AR_Account__c) ||
                    (item.OrderApi__Discount_Account__c != oldItem.OrderApi__Discount_Account__c) ||
                    (item.OrderApi__Adjustment_Account__c != oldItem.OrderApi__Adjustment_Account__c) ){
                if(item.EventApi__Ticket_Type__c != null){
                    ticketTypeIds.add(item.EventApi__Ticket_Type__c);
                }
                if(item.EventApi__Schedule_Item__c != null){
                    scheduleItemIds.add(item.EventApi__Schedule_Item__c);
                }
                if(item.EventApi__Sponsor_Package__c != null){
                    sponsorPackageIds.add(item.EventApi__Sponsor_Package__c);
                }
                items.add(item);
            }
        }

        /*****************Ticket Type *******************/
        Map<Id,EventApi__Ticket_Type__c> eventTypeMap = new Map<Id, EventApi__Ticket_Type__c>([SELECT Id,EventApi__Is_Active__c,EventApi__Income_Account__c,
                EventApi__Refund_Account__c,EventApi__AR_Account__c,EventApi__Adjustment_Account__c,EventApi__Discount_Account__c FROM EventApi__Ticket_Type__c WHERE Id IN:ticketTypeIds]);
        for(OrderApi__Item__c item : items){
            EventApi__Ticket_Type__c ticketType = eventTypeMap.get(item.EventApi__Ticket_Type__c);
            if(ticketType != null){
                ticketType.EventApi__Is_Active__c =  item.OrderApi__Is_Active__c;
                if (item.OrderApi__Income_Account__c != null) {
                    ticketType.EventApi__Income_Account__c = item.OrderApi__Income_Account__c;
                }
                if (item.OrderApi__Refund_Account__c != null) {
                    ticketType.EventApi__Refund_Account__c = item.OrderApi__Refund_Account__c;
                }
                if (item.OrderApi__AR_Account__c != null) {
                    ticketType.EventApi__AR_Account__c = item.OrderApi__AR_Account__c;
                }
                if (item.OrderApi__Adjustment_Account__c != null) {
                    ticketType.EventApi__Adjustment_Account__c = item.OrderApi__Adjustment_Account__c;
                }
                if (item.OrderApi__Discount_Account__c != null) {
                    ticketType.EventApi__Discount_Account__c = item.OrderApi__Discount_Account__c;
                }
                ticketTypeList.add(ticketType);
            }
        }

        /*************Schedule Item*********/
        Map<Id,EventApi__Schedule_Item__c> scheduleItemMap = new Map<Id, EventApi__Schedule_Item__c>([SELECT Id,EventApi__Is_Active__c,EventApi__Income_Account__c,EventApi__Refund_Account__c,
                EventApi__AR_Account__c,EventApi__Adjustment_Account__c,EventApi__Discount_Account__c FROM EventApi__Schedule_Item__c WHERE Id IN:scheduleItemIds]);
        for(OrderApi__Item__c item : items){
            EventApi__Schedule_Item__c scheduleItem = scheduleItemMap.get(item.EventApi__Schedule_Item__c);
            if(scheduleItem != null){
                scheduleItem.EventApi__Is_Active__c = item.OrderApi__Is_Active__c;
                scheduleItem.EventApi__Income_Account__c = item.OrderApi__Income_Account__c;
                scheduleItem.EventApi__Refund_Account__c = item.OrderApi__Refund_Account__c;
                scheduleItem.EventApi__AR_Account__c = item.OrderApi__AR_Account__c;
                scheduleItem.EventApi__Adjustment_Account__c = item.OrderApi__Adjustment_Account__c;
                scheduleItem.EventApi__Discount_Account__c = item.OrderApi__Discount_Account__c;
                scheduleItems.add(scheduleItem);
            }
        }

        /***************Sponsor Package******************/
        Map<Id,EventApi__Sponsor_Package__c> sponsorPackageMap = new Map<Id, EventApi__Sponsor_Package__c>([SELECT Id,EventApi__Is_Active__c,EventApi__Income_Account__c,
                EventApi__Refund_Account__c,EventApi__AR_Account__c,EventApi__Adjustment_Account__c,EventApi__Discount_Account__c FROM EventApi__Sponsor_Package__c WHERE Id IN:sponsorPackageIds]);
        for(OrderApi__Item__c item : items){
            EventApi__Sponsor_Package__c sponsorPackage = sponsorPackageMap.get(item.EventApi__Sponsor_Package__c);
            if(sponsorPackage != null){
                sponsorPackage.EventApi__Is_Active__c = item.OrderApi__Is_Active__c;
                sponsorPackage.EventApi__Income_Account__c = item.OrderApi__Income_Account__c;
                sponsorPackage.EventApi__Refund_Account__c = item.OrderApi__Refund_Account__c;
                sponsorPackage.EventApi__AR_Account__c = item.OrderApi__AR_Account__c;
                sponsorPackage.EventApi__Adjustment_Account__c = item.OrderApi__Adjustment_Account__c;
                sponsorPackage.EventApi__Discount_Account__c = item.OrderApi__Discount_Account__c;
                sponsorPackages.add(sponsorPackage);
            }
        }


        if(!ticketTypeList.isEmpty()){
            update ticketTypeList;
        }
        if(!scheduleItems.isEmpty()){
            update scheduleItems;
        }
        if(!sponsorPackages.isEmpty()){
            update sponsorPackages;
        }
    }
}