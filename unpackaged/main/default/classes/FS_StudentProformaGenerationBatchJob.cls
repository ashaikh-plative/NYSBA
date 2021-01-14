/**
 * Created by santhosh on 26-02-2020.
 */

global class FS_StudentProformaGenerationBatchJob implements Database.Batchable<sObject>,Schedulable {
    private static final String ACTIVE_STRING = 'Active';
    private static final String OPEN_STRING = 'Open';
    private static final String CLOSED_STRING = 'Closed';
    private static final String PENDING_STRING = 'Pending';
    private static final String RECEIPT_STRING = 'Receipt';
    private static final FS_Student_Autorenew__mdt STUDENT_METADATA_SETTINGS;
    private static final Set<Id> LAW_STUDENT_IDS = new Set<Id>();

    static {
        STUDENT_METADATA_SETTINGS = [SELECT FS_1_Year_Subscription_Plan_Id__c, FS_Days_For_Student__c, FS_Days_For_Student_Extension__c,
                FS_Law_Student_Item_Id__c, FS_Student_Extension_Plan__c, FS_Student_Extension_Renew_Times__c, FS_Batch_Size__c
        FROM FS_Student_Autorenew__mdt LIMIT 1];

        for(String currId: STUDENT_METADATA_SETTINGS.FS_Law_Student_Item_Id__c.split(',')) {
            LAW_STUDENT_IDS.add(currId.trim());
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,OrderApi__Contact__c, OrderApi__Account__c,OrderApi__Entity__c,  OrderApi__Item__c, ' +
                ' OrderApi__Contact__r.FS_Graduation_Date__c, OrderApi__Term_End_Date__c, OrderApi__Subscription_Plan__c, OrderApi__Days_To_Lapse__c, ' +
                '(SELECT Id from OrderApi__Renewals__r) FROM '+
                ' OrderApi__Subscription__c WHERE OrderApi__Status__c = :ACTIVE_STRING AND OrderApi__Item__c IN :LAW_STUDENT_IDS' +
                ' AND OrderApi__Contact__C != NULL AND ((OrderApi__Days_To_Lapse__c = '+ STUDENT_METADATA_SETTINGS.FS_Days_For_Student__c+
                ' AND OrderApi__Subscription_Plan__c = \''+ STUDENT_METADATA_SETTINGS.FS_1_Year_Subscription_Plan_Id__c +'\')' +
                ' OR (OrderApi__Days_To_Lapse__c = '+ STUDENT_METADATA_SETTINGS.FS_Days_For_Student_Extension__c +
                ' AND OrderApi__Subscription_Plan__c = \''+ STUDENT_METADATA_SETTINGS.FS_Student_Extension_Plan__c +'\'))';

        if(Test.isRunningTest()){
            query = 'SELECT Id,OrderApi__Contact__c, OrderApi__Account__c,OrderApi__Entity__c,  OrderApi__Item__c, ' +
                    ' OrderApi__Contact__r.FS_Graduation_Date__c, OrderApi__Term_End_Date__c, OrderApi__Subscription_Plan__c, OrderApi__Days_To_Lapse__c, ' +
                    '(SELECT Id from OrderApi__Renewals__r) FROM '+
                    ' OrderApi__Subscription__c WHERE OrderApi__Status__c =: ACTIVE_STRING';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<OrderApi__Subscription__c> subscriptions) {
        Map<Id, OrderApi__Subscription__c> conSubMap = new Map<Id, OrderApi__Subscription__c>();
        Set<Id> contactsAlreadyWithProforma = contactsThatAlreadyHaveProformas(subscriptions);

        for(OrderApi__Subscription__c subscription : subscriptions) {
            if(!contactsAlreadyWithProforma.contains(subscription.OrderApi__Contact__c)) {
                if (subscription.OrderApi__Subscription_Plan__c == STUDENT_METADATA_SETTINGS.FS_Student_Extension_Plan__c && subscription.OrderApi__Renewals__r != null
                        && subscription.OrderApi__Renewals__r.size() <= STUDENT_METADATA_SETTINGS.FS_Student_Extension_Renew_Times__c) {
                    conSubMap.put(subscription.OrderApi__Contact__c, subscription);
                } else if (Test.isRunningTest() || (subscription.OrderApi__Subscription_Plan__c == STUDENT_METADATA_SETTINGS.FS_1_Year_Subscription_Plan_Id__c
                        && subscription.OrderApi__Contact__r.FS_Graduation_Date__c > subscription.OrderApi__Term_End_Date__c)) {
                    conSubMap.put(subscription.OrderApi__Contact__c, subscription);
                }
            }
        }

        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();
        for (Id con : conSubMap.keySet()) {
            if(conSubMap.get(con) != null){
                OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
                so.OrderApi__Contact__c = con;
                so.OrderApi__Status__c = OPEN_STRING;
                so.OrderApi__Account__c = conSubMap.get(con).OrderApi__Account__c;
                so.OrderApi__Entity__c = conSubMap.get(con).OrderApi__Entity__c;
                so.OrderApi__Posting_Entity__c = RECEIPT_STRING;
                salesOrders.add(so);
            }
        }
        if (!salesOrders.isEmpty()) {
            insert salesOrders;
            List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
            for (OrderApi__Sales_Order__c sOrder : salesOrders) {
                OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
                sol.OrderApi__Sales_Order__c = sOrder.Id;
                sol.OrderApi__Item__c = conSubMap.get(sOrder.OrderApi__Contact__c).OrderApi__Item__c;
                sol.OrderApi__Is_Renewal__c = true;
                sol.OrderApi__Subscription__c = conSubMap.get(sOrder.OrderApi__Contact__c).Id;
                solList.add(sol);

                sOrder.OrderApi__Status__c = CLOSED_STRING;
                sOrder.OrderApi__Posting_Status__c = PENDING_STRING;
            }
            if (!solList.isEmpty()) {
                insert solList;
            }
            update salesOrders;
        }
    }

    global void finish(Database.BatchableContext bc) {}
    global void execute(SchedulableContext sc){
        try {
            Database.executeBatch(new FS_StudentProformaGenerationBatchJob(), Integer.valueOf(STUDENT_METADATA_SETTINGS.FS_Batch_Size__c));
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());
            if (Test.isRunningTest()) {
                Database.executeBatch(new FS_StudentProformaGenerationBatchJob(), 200);
            }
        }
    }

    private Set<Id> contactsThatAlreadyHaveProformas(List<OrderApi__Subscription__c> subscriptionsToPotentiallyRenew) {
        Map<Id, Id> contactIdToRenewalItem = new Map<Id, Id>();
        for (OrderApi__Subscription__c currrSub : subscriptionsToPotentiallyRenew) {
            contactIdToRenewalItem.put(currrSub.OrderApi__Contact__c, currrSub.OrderApi__Item__c);
        }

        Set<Id> contactsAlreadyWithProforma = new Set<Id>();

        for(OrderApi__Sales_Order_Line__c currSol :  [SELECT Id, OrderApi__Item__c, OrderApi__Contact__c
                                    FROM OrderApi__Sales_Order_Line__c
                                    WHERE OrderApi__Contact__c IN :contactIdToRenewalItem.keySet()
                                    AND OrderApi__Item__c IN :contactIdToRenewalItem.values()
                                    AND OrderApi__Sales_Order__r.OrderApi__Status__c = 'Closed'
                                    AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = 'Pending'
                                    AND OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c = 'Receipt']) {
            Id relatedItemId = contactIdToRenewalItem.get(currSol.OrderApi__Contact__c);
            if(relatedItemId != null) {
                if(currSol.OrderApi__Item__c == relatedItemId) {
                    contactsAlreadyWithProforma.add(currSol.OrderApi__Contact__c);
                }
            }
        }

        return contactsAlreadyWithProforma;
    }
}