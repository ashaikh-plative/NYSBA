/**
 * Created by Krishna on 23-09-2020.
 */
global without sharing class FS_SustainingMemberSORoutingRule extends Framework.Domain {
    public FS_SustainingMemberSORoutingRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_SustainingMemberSORoutingRule (sObjectList);
        }
    }

    private static String sustainingMemberItemId;
    static{
        List<FS_Constants__mdt> constants = [SELECT FS_Text_Value__c FROM FS_Constants__mdt WHERE MasterLabel = :FS_Constant.SUSTAINING_MEMBER_ITEM_ID LIMIT 1];
        if(constants != null && constants.size() == 1){
            sustainingMemberItemId = constants[0].FS_Text_Value__c;
        }
    }

    public override void afterUpdate (Map<Id, SObject> oldMap) {
        Framework.Log.push(OrderApi__Sales_Order__c.class.getName(),'after update');
        updateSustainingMemberOnContact((List<OrderApi__Sales_Order__c>)records, oldMap);
        Framework.Log.pop();
    }

    private static void updateSustainingMemberOnContact(List<OrderApi__Sales_Order__c> records, Map<Id, SObject> oldMap){
        if(Test.isRunningTest()){
            //Hardcoded the Item name for test class
            sustainingMemberItemId = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Sustaining Member'].Id;
        }
        if(String.isNotBlank(sustainingMemberItemId)){
            Map<Id,Id> salesOrderIdToContactIdMap = new Map<Id,Id>();
            for(OrderApi__Sales_Order__c salesOrder : records) {
                OrderApi__Sales_Order__c oldSalesOrder=(OrderApi__Sales_Order__c)oldMap.get(salesOrder.Id);
                if( salesOrder.OrderApi__Status__c == FS_Constant.SALES_ORDER_CLOSED && salesOrder.OrderApi__Posting_Status__c == FS_Constant.SALES_ORDER_POSTED &&
                        salesOrder.OrderApi__Posting_Status__c != oldSalesOrder.OrderApi__Posting_Status__c
                        && salesOrder.OrderApi__Contact__c != null) {
                    salesOrderIdToContactIdMap.put(salesOrder.Id,salesOrder.OrderApi__Contact__c);
                }
            }

            if(!salesOrderIdToContactIdMap.isEmpty()){
                Map<Id,Contact> contactsToBeUpdatedMap = new Map<Id,Contact>();
                for(OrderApi__Sales_Order_Line__c salesLineObj: getSalesOrderLinesBySoId(salesOrderIdToContactIdMap.keySet())){
                    Contact conObj = new Contact();
                    conObj.Id = salesOrderIdToContactIdMap.get(salesLineObj.OrderApi__Sales_Order__c);
                    conObj.FS_Sustaining_Member__c =true;
                    contactsToBeUpdatedMap.put(conObj.Id, conObj);
                }

                update contactsToBeUpdatedMap.values();
            }
        }
    }

    private static List<OrderApi__Sales_Order_Line__c> getSalesOrderLinesBySoId(Set<Id> soIds){
        return [SELECT Id,Name,OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Item__c =:sustainingMemberItemId
        AND OrderApi__Sales_Order__c IN : soIds];
    }
}