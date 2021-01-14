/**
 * @author Christopher Mudd from fusionSpan
 * @date 10/17/2019
 *
 * @description When a community group member is deactivated, this routing rule will deactivate all community group members for
 * children committees of the original deactivated group member's committee. This will continue searching for community group members
 * all child committee branches are exhausted
 */

global without sharing class FS_CommunityGroupParentMemberDrop extends Framework.Domain {

    private static Set<String> communityGroupIds;
    private static Set<String> contactIds;
    private static Set<String> contactCommGroupPair;


    public FS_CommunityGroupParentMemberDrop(List<PagesApi__Community_Group_Member__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_CommunityGroupParentMemberDrop(sObjectList);
        }
    }

    global virtual override void afterUpdate(Map<Id, SObject> existingRecords) {

        Framework.Log.push(FS_CommunityGroupParentMemberDrop.class.getName(), 'afterInsert');
        handleAfterUpdate((Map<Id, PagesApi__Community_Group_Member__c>) existingRecords, (List<PagesApi__Community_Group_Member__c>) records);
        Framework.Log.pop();

    }

    private static void handleAfterUpdate(Map<Id, PagesApi__Community_Group_Member__c> oldMembersById, List<PagesApi__Community_Group_Member__c> updatedMembers) {
        communityGroupIds = new Set<String>();
        contactIds = new Set<String>();
        contactCommGroupPair = new Set<String>();

        for (PagesApi__Community_Group_Member__c member : updatedMembers) {
            PagesApi__Community_Group_Member__c oldMember = oldMembersById.get(member.Id);
            if (oldMember.PagesApi__Is_Active__c && !member.PagesApi__Is_Active__c) {
                communityGroupIds.add(member.PagesApi__Community_Group__c);
                contactIds.add(member.PagesApi__Contact__c);
                contactCommGroupPair.add(member.PagesApi__Contact__c + '' + member.PagesApi__Community_Group__c);
            }
        }
        // retrieve a map of all community group members to deactivate, including children members to deactivate
        Map<Id, PagesApi__Community_Group_Member__c> membersToDeactivateMap = getCommunityMembersToDeactivateByIdMap();

        // deactivate all terms for the members as well
        List<FS_Community_Group_Member_Term__c> termsToEndDate = getCommunityTermsToEndDate(membersToDeactivateMap.keySet());

        update termsToEndDate;
        update membersToDeactivateMap.values();
    }

    private static Map<Id, PagesApi__Community_Group_Member__c> getCommunityMembersToDeactivateByIdMap() {
        Map<Id, PagesApi__Community_Group_Member__c> membersToDeactivateMap = new Map<Id, PagesApi__Community_Group_Member__c>();
        List<PagesApi__Community_Group__c> commGroups = [
                SELECT Id
                FROM PagesApi__Community_Group__c
                WHERE FS_Parent_Section__c IN :communityGroupIds
        ];
        while (commGroups != null && commGroups.size() > 0) {
            communityGroupIds.clear();

            membersToDeactivateMap.putAll(getChildrenToDeactivateMap(commGroups));

            commGroups.clear();

            commGroups = [
                    SELECT Id
                    FROM PagesApi__Community_Group__c
                    WHERE FS_Parent_Section__c IN :communityGroupIds
            ];
        }

        for (String memId : membersToDeactivateMap.keySet()) {
            PagesApi__Community_Group_Member__c memToDeactivate = membersToDeactivateMap.get(memId);
            if (contactCommGroupPair.contains(memToDeactivate.PagesApi__Contact__c + '' +
                    memToDeactivate.PagesApi__Community_Group__r.FS_Parent_Section__c)) {
                memToDeactivate.FS_Grace_Period_End_Date__c = null;
                memToDeactivate.FS_Paid_Through_Date__c = System.today();
                memToDeactivate.PagesApi__Is_Active__c = false;
                contactCommGroupPair.add(memToDeactivate.PagesApi__Contact__c + '' + memToDeactivate.PagesApi__Community_Group__r.FS_Parent_Section__c);

            }
        }

        return membersToDeactivateMap;
    }


    private static Map<Id, PagesApi__Community_Group_Member__c> getChildrenToDeactivateMap(List<PagesApi__Community_Group__c> communityGroups) {

        for (PagesApi__Community_Group__c commGroup : communityGroups) {
            communityGroupIds.add(commGroup.Id);
        }

        return new Map<Id, PagesApi__Community_Group_Member__c>([
                SELECT Id,FS_Grace_Period_End_Date__c,FS_Paid_Through_Date__c,
                        PagesApi__Is_Active__c,PagesApi__Community_Group__c,PagesApi__Contact__c,
                        PagesApi__Community_Group__r.FS_Parent_Section__c
                FROM PagesApi__Community_Group_Member__c
                WHERE PagesApi__Community_Group__c IN :communityGroupIds
                AND PagesApi__Contact__c IN :contactIds
                AND PagesApi__Is_Active__c = TRUE
        ]);
    }

    private static List<FS_Community_Group_Member_Term__c> getCommunityTermsToEndDate(Set<Id> communityMemberIds) {
        List<FS_Community_Group_Member_Term__c> termsToEndDate = [
                SELECT Id,FS_Term_End_Date__c,FS_Term_Grace_Period_End_Date__c
                FROM FS_Community_Group_Member_Term__c
                WHERE FS_Community_Group_Member__c IN :communityMemberIds
        ];
        for (FS_Community_Group_Member_Term__c term : termsToEndDate) {
            term.FS_Term_End_Date__c = System.today();
            term.FS_Term_Grace_Period_End_Date__c = null;
            term.FS_Deactivated_Manually__c = true;
        }
        return termsToEndDate;
    }
}