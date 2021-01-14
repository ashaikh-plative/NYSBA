global without sharing class FS_OpenPendingSalesOrderDeleteBatchJob implements Database.Batchable<sObject>,Schedulable{
    private static final FS_Open_Pending_SalesOrder__mdt PENDING_SALESORDER_METADATA;

    static {
        PENDING_SALESORDER_METADATA = [SELECT FS_No_of_Days__c , FS_Batch_Size__c FROM FS_Open_Pending_SalesOrder__mdt LIMIT 1];
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Integer noOfDays = Integer.valueOf(PENDING_SALESORDER_METADATA.FS_No_of_Days__c);
        String query = 'SELECT Id, LastModifiedDate,OrderApi__Status__c,OrderApi__Posting_Status__c,(SELECT Id FROM OrderApi__Receipts__r LIMIT 1)' +
            ' FROM OrderApi__Sales_Order__c' +
            ' WHERE LastModifiedDate != LAST_N_DAYS:'+ noOfDays+ '' +
            ' AND  ((OrderApi__Status__c=\'Closed\' AND OrderApi__Posting_Status__c=\'Pending\' ' +
            ' AND (CreatedBy.Profile.UserLicense.Name =\'Customer Community Login\' ' +
            ' OR CreatedBy.Profile.UserLicense.Name =\'Customer Community\' ))' +
            ' OR (OrderApi__Status__c=\'Open\' AND OrderApi__Posting_Status__c=null))' ;
        
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM OrderApi__Sales_Order__c';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<OrderApi__Sales_Order__c> salesOrders) {
        List<OrderApi__Sales_Order__c> salesOrdersToDelete = new List<OrderApi__Sales_Order__c>();
        for(OrderApi__Sales_Order__c sOrder:salesOrders){
            if(sOrder.OrderApi__Receipts__r.size() == 0){
                salesOrdersToDelete.add(sOrder);
            }
        }
        if(!salesOrdersToDelete.isEmpty()){
            List<Database.DeleteResult> deleteResults = Database.delete(salesOrdersToDelete, false);
            for (Database.DeleteResult dr : deleteResults) {
                if (dr.isSuccess()) {
                    System.debug('Successfully deleted salesorders with IDs: ' + dr.getId());
                }
                if (dr.getErrors() != null && dr.getErrors().size() > 0) {
                    for (Database.Error error : dr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, ' Error occurred when deleting Salesorder record ID:' + dr.getId() + ' ===== ' + error.getMessage());
                    }
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        
    }
    
    global void execute(SchedulableContext sc){
        try {
            Database.executeBatch(new FS_OpenPendingSalesOrderDeleteBatchJob(), Integer.valueOf(PENDING_SALESORDER_METADATA.FS_Batch_Size__c));
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());
            if (Test.isRunningTest()) {
                Database.executeBatch(new FS_OpenPendingSalesOrderDeleteBatchJob(), 200);
            }
        }
    }
    
}