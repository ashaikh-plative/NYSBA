/**
 * @author Christopher Mudd from fusionSpan
 * @date 01/27/20
 *
 * @description when community group members are made inactive, this batch class will be responsible for deactivating the badges associated
 * to the Contact.
 */


global without sharing class FS_DeactivateBadgesForCGM implements Database.Batchable<SObject>,Schedulable {

    private static final String COMMUNITY_GROUP_MEMBER_STRING = 'PagesApi__Community_Group_Member__c';
    private static final String ACTIVE_FIELD = 'PagesApi__Is_Active__c';
    private static final String END_DATE_FIELD = 'PagesApi__Deactivated_Date__c';
    private static final String MODIFIED_DATE_FIELD = 'LastModifiedDate';

    global void execute(Database.BatchableContext param1, List<SObject> param2) {
        deactivateBadges((List<PagesApi__Community_Group_Member__c>) param2);
    }

    global void finish(Database.BatchableContext param1) {
    }

    global Database.QueryLocator start(Database.BatchableContext param1) {
        Datetime lastHour = System.now().addHours(-1);
        return Database.getQueryLocator(getCommGroupMemQuery());
    }

    global void execute(SchedulableContext param1) {
        FS_DeactivateBadgesForCGM batch = new FS_DeactivateBadgesForCGM();
        Database.executeBatch(batch);
    }


    private void deactivateBadges(List<PagesApi__Community_Group_Member__c> membersList) {

        Set<Id> contactIds = new Set<Id>();
        Set<Id> commGroupIds = new Set<Id>();

        // get the contact and community group ids for all recently deactivated community group members
        for (PagesApi__Community_Group_Member__c member : membersList) {
                contactIds.add(member.PagesApi__Contact__c);
                commGroupIds.add(member.PagesApi__Community_Group__c);
        }


        // retrieve a list of all active members for deactivation verification later
        List<PagesApi__Community_Group_Member__c> activeMembers = [
                SELECT Id,PagesApi__Is_Active__c,PagesApi__Contact__c,PagesApi__Community_Group__c,PagesApi__Deactivated_Date__c
                FROM PagesApi__Community_Group_Member__c
                WHERE PagesApi__Contact__c IN :contactIds AND PagesApi__Community_Group__c IN :commGroupIds
                AND PagesApi__Is_Active__c = TRUE
        ];
        Set<String> activeCommunityGroupContactIdPair = new Set<String>();
        for (PagesApi__Community_Group_Member__c member : activeMembers) {
            activeCommunityGroupContactIdPair.add(member.PagesApi__Contact__c + '' + member.PagesApi__Community_Group__c);
        }


        // we will use the Linked Community Group field on items, because the badge has a lookup to item but not community group
        Map<Id, OrderApi__Item__c> itemsMap = new Map<Id, OrderApi__Item__c>([
                SELECT Id,FS_Linked_Community_Group__c
                FROM OrderApi__Item__c
                WHERE FS_Linked_Community_Group__c IN :commGroupIds
        ]);

        // get all active badges for deactivation
        List<OrderApi__Badge__c> badgesToDeactivate = [
                SELECT OrderApi__Is_Active__c,OrderApi__Contact__c,OrderApi__Item__c
                FROM OrderApi__Badge__c
                WHERE OrderApi__Contact__c IN :contactIds AND OrderApi__Item__c IN :itemsMap.keySet()
                AND OrderApi__Is_Active__c = TRUE
        ];
        List<OrderApi__Badge__c> badgesToUpdate = new List<OrderApi__Badge__c>();

        for (OrderApi__Badge__c badge : badgesToDeactivate) {
            // verify that the Contact has no active community group members for the section we are deactivating
            if (activeCommunityGroupContactIdPair != null && activeCommunityGroupContactIdPair.size() > 0 &&
                    !activeCommunityGroupContactIdPair.contains(badge.OrderApi__Contact__c + '' + itemsMap.get(badge.OrderApi__Item__c).FS_Linked_Community_Group__c)) {
                badge.OrderApi__Is_Active__c = false;
                badge.OrderApi__Expired_Date__c = System.today().addDays(-1);
                badgesToUpdate.add(badge);
            } else if (activeCommunityGroupContactIdPair == null || activeCommunityGroupContactIdPair.size() == 0){
                badge.OrderApi__Is_Active__c = false;
                badge.OrderApi__Expired_Date__c = System.today().addDays(-1);
                badgesToUpdate.add(badge);
            }
        }

        if (badgesToUpdate.size() > 0) {
            update badgesToUpdate;
        }
    }

    /** dynamically queries for community group members to ensure all fields are queried
     *
     *
     * @param setName
     *
     * @return
     */
    private static String getCommGroupMemQuery() {

        SObjectType appType = Schema.getGlobalDescribe().get(COMMUNITY_GROUP_MEMBER_STRING);
        Map<String, Schema.SObjectField> mfields = appType.getDescribe().fields.getMap();

        String commGroupMemQuery = 'SELECT ';

        for (String fieldName : mfields.keySet()) {
            commGroupMemQuery += fieldName + ',';
        }
        commGroupMemQuery = commGroupMemQuery.removeEnd(',');

        commGroupMemQuery += ' FROM ' + COMMUNITY_GROUP_MEMBER_STRING + ' WHERE (' + ACTIVE_FIELD + ' = FALSE AND (' +
                END_DATE_FIELD + ' = YESTERDAY OR ' + END_DATE_FIELD + ' = TODAY)) AND ' + MODIFIED_DATE_FIELD + ' > :lastHour';
        return commGroupMemQuery;
    }

}