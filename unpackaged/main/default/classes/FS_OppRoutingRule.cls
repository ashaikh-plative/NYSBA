/**
 * Created by Gopi on 10-10-2019.
 */
global without sharing class FS_OppRoutingRule extends Framework.Domain {
    private static final String OPPORTUNITY_STAGE_NAME = 'Closed Won';
    public FS_OppRoutingRule(List<Opportunity> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_OppRoutingRule(sObjectList);
        }
    }
    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_OppRoutingRule.class.getName(), 'After update');
        FS_OppRoutingRule.insertSOLines((List<Opportunity>) records, existingRecords);
        Framework.Log.pop();
    }
    private static void insertSOLines(List<Opportunity> Opportunities,Map<Id,SObject> existingRecords) {
        Set<Id> updatedOppIds = new Set<Id>();
        // Adding 'Closed Won' updated OpportunityIds to the updatedOppIds set
        for (Opportunity Opp : Opportunities) {
            Opportunity oldOpp = (Opportunity) existingRecords.get(Opp.Id);
            if (oldOpp.StageName != OPPORTUNITY_STAGE_NAME && Opp.StageName == OPPORTUNITY_STAGE_NAME) {
                updatedOppIds.add(Opp.Id);
            }
        }
        List<Opportunity> OppList = [SELECT Id,StageName,AccountId,ContactId,
        (SELECT Id,OpportunityId,Product2Id,UnitPrice,Quantity FROM OpportunityLineItems WHERE Product2Id != NULL),
        (SELECT Id,Contact.Name,ContactId FROM OpportunityContactRoles WHERE IsPrimary = TRUE)
        FROM Opportunity WHERE Id = :updatedOppIds];
        Set<Id> productIds = new Set<Id>();
        //Adding ProductIds(in set) to use in querying childs
        for (Opportunity opportunity : OppList) {
            for (OpportunityLineItem opLItem : Opportunity.OpportunityLineItems) {
                productIds.add(opLItem.Product2Id);
            }
        }
        Map<Id,OrderApi__Item__c> prodItemMap = new Map<Id,OrderApi__Item__c>();
        Map<Id,Product2> prodMap = new Map<Id,Product2>([SELECT Id,(SELECT Id FROM Items__r) FROM Product2 WHERE Id =:productIds]);
        //Mapping product and corresponding item childs
        for(Product2 prod : prodMap.values()){
            if(prod.Items__r.size()>0){
                prodItemMap.put(prod.Id,prod.Items__r[0]);
            }
        }
        Map<Id, OrderApi__Sales_Order__c> oppIdSOMap = new Map<Id, OrderApi__Sales_Order__c>();
        for (Opportunity op : OppList) {
            if (op.OpportunityLineItems.size() > 0){
                for (OpportunityLineItem opLItem : op.OpportunityLineItems) {
                    //Mapping Sales Order,OpportunityId if map doesn't contain sales order for OpportunityId
                    if (!oppIdSOMap.containsKey(op.Id) && opLItem.Product2Id != null && prodItemMap.get(opLItem.Product2Id) != null) {
                        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
                        salesOrder.OrderApi__Account__c = op.AccountId;
                        salesOrder.FS_Opportunity__c = op.Id;
                        //Checking if primary contact exists for populating on SalesOrder Contact field
                        if ((op.OpportunityContactRoles.size() > 0) && op.OpportunityContactRoles[0].ContactId != null) {
                            salesOrder.OrderApi__Contact__c = op.OpportunityContactRoles[0].ContactId;
                        }
                        salesOrder.OrderApi__Status__c = 'Open';
                        oppIdSOMap.put(op.Id, salesOrder);
                    }
                }
            }
        }
        if (!oppIdSOMap.values().isEmpty()) {
            insert oppIdSOMap.values();
            List<OrderApi__Sales_Order_Line__c> soLineList = new List<OrderApi__Sales_Order_Line__c>();
            for (Opportunity op : OppList) {
                if (op.OpportunityLineItems.size() > 0) {
                    for (OpportunityLineItem opLItem : op.OpportunityLineItems) {
                        if (opLItem.Product2Id != null && prodItemMap.get(opLItem.Product2Id) != null) {
                            OrderApi__Item__c item = prodItemMap.get(opLItem.Product2Id);
                            OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c();
                            soLine.OrderApi__Item__c = item.Id;
                            soLine.OrderApi__Sales_Order__c = oppIdSOMap.get(op.Id).Id;
                            soLine.OrderApi__Quantity__c = opLItem.Quantity;
                            soLine.OrderApi__Sale_Price__c = opLItem.UnitPrice;
                            soLine.OrderApi__Price_Override__c = true;
                            soLineList.add(soLine);
                        }
                    }
                }
            }
            if (!soLineList.isEmpty()) {
                insert soLineList;
            }
            for (OrderApi__Sales_Order__c so : oppIdSOMap.values()) {
                so.OrderApi__Status__c = 'Closed';
                so.OrderApi__Posting_Entity__c = 'Invoice';
                so.OrderApi__Posting_Status__c = 'Pending';
                so.OrderApi__Schedule_Type__c = 'Simple Invoice';
            }
            update oppIdSOMap.values();
            for (OrderApi__Sales_Order__c so : oppIdSOMap.values()) {
                so.OrderApi__Posting_Status__c = 'Posted';
            }
            update oppIdSOMap.values();
        }
    }
}