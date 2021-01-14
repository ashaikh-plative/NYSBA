/**
 * @author Christopher Mudd
 * @date 07/17/19
 *
 * @description Handles updating the community group member upon update of the community group member term.
 */

global without sharing class FS_CommunityMemberTermRoutingRule extends Framework.Domain {

    private static final String COMMUNITY_GROUP_MEMBER_TERM_STRING = 'FS_Community_Group_Member_Term__c';
    private static final String COMMUNITY_GROUP_MEMBER_STRING = 'PagesApi__Community_Group_Member__c';
    private static final String START_DATE_FIELD = 'FS_Term_Start_Date__c';
    private static final String END_DATE_FIELD = 'FS_Term_End_Date__c';
    private static final String LAST_DATE_FIELD = 'LastModifiedDate';
    private static final String GRACE_END_DATE_FIELD = 'FS_Term_Grace_Period_End_Date__c';
    private static final String ACTIVE_FIELD = 'FS_Community_Group_Member__r.PagesApi__Is_Active__c';


    public FS_CommunityMemberTermRoutingRule(List<FS_Community_Group_Member_Term__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_CommunityMemberTermRoutingRule(sObjectList);
        }
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        manuallyDeactivateTerms((List<FS_Community_Group_Member_Term__c>) records, existingRecords);
    }

    public override void afterInsert() {
        Framework.Log.push(FS_CommunityMemberTermRoutingRule.class.getName(), 'afterInsert');
        updateCommunityGroupMemberFromTerm((List<FS_Community_Group_Member_Term__c>) records, null);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_CommunityMemberTermRoutingRule.class.getName(), 'afterInsert');
        updateCommunityGroupMemberFromTerm((List<FS_Community_Group_Member_Term__c>) records, (Map<Id, FS_Community_Group_Member_Term__c>) existingRecords);
        Framework.Log.pop();
    }

    /** retrieves the related community group members and updates them from the community group member terms
     *
     *
     * @param termsToProcess
     */
    public void updateCommunityGroupMemberFromTerm(List<FS_Community_Group_Member_Term__c> termsToProcess,
            Map<Id, FS_Community_Group_Member_Term__c> oldTermsMap) {
        List<PagesApi__Community_Group_Member__c> membersList = getCommGroupMemsFromTerm(termsToProcess);
        Map<Id, Id> groupMemIdsByTermIds = mapGroupMemIdsByTermIds(termsToProcess);
        Map<Id, PagesApi__Community_Group_Member__c> membersById = new Map<Id, PagesApi__Community_Group_Member__c>();
        Map<Id, PagesApi__Community_Group_Member__c> membersToUpdate = new Map<Id, PagesApi__Community_Group_Member__c>();


        if (membersList != null) {
            membersById = mapGroupMembersByIds(membersList);
        }


        for (FS_Community_Group_Member_Term__c term : termsToProcess) {
            PagesApi__Community_Group_Member__c memberToUpdate = membersById.get(groupMemIdsByTermIds.get(term.Id));
            if (memberToUpdate != null && !String.isBlank(memberToUpdate.Id)) {
                FS_Community_Group_Member_Term__c oldTerm = new FS_Community_Group_Member_Term__c();
                if (oldTermsMap != null && oldTermsMap.get(term.Id) != null) {
                    oldTerm = oldTermsMap.get(term.Id);
                }
                updateMemberFields(memberToUpdate, term, oldTerm);
                membersToUpdate.put(memberToUpdate.Id, memberToUpdate);
            }
        }

        List<Database.SaveResult> updateResults = Database.update(new List<PagesApi__Community_Group_Member__c>(membersToUpdate.values()));

        for (Database.SaveResult sr : updateResults) {
            if (sr.getErrors() != null && sr.getErrors().size() > 0) {
                for (Database.Error error : sr.getErrors()) {
                    System.debug('=====Update error occurred for record w/ ID:' + sr.getId() + ' ===== ' + error.getMessage());
                }
            }
        }
    }

