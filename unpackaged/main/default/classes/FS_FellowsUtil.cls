/**
 * Created by cloudwebsolutions on 2/4/20.
 * Description : This is Util class for fellows pledgeamount calculation
 */

public without sharing class FS_FellowsUtil {

    private static final String CLOSED_STATUS = 'Closed';
    private static final String POSTING_STATUS = 'Posted';
    private static final String POSTING_ENTITY = 'Receipt';
    private static final Date DEFAULT_DATE = Date.newInstance(0000,00,0);

    public static void fellowPledgeAmountCalculations(Set<Id> fellowIds){

        Map<Id,FS_Fellow__c> fellowsByIds = new Map<Id,FS_Fellow__c>();
        Map<Id,FS_Fellow__c> fellowMap = new Map<Id,FS_Fellow__c>();
        Map<Id,List<OrderApi__Receipt_Line__c>> receiptLinesBySOLId = new Map<Id,List<OrderApi__Receipt_Line__c>>();
        Map<Id,Decimal> paymentPledgeAmountByFellowId = new Map<Id,Decimal>();
        Map<Id,Decimal> refundPledgeAmountByFellowId = new Map<Id,Decimal>();
        Map<Id,Date> latestPostedDate = new Map<Id,Date>();
        Map<Id,Map<Id,List<OrderApi__Receipt_Line__c>>> receiptLinesBySOLIdsByFellowIds = new Map<Id,Map<Id,List<OrderApi__Receipt_Line__c>>>();

        for(FS_Fellow__c fellow: [SELECT Id,FS_Pledge_Amount_Paid__c,FS_Last_Payment_Date__c FROM FS_Fellow__c WHERE Id IN:fellowIds]){
            fellowsByIds.put(fellow.Id,fellow);
        }

        Map<Id,OrderApi__Sales_Order_Line__c> salesOrderLinesByIds = new Map<Id,OrderApi__Sales_Order_Line__c>([SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE FS_Fellow__c IN:fellowsByIds.keySet()]);
        Map<Id,OrderApi__Receipt_Line__c> receiptLinesByIds = new Map<Id,OrderApi__Receipt_Line__c>([SELECT Id,OrderApi__Total__c,
                OrderApi__Sales_Order_Line__c,OrderApi__Sales_Order_Line__r.FS_Fellow__c,
                OrderApi__Receipt__r.OrderApi__Is_Refund__c,OrderApi__Receipt__r.OrderApi__Posted_Date__c
                FROM OrderApi__Receipt_Line__c WHERE OrderApi__Sales_Order_Line__c IN:salesOrderLinesByIds.keySet() AND
                OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Status__c =:CLOSED_STATUS AND
                OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Posting_Status__c =:POSTING_STATUS AND
                OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c =:POSTING_ENTITY AND
                OrderApi__Receipt__r.OrderApi__Is_Posted__c = true ]);

        if(!receiptLinesByIds.isEmpty() && !receiptLinesByIds.values().isEmpty()) {
            for (OrderApi__Receipt_Line__c receiptLine : receiptLinesByIds.values()) {
                if (receiptLinesBySOLId.containsKey(receiptLine.OrderApi__Sales_Order_Line__c)) {
                    receiptLinesBySOLId.get(receiptLine.OrderApi__Sales_Order_Line__c).add(receiptLine);
                } else {
                    receiptLinesBySOLId.put(receiptLine.OrderApi__Sales_Order_Line__c, new List<OrderApi__Receipt_Line__c>{receiptLine});
                }
            }
        }

        if(!receiptLinesByIds.isEmpty() && !receiptLinesByIds.values().isEmpty()) {
            for (OrderApi__Receipt_Line__c receiptLine : receiptLinesByIds.values()) {
                if (receiptLinesBySOLIdsByFellowIds.containsKey(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c)) {
                    receiptLinesBySOLIdsByFellowIds.get(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c).put(receiptLine.OrderApi__Sales_Order_Line__c,
                            receiptLinesBySOLId.get(receiptLine.OrderApi__Sales_Order_Line__c));
                } else {
                    receiptLinesBySOLIdsByFellowIds.put(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c, new Map<Id, List<OrderApi__Receipt_Line__c>>{
                            receiptLine.OrderApi__Sales_Order_Line__c => receiptLinesBySOLId.get(receiptLine.OrderApi__Sales_Order_Line__c)});
                }
            }
        }

        for(Id fellowId : fellowsByIds.keySet()) {
            Date latestDate = DEFAULT_DATE;
            paymentPledgeAmountByFellowId.put(fellowId, 0.0);
            refundPledgeAmountByFellowId.put(fellowId, 0.0);
                if (!receiptLinesBySOLIdsByFellowIds.isEmpty() && receiptLinesBySOLIdsByFellowIds.get(fellowId) != NULL) {
                    Map<Id, List<OrderApi__Receipt_Line__c>> receiptLinesBySOLIds = receiptLinesBySOLIdsByFellowIds.get(fellowId);
                    if (!receiptLinesBySOLIds.isEmpty()) {
                        for (Id solId : receiptLinesBySOLIds.keySet()) {
                            if(receiptLinesBySOLIdsByFellowIds.get(fellowId).get(solId) != NULL) {
                                List<OrderApi__Receipt_Line__c> receiptLines = receiptLinesBySOLIdsByFellowIds.get(fellowId).get(solId);
                                if (!receiptLines.isEmpty()) {
                                    for (OrderApi__Receipt_Line__c receiptLine : receiptLines) {
                                        if (latestDate < receiptLine.OrderApi__Receipt__r.OrderApi__Posted_Date__c) {
                                            latestDate = receiptLine.OrderApi__Receipt__r.OrderApi__Posted_Date__c;
                                            latestPostedDate.put(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c, latestDate);
                                        }
                                        if (receiptLine.OrderApi__Receipt__r.OrderApi__Is_Refund__c == false) {
                                            paymentPledgeAmountByFellowId.put(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c, paymentPledgeAmountByFellowId.get(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c) + receiptLine.OrderApi__Total__c);
                                        } else {
                                            refundPledgeAmountByFellowId.put(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c, refundPledgeAmountByFellowId.get(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c) + receiptLine.OrderApi__Total__c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


        for(Id fellowId: fellowsByIds.keySet()){
            Decimal paymentAmount = paymentPledgeAmountByFellowId.get(fellowId);
            Decimal refundAmount = refundPledgeAmountByFellowId.get(fellowId);
            Date recentPostedDate = latestPostedDate.get(fellowId);
            fellowMap.put(fellowId,new FS_Fellow__c(Id = fellowId,FS_Pledge_Amount_Paid__c = paymentAmount - refundAmount,FS_Last_Payment_Date__c = recentPostedDate));
        }

        if(!fellowMap.isEmpty()){
            update fellowMap.values(); 
        }
    }
}