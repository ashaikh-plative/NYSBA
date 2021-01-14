/**
 * Created by cloudwebsolutions on 12-12-2019.
 */

global class FS_AsyncProcessPayment implements Queueable {

    private Set<Id> salesOrderIds;
    private static final String TRANSACTION_TYPE = 'Authorization';
    private static final String SIF_AMS_STATUS_ERROR = 'Error'; 

    public FS_AsyncProcessPayment(Set<Id> soIds) {
        this.salesOrderIds = soIds;
    }

    public void execute(QueueableContext context) {
        List<OrderApi__EPayment__c> ePayments = [
                SELECT Id, OrderApi__Process_Payment__c
                FROM OrderApi__EPayment__c
                WHERE OrderApi__EPayment__c != NULL AND OrderApi__Process_Payment__c = FALSE
                AND OrderApi__Succeeded__c = FALSE AND OrderApi__Transaction_Type__c = :TRANSACTION_TYPE AND OrderApi__Sales_Order__c = :salesOrderIds
        ];
        if (!ePayments.isEmpty()) {
            for (OrderApi__EPayment__c ePayment : ePayments) {
                ePayment.OrderApi__Process_Payment__c = true;
            }
            Database.SaveResult[] srList = Database.update(ePayments, false);
            if (srList != null) {
                Map<Id, String> errorEPaymentIdMsgMap = new Map<Id, String>();
                for (Integer index = 0; index < srList.size(); index++) {
                    if (!srList[index].isSuccess() || Test.isRunningTest()) {
                        String errMsg = '';
                        for (Database.Error err : srList[index].getErrors()) {
                            if (String.isNotBlank(errMsg)) {
                                errMsg += '\n';
                            }
                            errMsg += err.getStatusCode() + ' ' + err.getMessage();
                            System.debug(LoggingLevel.ERROR, err.getStatusCode() + ': Unable to capture ePayment record ' + ePayments[index].Id + ': ' + err.getMessage());
                        }
                        errorEPaymentIdMsgMap.put(ePayments[index].Id, errMsg);
                    }
                }
                Map<Id, FS_Order_Fulfillment__c> toBeUpdatedFulfillmentsMap = new Map<Id, FS_Order_Fulfillment__c>();
                for (FS_Order_Fulfillment__c fulfillment : [
                        SELECT Id,FS_Order__c,FS_Order_Line__c,FS_ePayment__c,FS_Error_Message__c,
                                FS_Status__c
                        FROM FS_Order_Fulfillment__c
                        WHERE
                        FS_Order__c IN :salesOrderIds AND FS_ePayment__c IN :errorEPaymentIdMsgMap.keySet()
                ]) {
                    if (salesOrderIds.contains(fulfillment.FS_Order__c) && errorEPaymentIdMsgMap.containsKey(fulfillment.FS_ePayment__c)) {
                        fulfillment.FS_Error_Message__c = errorEPaymentIdMsgMap.get(fulfillment.FS_ePayment__c);
                        fulfillment.FS_Status__c = SIF_AMS_STATUS_ERROR;
                        toBeUpdatedFulfillmentsMap.put(fulfillment.Id, fulfillment);
                    }
                }

                if (!toBeUpdatedFulfillmentsMap.isEmpty()) {
                    Database.update(toBeUpdatedFulfillmentsMap.values(), false);
                }
            }
        }
    }
}