//    private static List<FS_Community_Term__c> filterTerms(List<FS_Community_Term__c> termsToProcess) {
//        List<FS_Community_Term__c> termsToUse = new List<FS_Community_Term__c>();
//
//        for (FS_Community_Term__c term : termsToProcess) {
//
//        }
//    }

    /** retrieves community group members using the community group member field on the list of community group member terms supplied as input
     *
     *
     * @param termsToProcess
     *
     * @return
     */
    private List<PagesApi__Community_Group_Member__c> getCommGroupMemsFromTerm(List<FS_Community_Group_Member_Term__c> termsToProcess) {
        Set<Id> commGroupMemIds = new Set<Id>();

        for (FS_Community_Group_Member_Term__c term : termsToProcess) {
            commGroupMemIds.add(term.FS_Community_Group_Member__c);
        }

        String commGroupMemQuery = getCommGroupMemQuery('commGroupMemIds');
        List<PagesApi__Community_Group_Member__c> membersList = Database.query(commGroupMemQuery);

        return membersList != null && membersList.size() > 0 ? membersList : null;
    }

    /** dynamically queries for community group members to ensure all fields are queried
     *
     *
     * @param setName
     *
     * @return
     */
    private String getCommGroupMemQuery(String setName) {

        SObjectType appType = Schema.getGlobalDescribe().get(COMMUNITY_GROUP_MEMBER_STRING);
        Map<String, Schema.SObjectField> mfields = appType.getDescribe().fields.getMap();

        String commGroupMemQuery = 'SELECT ';

        for (String fieldName : mfields.keySet()) {
            commGroupMemQuery += fieldName + ',';
        }
        commGroupMemQuery = commGroupMemQuery.removeEnd(',');


        commGroupMemQuery += ' FROM ' + COMMUNITY_GROUP_MEMBER_STRING + ' WHERE Id IN :' + setName;
        return commGroupMemQuery;
    }

    /** maps community group member record ids by community group member term record ids, both of which are retrieved from
     *  a list of community group member terms
     *
     *
     * @param termsToProcess
     *
     * @return
     */
    private Map<Id, Id> mapGroupMemIdsByTermIds(List<FS_Community_Group_Member_Term__c> termsToProcess) {
        Map<Id, Id> groupMemsByTermId = new Map<Id, Id>();

        for (FS_Community_Group_Member_Term__c term : termsToProcess) {
            if (term.FS_Community_Group_Member__c != null) {
                groupMemsByTermId.put(term.Id, term.FS_Community_Group_Member__c);
            }
        }

        return groupMemsByTermId;
    }

    /** maps a list of community group members by record id
     *
     *
     * @param membersList
     *
     * @return
     */
    private Map<Id, PagesApi__Community_Group_Member__c> mapGroupMembersByIds(List<PagesApi__Community_Group_Member__c> membersList) {
        Map<Id, PagesApi__Community_Group_Member__c> commGroupMemsByIds = new Map<Id, PagesApi__Community_Group_Member__c>();

        for (PagesApi__Community_Group_Member__c groupMem : membersList) {
            commGroupMemsByIds.put(groupMem.Id, groupMem);
        }

        return commGroupMemsByIds;
    }

    /** Updates the following fields from the community group member term to the community group member:
     * Paid Through Date
     * Active
     * Role
     *
     *
     * @param member
     * @param term
     */
    private void updateMemberFields(PagesApi__Community_Group_Member__c member, FS_Community_Group_Member_Term__c term, FS_Community_Group_Member_Term__c oldTerm) {
        if (member.FS_Original_Join_Date__c == null) {
            member.FS_Original_Join_Date__c = System.today();
        }

        if (term.FS_Is_Active__c) {
            member.FS_Term_Start_Date__c = term.FS_Term_Start_Date__c;
        }
   // member end date
        if ((member.FS_Term_End_Date__c == null || member.FS_Term_End_Date__c == System.today() ||
                !member.PagesApi__Is_Active__c) && term.FS_Is_Active__c) {
            member.FS_Term_End_Date__c = term.FS_Term_End_Date__c;
            if (member.FS_Grace_Period_End_Date__c == null || term.FS_Term_Grace_Period_End_Date__c >= member.FS_Grace_Period_End_Date__c) {
                  member.FS_Grace_Period_End_Date__c = term.FS_Term_Grace_Period_End_Date__c;
            }

        }

        // member paid through date
        if (member.FS_Paid_Through_Date__c == null ||
                term.FS_Term_End_Date__c > member.FS_Paid_Through_Date__c) {
            member.FS_Paid_Through_Date__c = term.FS_Term_End_Date__c;
        } else if (term.FS_Term_End_Date__c <= System.today() && term.FS_Deactivated_Manually__c) {
            member.FS_Paid_Through_Date__c = System.today();
        }

        // member active/deactived
        if (member.FS_Paid_Through_Date__c != null &&
                member.FS_Term_Start_Date__c != null &&
                member.FS_Term_Start_Date__c <= System.today() &&
                (member.FS_Paid_Through_Date__c > System.today() ||
                        member.FS_Grace_Period_End_Date__c > System.today()) &&
                !member.PagesApi__Is_Active__c) {
                        member.PagesApi__Is_Active__c = true;
                        member.PagesApi__Status__c = 'Active';
                    if(member.FS_Re_Join_Date__c == null){
                         member.FS_Re_Join_Date__c = term.FS_Term_Start_Date__c;
                    }
        }
        if ((((member.FS_Paid_Through_Date__c != null &&
                (member.FS_Paid_Through_Date__c < System.today() || Test.isRunningTest()) &&
                (member.FS_Grace_Period_End_Date__c == null ||
                        member.FS_Grace_Period_End_Date__c < System.today())) ||
                member.FS_Term_Start_Date__c > System.today()) &&
                member.PagesApi__Is_Active__c)
                || term.FS_Deactivated_Manually__c) {
            member.PagesApi__Is_Active__c = false;
            member.PagesApi__Status__c = 'Deactivated';
                    if(member.FS_Re_Join_Date__c != null){
                        member.FS_Re_Join_Date__c = null;
                    }
            if (term.FS_Deactivated_Manually__c) {
                member.FS_Term_End_Date__c = System.today();
                member.FS_Grace_Period_End_Date__c = null;
            }
//            member.PagesApi__Deactivated_Date__c = System.today();
        }

        // update the role only if the term's end date was not changed to today/yesterday
        if ((member.PagesApi__Role__c == null || member.PagesApi__Role__c != term.FS_Term_Role__c) && term.FS_Is_Active__c) {
            member.PagesApi__Role__c = term.FS_Term_Role__c;
        }
    }
    /** dynamically queries for community group members to ensure all fields are queried
     *
     *
     * @param setName
     *
     * @return
     */
    public static String getCommGroupTermQuery() {

        SObjectType appType = Schema.getGlobalDescribe().get(COMMUNITY_GROUP_MEMBER_TERM_STRING);
        Map<String, Schema.SObjectField> mfields = appType.getDescribe().fields.getMap();

        String commGroupMemQuery = 'SELECT ';

        for (String fieldName : mfields.keySet()) {
            commGroupMemQuery += fieldName + ',';
        }
        commGroupMemQuery = commGroupMemQuery.removeEnd(',');

        // added start date to query 8/29/19 to handle terms that should be updating members on end date of previous terms
        commGroupMemQuery += ' FROM ' + COMMUNITY_GROUP_MEMBER_TERM_STRING + ' WHERE ((' + START_DATE_FIELD +
                ' = TODAY AND ' + ACTIVE_FIELD + ' = FALSE ) OR ((' + END_DATE_FIELD + ' < TODAY OR ' +
                GRACE_END_DATE_FIELD + ' < TODAY OR ' + LAST_DATE_FIELD + ' = TODAY OR ' + GRACE_END_DATE_FIELD +
                ' = NULL) AND ' + ACTIVE_FIELD + ' = TRUE)) ORDER BY ' + END_DATE_FIELD + ' ASC';
        return commGroupMemQuery;
    }

    public void manuallyDeactivateTerms(List<FS_Community_Group_Member_Term__c> termsToProcess, Map<Id, SObject> existingRecords) {
        List<FS_Community_Group_Member_Term__c> termsNeedToBeEnded = new List<FS_Community_Group_Member_Term__c>();
        for (FS_Community_Group_Member_Term__c currTerm : termsToProcess) {
            FS_Community_Group_Member_Term__c oldTerm = (FS_Community_Group_Member_Term__c) existingRecords.get(currTerm.Id);
            if (oldTerm.FS_Term_End_Date__c != currTerm.FS_Term_End_Date__c && currTerm.FS_Term_End_Date__c <= System.today()) {
                currTerm.FS_Deactivated_Manually__c = true;
            }
        }
    }


}