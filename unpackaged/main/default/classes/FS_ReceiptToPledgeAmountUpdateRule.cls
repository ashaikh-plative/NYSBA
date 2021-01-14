/**
 * Created by cloudwebsolutions on 05-02-2020.
 * Description : This is to calculate the pledgeAmount on creating the receipt.
 */

global without sharing class FS_ReceiptToPledgeAmountUpdateRule extends Framework.Domain {

    public FS_ReceiptToPledgeAmountUpdateRule(List<OrderApi__Receipt__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ReceiptToPledgeAmountUpdateRule(sObjectList);
        }
    }

    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ReceiptToPledgeAmountUpdateRule.class.getName(),'After update');
        updatePledgeAmountOnCreationOfReceipt((List<OrderApi__Receipt__c>) records,(Map<Id,OrderApi__Receipt__c>) existingRecords);
        Framework.Log.pop();
    }

    private static void updatePledgeAmountOnCreationOfReceipt(List<OrderApi__Receipt__c> receipts,Map<Id,OrderApi__Receipt__c> oldMap) {
        Set<Id> fellowIds = new Set<Id>();
        Set<Id> receiptIds = new Set<Id>();

        for(OrderApi__Receipt__c receipt : receipts){
            if(receipt.OrderApi__Is_Refund__c == true && receipt.OrderApi__Is_Posted__c == true && oldMap.get(receipt.id).OrderApi__Is_Posted__c == false){
                receiptIds.add(receipt.id);
            }
        }

        for(OrderApi__Receipt_Line__c receiptLine: [SELECT OrderApi__Sales_Order_Line__r.FS_Fellow__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c IN:receiptIds AND OrderApi__Sales_Order_Line__r.FS_Fellow__c != NULL]){
            fellowIds.add(receiptLine.OrderApi__Sales_Order_Line__r.FS_Fellow__c);
        }

        FS_FellowsUtil.fellowPledgeAmountCalculations(fellowIds);
    }
}