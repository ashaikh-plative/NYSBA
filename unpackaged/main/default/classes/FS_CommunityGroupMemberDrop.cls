/**
 * @author Christopher Mudd from fusionSpan
 * @date 2019-10-17.
 *
 * @description When a Contact drops their membership, deactivate all community group members for that contact
 */

global without sharing class FS_CommunityGroupMemberDrop extends Framework.Domain {

    private static final String ACTIVE_STRING = 'Active';
    private static final String GRACE_STRING = 'Grace';

    public FS_CommunityGroupMemberDrop(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_CommunityGroupMemberDrop(sObjectList);
        }
    }

    global virtual override void afterUpdate(Map<Id, SObject> existingRecords) {

        Framework.Log.push(FS_CommunityGroupMemberDrop.class.getName(), 'afterUpdate');
        handleAfterUpdate((Map<Id, Contact>) existingRecords, (List<Contact>) records);
        Framework.Log.pop();

    }

    private static void handleAfterUpdate(Map<Id, Contact> oldMembersById, List<Contact> updatedMembers) {
        List<String> expiredContactIds = new List<String>();

        // check if the Contact is a member. If not, add to list for querying Community Group Members to deactivate
        for (Contact member : updatedMembers) {
            Contact oldMember = oldMembersById.get(member.Id);
//            if (oldMember.FS_Member_Status__c != NON_MEMBER_STRING && member.FS_Member_Status__c == NON_MEMBER_STRING) {
            if ((oldMember.FS_Contact_Member_Status__c == ACTIVE_STRING || oldMember.FS_Contact_Member_Status__c == GRACE_STRING) && (member.FS_Contact_Member_Status__c != ACTIVE_STRING && member.FS_Contact_Member_Status__c != GRACE_STRING)) {
                expiredContactIds.add(oldMember.Id);
            }
        }

        //Query for Community Group Members to deactivate
        List<PagesApi__Community_Group_Member__c> membersToDeactivate = [SELECT Id,PagesApi__Contact__c,PagesApi__Is_Active__c,FS_Grace_Period_End_Date__c,FS_Paid_Through_Date__c
                FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Contact__c IN :expiredContactIds];

        Map<Id, PagesApi__Community_Group_Member__c> membersToUpdate = new Map<Id, PagesApi__Community_Group_Member__c>();
        for (PagesApi__Community_Group_Member__c member : membersToDeactivate) {
            member.PagesApi__Is_Active__c = false;
            member.FS_Term_End_Date__c = System.today();
            member.FS_Grace_Period_End_Date__c = null;
            member.FS_Paid_Through_Date__c = System.today();
            membersToUpdate.put(member.Id, member);
        }

        List<FS_Community_Group_Member_Term__c> termsToDeactivate = [
                SELECT Id,FS_Term_End_Date__c,FS_Term_Grace_Period_End_Date__c,FS_Deactivated_Manually__c
                FROM FS_Community_Group_Member_Term__c
                WHERE FS_Community_Group_Member__c IN :membersToUpdate.keySet()
        ];

        for (FS_Community_Group_Member_Term__c term : termsToDeactivate) {
            term.FS_Term_End_Date__c = System.today();
            term.FS_Term_Grace_Period_End_Date__c = null;
            term.FS_Deactivated_Manually__c = true;
        }

        update termsToDeactivate;
        update membersToUpdate.values();
    }
}