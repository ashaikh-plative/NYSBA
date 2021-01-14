/**
 * Created by cloudwebsolutions on 13-01-2020.
 */

global without sharing class FS_AutoPopulateOrderDetails extends Framework.Domain {
    public FS_AutoPopulateOrderDetails(List<FS_Order_Fulfillment__c > sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_AutoPopulateOrderDetails(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_AutoPopulateOrderDetails.class.getName(), 'Before Insert');
        populateOrderAndOrderLineIds((FS_Order_Fulfillment__c[]) records);
        Framework.Log.pop();
    }

    private static void populateOrderAndOrderLineIds(List<FS_Order_Fulfillment__c> fulfillments) {
        Set<Id> orderTrackingIds = new Set<Id>();

        //Storing the orderTracking ids into a set
        for (FS_Order_Fulfillment__c fulfillment : fulfillments) {
            orderTrackingIds.add(fulfillment.FS_Order_Tracking__c);
        }

        //Retrieving the orderTracking record associated with the orderfulfillments.
        Map<Id, FS_Order_Tracking__c> orderTrackingMap = new Map<Id, FS_Order_Tracking__c>([
                SELECT FS_Sales_Order__c,FS_Sales_Order_Line__c
                FROM FS_Order_Tracking__c
                WHERE Id IN:orderTrackingIds
                AND FS_Sales_Order__c != NULL
        ]);


        //Updating the salesOrder and salesOrderline ids to the fulfillment record
        if (orderTrackingMap != NULL && !orderTrackingMap.isEmpty()) {
            for (FS_Order_Fulfillment__c fulfillment : fulfillments) {
                if (orderTrackingMap.containsKey(fulfillment.FS_Order_Tracking__c)) {
                    fulfillment.FS_Order__c = orderTrackingMap.get(fulfillment.FS_Order_Tracking__c).FS_Sales_Order__c;
                    fulfillment.FS_Order_Line__c = orderTrackingMap.get(fulfillment.FS_Order_Tracking__c).FS_Sales_Order_Line__c;
                }
            }
        }
    }
}