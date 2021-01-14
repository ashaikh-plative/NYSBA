public without sharing class FS_GetToCorrectCartSparkPlugController {

    @AuraEnabled
    public static String getCorrectSalesOrder(String salesOrderId) {
        try {
            User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            List<OrderApi__Sales_Order__c> soList = [
                    SELECT
                            Id, Name, OrderApi__Item_Count__c
                    FROM
                            OrderApi__Sales_Order__c
                    WHERE
                            (OrderApi__Status__c = 'Open' OR (OrderApi__Status__c = 'Closed' AND OrderApi__Posting_Status__c = 'Pending'))
                            AND Id = :salesOrderId
            ];
            if (soList != null && soList.size() == 1) {
                return soList[0].Id;
            } else {
                soList = [
                        SELECT
                                Id, Name, OrderApi__Item_Count__c
                        FROM
                                OrderApi__Sales_Order__c
                        WHERE
                                (OrderApi__Status__c = 'Open' OR (OrderApi__Status__c = 'Closed' AND OrderApi__Posting_Status__c = 'Pending'))
                                AND OrderApi__Contact__c = :u.ContactId
                                AND CreatedBy.ContactId = :u.ContactId
                                ORDER BY LastModifiedDate DESC LIMIT 1
                ];
                if (soList != null && !soList.isEmpty()) {
                    return soList[0].Id;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.Error, 'Sales Order not found: ' + e);
        }

        return salesOrderId;
    }
}