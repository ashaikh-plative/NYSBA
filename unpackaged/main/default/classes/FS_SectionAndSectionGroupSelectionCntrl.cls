public without sharing class FS_SectionAndSectionGroupSelectionCntrl {

    private static final String ORDER_STATUS = 'Open';
    private static final String ORDER_ENTITY = 'Contact';
    private static final String SECTION_DUES = 'Section Dues';
    private static final String SECTION_RENEWAL_DUES = 'Section Renewal Dues';

    public class FS_Section {
        OrderApi__Item__c sectionItem;
        PagesApi__Community_Group__c linkedSectionCommunityGroup;
        Boolean checked = false;
        List<FS_SectionCommittee> sectionCommittees;
    }

    public class FS_SectionCommittee {
        PagesApi__Community_Group__c communityGroup;
        Boolean checked = false;
        List<FS_SectionSubCommittee> sectionSubCommittees;
    }

    public class FS_SectionSubCommittee {
        Boolean checked = false;
        PagesApi__Community_Group__c communityGroup;
    }

    @AuraEnabled
    public static Map<String, Object> setup(Boolean isStudentJoin, Boolean determineIsStudent,
            String contactId, Boolean prepopulateBasedOnSalesOrderId,
            String existingSalesOrderId, Boolean filterOutExistingItems) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Set<Id> IdsChecked = new Set<Id>();
            Set<Id> CGIdsExisting = new Set<Id>();
            if (filterOutExistingItems) {
                for (PagesApi__Community_Group_Member__c tempCommunityGroupMember : [SELECT Id, PagesApi__Community_Group__c FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Contact__c = :contactId AND PagesApi__Status__c = 'Active']) {
                    CGIdsExisting.add(tempCommunityGroupMember.PagesApi__Community_Group__c);
                }
            }

            // Added by Christopher Mudd 12/27

            Boolean isJoin = false;
            // if a renewal sales order line exists already, we are in a renewal use case
            // otherwise, process as a join
            List<OrderApi__Sales_Order_Line__c> renewalOrderLine = [
                    SELECT Id
                    FROM OrderApi__Sales_Order_Line__c
                    WHERE OrderApi__Is_Renewal__c = TRUE
                    AND OrderApi__Is_Posted__c = FALSE
                    AND OrderApi__Contact__c = :contactId
                    AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
            ];
            if (renewalOrderLine.isEmpty()) {
                isJoin = true;
            }

            // End of added by Christopher Mudd 12/27

            if (prepopulateBasedOnSalesOrderId) {
                List<OrderApi__Sales_Order__c> existingSalesOrders = null;
                if (existingSalesOrderId == null) {
                    existingSalesOrders = [
                            SELECT Id, OrderApi__Contact__c, (
                                    SELECT Id, OrderApi__Item__c,
                                            FS_Additional_Data__c, OrderApi__Item__r.FS_Linked_Community_Group__c
                                    FROM
                                            OrderApi__Sales_Order_Lines__r
                                    WHERE OrderApi__Item__r.OrderApi__Is_Active__c = TRUE AND OrderApi__Item__r.FS_Linked_Community_Group__c !=
                                            NULL AND OrderApi__Item__r.FS_Hidden_From_Student_Membership__c = FALSE AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Type__c =
                                            'Section' AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Is_Published__c = TRUE
                                    AND OrderApi__Item__r.FS_Linked_Community_Group__r.FS_Is_Executive__c = FALSE
                            )
                            FROM
                                    OrderApi__Sales_Order__c
                            WHERE OrderApi__Entity__c = 'Contact' AND OrderApi__Contact__c =
                                    :contactId And (OrderApi__Status__c = 'Open' OR (OrderApi__Status__c =
                                    'Closed' AND OrderApi__Posting_Status__c = 'Pending'))
                            ORDER BY LastModifiedDate DESC
                            LIMIT 1
                    ];
                } else {
                    existingSalesOrders = [
                            SELECT Id, OrderApi__Contact__c, (
                                    SELECT Id, OrderApi__Item__c,
                                            FS_Additional_Data__c, OrderApi__Item__r.FS_Linked_Community_Group__c
                                    FROM
                                            OrderApi__Sales_Order_Lines__r
                                    WHERE OrderApi__Item__r.OrderApi__Is_Active__c = TRUE AND OrderApi__Item__r.FS_Linked_Community_Group__c !=
                                            NULL AND OrderApi__Item__r.FS_Hidden_From_Student_Membership__c = FALSE AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Type__c =
                                            'Section' AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Is_Published__c = TRUE
                                    AND OrderApi__Item__r.FS_Linked_Community_Group__r.FS_Is_Executive__c = FALSE
                            )
                            FROM
                                    OrderApi__Sales_Order__c
                            WHERE Id = :existingSalesOrderId
                            ORDER BY LastModifiedDate DESC
                            LIMIT 1
                    ];
                    if (existingSalesOrders.isEmpty()) {
                        result.put('Invalid Sales Order', true);
                        return result;
                    }
                }
                if (!existingSalesOrders.isEmpty()) {
                    if (determineIsStudent && !isStudentJoin) {
                        List<OrderApi__Sales_Order_Line__c> tempSalesOrderLinesStudentMembership = [
                                SELECT
                                        Id
                                FROM
                                        OrderApi__Sales_Order_Line__c
                                WHERE OrderApi__Sales_Order__c = :existingSalesOrders[0].Id AND OrderApi__Item__r.Name = 'Law Student' LIMIT 1
                        ];
                        if (!tempSalesOrderLinesStudentMembership.isEmpty()) {
                            isStudentJoin = true;
                        }
                    }
                    result.put('salesOrderId', existingSalesOrders[0].Id);
                    for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : existingSalesOrders[0].OrderApi__Sales_Order_Lines__r) {
                        IdsChecked.add(tempSalesOrderLine.OrderApi__Item__c);
                        if (tempSalesOrderLine.FS_Additional_Data__c != null && tempSalesOrderLine.FS_Additional_Data__c != '') {
                            if (tempSalesOrderLine.FS_Additional_Data__c.contains('"status":')) {
                                Map<String, Object> additionalData = (Map<String, Object>) JSON.deserializeUntyped(tempSalesOrderLine.FS_Additional_Data__c);
                                for (Object tempId : (List<Object>) additionalData.get('sectionCommittees')) {
                                    IdsChecked.add((String) tempId);
                                }
                            } else {
                                Map<String, Set<Id>> additionalData = (Map<String, Set<Id>>) JSON.deserialize(tempSalesOrderLine.FS_Additional_Data__c, Map<String, Set<Id>>.class);
                                if (additionalData.containsKey('sectionCommittees')) {
                                    IdsChecked.addAll(additionalData.get('sectionCommittees'));
                                }
                            }
                        }
                    }
                } else {
                    if (determineIsStudent && !isStudentJoin) {
                        List<OrderApi__Subscription__c> tempMemberships = [
                                SELECT
                                        Id
                                FROM
                                        OrderApi__Subscription__c
                                WHERE OrderApi__Contact__c = :contactId AND OrderApi__Is_Active__c = TRUE AND OrderApi__Item__r.Name = 'Law Student' LIMIT 1
                        ];
                        if (!tempMemberships.isEmpty()) {
                            isStudentJoin = true;
                        }
                    }
                }
            } else {
                if (determineIsStudent && !isStudentJoin) {
                    List<OrderApi__Subscription__c> tempMemberships = [
                            SELECT
                                    Id
                            FROM
                                    OrderApi__Subscription__c
                            WHERE OrderApi__Contact__c = :contactId AND OrderApi__Is_Active__c = TRUE AND OrderApi__Item__r.Name = 'Law Student' LIMIT 1
                    ];
                    if (!tempMemberships.isEmpty()) {
                        isStudentJoin = true;
                    }
                }
            }
            result.put('isStudentJoin', isStudentJoin);
            Map<Id, FS_Section> communityGroupIdToFSSection = new Map<Id, FS_Section>();
            Id youngLawyersSectionId = null;

            Map<Id, OrderApi__Item__c> sectionItemsParent = null;
            if (isStudentJoin) {
                sectionItemsParent = new Map<Id, OrderApi__Item__c>([
                        SELECT Id, Name,
                                OrderApi__Price__c, FS_Linked_Community_Group__c, FS_Linked_Community_Group__r.Name,
                                OrderApi__Item_Class__r.Name, OrderApi__Display_Name__c
                        FROM
                                OrderApi__Item__c
                        WHERE OrderApi__Is_Active__c = TRUE AND FS_Linked_Community_Group__c !=
                                NULL AND FS_Hidden_From_Student_Membership__c = FALSE AND FS_Linked_Community_Group__r.Name !=
                                'Senior Lawyers Section' AND FS_Linked_Community_Group__r.PagesApi__Type__c =
                                'Section' AND FS_Linked_Community_Group__r.PagesApi__Is_Published__c = TRUE
                                AND FS_Linked_Community_Group__r.FS_Is_Executive__c = FALSE
                        ORDER BY Name ASC
                ]);
            } else {
                sectionItemsParent = new Map<Id, OrderApi__Item__c>([
                        SELECT Id, Name,
                                OrderApi__Price__c, FS_Linked_Community_Group__c, FS_Linked_Community_Group__r.Name,
                                OrderApi__Item_Class__r.Name, OrderApi__Display_Name__c
                        FROM
                                OrderApi__Item__c
                        WHERE OrderApi__Is_Active__c = TRUE AND FS_Linked_Community_Group__c !=
                                NULL AND FS_Hidden_From_Student_Membership__c = FALSE AND FS_Linked_Community_Group__r.PagesApi__Type__c =
                                'Section' AND FS_Linked_Community_Group__r.PagesApi__Is_Published__c = TRUE
                                AND FS_Linked_Community_Group__r.FS_Is_Executive__c = FALSE
                        ORDER BY Name ASC
                ]);
            }
            Set<Id> communityGroupIdsParent = new Set<Id>();
            for (OrderApi__Item__c tempItem : sectionItemsParent.values()) {
                if (filterOutExistingItems) {
                    if (!CGIdsExisting.contains(tempItem.FS_Linked_Community_Group__c)) {
                        communityGroupIdsParent.add(tempItem.FS_Linked_Community_Group__c);
                        FS_Section tempSection = new FS_Section();
                        tempSection.sectionItem = tempItem;
                        tempSection.linkedSectionCommunityGroup = new PagesApi__Community_Group__c(Id = tempItem.FS_Linked_Community_Group__c, Name = tempItem.FS_Linked_Community_Group__r.Name);
                        tempSection.sectionCommittees = new List<FS_SectionCommittee>();
                        if (isStudentJoin && tempItem.FS_Linked_Community_Group__r.Name == 'Young Lawyers Section') {
                            tempSection.checked = true;
                            youngLawyersSectionId = tempItem.FS_Linked_Community_Group__c;
                            if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() &&!IdsChecked.contains(tempItem.Id)) {
                                tempSection.checked = false;
                            }
                        }
                        if (IdsChecked.contains(tempItem.Id)) {
                            tempSection.checked = true;
                        }
                        // Added by Christopher Mudd 12/27

                        if (isJoin && tempItem.OrderApi__Item_Class__r.Name != SECTION_RENEWAL_DUES) {
                            communityGroupIdToFSSection.put(tempItem.FS_Linked_Community_Group__c, tempSection);

                        } else if (!isJoin && tempItem.OrderApi__Item_Class__r.Name == SECTION_RENEWAL_DUES){
                            communityGroupIdToFSSection.put(tempItem.FS_Linked_Community_Group__c, tempSection);

                        }
                        // End of added by Christopher Mudd 12/27
                        
                    }
                } else {
                    communityGroupIdsParent.add(tempItem.FS_Linked_Community_Group__c);
                    FS_Section tempSection = new FS_Section();
                    tempSection.sectionItem = tempItem;
                    tempSection.linkedSectionCommunityGroup = new PagesApi__Community_Group__c(Id = tempItem.FS_Linked_Community_Group__c, Name = tempItem.FS_Linked_Community_Group__r.Name);
                    tempSection.sectionCommittees = new List<FS_SectionCommittee>();
                    if (isStudentJoin && tempItem.FS_Linked_Community_Group__r.Name == 'Young Lawyers Section') {
                        tempSection.checked = true;
                        youngLawyersSectionId = tempItem.FS_Linked_Community_Group__c;
                        if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempItem.Id)) {
                            tempSection.checked = false;
                        }
                    }
                    if (IdsChecked.contains(tempItem.Id)) {
                        tempSection.checked = true;
                    }

                    // Added by Christopher Mudd 12/27

                    if (isJoin && tempItem.OrderApi__Item_Class__r.Name != SECTION_RENEWAL_DUES) {
                        communityGroupIdToFSSection.put(tempItem.FS_Linked_Community_Group__c, tempSection);

                    } else if (!isJoin && tempItem.OrderApi__Item_Class__r.Name == SECTION_RENEWAL_DUES){
                        communityGroupIdToFSSection.put(tempItem.FS_Linked_Community_Group__c, tempSection);

                    }
                    // End of added by Christopher Mudd 12/27

                }
            }



            Map<Id, PagesApi__Community_Group__c> sectionCommitteesChildren = new Map<Id, PagesApi__Community_Group__c>([
                    SELECT Id, Name, FS_Parent_Section__c, FS_Parent_Section__r.Name, (
                            SELECT Id, Name, FS_Parent_Section__c,
                                    FS_Parent_Section__r.FS_Parent_Section__r.Name
                            FROM Community_Groups__r
                            WHERE PagesApi__Type__c =
                                    'Section Committee' AND PagesApi__Is_Published__c = TRUE
                    )
                    FROM PagesApi__Community_Group__c
                    WHERE PagesApi__Type__c =
                            'Section Committee' AND PagesApi__Is_Published__c = TRUE AND FS_Parent_Section__c IN :communityGroupIdsParent AND FS_Is_Executive__c = FALSE
            ]);
            for (PagesApi__Community_Group__c tempCommunityGroup : sectionCommitteesChildren.values()) {
                if (filterOutExistingItems) {
                    if (!CGIdsExisting.contains(tempCommunityGroup.Id)) {
                        List<FS_SectionSubCommittee> tempSectionSubCommittees = new List<FS_SectionSubCommittee>();
                        for (PagesApi__Community_Group__c tempCommunityGroupChild : tempCommunityGroup.Community_Groups__r) {
                            if (filterOutExistingItems) {
                                if (!CGIdsExisting.contains(tempCommunityGroupChild.Id)) {
                                    FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                                    tempSectionSubCommittee.communityGroup = tempCommunityGroupChild;
                                    tempSectionSubCommittees.add(tempSectionSubCommittee);
                                    if (isStudentJoin && tempCommunityGroupChild.FS_Parent_Section__r.FS_Parent_Section__r.Name == 'Young Lawyers Section') {
                                        tempSectionSubCommittee.checked = true;
                                        if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                            tempSectionSubCommittee.checked = false;
                                        }
                                    }
                                    if (IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                        tempSectionSubCommittee.checked = true;
                                    }
                                }
                            } else {
                                FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                                tempSectionSubCommittee.communityGroup = tempCommunityGroupChild;
                                tempSectionSubCommittees.add(tempSectionSubCommittee);
                                if (isStudentJoin && tempCommunityGroupChild.FS_Parent_Section__r.FS_Parent_Section__r.Name == 'Young Lawyers Section') {
                                    tempSectionSubCommittee.checked = true;
                                    if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                        tempSectionSubCommittee.checked = false;
                                    }
                                }
                                if (IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                    tempSectionSubCommittee.checked = true;
                                }
                            }
                        }
                        FS_SectionCommittee tempSectionCommittee = new FS_SectionCommittee();
                        tempSectionCommittee.communityGroup = tempCommunityGroup;
                        tempSectionCommittee.sectionSubCommittees = tempSectionSubCommittees;
                        if (isStudentJoin && tempCommunityGroup.FS_Parent_Section__r.Name == 'Young Lawyers Section') {
                            tempSectionCommittee.checked = true;
                            if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempCommunityGroup.Id)) {
                                tempSectionCommittee.checked = false;
                            }
                        }
                        if (IdsChecked.contains(tempCommunityGroup.Id)) {
                            tempSectionCommittee.checked = true;
                        }
                        communityGroupIdToFSSection.get(tempCommunityGroup.FS_Parent_Section__c).sectionCommittees.add(tempSectionCommittee);
                    }
                } else {
                    List<FS_SectionSubCommittee> tempSectionSubCommittees = new List<FS_SectionSubCommittee>();
                    for (PagesApi__Community_Group__c tempCommunityGroupChild : tempCommunityGroup.Community_Groups__r) {
                        if (filterOutExistingItems) {
                            if (!CGIdsExisting.contains(tempCommunityGroupChild.Id)) {
                                FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                                tempSectionSubCommittee.communityGroup = tempCommunityGroupChild;
                                tempSectionSubCommittees.add(tempSectionSubCommittee);
                                if (isStudentJoin && tempCommunityGroupChild.FS_Parent_Section__r.FS_Parent_Section__r.Name == 'Young Lawyers Section') {
                                    tempSectionSubCommittee.checked = true;
                                    if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                        tempSectionSubCommittee.checked = false;
                                    }
                                }
                                if (IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                    tempSectionSubCommittee.checked = true;
                                }
                            }
                        } else {
                            FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                            tempSectionSubCommittee.communityGroup = tempCommunityGroupChild;
                            tempSectionSubCommittees.add(tempSectionSubCommittee);
                            if (isStudentJoin && tempCommunityGroupChild.FS_Parent_Section__r.FS_Parent_Section__r.Name == 'Young Lawyers Section') {
                                tempSectionSubCommittee.checked = true;
                                if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                    tempSectionSubCommittee.checked = false;
                                }
                            }
                            if (IdsChecked.contains(tempCommunityGroupChild.Id)) {
                                tempSectionSubCommittee.checked = true;
                            }
                        }
                    }
                    FS_SectionCommittee tempSectionCommittee = new FS_SectionCommittee();
                    tempSectionCommittee.communityGroup = tempCommunityGroup;
                    tempSectionCommittee.sectionSubCommittees = tempSectionSubCommittees;
                    if (isStudentJoin && tempCommunityGroup.FS_Parent_Section__r.Name == 'Young Lawyers Section') {
                        tempSectionCommittee.checked = true;
                        if (prepopulateBasedOnSalesOrderId && !IdsChecked.isEmpty() && !IdsChecked.contains(tempCommunityGroup.Id)) {
                            tempSectionCommittee.checked = false;
                        }
                    }
                    if (IdsChecked.contains(tempCommunityGroup.Id)) {
                        tempSectionCommittee.checked = true;
                    }
                    communityGroupIdToFSSection.get(tempCommunityGroup.FS_Parent_Section__c).sectionCommittees.add(tempSectionCommittee);
                }
            }
            List<FS_Section> resultList;
            if (isStudentJoin && youngLawyersSectionId != null) {
                FS_Section tempSection = communityGroupIdToFSSection.get(youngLawyersSectionId);
                communityGroupIdToFSSection.remove(youngLawyersSectionId);
                resultList = communityGroupIdToFSSection.values();
                resultList.add(0, tempSection);
            } else {
                resultList = communityGroupIdToFSSection.values();
            }
            result.put('Items', JSON.serialize(resultList));
        } catch (Exception e) {
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> deleteMembershipItemFromOrder(String contactId, String salesOrderId, String membershipItemId, Boolean isStudentJoin) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('success', true);
        try {
            if(String.isNotBlank(salesOrderId) && !isStudentJoin) {
                // get prev. sales order line for membership item and delete it.
                List<OrderApi__Sales_Order_Line__c> membershipOrderLineList = [SELECT Id
                                                                            FROM OrderApi__Sales_Order_Line__c 
                                                                            WHERE OrderApi__Sales_Order__c = :salesOrderId
                                                                            AND OrderApi__Item__r.Id = :membershipItemId];
                if (!membershipOrderLineList.isEmpty()) {
                    delete membershipOrderLineList.get(0);
                    OrderApi__Sales_Order_Line__c membershipOrderLine = new OrderApi__Sales_Order_Line__c(
                        OrderApi__Item__c = membershipItemId,
                        OrderApi__Sales_Order__c = salesOrderId,
                        OrderApi__Entity__c = ORDER_ENTITY,
                        OrderApi__Contact__c = contactId
                    );
                    insert membershipOrderLine;
                }
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('error_message', e.getMessage() + ': ' + e.getLineNumber() + ': ' + e.getCause() + ': ' + e.getTypeName());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> nextController(String itemsString, String contactId, String salesOrderId, Boolean isStudentJoin, String membershipItemId, String urlField, Boolean isStudentPortalUse, String lawStudentItemId) {
        Map<String, Object> result = new Map<String, Object>();
        // Savepoint sp = Database.setSavepoint();
        try {
            List<OrderApi__Sales_Order_Line__c> tempSalesOrderLines = new List<OrderApi__Sales_Order_Line__c>();

            List<FS_Section> items = (List<FS_Section>) JSON.deserialize(itemsString, List<FS_Section>.class);
            OrderApi__Sales_Order__c salesOrder = null;
            Map<Id, OrderApi__Sales_Order_Line__c> itemIdToSalesOrderLine = new Map<Id, OrderApi__Sales_Order_Line__c>();            
            if (salesOrderId == null) {
                if (membershipItemId == null) {
                    salesOrder = new OrderApi__Sales_Order__c(
                            OrderApi__Contact__c = contactId,
                            OrderApi__Entity__c = 'Contact',
                            OrderApi__Status__c = 'Open'
                    );
                    insert salesOrder;
                } else {
                    salesOrder = new OrderApi__Sales_Order__c(
                            OrderApi__Contact__c = contactId,
                            OrderApi__Entity__c = ORDER_ENTITY,
                            OrderApi__Status__c = ORDER_STATUS,
                            OrderApi__Date__c = System.today()
                    );
                    insert salesOrder;
                    // create the sales order line containing the membership item
                    OrderApi__Sales_Order_Line__c membershipOrderLine = new OrderApi__Sales_Order_Line__c(
                            OrderApi__Item__c = membershipItemId,
                            OrderApi__Sales_Order__c = salesOrder.Id,
                            OrderApi__Entity__c = ORDER_ENTITY,
                            OrderApi__Contact__c = contactId
                            // This pending status is no longer needed.
                    // FS_Additional_Data__c = '{"membership":{"status":"pending"}}'
                    );
                    // since this IF branch is done for the attorney page.
                    // we need to validate if the contact already has a "Law Student" active membership.
                    // If so, set Is Renew = true and Subscription to the proper mem. record Id.
                    // Otherwise, do not set any additional fields
                    List<OrderApi__Subscription__c> studentMembershipList = [SELECT Id 
                                                                    FROM OrderApi__Subscription__c 
                                                                    WHERE OrderApi__Contact__c = :contactId
                                                                    AND OrderApi__Status__c = 'Active'
                                                                    AND OrderApi__Item__c = :lawStudentItemId];
                    if (!studentMembershipList.isEmpty()) {
                        OrderApi__Subscription__c studentMembership = studentMembershipList.get(0);
                        membershipOrderLine.OrderApi__Is_Renewal__c = true;
                        membershipOrderLine.OrderApi__Subscription__c = studentMembership.Id;
                    }                    
                    insert membershipOrderLine;
                    //tempSalesOrderLines.add(membershipOrderLine);
                }                
            } else {
                salesOrder = new OrderApi__Sales_Order__c(Id = salesOrderId);
                List<OrderApi__Sales_Order_Line__c> tempSalesOrderLinesExisting = [
                        SELECT Id, OrderApi__Item__c, FS_Additional_Data__c
                        FROM OrderApi__Sales_Order_Line__c
                        WHERE OrderApi__Sales_Order__c = :salesOrderId 
                        AND OrderApi__Item__r.OrderApi__Is_Active__c = TRUE 
                        AND OrderApi__Item__r.FS_Linked_Community_Group__c != NULL 
                        AND OrderApi__Item__r.FS_Hidden_From_Student_Membership__c = FALSE 
                        AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Type__c = 'Section' 
                        AND OrderApi__Item__r.FS_Linked_Community_Group__r.PagesApi__Is_Published__c = TRUE
                        AND OrderApi__Item__r.FS_Linked_Community_Group__r.FS_Is_Executive__c = FALSE
                ];
                for (OrderApi__Sales_Order_Line__c tempSalesOrderLine : tempSalesOrderLinesExisting) {
                    itemIdToSalesOrderLine.put(tempSalesOrderLine.OrderApi__Item__c, tempSalesOrderLine);
                }
            }
            Boolean hasNewSalesOrderLineItem = false;
            for (FS_Section tempSection : items) {
                if (tempSection.checked) {
                    Map<String, Set<Id>> additionalData = new Map<String, Set<Id>> {
                            'sectionCommittees' => new Set<Id>()
                    };
                    // we are no longer using Needs Approval
                    // if (!isStudentJoin) {
                    //     additionalData.put('status', 'Needs Approval');
                    // }
                    for (FS_SectionCommittee tempSectionCommittee : tempSection.sectionCommittees) {
                        if (tempSectionCommittee.checked) {
                            additionalData.get('sectionCommittees').add(tempSectionCommittee.communityGroup.Id);
                            for (FS_SectionSubCommittee tempSectionSubCommittee : tempSectionCommittee.sectionSubCommittees) {
                                if (tempSectionSubCommittee.checked) {
                                    additionalData.get('sectionCommittees').add(tempSectionSubCommittee.communityGroup.Id);
                                }
                            }
                        }
                    }
                    OrderApi__Sales_Order_Line__c tempSalesOrderLine = null;
                    if (itemIdToSalesOrderLine.containsKey(tempSection.sectionItem.Id)) {
                        String formattedAdditionalData = JSON.serialize(additionalData);
                        if (itemIdToSalesOrderLine.get(tempSection.sectionItem.Id).FS_Additional_Data__c != formattedAdditionalData) {
                            tempSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                                    Id = itemIdToSalesOrderLine.get(tempSection.sectionItem.Id).Id,
                                    FS_Additional_Data__c = formattedAdditionalData
                            );
                        }
                        itemIdToSalesOrderLine.remove(tempSection.sectionItem.Id);
                    } else {
                        hasNewSalesOrderLineItem = true;
                        tempSalesOrderLine = new OrderApi__Sales_Order_Line__c(
                                OrderApi__Sales_Order__c = salesOrder.Id,
                                OrderApi__Item__c = tempSection.sectionItem.Id,
                                OrderApi__Price_Override__c = (!isStudentPortalUse && isStudentJoin) ? true : false,
                                OrderApi__Sale_Price__c = 0,
                                OrderApi__Contact__c = contactId,
                                OrderApi__Entity__c = 'Contact',
                                FS_Additional_Data__c = JSON.serialize(additionalData)
                        );
                    }
                    if (tempSalesOrderLine != null) {
                        tempSalesOrderLines.add(tempSalesOrderLine);
                    }
                }
            }
            
            // Before adding/removing an Item to the Sales Order, we need to Re-Open it and delete Draft invoice records
            if ((hasNewSalesOrderLineItem && salesOrderId != null) || !itemIdToSalesOrderLine.isEmpty()) {
                FS_MemberhipJoinHelper.reopenSalesOrder(salesOrder);
            }

            upsert tempSalesOrderLines;
            if (!itemIdToSalesOrderLine.isEmpty()) {
                delete itemIdToSalesOrderLine.values();
            }
            salesOrder.OrderApi__Posting_Status__c = 'Pending';
            salesOrder.OrderApi__Status__c = 'Closed';
            update salesOrder;
            
            // Query Order to get the URL the user will be redirected to.
            if (urlField != null) {
                String soqlQuery = 'SELECT ' + urlField + ' FROM OrderApi__Sales_Order__c WHERE Id = \'' + salesOrder.Id + '\' LIMIT 1';
                OrderApi__Sales_Order__c newlyCreatedUpdatedSalesOrder = Database.query(soqlQuery);
                result.put('Response', newlyCreatedUpdatedSalesOrder.get(urlField));
            }
            result.put('salesOrderId', salesOrder.Id);
            
            //Database.rollback(sp);
        } catch (Exception e) {            
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            // Database.rollback(sp);
        }
        return result;
    }

}