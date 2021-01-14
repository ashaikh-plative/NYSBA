/**
 * Created by daweima on 6/2/20.
 */

global without sharing class FS_ReceiptRefundDateRule extends Framework.Domain {
    public FS_ReceiptRefundDateRule(List<OrderApi__Receipt__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ReceiptRefundDateRule(sObjectList);
        }
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ReceiptRefundDateRule.class.getName(), 'afterUpdate');
        setPostedDateToToday(records, existingRecords);
        Framework.Log.pop();
    }

    private void setPostedDateToToday(List<OrderApi__Receipt__c> records, Map<Id, SObject> oldMap){
        for (OrderApi__Receipt__c currReceipt : records) {
            // if a refund is posted
            OrderApi__Receipt__c oldReceipt = (oldMap == null) ? null : ((OrderApi__Receipt__c)oldMap.get(currReceipt.Id));
            if (!String.isBlank(currReceipt.OrderApi__Contact__c) && currReceipt.OrderApi__Type__c == 'Refund' &&
                    currReceipt.OrderApi__Is_Refund__c && currReceipt.OrderApi__Is_Posted__c && (oldReceipt == null || !oldReceipt.OrderApi__Is_Posted__c)) {
                currReceipt.OrderApi__Posted_Date__c = System.today();
            }
        }
    }

}