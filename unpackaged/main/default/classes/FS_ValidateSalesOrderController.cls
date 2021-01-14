public without sharing class FS_ValidateSalesOrderController {
    public static String getValidationResult() {
        try {
            String soId = ApexPages.currentPage().getParameters().get('soId');
            OrderApi__Sales_Order__c salesOrder = [
                    SELECT
                            Id, (
                            SELECT
                                    Id
                            FROM
                                    OrderApi__Sales_Order_Lines__r
                            WHERE
                                    OrderApi__Item__r.OrderApi__Item_Class__r.Name != 'Donations Item Class'
                    )
                    FROM
                            OrderApi__Sales_Order__c
                    WHERE
                            Id = :soId
            ];
            if (salesOrder.OrderApi__Sales_Order_Lines__r == null || salesOrder.OrderApi__Sales_Order_Lines__r.isEmpty()) {
                return 'guest';
            } else {
                return 'login';
            }
        } catch (Exception e) {
            System.debug(e);
            return 'error';
        }
    }
}