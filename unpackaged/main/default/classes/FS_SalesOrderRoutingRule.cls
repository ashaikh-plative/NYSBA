global without sharing class FS_SalesOrderRoutingRule extends Framework.Domain {
    public FS_SalesOrderRoutingRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_SalesOrderRoutingRule(sObjectList);
        }
    }

//    public override void beforeInsert() {
//        Framework.Log.push(FS_SalesOrderRoutingRule.class.getName(), 'beforeInsert');

//        Framework.Log.pop();
//    }

//    public override void afterInsert() {
//        Framework.Log.push(FS_SalesOrderRoutingRule.class.getName(), 'afterInsert');
//        Framework.Log.pop();
//    }

//    public override void beforeUpdate(Map<Id, SObject> oldMap) {
//        Framework.Log.push(FS_CommunityGroupMemberRoutingRule.class.getName(), 'beforeUpdate');
//        //FS_CommunityGroupMemberRoutingRuleServic.beforeUpdate((List<PagesApi__Community_Group_Member__c>) records, (Map<Id, PagesApi__Community_Group_Member__c>) oldMap);
//        Framework.Log.pop();
//    }

    public override void afterUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_SalesOrderRoutingRule.class.getName(), 'afterUpdate');
        processSalesOrders((List<OrderApi__Sales_Order__c>) records, (Map<Id, OrderApi__Sales_Order__c>) oldMap);
        Framework.Log.pop();
    }

    public static void processSalesOrders(List<OrderApi__Sales_Order__c> records, Map<Id, OrderApi__Sales_Order__c> oldMap) {
        Savepoint sp = Database.setSavepoint();
        System.debug('here0');
        try {
            System.debug('here1');
            // for sales orders contains section items, no membership item.
            List<OrderApi__Sales_Order__c> salesOrdersForSectionItems = [
                    SELECT
                            Id, OrderApi__Entity__c, OrderApi__Status__c, OrderApi__Posting_Status__c, OrderApi__Contact__c, (
                            SELECT
                                    Id, OrderApi__Item__r.FS_Linked_Community_Group__c, FS_Additional_Data__c,
                                    OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Type__c,
                                    OrderApi__Item__r.FS_Is_Membership__c
                            FROM OrderApi__Sales_Order_Lines__r
                    )
                    FROM
                            OrderApi__Sales_Order__c
                    WHERE
                            Id IN :oldMap.keySet()
            ];
            System.debug('**********: ' + salesOrdersForSectionItems);
            Set<Id> contactIds = new Set<Id>();
            Set<Id> eligibleSalesOrderIdsForSectionItems = new Set<Id>();
            for (OrderApi__Sales_Order__c tempSalesOrder : salesOrdersForSectionItems) {
                if (!tempSalesOrder.OrderApi__Sales_Order_Lines__r.isEmpty()) {
                    Boolean noMembership = true;
                    System.debug('Line61'+noMembership);
                    for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : tempSalesOrder.OrderApi__Sales_Order_Lines__r) {
                        if (tempSalesOrderLine.OrderApi__Item__r.FS_Is_Membership__c) {
                            noMembership = false;
                            break;
                        }
                        System.debug('Line67'+noMembership);
                    }
                    if (noMembership) {
                        if (tempSalesOrder.OrderApi__Entity__c == 'Contact' &&
                                tempSalesOrder.OrderApi__Status__c == 'Closed' &&
                                tempSalesOrder.OrderApi__Posting_Status__c == 'Posted' &&
                                oldMap.get(tempSalesOrder.Id).OrderApi__Posting_Status__c != 'Posted') {
                                    System.debug('Line74 Entered');
                            eligibleSalesOrderIdsForSectionItems.add(tempSalesOrder.Id);
                            contactIds.add(tempSalesOrder.OrderApi__Contact__c);
                        }
                    }
                }
            }
            System.debug('Line81: ' + eligibleSalesOrderIdsForSectionItems);
            List<OrderApi__Sales_Order_Line__c> salesOrderLines = [
                    SELECT
                            Id, FS_Additional_Data__c, OrderApi__Contact__c, OrderApi__Item__r.FS_Linked_Community_Group__c
                    FROM
                            OrderApi__Sales_Order_Line__c
                    WHERE
                    OrderApi__Sales_Order__c IN :eligibleSalesOrderIdsForSectionItems
                    AND OrderApi__Item__r.FS_Linked_Community_Group__c != NULL
                    AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Type__c = 'Section'
            ];
            System.debug('Line 92: ' + salesOrderLines);
            List<Contact> contacts = [
                    SELECT
                            Id, (
                            SELECT Id, OrderApi__Item__c, OrderApi__Activated_Date__c,
                                    OrderApi__Expired_Date__c
                            FROM OrderApi__Subscriptions__r
                            WHERE OrderApi__Status__c
                                    = 'Active'
                            AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                            ORDER BY LastModifiedDate DESC
                            LIMIT 1
                    )
                    FROM
                            Contact
                    WHERE
                            Id IN :contactIds
            ];

            Map<Id, OrderApi__Subscription__c> contactIdToMembership = new Map<Id, OrderApi__Subscription__c>();
            Map<Id, OrderApi__Renewal__c> contactIdToTerm = new Map<Id, OrderApi__Renewal__c>();
            Map<Id, OrderApi__Renewal__c> contactIdToFutureTerm = new Map<Id, OrderApi__Renewal__c>();
            for (Contact tempContact : contacts) {
                if (!tempContact.OrderApi__Subscriptions__r.isEmpty()) {
                    contactIdToMembership.put(tempContact.Id, tempContact.OrderApi__Subscriptions__r[0]);
                }
            }

            for (OrderApi__Subscription__c tempSubscription : [SELECT Id, OrderApi__Contact__c, (SELECT Id, OrderApi__Is_Active__c, OrderApi__Term_Start_Date__c, OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c FROM OrderApi__Renewals__r WHERE OrderApi__Is_Active__c = TRUE ORDER BY OrderApi__Term_End_Date__c DESC LIMIT 1) FROM OrderApi__Subscription__c WHERE Id IN :contactIdToMembership.values()]) {
                if (!tempSubscription.OrderApi__Renewals__r.isEmpty()) {
                    contactIdToTerm.put(tempSubscription.OrderApi__Contact__c, tempSubscription.OrderApi__Renewals__r[0]);
                }
            }

            for (OrderApi__Subscription__c tempSubscription : [SELECT Id, OrderApi__Contact__c, (SELECT Id, OrderApi__Is_Active__c, OrderApi__Term_Start_Date__c, OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c FROM OrderApi__Renewals__r WHERE OrderApi__Is_Active__c = FALSE AND OrderApi__Term_Start_Date__c > TODAY ORDER BY OrderApi__Term_End_Date__c DESC LIMIT 1) FROM OrderApi__Subscription__c WHERE Id IN :contactIdToMembership.values()]) {
                if (!tempSubscription.OrderApi__Renewals__r.isEmpty()) {
                    contactIdToFutureTerm.put(tempSubscription.OrderApi__Contact__c, tempSubscription.OrderApi__Renewals__r[0]);
                }
            }

            Map<String, PagesApi__Community_Group_Member__c> communityGroupMembersNeedToInsert = new Map<String, PagesApi__Community_Group_Member__c>();
            List<FS_Community_Group_Member_Term__c> termsNeedToInsert = new List<FS_Community_Group_Member_Term__c>();
            Map<String, FS_Community_Group_Member_Term__c> termsNeedToInsertLater = new Map<String, FS_Community_Group_Member_Term__c>();
            Map<Id, Map<String, Object>> contactIdToExistingCommunityGroups = new Map<Id, Map<String, Object>>();

            for (PagesApi__Community_Group_Member__c tempCommunityGroupMember : [
                    SELECT Id, PagesApi__Contact__c,
                            PagesApi__Community_Group__c
                    FROM PagesApi__Community_Group_Member__c
                    WHERE PagesApi__Contact__c IN :contactIdToMembership.keySet()
            ]) {
                if (contactIdToExistingCommunityGroups.containsKey(tempCommunityGroupMember.PagesApi__Contact__c)) {
                    ((Set<Id>) contactIdToExistingCommunityGroups.get(tempCommunityGroupMember.PagesApi__Contact__c).get('Ids')).add(tempCommunityGroupMember.PagesApi__Community_Group__c);
                    ((Map<Id, Id>) contactIdToExistingCommunityGroups.get(tempCommunityGroupMember.PagesApi__Contact__c).get('CGM')).put(tempCommunityGroupMember.PagesApi__Community_Group__c, tempCommunityGroupMember.Id);
                } else {
                    contactIdToExistingCommunityGroups.put(tempCommunityGroupMember.PagesApi__Contact__c, new Map<String, Object>{
                            'Ids' => new Set<Id>{
                                    tempCommunityGroupMember.PagesApi__Community_Group__c
                            },
                            'CGM' => new Map<Id, Id>{
                                    tempCommunityGroupMember.PagesApi__Community_Group__c => tempCommunityGroupMember.Id
                            }
                    });
                }
            }
            System.debug('3: ' + contactIdToExistingCommunityGroups);
            System.debug('contactIdToMembership: ' + contactIdToMembership);
            for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : salesOrderLines) {
                // only consider has an active membership
                if (contactIdToMembership.containsKey(tempSalesOrderLine.OrderApi__Contact__c)) {
                    String tempStatus = null;
                    if (tempSalesOrderLine.FS_Additional_Data__c != null && tempSalesOrderLine.FS_Additional_Data__c.contains('"sectionCommittees"')) {
                        Map<String, Object> tempAdditionalData = (Map<String, Object>) JSON.deserializeUntyped(tempSalesOrderLine.FS_Additional_Data__c);
                        if (tempAdditionalData.containsKey('status')) {
                            tempStatus = (String) tempAdditionalData.get('status');
                        }

                    }

                    if (!contactIdToExistingCommunityGroups.isEmpty() && ((Set<Id>) contactIdToExistingCommunityGroups.get(tempSalesOrderLine.OrderApi__Contact__c).get('Ids')).contains(tempSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c)) {
                        if (contactIdToFutureTerm.containsKey(tempSalesOrderLine.OrderApi__Contact__c)) {
                            termsNeedToInsert.add(new FS_Community_Group_Member_Term__c(
                                    FS_Community_Group_Member__c = ((Map<Id, Id>) contactIdToExistingCommunityGroups.get(tempSalesOrderLine.OrderApi__Contact__c).get('CGM')).get(tempSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c),
                                    FS_Sales_Order_Line__c = tempSalesOrderLine.Id,
                                    FS_Term__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).Id,
                                    FS_Term_Start_Date__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                    FS_Term_End_Date__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c,
                                    FS_Term_Grace_Period_End_Date__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c
                            ));
                        } else {
                            termsNeedToInsert.add(new FS_Community_Group_Member_Term__c(
                                    FS_Community_Group_Member__c = ((Map<Id, Id>) contactIdToExistingCommunityGroups.get(tempSalesOrderLine.OrderApi__Contact__c).get('CGM')).get(tempSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c),
                                    FS_Sales_Order_Line__c = tempSalesOrderLine.Id,
                                    FS_Term__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).Id,
                                    FS_Term_Start_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                    FS_Term_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c,
                                    FS_Term_Grace_Period_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c
                            ));
                        }
                    } else {
                        communityGroupMembersNeedToInsert.put(
                                tempSalesOrderLine.OrderApi__Contact__c + '&' + tempSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c,
                                new PagesApi__Community_Group_Member__c(
                                        PagesApi__Contact__c = tempSalesOrderLine.OrderApi__Contact__c,
                                        PagesApi__Community_Group__c = tempSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c,
                                        // We are no long using Needs Approval
//                                        PagesApi__Status__c = (tempStatus != null && tempStatus == 'Needs Approval') ? 'Request Submitted' : 'Active',
                                        PagesApi__Status__c = 'Active',
                                        FS_Term_Start_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                        FS_Term_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c
                                )
                        );
                        termsNeedToInsertLater.put(
                                tempSalesOrderLine.OrderApi__Contact__c + '&' + tempSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c,
                                new FS_Community_Group_Member_Term__c(
                                        FS_Sales_Order_Line__c = tempSalesOrderLine.Id,
                                        FS_Term__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).Id,
                                        FS_Term_Start_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                        FS_Term_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c,
                                        FS_Term_Grace_Period_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c
                                )
                        );
                    }

                    // for additional data
                    if (tempSalesOrderLine.FS_Additional_Data__c != null && tempSalesOrderLine.FS_Additional_Data__c.contains('"sectionCommittees"')) {
                        Map<String, Object> tempAdditionalData = (Map<String, Object>) JSON.deserializeUntyped(tempSalesOrderLine.FS_Additional_Data__c);
                        for (Object tempId : (List<Object>) tempAdditionalData.get('sectionCommittees')) {
                            if (!contactIdToExistingCommunityGroups.isEmpty() && ((Set<Id>) contactIdToExistingCommunityGroups.get(tempSalesOrderLine.OrderApi__Contact__c).get('Ids')).contains((String) tempId)) {
                                if (contactIdToFutureTerm.containsKey(tempSalesOrderLine.OrderApi__Contact__c)) {
                                    termsNeedToInsert.add(new FS_Community_Group_Member_Term__c(
                                            FS_Community_Group_Member__c = ((Map<Id, Id>) contactIdToExistingCommunityGroups.get(tempSalesOrderLine.OrderApi__Contact__c).get('CGM')).get((String) tempId),
                                            FS_Sales_Order_Line__c = tempSalesOrderLine.Id,
                                            FS_Term__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).Id,
                                            FS_Term_Start_Date__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                            FS_Term_End_Date__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c,
                                            FS_Term_Grace_Period_End_Date__c = contactIdToFutureTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c
                                    ));
                                } else {
                                    termsNeedToInsert.add(new FS_Community_Group_Member_Term__c(
                                            FS_Community_Group_Member__c = ((Map<Id, Id>) contactIdToExistingCommunityGroups.get(tempSalesOrderLine.OrderApi__Contact__c).get('CGM')).get((String) tempId),
                                            FS_Sales_Order_Line__c = tempSalesOrderLine.Id,
                                            FS_Term__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).Id,
                                            FS_Term_Start_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                            FS_Term_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c,
                                            FS_Term_Grace_Period_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c
                                    ));
                                }
                            } else {
                                communityGroupMembersNeedToInsert.put(
                                        tempSalesOrderLine.OrderApi__Contact__c + '&' + (String) tempId,
                                        new PagesApi__Community_Group_Member__c(
                                                PagesApi__Contact__c = tempSalesOrderLine.OrderApi__Contact__c,
                                                PagesApi__Community_Group__c = (String) tempId,
                                                // We are no longer using Needs Approval
//                                                PagesApi__Status__c = tempStatus == 'Needs Approval' ? 'Request Submitted' : 'Active',
                                                PagesApi__Status__c = 'Active',
                                                FS_Term_Start_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                                FS_Term_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c
                                        )
                                );
                                termsNeedToInsertLater.put(
                                        tempSalesOrderLine.OrderApi__Contact__c + '&' + (String) tempId,
                                        new FS_Community_Group_Member_Term__c(
                                                FS_Sales_Order_Line__c = tempSalesOrderLine.Id,
                                                FS_Term__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).Id,
                                                FS_Term_Start_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_Start_Date__c,
                                                FS_Term_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Term_End_Date__c,
                                                FS_Term_Grace_Period_End_Date__c = contactIdToTerm.get(tempSalesOrderLine.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c
                                        )
                                );
                            }
                        }
                    }
                }
            }
            if (!termsNeedToInsert.isEmpty()) {
                insert termsNeedToInsert;
            }
            if (!communityGroupMembersNeedToInsert.isEmpty()) {
                insert communityGroupMembersNeedToInsert.values();
                for (String tempKey : termsNeedToInsertLater.keySet()) {
                    termsNeedToInsertLater.get(tempKey).FS_Community_Group_Member__c = communityGroupMembersNeedToInsert.get(tempKey).Id;
                }
                insert termsNeedToInsertLater.values();
            }
            System.debug('4: ' + communityGroupMembersNeedToInsert);
            System.debug('here2');
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error Occurred');
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
        }
    }
}