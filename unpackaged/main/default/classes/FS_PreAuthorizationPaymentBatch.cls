/**
 * Created by cloudwebsolutions on 03-12-2019.
 */
global class FS_PreAuthorizationPaymentBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    private static final String TYPE_E_PAYMENT_LINE = 'ePaymentLine';
    private static final String TYPE_E_PAYMENT_LINE_TAX = 'tax';
    private static final String TYPE_E_PAYMENT_LINE_SHIPPING = 'shipping';
    private static final String OF_AMS_ERROR_MESSAGE = 'OF_AMS_ERROR_MESSAGE';
    private static final String OF_AMS_EXCEPTION_MESSAGE = 'OF_AMS_EXCEPTION_MESSAGE';
    public static final String OF_AMS_HIGH_QUANTITY_MESSAGE = 'OF_AMS_HIGH_QUANTITY_MESSAGE';
    private static final String OF_AMS_QUANTITY_MESSAGE = 'OF_AMS_QUANTITY_MESSAGE';
    private static final String OF_STATUS_EXCEPTION = 'Exception';
    private static final String OF_STATUS_HIGH_QUANTITY = 'HighQuantity';
    private static final String OF_STATUS_QUANTITY = 'Quantity';
    private static final String OF_STATUS_PROCESSED = 'Processed';
    private static final String OF_AMS_STATUS_ERROR = 'Error';
    private static final String OF_AMS_STATUS_SUBMITTED = 'ePayment Submitted';
    private static final String OF_AMS_STATUS_NO_E_PAYMENT = 'No ePayment';
    private Set<Id> soIdsToUpdateEpayments;
    private static final Date TODAYS_DATE = System.today();

    private Map<Id, Id> orderFulfillmentIdSOLIdMap = new Map<Id, Id>();
    private Map<Id, String> ofIdStatusMap = new Map<Id, String>();
    private Map<Id, Set<Id>> soIdSOLIdsMap = new Map<Id, Set<Id>>();
    private Map<Id, OrderApi__EPayment_Line__c> solIdClonedEPaymentLineMap = new Map<Id, OrderApi__EPayment_Line__c>();
    private Map<Id, OrderApi__EPayment_Line__c> solIdClonedTaxEPaymentLineMap = new Map<Id, OrderApi__EPayment_Line__c>();
    private Map<Id, OrderApi__EPayment__c> soIdClonedEPaymentMap = new Map<Id, OrderApi__EPayment__c>();
    private Map<Id, OrderApi__EPayment_Line__c> clonedShippingEPaymentLineMap = new Map<Id, OrderApi__EPayment_Line__c>();
    private Map<Id, String> solIdErrorMap = new Map<Id, String>();
    private Map<String, String> amsSyncMessagesMap = new Map<String, String>();

    global FS_PreAuthorizationPaymentBatch() {
        soIdsToUpdateEpayments = new Set<Id>();
        for (Custom_Pre_Auth_Message__mdt synMessage : [SELECT MasterLabel,FS_AMS_Sync_Message__c FROM Custom_Pre_Auth_Message__mdt]) {
            amsSyncMessagesMap.put(synMessage.MasterLabel, synMessage.FS_AMS_Sync_Message__c);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id,FS_Order__c,FS_Order_Line__c,FS_Order_Line__r.OrderApi__Quantity__c,' +
                'FS_Order_Tracking__c,FS_Order_Tracking__r.FS_Total_Quantity_Shipped__c,FS_Order_Tracking__r.FS_Quantity__c,' +
                'FS_Quantity_Shipped__c,FS_Tracking_Number__c FROM FS_Order_Fulfillment__c WHERE FS_Status__c = \'New\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        orderFulfillmentIdSOLIdMap.clear();
        ofIdStatusMap.clear();
        soIdSOLIdsMap.clear();
        solIdClonedEPaymentLineMap.clear();
        solIdClonedTaxEPaymentLineMap.clear();
        soIdClonedEPaymentMap.clear();
        clonedShippingEPaymentLineMap.clear();
        solIdErrorMap.clear();

        Map<Id, FS_Order_Fulfillment__c> orderFulfillmentMap = new Map<Id, FS_Order_Fulfillment__c>();//Contains OrderFullfillmentId and fullfillObject
        Map<Id, Set<Id>> solIdOFIdsMap = new Map<Id, Set<Id>>();//Map of Sales Order Line Id and List of OrderFullfillment Fulfillment Ids
        Map<Id, Set<FS_Order_Fulfillment__c>> solIdOFMap = new Map<Id, Set<FS_Order_Fulfillment__c>>();
        Map<Id, Decimal> soIdItemsQuantity = new Map<Id, Decimal>();
        Map<Id, Decimal> soIdOrderedQuantityMap = new Map<Id, Decimal>();

        try {
            this.getRequiredData(scope, orderFulfillmentMap, orderFulfillmentIdSOLIdMap, solIdOFIdsMap, solIdOFMap, soIdItemsQuantity, soIdOrderedQuantityMap);
            Map<Id, List<OrderApi__EPayment__c>> soIdEPaymentMap = getEPayments(soIdSOLIdsMap.keySet());

            //Fetching the original epayment based on sourceepayment field and transactiontype
            for (Id soId : soIdSOLIdsMap.keySet()) {
                Set<Id> solIds = soIdSOLIdsMap.get(soId);
                OrderApi__EPayment__c originalEPayment = null;
                if (soIdEPaymentMap.get(soId) != null) {
                    for (OrderApi__EPayment__c ePayment : soIdEPaymentMap.get(soId)) {
                        if (ePayment.OrderApi__EPayment__c == null && ePayment.OrderApi__Transaction_Type__c == 'Authorization') {
                            originalEPayment = ePayment;
                        }
                    }
                }


                if (originalEPayment != null) {
                    Integer count = solIdClonedEPaymentLineMap.size();
                    for (Id solId : solIds) {
                        this.processPaymentForItems(solId, orderFulfillmentMap, originalEPayment, solIdOFIdsMap);
                    }

                    if (solIdClonedEPaymentLineMap.size() > count) {
                        OrderApi__EPayment__c clonedEPayment = originalEPayment.clone(false, true, false, false);
                        clonedEPayment.OrderApi__Date__c = TODAYS_DATE;
                        clonedEPayment.OrderApi__EPayment__c = originalEPayment.Id;
                        soIdClonedEPaymentMap.put(soId, clonedEPayment);
                        this.processShipping(originalEPayment, soId, clonedShippingEPaymentLineMap);
                    }
                }
            }

            this.insertEPayments();
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '===============>' + e.getMessage());
        }
    }

    private void processShipping(OrderApi__EPayment__c originalEPayment, Id soId,
            Map<Id, OrderApi__EPayment_Line__c> clonedShippingEPaymentLineMap) {
        try {
            OrderApi__EPayment_Line__c originalShippingEPaymentLine = null;
            for (OrderApi__EPayment_Line__c ePaymentLine : originalEPayment.OrderApi__EPayment_Lines__r) {
                if (ePaymentLine.OrderApi__Item__r.OrderApi__Is_Shipping_Rate__c) {
                    originalShippingEPaymentLine = ePaymentLine;
                    break;
                }
            }

            if (originalShippingEPaymentLine != null) {
                OrderApi__EPayment_Line__c clonedShippingEPaymentLine = originalShippingEPaymentLine.clone(false, true, false, false);
                clonedShippingEPaymentLineMap.put(soId, clonedShippingEPaymentLine);
            }

        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '=======================>' + e.getMessage());
        }
    }

    private void getRequiredData(List<SObject> scope, Map<Id, FS_Order_Fulfillment__c> orderFulfillmentMap,
            Map<Id, Id> orderFulfillmentIdSOLIdMap, Map<Id, Set<Id>> solIdOFIdsMap, Map<Id, Set<FS_Order_Fulfillment__c>> solIdOFMap,
            Map<Id, Decimal> soIdItemsQuantity, Map<Id, Decimal> soIdOrderedQuantityMap) {

        try {
            for (FS_Order_Fulfillment__c fulfillment : (List<FS_Order_Fulfillment__c>) scope) {
                if (fulfillment.FS_Order_Line__c != null && fulfillment.FS_Order__c != null) {
                    orderFulfillmentIdSOLIdMap.put(fulfillment.Id, fulfillment.FS_Order_Line__c);
                    if (fulfillment.FS_Quantity_Shipped__c == null || fulfillment.FS_Quantity_Shipped__c <= 0) {
                        this.addOFStatusInfo(OF_STATUS_QUANTITY, new List<Id>{fulfillment.Id});
                        continue;
                    }
                    orderFulfillmentMap.put(fulfillment.Id, fulfillment);



                    if (soIdSOLIdsMap.containsKey(fulfillment.FS_Order__c)) {
                        soIdSOLIdsMap.get(fulfillment.FS_Order__c).add(fulfillment.FS_Order_Line__c);
                    } else {
                        soIdSOLIdsMap.put(fulfillment.FS_Order__c, new Set<Id>{fulfillment.FS_Order_Line__c});
                    }

                    if (solIdOFIdsMap.containsKey(fulfillment.FS_Order_Line__c)) {
                        solIdOFIdsMap.get(fulfillment.FS_Order_Line__c).add(fulfillment.Id);
                        solIdOFMap.get(fulfillment.FS_Order_Line__c).add(fulfillment);
                    } else {
                        solIdOFIdsMap.put(fulfillment.FS_Order_Line__c, new Set<Id>{fulfillment.Id});
                        solIdOFMap.put(fulfillment.FS_Order_Line__c, new Set<FS_Order_Fulfillment__c>{fulfillment});
                    }
                }
            }


            //Fetching the ordered quantity based on ordertrackings
            for (FS_Order_Tracking__c relatedOrderTracking : [SELECT Id,FS_Sales_Order_Line__c,FS_Sales_Order__c,FS_Quantity__c
            FROM FS_Order_Tracking__c WHERE FS_Sales_Order__c IN:soIdSOLIdsMap.keySet()]) {
                if (soIdOrderedQuantityMap.containsKey(relatedOrderTracking.FS_Sales_Order__c)) {
                    soIdOrderedQuantityMap.put(relatedOrderTracking.FS_Sales_Order__c,
                            soIdOrderedQuantityMap.get(relatedOrderTracking.FS_Sales_Order__c) + Decimal.valueOf(relatedOrderTracking.FS_Quantity__c));
                } else {
                    soIdOrderedQuantityMap.put(relatedOrderTracking.FS_Sales_Order__c, Decimal.valueOf(relatedOrderTracking.FS_Quantity__c));
                }
            }


            //Fetching the shipped quantity based on the orderFulfillments for the soId
            for (Id salesOrderId : soIdSOLIdsMap.keySet()) {
                Decimal shippedQuantity = 0;
                for (Id lineId : soIdSOLIdsMap.get(salesOrderId)) {
                    for (FS_Order_Fulfillment__c relatedFulfillment : solIdOFMap.get(lineId)) {
                        if (relatedFulfillment.FS_Quantity_Shipped__c != null) {
                            shippedQuantity += relatedFulfillment.FS_Order_Tracking__r.FS_Total_Quantity_Shipped__c;
                        }
                    }
                }
                soIdItemsQuantity.put(salesOrderId, shippedQuantity);
            }


            for (Id salesOrderId : soIdSOLIdsMap.keySet()) {
                if (soIdOrderedQuantityMap.get(salesOrderId) > soIdItemsQuantity.get(salesOrderId)) {
                    Set<Id> salesOrderLineIds = soIdSOLIdsMap.get(salesOrderId);
                    for (Id relatedSalesOrderLine : salesOrderLineIds) {
                        for (Id relatedOrderfulfillmentId : solIdOFIdsMap.get(relatedSalesOrderLine)) {
                            if (orderFulfillmentIdSOLIdMap.containsKey(relatedOrderfulfillmentId)) {
                                orderFulfillmentIdSOLIdMap.remove(relatedOrderfulfillmentId);
                            }
                        }
                    }
                    soIdSOLIdsMap.remove(salesOrderId);
                }
            }


        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '==================>' + e.getMessage());
        }
    }

    private static Map<Id, List<OrderApi__EPayment__c>> getEPayments(Set<Id> soIds) {
        Map<Id, List<OrderApi__EPayment__c>> soIdEPaymentMap = new Map<Id, List<OrderApi__EPayment__c>>();
        try {
            String ePaymentFields = '';
            Map < String, Schema.SObjectField > fields = Schema.getGlobalDescribe().get('OrderApi__EPayment__c').getDescribe().fields.getMap();
            for (String field : fields.keySet()) {
                if (field == 'OrderApi__State__c' || field == 'OrderApi__Message__c'){
                    continue;
                }
                if (ePaymentFields == '') {
                    ePaymentFields = field;
                } else {
                    ePaymentFields += ',' + field;
                }
            }

            String ePaymentLineFields = '';
            fields = Schema.getGlobalDescribe().get('OrderApi__EPayment_Line__c').getDescribe().fields.getMap();
            for (String field : fields.keySet()) {
                if (ePaymentLineFields == '') {
                    ePaymentLineFields = field;
                } else {
                    ePaymentLineFields += ',' + field;
                }
            }

            String salesOrderIds = '';
            for (Id soId : soIds) {
                if (salesOrderIds == '') {
                    salesOrderIds = '\'' + soId + '\'';
                } else {
                    salesOrderIds += ', \'' + soId + '\'';
                }
            }
            List<OrderApi__EPayment__c> ePaymentsList = new List<OrderApi__EPayment__c>();
            String query = '';
            if (String.isNotBlank(salesOrderIds)) {
                query = 'SELECT ' + ePaymentFields + ',(SELECT ' + ePaymentLineFields + ',OrderApi__Item__r.OrderApi__Is_Shipping_Rate__c ' +
                        'FROM OrderApi__EPayment_Lines__r) FROM OrderApi__EPayment__c  WHERE OrderApi__Sales_Order__c IN (' + salesOrderIds + ')';
                ePaymentsList = Database.query(query);
            }

            for (OrderApi__EPayment__c ePayment : ePaymentsList) {
                if (soIdEPaymentMap.containsKey(ePayment.OrderApi__Sales_Order__c)) {
                    soIdEPaymentMap.get(ePayment.OrderApi__Sales_Order__c).add(ePayment);
                } else {
                    soIdEPaymentMap.put(ePayment.OrderApi__Sales_Order__c, new List<OrderApi__EPayment__c>{
                            ePayment
                    });
                }
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '=======================>' + e.getMessage());
        }
        return soIdEPaymentMap;
    }

    private void processPaymentForItems(Id solId, Map<Id, FS_Order_Fulfillment__c> orderFulfillmentMap, OrderApi__EPayment__c originalEPayment,
            Map<Id, Set<Id>> solIdOFIdsMap) {
        Decimal shippedQuantity = 0;
        List<Id> sifIdList = new List<Id>();

        try {
            //Adding error message if shipped quantity is greater than the ordered quantity
            Set<Id> ofIds = solIdOFIdsMap.get(solId);
            for (Id ofId : ofIds) {
                FS_Order_Fulfillment__c fulfillment = orderFulfillmentMap.get(ofId);
                if (fulfillment != null) {
                    if (fulfillment.FS_Quantity_Shipped__c != null && fulfillment.FS_Quantity_Shipped__c > 0) {
                        Integer orderTrackingQuantity = 0;
                        try {
                            orderTrackingQuantity = Integer.valueOf(fulfillment.FS_Order_Tracking__r.FS_Quantity__c);
                        } catch (Exception e) {

                        }
                        //Checking if the Ordered quantity is greater than the shipped quantity
                        if (orderTrackingQuantity < fulfillment.FS_Order_Tracking__r.FS_Total_Quantity_Shipped__c) {
                            if (String.isBlank(solIdErrorMap.get(solId))){
                                solIdErrorMap.put(solId, amsSyncMessagesMap.get(OF_AMS_ERROR_MESSAGE));
                            }
                            this.addOFStatusInfo(OF_STATUS_HIGH_QUANTITY, new List<Id>{ofId});
                        } else {
                            //get shipped quantity
                            shippedQuantity += fulfillment.FS_Quantity_Shipped__c;
                            sifIdList.add(ofId);
                        }
                    } else {
                        this.addOFStatusInfo(OF_STATUS_QUANTITY, new List<Id>{ofId});
                    }
                }
            }


            if (shippedQuantity > 0 && originalEPayment != null) {
                List<OrderApi__EPayment_Line__c> ePaymentLines = originalEPayment.OrderApi__EPayment_Lines__r;
                OrderApi__EPayment_Line__c originalEPaymentLine = null;
                OrderApi__EPayment_Line__c originalTaxEPaymentLine = null;

                //Getting the original epayment line of Sales Order Line
                for (OrderApi__EPayment_Line__c ePaymentLine : ePaymentLines) {
                    if (ePaymentLine.OrderApi__Sales_Order_Line__c == solId) {
                        originalEPaymentLine = ePaymentLine;
                        break;
                    }
                }


                if (originalEPaymentLine != null) {
                    //Getting the original tax and shipping epayment lines of Sales Order Line
                    for (OrderApi__EPayment_Line__c ePaymentLine : ePaymentLines) {
                        if (ePaymentLine.OrderApi__EPayment_Line__c == originalEPaymentLine.Id && ePaymentLine.OrderApi__Is_Tax__c) {
                            originalTaxEPaymentLine = ePaymentLine;
                            break;
                        }
                    }


                    //Cloning the original epayment line and updating the shipped quantity & original epayment line Id
                    OrderApi__EPayment_Line__c clonedEPaymentLine = originalEPaymentLine.clone(false, true, false, false);
                    clonedEPaymentLine.OrderApi__EPayment_Line__c = originalEPaymentLine.Id;
                    solIdClonedEPaymentLineMap.put(solId, clonedEPaymentLine);

                    if (originalTaxEPaymentLine != null) {
                        //Cloning the original tax epayment line and updating the tax amount
                        OrderApi__EPayment_Line__c clonedTaxEPaymentLine = originalTaxEPaymentLine.clone(false, true, false, false);
                        solIdClonedTaxEPaymentLineMap.put(solId, clonedTaxEPaymentLine);
                    }
                }
            }

            // call addOFStatusInfo with process status
            this.addOFStatusInfo(OF_STATUS_PROCESSED, sifIdList);
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '================>' + e.getMessage());
            if (String.isBlank(solIdErrorMap.get(solId))) {
                solIdErrorMap.put(solId, amsSyncMessagesMap.get(OF_AMS_ERROR_MESSAGE));
                this.addOFStatusInfo(OF_STATUS_EXCEPTION, sifIdList);
                shippedQuantity = 0;
            }
        }
    }


    private void addOFStatusInfo(String msg, List<Id> OFIdList) {
        for (Id ofId : OFIdList) {
            ofIdStatusMap.put(ofId, msg);
        }
    }


    private void insertEPayments() {
        Map<Id, String> soIdErrorMap = new Map<Id, String>();
        Map<Id, Id> solSoIdMap = new Map<Id, Id>();
        try {
            for (Id soId : soIdSOLIdsMap.keySet()) {
                for (Id solId : soIdSOLIdsMap.get(soId)) {
                    solSoIdMap.put(solId, soId);
                }
            }


            if (!soIdClonedEPaymentMap.values().isEmpty()) {
                Database.SaveResult[] srList = Database.insert(soIdClonedEPaymentMap.values(), false);
                if (srList != null) {
                    for (Integer index = 0; index < srList.size(); index++) {
                        if (!srList[index].isSuccess()) {
                            String error = null;
                            for (Database.Error err : srList[index].getErrors()) {
                                error = String.isNotBlank(error) ? error + '\n' : '';
                                error = error + err.getStatusCode() + ': ' + err.getMessage();
                            }
                            soIdErrorMap.put(soIdClonedEPaymentMap.values()[index].OrderApi__Sales_Order__c, error);
                        }
                    }
                }

                //Iterating by for all the Sales orders
                for (Id soId : soIdSOLIdsMap.keySet()) {
                    //Getting the cloned ePayment record of sales order
                    OrderApi__EPayment__c clonedEPayment = soIdClonedEPaymentMap.get(soId);
                    soIdsToUpdateEpayments.add(soId);//Adding SalesOrder Id to the set and passing it through the queueable class
                    for (Id solId : soIdSOLIdsMap.get(soId)) {
                        if (solIdClonedEPaymentLineMap.get(solId) != null) {
                            OrderApi__EPayment_Line__c clonedEPaymentLine = solIdClonedEPaymentLineMap.get(solId);
                            //Updating the E-Payment field of cloned ePayment Line with the Id of cloned ePayment
                            clonedEPaymentLine.OrderApi__EPayment__c = clonedEPayment.Id;
                        }
                    }
                    if (clonedShippingEPaymentLineMap.get(soId) != null) {
                        clonedShippingEPaymentLineMap.get(soId).OrderApi__EPayment__c = clonedEPayment.Id;
                    }
                }

                if (!solIdClonedEPaymentLineMap.values().isEmpty()) {
                    this.insertEPaymentLines(TYPE_E_PAYMENT_LINE, null);

                    for (Id solId : solIdClonedEPaymentLineMap.keySet()) {
                        OrderApi__EPayment_Line__c clonedEPaymentLine = solIdClonedEPaymentLineMap.get(solId);
                        if (clonedEPaymentLine != null) {
                            if (solIdClonedTaxEPaymentLineMap.get(solId) != null) {
                                OrderApi__EPayment_Line__c clonedTaxEPaymentLine = solIdClonedTaxEPaymentLineMap.get(solId);
                                //Updating the E-Payment field of cloned ePayment Line with the Id of cloned ePayment
                                clonedTaxEPaymentLine.OrderApi__EPayment__c = clonedEPaymentLine.OrderApi__EPayment__c;
                                //Updating the Parent EPayment Line of cloned tax ePayment Line with the Id of cloned ePayment Line
                                clonedTaxEPaymentLine.OrderApi__EPayment_Line__c = clonedEPaymentLine.Id;
                            }
                            //We may not need below if block code
                            if (clonedShippingEPaymentLineMap.get(solId) != null) {
                                OrderApi__EPayment_Line__c clonedShipEPaymentLine = clonedShippingEPaymentLineMap.get(solId);
                                //Updating the E-Payment field of cloned ePayment Line with the Id of cloned ePayment
                                clonedShipEPaymentLine.OrderApi__EPayment__c = clonedEPaymentLine.OrderApi__EPayment__c;
                                //Updating the Parent EPayment Line of cloned shipping ePayment Line with the Id of cloned ePayment Line
                                clonedShipEPaymentLine.OrderApi__EPayment_Line__c = clonedEPaymentLine.Id;
                            }
                        }
                    }
                }

                if (!solIdClonedTaxEPaymentLineMap.values().isEmpty()) {
                    this.insertEPaymentLines(TYPE_E_PAYMENT_LINE_TAX, null);
                }

                if (!clonedShippingEPaymentLineMap.values().isEmpty()) {
                    this.insertEPaymentLines(TYPE_E_PAYMENT_LINE_SHIPPING, soIdErrorMap);
                }
            }

            for (Id solId : solIdErrorMap.keySet()) {
                if (solSoIdMap.get(solId) != null) {
                    String error = soIdErrorMap.get(solSoIdMap.get(solId));
                    error = String.isNotBlank(error) ? error + '\n' : '';
                    error = error + solIdErrorMap.get(solId);
                    soIdErrorMap.put(solSoIdMap.get(solId), error);
                }
            }

            Map<Id, OrderApi__EPayment__c> deleteEPaymentsMap = new Map<Id, OrderApi__EPayment__c>();
            for (Id soId : soIdErrorMap.keySet()) {
                if (soIdClonedEPaymentMap.get(soId) != null && soIdClonedEPaymentMap.get(soId).Id != null) {
                    deleteEPaymentsMap.put(soId, soIdClonedEPaymentMap.get(soId));
                    soIdClonedEPaymentMap.remove(soId);
                }
            }


            if (!deleteEPaymentsMap.values().isEmpty()) {
                try {
                    delete deleteEPaymentsMap.values();
                } catch (Exception e) {
                }
            }

            List<FS_Order_Fulfillment__c> ofToUpdate = new List<FS_Order_Fulfillment__c>();
            for (Id ofId : orderFulfillmentIdSOLIdMap.keySet()) {
                if (orderFulfillmentIdSOLIdMap.get(ofId) != null) {
                    Id solId = orderFulfillmentIdSOLIdMap.get(ofId);
                    if (ofIdStatusMap.get(ofId) == OF_STATUS_QUANTITY || ofIdStatusMap.get(ofId) == OF_STATUS_EXCEPTION) {
                        FS_Order_Fulfillment__c fulfillment = new FS_Order_Fulfillment__c(Id = ofId, FS_Status__c = OF_AMS_STATUS_ERROR);
                        fulfillment.FS_Error_Message__c = ofIdStatusMap.get(ofId) == OF_STATUS_QUANTITY ?
                                amsSyncMessagesMap.get(OF_AMS_QUANTITY_MESSAGE) : amsSyncMessagesMap.get(OF_AMS_EXCEPTION_MESSAGE) + '\n' + amsSyncMessagesMap.get(OF_AMS_ERROR_MESSAGE);
                        ofToUpdate.add(fulfillment);
                    } else if (ofIdStatusMap.get(ofId) == OF_STATUS_HIGH_QUANTITY) {
                        ofToUpdate.add(new FS_Order_Fulfillment__c(Id = ofId,
                                FS_Status__c = OF_AMS_STATUS_ERROR, FS_Error_Message__c = amsSyncMessagesMap.get(OF_AMS_HIGH_QUANTITY_MESSAGE)));
                    } else if (ofIdStatusMap.get(ofId) == OF_STATUS_PROCESSED) {
                        FS_Order_Fulfillment__c fulfillment = new FS_Order_Fulfillment__c(Id = ofId);
                        if (solSoIdMap.get(solId) != null && String.isNotBlank(soIdErrorMap.get(solSoIdMap.get(solId)))) {
                            fulfillment.FS_Status__c = OF_AMS_STATUS_ERROR;
                            fulfillment.FS_Error_Message__c = soIdErrorMap.get(solSoIdMap.get(solId)).contains(amsSyncMessagesMap.get(OF_AMS_ERROR_MESSAGE)) ?
                                    soIdErrorMap.get(solSoIdMap.get(solId))
                                    : soIdErrorMap.get(solSoIdMap.get(solId)) + '\n' + amsSyncMessagesMap.get(OF_AMS_ERROR_MESSAGE);
                        } else {
                            if (solSoIdMap.get(solId) != null && soIdClonedEPaymentMap.get(solSoIdMap.get(solId)) != null){
                                fulfillment.FS_ePayment__c = soIdClonedEPaymentMap.get(solSoIdMap.get(solId)).Id;
                            }
                            fulfillment.FS_Status__c = OF_AMS_STATUS_SUBMITTED;
                            fulfillment.FS_Error_Message__c = '';
                        }
                        ofToUpdate.add(fulfillment);
                    } else if (ofIdStatusMap.get(ofId) == null) {
                        ofToUpdate.add(new FS_Order_Fulfillment__c(Id = ofId,
                                FS_Status__c = OF_AMS_STATUS_NO_E_PAYMENT));
                    }
                }
            }

            if (!ofToUpdate.isEmpty()) {
                Database.update(ofToUpdate, false);
            }

        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '================>' + e.getMessage());
        }
    }

    private void insertEPaymentLines(String type, Map<Id, String> soIdErrorMap) {
        Map<Id, OrderApi__EPayment_Line__c> tempMap = null;
        if (type == TYPE_E_PAYMENT_LINE) {
            tempMap = solIdClonedEPaymentLineMap;
        } else if (type == TYPE_E_PAYMENT_LINE_TAX) {
            tempMap = solIdClonedTaxEPaymentLineMap;
        } else if (type == TYPE_E_PAYMENT_LINE_SHIPPING) {
            tempMap = clonedShippingEPaymentLineMap;
        }

        if (tempMap != null) {
            List<Id> keysList = new List<Id>();
            List<OrderApi__EPayment_Line__c> valuesList = new List<OrderApi__EPayment_Line__c>();
            for (Id key : tempMap.keySet()) {
                keysList.add(key);
                valuesList.add(tempMap.get(key));
            }

            Database.SaveResult[] srList = Database.insert(valuesList, false);
            if (srList != null) {
                for (Integer index = 0; index < srList.size(); index++) {
                    if (!srList[index].isSuccess()) {
                        String error = null;
                        if (soIdErrorMap == null) {
                            error = solIdErrorMap.get(keysList[index]);
                        } else {
                            error = soIdErrorMap.get(keysList[index]);
                        }
                        for (Database.Error err : srList[index].getErrors()) {
                            error = String.isNotBlank(error) ? error + '\n' : '';
                            error = error + err.getStatusCode() + ': ' + err.getMessage();
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        if (soIdErrorMap == null) {
                            solIdErrorMap.put(keysList[index], error);
                        } else {
                            soIdErrorMap.put(keysList[index], error);
                        }
                    }
                }
            }
        }
    }


    global void finish(Database.BatchableContext BC) {
        System.enqueueJob(new FS_AsyncProcessPayment(soIdsToUpdateEpayments));
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new FS_PreAuthorizationPaymentBatch(), Integer.valueOf(Label.FS_PreAuthorizationPaymentBatchSize));
    }
}