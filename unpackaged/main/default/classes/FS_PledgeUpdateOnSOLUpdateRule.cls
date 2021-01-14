/**
 * Created by cloudwebsolutions on 05-02-2020.
 * Description : This is to calculate the fellow pledgeBalance on updating the fellow on SOL and changing one fellow
 * to another fellow and removing the fellow from the SOL.
 */

global without sharing class FS_PledgeUpdateOnSOLUpdateRule extends Framework.Domain {

    public FS_PledgeUpdateOnSOLUpdateRule(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_PledgeUpdateOnSOLUpdateRule(sObjectList);
        }
    }

    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_PledgeUpdateOnSOLUpdateRule.class.getName(),'Before update');
        updatePledgeAmountOnUpdatingSOL((List<OrderApi__Sales_Order_Line__c>) records,(Map<Id,OrderApi__Sales_Order_Line__c>) existingRecords);
        updatePledgeAmountOnChangingFellow((List<OrderApi__Sales_Order_Line__c>) records,(Map<Id,OrderApi__Sales_Order_Line__c>) existingRecords);
        updatePledgeAmountOnRemovingFellow((List<OrderApi__Sales_Order_Line__c>) records,(Map<Id,OrderApi__Sales_Order_Line__c>) existingRecords);
        Framework.Log.pop();
    }

    private static void updatePledgeAmountOnUpdatingSOL(List<OrderApi__Sales_Order_Line__c> salesOrderLines,Map<Id,OrderApi__Sales_Order_Line__c> oldMap){

        Set<Id> fellowIds = new Set<Id>();
        for(OrderApi__Sales_Order_Line__c salesOrderLine: salesOrderLines){
            if(salesOrderLine.FS_Fellow__c != NULL &&  oldMap.get(salesOrderLine.id).FS_Fellow__c == NULL){
                fellowIds.add(salesOrderLine.FS_Fellow__c);
            }
        }

        FS_FellowsUtil.fellowPledgeAmountCalculations(fellowIds);
    }

    private static void updatePledgeAmountOnChangingFellow(List<OrderApi__Sales_Order_Line__c> records,Map<Id,OrderApi__Sales_Order_Line__c> oldMap){
        Set<Id> fellowIds = new Set<Id>();

        for(OrderApi__Sales_Order_Line__c salesOrderLine : records){
            if(salesOrderLine.FS_Fellow__c != NULL && salesOrderLine.FS_Fellow__c != oldMap.get(salesOrderLine.id).FS_Fellow__c){
                fellowIds.add(salesOrderLine.FS_Fellow__c);
                fellowIds.add(oldMap.get(salesOrderLine.id).FS_Fellow__c);
            }
        }

        FS_FellowsUtil.fellowPledgeAmountCalculations(fellowIds);
    }

    private static void updatePledgeAmountOnRemovingFellow(List<OrderApi__Sales_Order_Line__c> records,Map<Id,OrderApi__Sales_Order_Line__c> oldMap){
        Set<Id> fellowIds = new Set<Id>();

        for(OrderApi__Sales_Order_Line__c salesOrderLine : records){
            if(salesOrderLine.FS_Fellow__c == NULL && oldMap.get(salesOrderLine.id).FS_Fellow__c != NULL){
                fellowIds.add(oldMap.get(salesOrderLine.id).FS_Fellow__c);
            }
        }

        FS_FellowsUtil.fellowPledgeAmountCalculations(fellowIds); 
    }
}