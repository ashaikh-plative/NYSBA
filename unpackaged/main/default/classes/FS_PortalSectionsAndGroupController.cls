public without sharing class FS_PortalSectionsAndGroupController {

    //private static final Integer WITHIN_DAYS = 90;
    private static final String DEACTIVATED = 'Deactivated';
    private static final String CLOSED = 'Closed';
    private static final String PENDING = 'Pending';

    public class FS_Section {
        OrderApi__Item__c sectionItem;
        //PagesApi__Community_Group__c linkedSectionCommunityGroup;
        PagesApi__Community_Group_Member__c communityGroupMember;
        Boolean checked = false;
        String name;
        List<FS_SectionCommittee> sectionCommittees;
    }

    public class FS_SectionCommittee {
        PagesApi__Community_Group_Member__c communityGroupMember;
        Boolean checked = false;
        String name;
        List<FS_SectionSubCommittee> sectionSubCommittees;
    }

    public class FS_SectionSubCommittee {
        Boolean checked = false;
        String name;
        PagesApi__Community_Group_Member__c communityGroupMember;
    }

    @AuraEnabled
    public static Map<String, Object> setup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()][0].ContactId;
            //contactId = '003S000001HaUk5IAF';
            result.put('contactId', contactId);

            Boolean hasEligibleMembership = ![
                    SELECT Id, (SELECT Id FROM OrderApi__Subscriptions__r WHERE OrderApi__Is_Active__c = TRUE)
                    FROM Contact
                    WHERE Id = :contactId
            ][0].OrderApi__Subscriptions__r.isEmpty();
            result.put('hasEligibleMembership', hasEligibleMembership);
            if (hasEligibleMembership) {
                Map<Id, FS_Section> communityGroupIdToFSSection = new Map<Id, FS_Section>();
                List<PagesApi__Community_Group_Member__c> communityGroupMembersParents = [
                        SELECT Id, PagesApi__Contact__c, PagesApi__Community_Group__c, PagesApi__Community_Group__r.Name
                        FROM PagesApi__Community_Group_Member__c
                        WHERE PagesApi__Is_Active__c = TRUE AND PagesApi__Contact__c = :contactId AND
                        PagesApi__Community_Group__r.PagesApi__Type__c = 'Section' AND PagesApi__Community_Group__r.PagesApi__Is_Published__c = TRUE
                        AND PagesApi__Community_Group__r.FS_Is_Executive__c = FALSE
                ];
                for (PagesApi__Community_Group_Member__c tempCGM : communityGroupMembersParents) {
                    FS_Section tempSection = new FS_Section();
                    tempSection.checked = true;
                    tempSection.communityGroupMember = tempCGM;
                    //tempSection.linkedSectionCommunityGroup = new PagesApi__Community_Group__c(Id = tempCGM.PagesApi__Community_Group__c, Name = tempCGM.PagesApi__Community_Group__r.Name);
                    tempSection.sectionCommittees = new List<FS_SectionCommittee>();
                    communityGroupIdToFSSection.put(tempCGM.PagesApi__Community_Group__c, tempSection);
                }
                for (OrderApi__Item__c tempItem : [
                        SELECT Id, Name, OrderApi__Price__c, FS_Linked_Community_Group__c,
                                OrderApi__Display_Name__c,
                                FS_Linked_Community_Group__r.Name
                        FROM OrderApi__Item__c
                        WHERE FS_Linked_Community_Group__c IN :communityGroupIdToFSSection.keySet()
                ]) {
                    communityGroupIdToFSSection.get(tempItem.FS_Linked_Community_Group__c).sectionItem = tempItem;
                }

                System.debug('===Community group id to fs section===' + communityGroupIdToFSSection);


                Map<Id, PagesApi__Community_Group_Member__c> communityGroupMembers = new Map<Id, PagesApi__Community_Group_Member__c>([
                        SELECT Id, PagesApi__Community_Group__c, PagesApi__Community_Group__r.Name, PagesApi__Community_Group__r.FS_Parent_Section__c, PagesApi__Is_Active__c
                        FROM PagesApi__Community_Group_Member__c
                        WHERE PagesApi__Contact__c = :contactId AND PagesApi__Community_Group__r.FS_Is_Executive__c = FALSE AND
                        PagesApi__Community_Group__r.FS_Parent_Section__c IN :communityGroupIdToFSSection.keySet() ORDER BY PagesApi__Is_Active__c
                ]);
                Set<Id> tempCommunityGroupIds = new Set<Id>();
                for (PagesApi__Community_Group_Member__c tempCommunityGroupMember : communityGroupMembers.values()) {
                    tempCommunityGroupIds.add(tempCommunityGroupMember.PagesApi__Community_Group__c);
                }

                Map<Id, PagesApi__Community_Group__c> communityGroupsForDummyCGMByIds = new Map<Id, PagesApi__Community_Group__c>([
                        SELECT Id,FS_Parent_Section__c,Name
                        FROM PagesApi__Community_Group__c
                        WHERE FS_Parent_Section__c IN :communityGroupIdToFSSection.keySet() AND (NOT Id IN :tempCommunityGroupIds)
                        AND FS_Is_Executive__c = FALSE
                ]);

                List<PagesApi__Community_Group_Member__c> communityGroupMembersChild = [
                        SELECT Id, PagesApi__Community_Group__c, PagesApi__Community_Group__r.Name, PagesApi__Community_Group__r.FS_Parent_Section__c, PagesApi__Is_Active__c
                        FROM PagesApi__Community_Group_Member__c
                        WHERE PagesApi__Contact__c = :contactId AND PagesApi__Community_Group__r.FS_Parent_Section__c IN :tempCommunityGroupIds
                        AND PagesApi__Community_Group__r.FS_Is_Executive__c = FALSE ORDER BY PagesApi__Is_Active__c
                ];

                Set<Id> currentCommunityGroupIds = new Set<Id>();
                for (PagesApi__Community_Group_Member__c member : communityGroupMembersChild) {
                    currentCommunityGroupIds.add(member.PagesApi__Community_Group__c);
                }

                Map<Id, PagesApi__Community_Group__c> childrenCommunityGroupsForDummyCGMByIds = new Map<Id, PagesApi__Community_Group__c>([
                        SELECT Id,FS_Parent_Section__c,Name
                        FROM PagesApi__Community_Group__c
                        WHERE (NOT FS_Parent_Section__c IN :currentCommunityGroupIds) AND FS_Is_Executive__c = FALSE AND
                        (FS_Parent_Section__c IN :communityGroupsForDummyCGMByIds.keySet() OR FS_Parent_Section__c IN :tempCommunityGroupIds)
                ]);


                Map<Id, List<FS_SectionSubCommittee>> sectionSubCommittee = new Map<Id, List<FS_SectionSubCommittee>>();
                for (PagesApi__Community_Group_Member__c tempCommunityGroupMember : communityGroupMembersChild) {
                    if (sectionSubCommittee.containsKey(tempCommunityGroupMember.PagesApi__Community_Group__r.FS_Parent_Section__c)) {
                        FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                        tempSectionSubCommittee.checked = tempCommunityGroupMember.PagesApi__Is_Active__c;
                        tempSectionSubCommittee.name = tempCommunityGroupMember.PagesApi__Community_Group__r.Name;
                        tempSectionSubCommittee.communityGroupMember = tempCommunityGroupMember;
                        sectionSubCommittee.get(tempCommunityGroupMember.PagesApi__Community_Group__r.FS_Parent_Section__c).add(tempSectionSubCommittee);
                    } else {
                        FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                        tempSectionSubCommittee.checked = true;
                        tempSectionSubCommittee.communityGroupMember = tempCommunityGroupMember;
                        sectionSubCommittee.put(tempCommunityGroupMember.PagesApi__Community_Group__r.FS_Parent_Section__c, new List<FS_SectionSubCommittee>{
                                tempSectionSubCommittee
                        });
                    }
                }
                for (PagesApi__Community_Group__c tempCommGroup : childrenCommunityGroupsForDummyCGMByIds.values()) {
                    FS_SectionSubCommittee tempSectionSubCommittee = new FS_SectionSubCommittee();
                    tempSectionSubCommittee.checked = false;
                    tempSectionSubCommittee.name = tempCommGroup.Name;
                    tempSectionSubCommittee.communityGroupMember = new PagesApi__Community_Group_Member__c(
                            PagesApi__Contact__c = contactId,
                            PagesApi__Community_Group__c = tempCommGroup.Id,
                            PagesApi__Is_Active__c = false,
                            PagesApi__Status__c = DEACTIVATED
                    );
                    if (sectionSubCommittee.containsKey(tempCommGroup.FS_Parent_Section__c)) {
                        sectionSubCommittee.get(tempCommGroup.FS_Parent_Section__c).add(tempSectionSubCommittee);
                    } else {
                        sectionSubCommittee.put(tempCommGroup.FS_Parent_Section__c, new List<FS_SectionSubCommittee>{
                                tempSectionSubCommittee
                        });
                    }
                }
                for (PagesApi__Community_Group_Member__c tempCommunityGroupMember : communityGroupMembers.values()) {
                    FS_SectionCommittee tempSectionCommittee = new FS_SectionCommittee();
                    tempSectionCommittee.communityGroupMember = tempCommunityGroupMember;
                    tempSectionCommittee.checked = tempCommunityGroupMember.PagesApi__Is_Active__c;
                    tempSectionCommittee.name = tempCommunityGroupMember.PagesApi__Community_Group__r.Name;
                    tempSectionCommittee.sectionSubCommittees = sectionSubCommittee.containsKey(tempCommunityGroupMember.PagesApi__Community_Group__c) ?
                            sectionSubCommittee.get(tempCommunityGroupMember.PagesApi__Community_Group__c) : new List<FS_SectionSubCommittee>();
                    communityGroupIdToFSSection.get(tempCommunityGroupMember.PagesApi__Community_Group__r.FS_Parent_Section__c).sectionCommittees.add(tempSectionCommittee);
                }

                for (PagesApi__Community_Group__c tempCommGroup : communityGroupsForDummyCGMByIds.values()) {
                    FS_SectionCommittee tempSectionCommittee = new FS_SectionCommittee();
                    tempSectionCommittee.checked = false;
                    tempSectionCommittee.name = tempCommGroup.Name;
                    tempSectionCommittee.communityGroupMember = new PagesApi__Community_Group_Member__c(
                            PagesApi__Contact__c = contactId,
                            PagesApi__Community_Group__c = tempCommGroup.Id,
                            PagesApi__Is_Active__c = false,
                            PagesApi__Status__c = DEACTIVATED
                    );
                    tempSectionCommittee.sectionSubCommittees = sectionSubCommittee.containsKey(tempCommGroup.Id) ?
                            sectionSubCommittee.get(tempCommGroup.Id) : new List<FS_SectionSubCommittee>();
                    communityGroupIdToFSSection.get(tempCommGroup.FS_Parent_Section__c).sectionCommittees.add(tempSectionCommittee);
                }
                result.put('Items', JSON.serialize(communityGroupIdToFSSection.values()));

                Decimal withinDaysParameter = [SELECT Id, Section_Cutoff_Date_Before_Year_End__c FROM FS_Components_Settings__mdt LIMIT 1].Section_Cutoff_Date_Before_Year_End__c;

                Boolean withinDays = Date.today().daysBetween(Date.newInstance(Date.today().year(), 12, 31)) <= Integer.valueOf(withinDaysParameter);
                Boolean hasRenewalSalesOrders = false;
                for (OrderApi__Sales_Order__c tempSalesOrder : [
                        SELECT Id, (SELECT Id FROM OrderApi__Sales_Order_Lines__r WHERE OrderApi__Is_Renewal__c = TRUE AND OrderApi__Item__r.FS_Is_Membership__c = TRUE)
                        FROM OrderApi__Sales_Order__c
                        WHERE OrderApi__Contact__c = :contactId AND OrderApi__Status__c = :CLOSED AND OrderApi__Posting_Status__c = :PENDING
                ]) {
                    if (!tempSalesOrder.OrderApi__Sales_Order_Lines__r.isEmpty()) {
                        hasRenewalSalesOrders = true;
                        break;
                    }
                }
                result.put('showContactNYSBAMessage', withinDays || hasRenewalSalesOrders);

                //for coverage
                Integer coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
                coverage = 1;
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> updateCGM(String itemsString, String tempItemsString, String contactId) {
        System.debug('123:' + itemsString);
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            List<FS_Section> items = (List<FS_Section>) JSON.deserialize(itemsString, List<FS_Section>.class);
            List<FS_Section> tempItems = (List<FS_Section>) JSON.deserialize(tempItemsString, List<FS_Section>.class);
            Map<String, FS_Section> sectionsByCommunityGroupIds = new Map<String, FS_Section>();
            Map<String, FS_SectionCommittee> sectionCommitteesByCommunityGroupIds = new Map<String, FS_SectionCommittee>();
            Map<String, FS_SectionSubCommittee> sectionSubCommitteesByCommunityGroupIds = new Map<String, FS_SectionSubCommittee>();
            for (FS_Section tempSection : tempItems) {
                sectionsByCommunityGroupIds.put(tempSection.communityGroupMember.PagesApi__Community_Group__c, tempSection);
                for (FS_SectionCommittee tempSectionCommittee : tempSection.sectionCommittees) {
                    sectionCommitteesByCommunityGroupIds.put(tempSectionCommittee.communityGroupMember.PagesApi__Community_Group__c, tempSectionCommittee);
                    for (FS_SectionSubCommittee tempSectionSubCommittee : tempSectionCommittee.sectionSubCommittees) {
                        sectionSubCommitteesByCommunityGroupIds.put(tempSectionSubCommittee.communityGroupMember.PagesApi__Community_Group__c, tempSectionSubCommittee);
                    }
                }
            }
            List<OrderApi__Renewal__c> termToUse = [
                    SELECT Id,OrderApi__Contact__c,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,OrderApi__Grace_Period_End_Date__c,OrderApi__Sales_Order_Line__c
                    FROM OrderApi__Renewal__c
                    WHERE OrderApi__Contact__c = :contactId AND OrderApi__Is_Active__c = TRUE
                    ORDER BY OrderApi__Term_End_Date__c DESC
            ];

            System.debug('===== Term to use =====' + termToUse);
            List<PagesApi__Community_Group_Member__c> CGMNeedToUpdate = new List<PagesApi__Community_Group_Member__c>();
            List<FS_TermRoutingRule.CommunityGroupWrapper> CGMNeedToInsert = new List<FS_TermRoutingRule.CommunityGroupWrapper>();
            for (FS_Section tempSection : items) {
                FS_Section oldTempSection = sectionsByCommunityGroupIds.get(tempSection.communityGroupMember.PagesApi__Community_Group__c);
                if (oldTempSection.checked != tempSection.checked) {
                    if (!tempSection.checked) {
                        CGMNeedToUpdate.add(new PagesApi__Community_Group_Member__c(
                                Id = tempSection.communityGroupMember.Id,
                                FS_Term_End_Date__c = Date.today(),
                                PagesApi__Deactivated_Date__c = Date.today()
                        ));
                    } else {
                        CGMNeedToInsert.add(new FS_TermRoutingRule.CommunityGroupWrapper(termToUse[0], tempSection.communityGroupMember, null, tempSection.communityGroupMember.PagesApi__Community_Group__c));
                    }
                }

                for (FS_SectionCommittee tempSectionCommittee : tempSection.sectionCommittees) {
                    FS_SectionCommittee oldTempSectionCommittee = sectionCommitteesByCommunityGroupIds.get(tempSectionCommittee.communityGroupMember.PagesApi__Community_Group__c);
                    if (oldTempSectionCommittee.checked != tempSectionCommittee.checked) {
                        if (!tempSectionCommittee.checked) {
                            CGMNeedToUpdate.add(new PagesApi__Community_Group_Member__c(
                                    Id = tempSectionCommittee.communityGroupMember.Id,
                                    FS_Term_End_Date__c = Date.today(),
                                    PagesApi__Deactivated_Date__c = Date.today()
                            ));
                        } else {
                            CGMNeedToInsert.add(new FS_TermRoutingRule.CommunityGroupWrapper(termToUse[0], tempSectionCommittee.communityGroupMember, null, tempSectionCommittee.communityGroupMember.PagesApi__Community_Group__c));
                        }
                    }
                    for (FS_SectionSubCommittee tempSectionSubCommittee : tempSectionCommittee.sectionSubCommittees) {
                        FS_SectionSubCommittee oldTempSectionSubCommittee = sectionSubCommitteesByCommunityGroupIds.get(tempSectionSubCommittee.communityGroupMember.PagesApi__Community_Group__c);
                        if (oldTempSectionSubCommittee.checked != tempSectionSubCommittee.checked) {
                            if (!tempSectionSubCommittee.checked) {
                                CGMNeedToUpdate.add(new PagesApi__Community_Group_Member__c(
                                        Id = tempSectionSubCommittee.communityGroupMember.Id,
                                        FS_Term_End_Date__c = Date.today(),
                                        PagesApi__Deactivated_Date__c = Date.today()
                                ));
                            } else {
                                CGMNeedToInsert.add(new FS_TermRoutingRule.CommunityGroupWrapper(termToUse[0], tempSectionSubCommittee.communityGroupMember, null, tempSectionSubCommittee.communityGroupMember.PagesApi__Community_Group__c));
                            }
                        }
                    }
                }
            }

            if (!CGMNeedToUpdate.isEmpty()) {
                List<FS_Community_Group_Member_Term__c> tempCommunityGroupMemberTerms = new List<FS_Community_Group_Member_Term__c>();
                for (PagesApi__Community_Group_Member__c tempCommunityGroupMember : [SELECT Id, (SELECT Id FROM Community_Group_Member_Terms__r ORDER BY FS_Term_End_Date__c DESC LIMIT 1) FROM PagesApi__Community_Group_Member__c WHERE Id IN :CGMNeedToUpdate]) {
                    if (!tempCommunityGroupMember.Community_Group_Member_Terms__r.isEmpty()) {
                        tempCommunityGroupMemberTerms.add(new FS_Community_Group_Member_Term__c(
                                Id = tempCommunityGroupMember.Community_Group_Member_Terms__r[0].Id,
                                FS_Term_End_Date__c = Date.today()
                        ));
                    }
                }
                if (!tempCommunityGroupMemberTerms.isEmpty()) {
                    update tempCommunityGroupMemberTerms;
                }
                update CGMNeedToUpdate;
            }

            List<PagesApi__Community_Group_Member__c> communityGroupMembersToUpsert = new List<PagesApi__Community_Group_Member__c>();
            for (FS_TermRoutingRule.CommunityGroupWrapper wrapper : CGMNeedToInsert) {
                communityGroupMembersToUpsert.add(wrapper.buildCommunityGroupMember());
            }

            if (communityGroupMembersToUpsert.size() > 0) {
                upsert communityGroupMembersToUpsert;
            }

            List<FS_Community_Group_Member_Term__c> communityTermsToInsert = new List<FS_Community_Group_Member_Term__c>();
            for (FS_TermRoutingRule.CommunityGroupWrapper wrapper : CGMNeedToInsert) {
                communityTermsToInsert.add(wrapper.createCommunityTerm());
            }

            if (communityTermsToInsert.size() > 0) {
                insert communityTermsToInsert;
            }

        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    private static void getInactiveChildrenMembers() {

    }
}