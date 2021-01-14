/**
 * Created by cmudd on 1/23/20.
 */

trigger FS_CommunityTermTrigger on FS_Community_Group_Member_Term__c (before update, after insert, after update) {

        List<FS_Community_Group_Member_Term__c> termsToProcess= new List<FS_Community_Group_Member_Term__c>(Trigger.new);
    FS_CommunityMemberTermRoutingRule routingRule = new FS_CommunityMemberTermRoutingRule(termsToProcess);
    System.debug('=======calling comm. group mem term routing rule/trigger=======');
    if (Trigger.isBefore) {
    
        routingRule.manuallyDeactivateTerms((List<FS_Community_Group_Member_Term__c>) Trigger.new, (Map<Id, SObject>) Trigger.oldMap);
    } else if (Trigger.isAfter) {
    System.debug('=======AfterInsert calling comm. group mem term routing rule/trigger=======');
        if (Trigger.isUpdate) {
            routingRule.updateCommunityGroupMemberFromTerm((List<FS_Community_Group_Member_Term__c>) Trigger.new, (Map<Id,FS_Community_Group_Member_Term__c>) Trigger.oldMap);
        } else {
       
            routingRule.updateCommunityGroupMemberFromTerm((List<FS_Community_Group_Member_Term__c>) Trigger.new, null);
            
        }
        System.debug('=======finishing call to comm. group mem term routing rule/trigger =======');
    }
}