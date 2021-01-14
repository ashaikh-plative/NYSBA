public with sharing class FS_OrderConfirmationController {
    public FS_OrderConfirmationController() {

    }
    private static final String FS_PAYMENT_SUCCESSFUL='Payment Successful';

    @AuraEnabled
    public static  Map<String, Object> getOrderNumberApex(String orderNumber) {
        Map<String, Object> result=new Map<String, Object>();
        try{
            List<OrderApi__Sales_Order__c> soList = [SELECT Id,Name,OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE Name =:orderNumber LIMIT 1];
            if(soList != null && soList.size() == 1) {
                result.put('recordId', soList[0].Id);
                result.put('buttonLabel', 'Order Confirmation');
                result.put('FirstDisplayLines','Your order # '+soList[0].Name+ ' has been placed!');
                result.put('SecondDisplayLines','Your payment of  USD ' +soList[0].OrderApi__Total__c+ ' was successfully completed');
            }else{
                List<OrderApi__Receipt__c> receiptList = [SELECT Id,OrderApi__Total__c,OrderApi__Sales_Order__c,OrderApi__Sales_Order__r.OrderApi__Total__c FROM OrderApi__Receipt__c WHERE Name =:orderNumber LIMIT 1];
                if(receiptList != null && receiptList.size() == 1) {
                    result.put('recordId', receiptList[0].OrderApi__Sales_Order__c);
                    result.put('buttonLabel', 'Order Confirmation');
                    result.put('FirstDisplayLines',FS_PAYMENT_SUCCESSFUL);
                    result.put('SecondDisplayLines','Your payment of  USD ' +receiptList[0].OrderApi__Sales_Order__r.OrderApi__Total__c+ ' was successfully completed');
                }
            }
        } catch (ListException le) {
            System.debug('Receipt not found: '+le.getMessage());

        }
        return result;
    }

    @AuraEnabled
    public static List<SObject> getEventReceiptLines(String receiptId){
        Set<Id> soLineIds= new Set<Id>();
        List<SObject> resultList = new List<SObject>();
        List<OrderApi__Receipt__c> receiptList = [SELECT Id,(SELECT Id,OrderApi__Sales_Order_Line__c FROM OrderApi__Receipt_Lines__r WHERE
                OrderApi__Item__r.OrderApi__Is_Event__c = TRUE) FROM OrderApi__Receipt__c WHERE Name =: receiptId LIMIT 1];

        if(!receiptList.isEmpty() && receiptList[0].OrderApi__Receipt_Lines__r != null &&! receiptList[0].OrderApi__Receipt_Lines__r.isEmpty() ){

            for(OrderApi__Receipt_Line__c rLine: receiptList[0].OrderApi__Receipt_Lines__r ){
                if(rLine.OrderApi__Sales_Order_Line__c != null){
                    soLineIds.add(rLine.OrderApi__Sales_Order_Line__c);
                }
            }
            List<EventApi__Attendee__c> attendeeList = [SELECT Id,EventApi__Event__r.Name,EventApi__Event__r.EventApi__Start_Date__c,EventApi__Event__r.EventApi__End_Date__c,
            EventApi__Event__r.EventApi__Start_Time__c,EventApi__Event__r.EventApi__End_Time__c FROM EventApi__Attendee__c WHERE EventApi__Sales_Order_Line__c IN:soLineIds];
            if(!attendeeList.isEmpty()){
                resultList.addAll(attendeeList);
            }
        }
        return resultList;
    }
}