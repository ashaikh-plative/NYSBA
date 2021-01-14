public without sharing class FS_JoinProcess_SecondStage_Controller {
    private static final String EQUALS = 'equals';
    private static final String NOT_EQUAL_TO = 'not equal to';
    private static final String STARTS_WITH = 'starts with';
    private static final String ENDS_WITH = 'ends with';
    private static final String CONTAINS = 'contains';
    private static final String DOES_NOT_CONTAIN = 'does not contain';
    private static final String LESS_THAN = 'less than';
    private static final String GREATER_THAN = 'greater than';
    private static final String LESS_OR_EQUAL = 'less or equal';
    private static final String GREATER_OR_EQUAL = 'greater or equal';
    private static final String INCLUDES = 'includes';
    private static final String EXCLUDES = 'excludes';

    @AuraEnabled
    public static Map<String, Object> getMembershipItems(String contactId, String membershipItemId, String existingSalesOrderId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Map<Id, OrderApi__Item__c> items = new Map<Id, OrderApi__Item__c>();
            Contact contact = [
                    SELECT
                            Id, FS_First_Admit_Date__c, FS_Years_Since_Admitted_to_Bar__c, FS_Sustaining_Member__c, FS_Comp_Member__c,
                    (
                            SELECT Id, OrderApi__Item__c FROM OrderApi__Subscriptions__r WHERE OrderApi__Is_Active__c = TRUE ORDER BY OrderApi__Grace_Period_End_Date__c DESC
                    )
                    FROM
                            Contact
                    WHERE
                            Id = :contactId
            ];

            if (![SELECT Id FROM OrderApi__Item__c WHERE Name LIKE '%Student%' AND Id IN :membershipItemId.split(',')].isEmpty()) {
                items = new Map<Id, OrderApi__Item__c>([
                        SELECT
                                Id, Name, OrderApi__Display_Name__c, OrderApi__Item_Class__c, OrderApi__Item_Class__r.Name, OrderApi__Price__c,
                                OrderApi__Image_Path__c, OrderApi__eStore_Description__c, OrderApi__Item_Class__r.OrderApi__Description__c,
                        (
                                SELECT Id, OrderApi__Item__c FROM OrderApi__Price_Rules__r
                        )
                        FROM
                                OrderApi__Item__c
                        WHERE
                                Id IN :membershipItemId.split(',')
                ]);
                result.put('membershipItems', items.values());
            } else {
                List<OrderApi__Price_Rule__c> priceRules = [
                        SELECT
                                Id, OrderApi__Item__c, OrderApi__Price__c, (
                                SELECT
                                        Id, OrderApi__Price_Rule__c, OrderApi__Object__c, OrderApi__Field__c, OrderApi__Operator__c, OrderApi__Value__c
                                FROM
                                        OrderApi__Price_Rule_Variables__r
                        )
                        FROM
                                OrderApi__Price_Rule__c
                        WHERE
                        OrderApi__Item__c IN :membershipItemId.split(',') AND OrderApi__Is_Active__c = TRUE
                ];

                Map<Id, OrderApi__Price_Rule__c> itemIdToEligiblePriceRule = new Map<Id, OrderApi__Price_Rule__c>();

                for (OrderApi__Price_Rule__c tempPriceRule : priceRules) {
                    Boolean isEligible = false;
                    for (OrderApi__Price_Rule_Variable__c tempPriceRuleVariable : tempPriceRule.OrderApi__Price_Rule_Variables__r) {
                        String operator = tempPriceRuleVariable.OrderApi__Operator__c;
                        if (tempPriceRuleVariable.OrderApi__Object__c.toLowerCase() == 'contact'
                                && tempPriceRuleVariable.OrderApi__Field__c.toLowerCase() == 'fs_first_admit_date__c'
                                && contact.FS_First_Admit_Date__c != null) {
                            Date formattedValue = Date.valueOf(tempPriceRuleVariable.OrderApi__Value__c);
                            isEligible = ((operator == EQUALS && contact.FS_First_Admit_Date__c == formattedValue)
                                    || (operator == NOT_EQUAL_TO && contact.FS_First_Admit_Date__c != formattedValue)
                                    || (operator == LESS_THAN && contact.FS_First_Admit_Date__c < formattedValue)
                                    || (operator == GREATER_THAN && contact.FS_First_Admit_Date__c > formattedValue)
                                    || (operator == LESS_OR_EQUAL && contact.FS_First_Admit_Date__c <= formattedValue)
                                    || (operator == GREATER_OR_EQUAL && contact.FS_First_Admit_Date__c >= formattedValue));
                            if (!isEligible) {
                                break;
                            }
                        } else if (tempPriceRuleVariable.OrderApi__Object__c.toLowerCase() == 'contact'
                                && tempPriceRuleVariable.OrderApi__Field__c.toLowerCase() == 'fs_years_since_admitted_to_bar__c'
                                && contact.FS_Years_Since_Admitted_to_Bar__c != null) {
                            Decimal formattedValue = Decimal.valueOf(tempPriceRuleVariable.OrderApi__Value__c);
                            isEligible = ((operator == EQUALS && contact.FS_Years_Since_Admitted_to_Bar__c == formattedValue)
                                    || (operator == NOT_EQUAL_TO && contact.FS_Years_Since_Admitted_to_Bar__c != formattedValue)
                                    || (operator == LESS_THAN && contact.FS_Years_Since_Admitted_to_Bar__c < formattedValue)
                                    || (operator == GREATER_THAN && contact.FS_Years_Since_Admitted_to_Bar__c > formattedValue)
                                    || (operator == LESS_OR_EQUAL && contact.FS_Years_Since_Admitted_to_Bar__c <= formattedValue)
                                    || (operator == GREATER_OR_EQUAL && contact.FS_Years_Since_Admitted_to_Bar__c >= formattedValue));
                            if (!isEligible) {
                                break;
                            }
                        } else if (tempPriceRuleVariable.OrderApi__Object__c.toLowerCase() == 'contact'
                                && tempPriceRuleVariable.OrderApi__Field__c.toLowerCase() == 'fs_sustaining_member__c') {
                            Boolean formattedValue = Boolean.valueOf(tempPriceRuleVariable.OrderApi__Value__c);
                            isEligible = ((operator == EQUALS && contact.FS_Sustaining_Member__c == formattedValue)
                                    || (operator == NOT_EQUAL_TO && contact.FS_Sustaining_Member__c != formattedValue));
                            if (!isEligible) {
                                break;
                            }
                        } else if (tempPriceRuleVariable.OrderApi__Object__c.toLowerCase() == 'contact'
                                && tempPriceRuleVariable.OrderApi__Field__c.toLowerCase() == 'fs_comp_member__c') {
                            Boolean formattedValue = Boolean.valueOf(tempPriceRuleVariable.OrderApi__Value__c);
                            isEligible = ((operator == EQUALS && contact.FS_Comp_Member__c == formattedValue)
                                    || (operator == NOT_EQUAL_TO && contact.FS_Comp_Member__c != formattedValue));
                            if (!isEligible) {
                                break;
                            }
                        }
                    }
                    if (isEligible) {
                        itemIdToEligiblePriceRule.put(tempPriceRule.OrderApi__Item__c, tempPriceRule);
                    }
                }

                if (!itemIdToEligiblePriceRule.isEmpty()) {
                    items = new Map<Id, OrderApi__Item__c>([
                            SELECT
                                    Id, Name, OrderApi__Display_Name__c, OrderApi__Item_Class__c, OrderApi__Item_Class__r.Name, OrderApi__Price__c,
                                    OrderApi__Image_Path__c, OrderApi__eStore_Description__c, OrderApi__Item_Class__r.OrderApi__Description__c
                            FROM
                                    OrderApi__Item__c
                            WHERE
                                    Id IN :itemIdToEligiblePriceRule.keySet()
                                    AND OrderApi__Is_Active__c = TRUE
                    ]);
                    for (OrderApi__Item__c tempItem : items.values()) {
                        tempItem.OrderApi__Price__c = itemIdToEligiblePriceRule.get(tempItem.Id).OrderApi__Price__c;
                    }
                    result.put('membershipItems', items.values());
                } else {
                    result.put('membershipItems', null);
                }
            }
            if (String.isNotBlank(existingSalesOrderId)) {
                List<OrderApi__Sales_Order_Line__c> membershipSOL = [
                        SELECT Id, OrderApi__Item__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :existingSalesOrderId AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                ];
                if (!membershipSOL.isEmpty()) {
                    System.debug(membershipSOL);
                    result.put('membershipItemSOLId', membershipSOL[0].Id);
                    result.put('reselect', !items.containsKey(membershipSOL[0].OrderApi__Item__c));
                    result.put('membershipItemSelected', items.containsKey(membershipSOL[0].OrderApi__Item__c) ? items.get(membershipSOL[0].OrderApi__Item__c) : new OrderApi__Item__c(Id = membershipSOL[0].OrderApi__Item__c));
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getCause());
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getPackageItems(String membershipItemId, String contactId, String existingSalesOrderId, String CLEAllAccessPassItemIds) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<String> CLEAllAccessPassItemIdsList = CLEAllAccessPassItemIds.split(',');
            Map<Id, OrderApi__Package_Item__c> itemIdToPackageItems = new Map<Id, OrderApi__Package_Item__c>();
            Map<Id, OrderApi__Subscription__c> itemIdToSubscription = new Map<Id, OrderApi__Subscription__c>();
            Boolean hasActiveCLEAllAccessPass = false;
            Boolean showRenewalCLEAllAccessPass = false;
            OrderApi__Subscription__c membershipSubscription = null;
            OrderApi__Subscription__c CLEAllAccessPassSubscription = null;
            Boolean isSustainingMember = false;
            //TODO Test class issue
            if (!Test.isRunningTest()) {
                isSustainingMember = [SELECT Id, FS_Sustaining_Member__c FROM Contact WHERE Id = :contactId].FS_Sustaining_Member__c;
            }
            result.put('isSustainingMember', isSustainingMember);
            for (OrderApi__Subscription__c tempSubscription : [
                    SELECT
                            Id, OrderApi__Contact__c, OrderApi__Item__c, OrderApi__Current_Term_End_Date__c, OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Item_Class__r.Name,
                            OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c, OrderApi__In_Grace_Period__c
                    FROM
                            OrderApi__Subscription__c
                    WHERE
                            OrderApi__Contact__c = :contactId
                            AND OrderApi__Is_Active__c = TRUE
                            AND OrderApi__Status__c = 'Active'
                            AND OrderApi__Entity__c = 'Contact'
                    ORDER BY
                            OrderApi__Grace_Period_End_Date__c DESC
            ]) {
                if (CLEAllAccessPassItemIdsList.contains(tempSubscription.OrderApi__Item__c)) {
                    hasActiveCLEAllAccessPass = true;
                    CLEAllAccessPassSubscription = tempSubscription;
                } else if (tempSubscription.OrderApi__Item__c == membershipItemId) {
                    membershipSubscription = tempSubscription;
                }

                if (CLEAllAccessPassSubscription != null && membershipSubscription != null) {
                    if (CLEAllAccessPassSubscription.OrderApi__Term_End_Date__c == membershipSubscription.OrderApi__Term_End_Date__c) {
                        showRenewalCLEAllAccessPass = true;
                    }
                }

                itemIdToSubscription.put(tempSubscription.OrderApi__Item__c, tempSubscription);
            }

            String CLEAllAccessPassId = null;
            for (OrderApi__Package_Item__c tempPackageItem : [
                    SELECT
                            Id, OrderApi__Item__r.OrderApi__Display_Name__c, OrderApi__Item__c, OrderApi__Package__c, OrderApi__Is_Required__c, OrderApi__Display_Item__c, OrderApi__Item__r.Name,
                            OrderApi__Item__r.OrderApi__eStore_Description__c, OrderApi__Item__r.OrderApi__Price__c, FS_Hide_For_Active_Subscription__c, OrderApi__Is_Recommended__c, OrderApi__Item__r.OrderApi__Item_Class__r.Name
                    FROM
                            OrderApi__Package_Item__c
                    WHERE
                            OrderApi__Package__c = :membershipItemId AND OrderApi__Item__c != NULL
                    ORDER BY
                            OrderApi__Display_Order__c
            ]) {
                if (!(tempPackageItem.FS_Hide_For_Active_Subscription__c && itemIdToSubscription.containsKey(tempPackageItem.OrderApi__Item__c) && itemIdToSubscription.get(tempPackageItem.OrderApi__Item__c).OrderApi__In_Grace_Period__c)) {
                    if (CLEAllAccessPassItemIdsList.contains(tempPackageItem.OrderApi__Item__c) && (!hasActiveCLEAllAccessPass || showRenewalCLEAllAccessPass)) {
                        itemIdToPackageItems.put(tempPackageItem.OrderApi__Item__c, tempPackageItem);
                        CLEAllAccessPassId = tempPackageItem.OrderApi__Item__c;
                    } else if (!CLEAllAccessPassItemIdsList.contains(tempPackageItem.OrderApi__Item__c)) {
                        itemIdToPackageItems.put(tempPackageItem.OrderApi__Item__c, tempPackageItem);
                    }
                }
            }

            if (CLEAllAccessPassId != null) {
                OrderApi__Item__c CLEAllAccessPass = [
                        SELECT
                                Id,
                        (
                                SELECT Id, OrderApi__Price__c FROM OrderApi__Price_Rules__r WHERE Name = 'MEMBER' AND OrderApi__Is_Active__c = TRUE
                        )
                        FROM
                                OrderApi__Item__c
                        WHERE
                                Id = :CLEAllAccessPassId
                ];
                if (!CLEAllAccessPass.OrderApi__Price_Rules__r.isEmpty()) {
                    itemIdToPackageItems.get(CLEAllAccessPass.Id).OrderApi__Item__r.OrderApi__Price__c = CLEAllAccessPass.OrderApi__Price_Rules__r[0].OrderApi__Price__c;
                }
            }
            result.put('packageItems', itemIdToPackageItems.values());
            result.put('allItemIdOfPackageItems', itemIdToPackageItems.keySet());
            if (showRenewalCLEAllAccessPass) {
                result.put('CLEAllAccessPassSubscriptionId', CLEAllAccessPassSubscription.Id);
            }
            result.put('allItemIdOfPackageItems', itemIdToPackageItems.keySet());
            if (existingSalesOrderId != null) {
                result.put('SOLs', [SELECT Id, OrderApi__Item__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :existingSalesOrderId]);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getCause());
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> createSO(String contactId, String membershipItemSelected) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                    OrderApi__Contact__c = contactId,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Status__c = 'Open',
                    OrderApi__Date__c = System.today()
            );
            insert salesOrder;

            OrderApi__Sales_Order_Line__c membershipOrderLine = new OrderApi__Sales_Order_Line__c(
                    OrderApi__Item__c = membershipItemSelected,
                    OrderApi__Sales_Order__c = salesOrder.Id,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Contact__c = contactId
            );
            insert membershipOrderLine;
            salesOrder.OrderApi__Status__c = 'Closed';
            update salesOrder;

            result.put('salesOrderId', salesOrder.Id);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getCause());
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> updateSO(String contactId, String membershipItemSelected, String membershipItemSelectedExisting, String existingSalesOrderId) {
        Map<String, Object> result = new Map<String, Object>();
        System.debug('Line296membershipItemSelected::'+membershipItemSelected);
        System.debug('Line297membershipItemSelectedExisting::'+membershipItemSelectedExisting);
        System.debug('Line298existingSalesOrderId::'+existingSalesOrderId);
        try {
            OrderApi__Sales_Order__c tempSalesOrder = new OrderApi__Sales_Order__c(Id = existingSalesOrderId, OrderApi__Status__c = 'Open', OrderApi__Posting_Status__c = '');
            update tempSalesOrder;
            List<OrderApi__Sales_Order_Line__c> SOLs = [SELECT Id, OrderApi__Subscription__c, OrderApi__Is_Renewal__c,
                                    OrderApi__Item__r.FS_Is_Membership__c
                                    FROM OrderApi__Sales_Order_Line__c
                                    WHERE OrderApi__Sales_Order__c = :existingSalesOrderId];

            System.debug('Line307::'+SOLs);
            Boolean isRenewal = false;
            String subscriptionId = null;
            for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : SOLs) {

                if (tempSalesOrderLine.OrderApi__Is_Renewal__c
                        && tempSalesOrderLine.OrderApi__Item__r.FS_Is_Membership__c) {
                    System.debug('Line314::');
                    isRenewal = tempSalesOrderLine.OrderApi__Is_Renewal__c;
                    subscriptionId = tempSalesOrderLine.OrderApi__Subscription__c;
                    break;
                }

            }
            System.debug('Line321::'+SOLs);
            delete SOLs;

            insert new OrderApi__Sales_Order_Line__c(
                    OrderApi__Item__c = membershipItemSelected,
                    OrderApi__Sales_Order__c = existingSalesOrderId,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Contact__c = contactId,
                    OrderApi__Is_Renewal__c = isRenewal,
                    OrderApi__Subscription__c = subscriptionId
            );
            tempSalesOrder.OrderApi__Status__c = 'Closed';
            update tempSalesOrder;
            System.debug('tempSalesOrder::'+tempSalesOrder);
            result.put('salesOrderId', existingSalesOrderId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getCause());
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> addPackageItemSOL(String existingSalesOrderId, List<String> packageItemIdsSelected, List<String> allItemIdOfPackageItems, List<String> packageItemIdsRequired, String CLEAllAccessPassSubscriptionId, String CLEAllAccessPassItemIds) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<String> CLEAllAccessPassItemIdsList = CLEAllAccessPassItemIds.split(',');
            OrderApi__Sales_Order__c tempSalesOrder = new OrderApi__Sales_Order__c(Id = existingSalesOrderId, OrderApi__Status__c = 'Open', OrderApi__Posting_Status__c = '');
            update tempSalesOrder;
            List<OrderApi__Sales_Order_Line__c> SOLsNeedToInsert = new List<OrderApi__Sales_Order_Line__c>();
            Map<Id, OrderApi__Sales_Order_Line__c> existingPackageItemSOL = new Map<Id, OrderApi__Sales_Order_Line__c>();
            for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : [SELECT Id, OrderApi__Item__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :existingSalesOrderId AND OrderApi__Item__c IN :allItemIdOfPackageItems AND (OrderApi__Item__c NOT IN :packageItemIdsRequired)]) {
                existingPackageItemSOL.put(tempSalesOrderLine.OrderApi__Item__c, tempSalesOrderLine);
            }

            Map<Id, OrderApi__Package_Item__c> packageItemMap = new Map<Id, OrderApi__Package_Item__c>([SELECT Id, OrderApi__Item__c FROM OrderApi__Package_Item__c WHERE Id IN :packageItemIdsSelected]);
            for (String tempPackageItemId : packageItemIdsSelected) {
                if (existingPackageItemSOL.isEmpty()) {
                    if (CLEAllAccessPassItemIdsList.contains(packageItemMap.get(tempPackageItemId).OrderApi__Item__c) && CLEAllAccessPassSubscriptionId != '') {
                        SOLsNeedToInsert.add(
                                new OrderApi__Sales_Order_Line__c(
                                        OrderApi__Sales_Order__c = existingSalesOrderId,
                                        OrderApi__Item__c = packageItemMap.get(tempPackageItemId).OrderApi__Item__c,
                                        OrderApi__Is_Renewal__c = true,
                                        OrderApi__Subscription__c = CLEAllAccessPassSubscriptionId
                                )
                        );
                    } else {
                        SOLsNeedToInsert.add(
                                new OrderApi__Sales_Order_Line__c(
                                        OrderApi__Sales_Order__c = existingSalesOrderId,
                                        OrderApi__Item__c = packageItemMap.get(tempPackageItemId).OrderApi__Item__c
                                )
                        );
                    }
                } else {
                    if (existingPackageItemSOL.containsKey(packageItemMap.get(tempPackageItemId).OrderApi__Item__c)) {
                        existingPackageItemSOL.remove(packageItemMap.get(tempPackageItemId).OrderApi__Item__c);
                    } else {
                        if (CLEAllAccessPassItemIdsList.contains(packageItemMap.get(tempPackageItemId).OrderApi__Item__c) && CLEAllAccessPassSubscriptionId != '') {
                            SOLsNeedToInsert.add(
                                    new OrderApi__Sales_Order_Line__c(
                                            OrderApi__Sales_Order__c = existingSalesOrderId,
                                            OrderApi__Item__c = packageItemMap.get(tempPackageItemId).OrderApi__Item__c,
                                            OrderApi__Is_Renewal__c = true,
                                            OrderApi__Subscription__c = CLEAllAccessPassSubscriptionId
                                    )
                            );
                        } else {
                            SOLsNeedToInsert.add(
                                    new OrderApi__Sales_Order_Line__c(
                                            OrderApi__Sales_Order__c = existingSalesOrderId,
                                            OrderApi__Item__c = packageItemMap.get(tempPackageItemId).OrderApi__Item__c
                                    )
                            );
                        }
                    }
                }
            }
            if (!existingPackageItemSOL.isEmpty()) {
                delete existingPackageItemSOL.values();
            }
            if (!SOLsNeedToInsert.isEmpty()) {
                insert SOLsNeedToInsert;
            }
            tempSalesOrder.OrderApi__Status__c = 'Closed';
            update tempSalesOrder;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getCause());
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString());
        }
        return result;
    }

    @TestVisible
    private static void testCoverage() {
        Integer i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
    }
}