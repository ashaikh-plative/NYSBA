/**
* Created by Nikhil on 21-12-2019.
*/

global without sharing class FS_BadgeForExecutiveCommunityGroupMember extends Framework.Domain {
    public FS_BadgeForExecutiveCommunityGroupMember(List<PagesApi__Community_Group_Member__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_BadgeForExecutiveCommunityGroupMember(sObjectList);
        }
    }
    public override void afterInsert() {
        Framework.Log.push(FS_BadgeForExecutiveCommunityGroupMember.class.getName(), 'afterInsert');
        createBadgeOnCGMCreationCGWithExecutiveInName((List<PagesApi__Community_Group_Member__c>) records);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_BadgeForExecutiveCommunityGroupMember.class.getName(), 'afterUpdate');
        updateBadgeOnCGMUpdation((List<PagesApi__Community_Group_Member__c>) records, existingRecords);
        Framework.Log.pop();
    }
    public override void beforeDelete() {
        Framework.Log.push(FS_BadgeForExecutiveCommunityGroupMember.class.getName(), 'beforeDelete');
        deleteBadgeIfCGMDeleted((List<PagesApi__Community_Group_Member__c>) records);
        Framework.Log.pop();
    }

    private static void createBadgeOnCGMCreationCGWithExecutiveInName(List<PagesApi__Community_Group_Member__c> records) {
        Set<Id> conIds = new Set<Id>();
        List<PagesApi__Community_Group_Member__c> communityGroupMembers = [
                SELECT Id,PagesApi__Community_Group__c,PagesApi__Community_Group__r.FS_Is_Executive__c,
                        PagesApi__Community_Group__r.FS_Committee_Code__c,PagesApi__Contact__c
                FROM PagesApi__Community_Group_Member__c
                WHERE Id = :records AND PagesApi__Community_Group__r.FS_Is_Executive__c = true AND PagesApi__Community_Group__r.FS_Committee_Code__c != null
        ];

        for (PagesApi__Community_Group_Member__c communityGroupMember : communityGroupMembers) {
            conIds.add(communityGroupMember.PagesApi__Contact__c);
        }
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id = :conIds]);
        List<OrderApi__Badge__c> badges = new List<OrderApi__Badge__c>();
        for (PagesApi__Community_Group_Member__c communityGroupMember : communityGroupMembers) {
            Contact con = contactsMap.get(communityGroupMember.PagesApi__Contact__c);
            OrderApi__Badge__c badge = new OrderApi__Badge__c();
            badge.OrderApi__Contact__c = con.Id;
            badge.FS_Committee_Code__c = communityGroupMember.PagesApi__Community_Group__r.FS_Committee_Code__c;
            badge.OrderApi__Awarded_Date__c = Date.today();
            badges.add(badge);
        }
        if (!badges.isEmpty()) {
            insert badges;
        }
    }
    private static void updateBadgeOnCGMUpdation(List<PagesApi__Community_Group_Member__c> records, Map<Id, SObject> existingRecords) {
        Set<Id> conId = new Set<Id>();
        List<PagesApi__Community_Group_Member__c> communityGroupMembersList = new List<PagesApi__Community_Group_Member__c>();
        List<PagesApi__Community_Group_Member__c> backToActiveCommunityGroupMembersList = new List<PagesApi__Community_Group_Member__c>();
        for (PagesApi__Community_Group_Member__c communityGroupMember : [SELECT Id,PagesApi__Status__c,PagesApi__Community_Group__c,
                        PagesApi__Community_Group__r.FS_Committee_Code__c,PagesApi__Contact__c FROM PagesApi__Community_Group_Member__c WHERE Id = :records]) {

            PagesApi__Community_Group_Member__c oldCGMStatus = (PagesApi__Community_Group_Member__c) existingRecords.get(communityGroupMember.Id);
            if (communityGroupMember.PagesApi__Status__c != oldCGMStatus.PagesApi__Status__c && communityGroupMember.PagesApi__Status__c == 'Deactivated') {
                communityGroupMembersList.add(communityGroupMember);

            }
            if (communityGroupMember.PagesApi__Status__c != oldCGMStatus.PagesApi__Status__c && communityGroupMember.PagesApi__Status__c == 'Active') {
                backToActiveCommunityGroupMembersList.add(communityGroupMember);
            }
            conId.add(communityGroupMember.PagesApi__Contact__c);
        }
        Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, (SELECT Id,FS_Committee_Code__c,OrderApi__Expired_Date__c FROM OrderApi__Badges__r) FROM Contact WHERE Id = :conId]);
         Map<Id,OrderApi__Badge__c> badges = new Map<Id,OrderApi__Badge__c>();
        for (PagesApi__Community_Group_Member__c communityGroupMember : communityGroupMembersList) {
            Contact con = conMap.get(communityGroupMember.PagesApi__Contact__c);
            for (OrderApi__Badge__c badge : con.OrderApi__Badges__r) {
                if (badge.FS_Committee_Code__c != null && badge.FS_Committee_Code__c == communityGroupMember.PagesApi__Community_Group__r.FS_Committee_Code__c) {
                    badge.OrderApi__Is_Active__c = False;
                    badge.OrderApi__Awarded_Date__c = null;
                    badge.OrderApi__Expired_Date__c = system.today()-1;
                    badges.put(badge.Id,badge);
                }
            }
        }
        for (PagesApi__Community_Group_Member__c communityGroupMember : backToActiveCommunityGroupMembersList) {
            Contact con = conMap.get(communityGroupMember.PagesApi__Contact__c);
            for (OrderApi__Badge__c badge : con.OrderApi__Badges__r) {
                if (badge.FS_Committee_Code__c != null && badge.FS_Committee_Code__c == communityGroupMember.PagesApi__Community_Group__r.FS_Committee_Code__c) {
                    badge.OrderApi__Is_Active__c = True;
                    badge.OrderApi__Awarded_Date__c = Date.today();
                    badge.OrderApi__Expired_Date__c = null;
                  	badges.put(badge.Id,badge);
                }
            }
        }
        if (!badges.values().isEmpty()) {
            update badges.values();
        }
    }
    private static void deleteBadgeIfCGMDeleted(List<PagesApi__Community_Group_Member__c> records) {
        Set<Id> conId = new Set<Id>();
        List<PagesApi__Community_Group_Member__c> communityGroupMembers = [SELECT Id,PagesApi__Status__c,PagesApi__Community_Group__c,
                        PagesApi__Community_Group__r.FS_Committee_Code__c,PagesApi__Contact__c FROM PagesApi__Community_Group_Member__c WHERE Id = :records];
        for (PagesApi__Community_Group_Member__c communityGroupMember : communityGroupMembers) {
            conId.add(communityGroupMember.PagesApi__Contact__c);
        }
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, (SELECT Id,FS_Committee_Code__c FROM OrderApi__Badges__r) FROM Contact WHERE Id = :conId]);
        List<OrderApi__Badge__c> badges = new List<OrderApi__Badge__c>();
        for (PagesApi__Community_Group_Member__c communityGroupMember : communityGroupMembers) {
            Contact con = contactMap.get(communityGroupMember.PagesApi__Contact__c);
            for (OrderApi__Badge__c badge : con.OrderApi__Badges__r) {
                if (badge.FS_Committee_Code__c == communityGroupMember.PagesApi__Community_Group__r.FS_Committee_Code__c) {
                    badges.add(badge);
                }
            }
        }
        if (!badges.isEmpty()) {
            delete badges;
        }
    }
}