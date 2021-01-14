/**
 * Created by Anvesh on 02-Sep-20.
 */

global class FS_EventBundleRoutingRule extends Framework.Domain{

    public FS_EventBundleRoutingRule(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_EventBundleRoutingRule(sObjectList);
        }
    }
    public override void afterInsert(){
        Framework.Log.push(FS_EventBundleRoutingRule.class.getName(), 'afterInsert');
        addSalesOrderLines((List<OrderApi__Sales_Order_Line__c>)records);
        Framework.Log.pop();
    }

    public override void afterDelete(){
        Framework.Log.push(FS_EventBundleRoutingRule.class.getName(), 'afterDelete');
        deleteSalesOrderLines((List<OrderApi__Sales_Order_Line__c>)records);
        Framework.Log.pop();
    }
    public override void afterUpdate(Map<Id, SObject> oldMap){
        Framework.Log.push(FS_EventBundleRoutingRule.class.getName(), 'afterUpdate');
        List<OrderApi__Sales_Order_Line__c> salesOrderLinesToBeDeleted = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> salesOrderLinesToBeCreated = new List<OrderApi__Sales_Order_Line__c>();
        for(OrderApi__Sales_Order_Line__c sol : (List<OrderApi__Sales_Order_Line__c>)records){
            OrderApi__Sales_Order_Line__c oldSol = (OrderApi__Sales_Order_Line__c)oldMap.get(sol.Id);
            if(sol.OrderApi__Item__c  != oldSol.OrderApi__Item__c) {
                salesOrderLinesToBeDeleted.add(oldSol);
                salesOrderLinesToBeCreated.add(sol);
            }
        }
        if(!salesOrderLinesToBeDeleted.isEmpty()){
            deleteSalesOrderLines(salesOrderLinesToBeDeleted);
        }
        if(!salesOrderLinesToBeCreated.isEmpty()){
            addSalesOrderLines(salesOrderLinesToBeCreated);
        }
        Framework.Log.pop();
    }

    private static void addSalesOrderLines(List<OrderApi__Sales_Order_Line__c> records){
        Map<Id, OrderApi__Sales_Order_Line__c> itemToSOLIds = new Map<Id, OrderApi__Sales_Order_Line__c>();

        for(OrderApi__Sales_Order_Line__c salesOrderLine: records){
            itemToSOLIds.put(salesOrderLine.OrderApi__Item__c,salesOrderLine);
        }
        Map<Id,FS_Event_Bundle__c> eventBundlesList = new Map<Id,FS_Event_Bundle__c>([SELECT Id,FS_Parent_Item__c,FS_Child_Item__c,
                FS_Child_Item__r.OrderApi__Is_Active__c,FS_Schedule_Item_Id__c,FS_Ticket_Type_Id__c FROM FS_Event_Bundle__c WHERE FS_Parent_Item__c IN: itemToSOLIds.keySet()
        AND FS_Child_Item__r.OrderApi__Is_Active__c = TRUE ]);

        List<OrderApi__Sales_Order_Line__c> salesOrderBundleLinesToInsert = new List<OrderApi__Sales_Order_Line__c>();
        if(!eventBundlesList.isEmpty()){
            for(FS_Event_Bundle__c bundleItem : eventBundlesList.values()){
                if(itemToSOLIds.get(bundleItem.FS_Parent_Item__c) != null){
                    OrderApi__Sales_Order_Line__c soLine = itemToSOLIds.get(bundleItem.FS_Parent_Item__c);
                    if(soLine != null){
                        OrderApi__Sales_Order_Line__c sOrderLine = new OrderApi__Sales_Order_Line__c();
                        sOrderLine.OrderApi__Contact__c = soLine.OrderApi__Contact__c;
                        sOrderLine.OrderApi__Account__c = soLine.OrderApi__Account__c;
                        sOrderLine.OrderApi__Sales_Order__c = soLine.OrderApi__Sales_Order__c;
                        sOrderLine.OrderApi__Item__c = bundleItem.FS_Child_Item__c;
                        sOrderLine.OrderApi__Sales_Order_Line__c = soLine.Id;
                        if(bundleItem.FS_Schedule_Item_Id__c != null){
                            sOrderLine.EventApi__Schedule_Item__c = bundleItem.FS_Schedule_Item_Id__c;
                        }
                        if(bundleItem.FS_Ticket_Type_Id__c != null){
                            sOrderLine.EventApi__Ticket_Type__c = bundleItem.FS_Ticket_Type_Id__c;
                        }
                        salesOrderBundleLinesToInsert.add(sOrderLine);
                    }
                }
            }
            if(!salesOrderBundleLinesToInsert.isEmpty()){
                insert salesOrderBundleLinesToInsert ;
            }
        }
    }

    private static void deleteSalesOrderLines (List<OrderApi__Sales_Order_Line__c> records){
        Map<Id, OrderApi__Sales_Order_Line__c> itemToSalesOrderLines = new Map<Id, OrderApi__Sales_Order_Line__c>();
        Map<Id, OrderApi__Sales_Order_Line__c> soIdToSalesOrderLines  = new Map<Id, OrderApi__Sales_Order_Line__c>();
        Map<Id,Id> parentSolToSalesOrder = new Map<Id,Id>();
        for(OrderApi__Sales_Order_Line__c salesOrderLine: records){
            itemToSalesOrderLines.put(salesOrderLine.OrderApi__Item__c,salesOrderLine);
            soIdToSalesOrderLines.put(salesOrderLine.OrderApi__Sales_Order__c,salesOrderLine);
        }
        Map<Id,FS_Event_Bundle__c> eventBundlesList = new Map<Id,FS_Event_Bundle__c>([SELECT Id,FS_Parent_Item__c,FS_Child_Item__c,
                FS_Child_Item__r.OrderApi__Is_Active__c FROM FS_Event_Bundle__c WHERE FS_Parent_Item__c IN: itemToSalesOrderLines.keySet()
        AND FS_Child_Item__r.OrderApi__Is_Active__c = TRUE ]);
        Map<Id, OrderApi__Sales_Order_Line__c> salesOrderLinesToDelete = new Map<Id, OrderApi__Sales_Order_Line__c>();

        if(!eventBundlesList.isEmpty()){
            for(FS_Event_Bundle__c bundleItem : eventBundlesList.values()){
                if(itemToSalesOrderLines.get(bundleItem.FS_Parent_Item__c) != null){
                    OrderApi__Sales_Order_Line__c soLine = itemToSalesOrderLines.get(bundleItem.FS_Parent_Item__c);
                    if(soLine != null){
                        parentSolToSalesOrder.put(soLine.Id,soLine.OrderApi__Sales_Order__c);
                    }
                }
            }
        }

        Map<Id, OrderApi__Sales_Order__c>  salesOrderToSolMap = new Map<Id, OrderApi__Sales_Order__c>([SELECT Id,(SELECT
                Id,OrderApi__Item__c,OrderApi__Contact__c,OrderApi__Account__c,OrderApi__Sales_Order__c,OrderApi__Sales_Order_Line__c
                FROM OrderApi__Sales_Order_Lines__r WHERE OrderApi__Sales_Order_Line__c IN :parentSolToSalesOrder.keySet())
                FROM OrderApi__Sales_Order__c WHERE Id IN : parentSolToSalesOrder.values()]);
        if(!salesOrderToSolMap.isEmpty()){
            for(OrderApi__Sales_Order__c sOrder :salesOrderToSolMap.values()){
                for(OrderApi__Sales_Order_Line__c sLine : sOrder.OrderApi__Sales_Order_Lines__r){
                    if (parentSolToSalesOrder.get(sLine.OrderApi__Sales_Order_Line__c) != null &&
                            sLine.OrderApi__Sales_Order_Line__c == soIdToSalesOrderLines.get(sLine.OrderApi__Sales_Order__c).Id){
                        salesOrderLinesToDelete.put(sLine.Id,sLine);
                    }
                }
            }
            if(!salesOrderLinesToDelete.isEmpty()){
                delete salesOrderLinesToDelete.values();
            }
        }
    }
}