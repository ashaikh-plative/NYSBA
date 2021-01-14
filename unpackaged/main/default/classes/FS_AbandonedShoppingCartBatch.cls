/**
 * Created by Nikhil on 21-08-2020.
 */
global without sharing class FS_AbandonedShoppingCartBatch implements Database.Batchable<SObject>, Schedulable {
    private static final String FON_COMMUNITY_USER = 'Fonteva Customer Community Login User';
    private static final String OPEN_STATUS = 'Open';
    private static final String PENDING_STATUS = 'Pending';
    private static Map<String, Id> templateIdsByDeveloperName;
    private static Set<String> developerNameSet = new Set<String>();
    private static Map<Long, FS_Abandoned_Shopping_Cart_Options__mdt> abandonedShoppingCartMetadata;
    private static final DateTime EARLIEST_TIME = null;

    static {
        Long maxHours = 0;
        templateIdsByDeveloperName = new Map<String, Id>();
        abandonedShoppingCartMetadata = new Map<Long, FS_Abandoned_Shopping_Cart_Options__mdt>();
        for (FS_Abandoned_Shopping_Cart_Options__mdt shoppingCartOptions : [
                SELECT DeveloperName, FS_Email_Template__c,FS_Hours_Before_Sending_Email__c
                FROM FS_Abandoned_Shopping_Cart_Options__mdt
                ORDER BY FS_Hours_Before_Sending_Email__c
        ]) {
            developerNameSet.add(shoppingCartOptions.FS_Email_Template__c);
            Long hoursBeforeSending = Integer.valueOf(shoppingCartOptions.FS_Hours_Before_Sending_Email__c);
            if(hoursBeforeSending != null) {
                abandonedShoppingCartMetadata.put(hoursBeforeSending, shoppingCartOptions);
                if(maxHours < hoursBeforeSending) {
                    maxHours = hoursBeforeSending;
                }
            }
        }
        for (EmailTemplate emailTemplate : [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName = :developerNameSet]) {
            templateIdsByDeveloperName.put(emailTemplate.DeveloperName, emailTemplate.Id);
        }

        EARLIEST_TIME = Datetime.now().addHours(-1 * Integer.valueOf(maxHours) -1);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,OrderApi__Contact__c,OrderApi__Contact__r.OrderApi__Personal_Email__c,CreatedDate,LastModifiedDate,FSP_FonMPP__Long_URL_Lightning__c,' +
                'OrderApi__Contact__r.Email,OrderApi__Contact__r.OrderApi__Preferred_Email__c,(SELECT Id,OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c ' +
                'WHERE (OrderApi__Status__c =:OPEN_STATUS OR OrderApi__Posting_Status__c =:PENDING_STATUS) AND LastModifiedBy.Profile.Name =:FON_COMMUNITY_USER' +
                ' AND OrderApi__Contact__r.OrderApi__Preferred_Email__c != NULL' ;

        if(EARLIEST_TIME != null) {
            query += '  AND LastModifiedDate >= :EARLIEST_TIME';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> salesOrders) {
        Long todayDateTime = System.now().getTime();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (OrderApi__Sales_Order__c salesOrder : (List<OrderApi__Sales_Order__c>) salesOrders) {
            if (salesOrder.OrderApi__Sales_Order_Lines__r.size() > 0) {
                if (salesOrder.OrderApi__Contact__c != null && salesOrder.OrderApi__Contact__r.OrderApi__Preferred_Email__c != null &&
                        salesOrder.OrderApi__Contact__r.OrderApi__Preferred_Email__c != '') {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if (String.isNotBlank(salesOrder.OrderApi__Contact__r.OrderApi__Preferred_Email__c)) {
                        email.setToAddresses(new List<String>{
                                salesOrder.OrderApi__Contact__r.OrderApi__Preferred_Email__c
                        });
                    }
                    email.setWhatId(salesOrder.Id);
                    email.setSaveAsActivity(false);
                    email.setTargetObjectId(salesOrder.OrderApi__Contact__c);
                    Long lastModifiedDate = salesOrder.LastModifiedDate.getTime();
                    Long hoursBetween = (((((todayDateTime - lastModifiedDate) / 1000) / 60) / 60));
                    if (hoursBetween != null && abandonedShoppingCartMetadata.containsKey(hoursBetween)/* &&cartOptions.FS_Hours_Before_Sending_Email__c == hoursBetween*/) {
                        FS_Abandoned_Shopping_Cart_Options__mdt metadata = abandonedShoppingCartMetadata.get(hoursBetween);
                        if (templateIdsByDeveloperName.get(metadata.FS_Email_Template__c) != null) {
                            email.setTemplateId(templateIdsByDeveloperName.get(metadata.FS_Email_Template__c));
                            emails.add(email);
                        }
                        email.setTreatTargetObjectAsRecipient(true);
                    }
                }
            }
        }

        try {
            Messaging.sendEmail(emails);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error ==== ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw e;
        }
    }
    global void finish(Database.BatchableContext BC) {

    }
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new FS_AbandonedShoppingCartBatch());
    }
}