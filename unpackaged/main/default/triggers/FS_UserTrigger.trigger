trigger FS_UserTrigger on User (after insert, after update) {

    Set<Id> customerCommunityLoginProfiles = new Set<Id>();
    for (Profile currProfile : [SELECT Id FROM Profile WHERE UserLicense.Name LIKE '%Customer Community%']) {
        customerCommunityLoginProfiles.add(currProfile.Id);
    }

    List<String> userIdList = new List<String>();
    for (User user : Trigger.new) {
        //only for Community Users
        if (customerCommunityLoginProfiles.contains(user.ProfileId)) {

            if (!System.isBatch() && !System.isQueueable() && (!Test.isRunningTest() || FS_UserTriggerTest.runCallOut)) {
                if (user.FS_Force_OKTA_Sync__c  || user.Okta_ID__c == null || Trigger.oldMap == null || Trigger.oldMap.get(user.Id).Email != user.Email || Trigger.oldMap.get(user.Id).Username != user.Username || Trigger.oldMap.get(user.Id).FS_Public_Profile_Picture_URL__c  != user.FS_Public_Profile_Picture_URL__c) {
                    userIdList.add(user.Id);                    
                }
            }
        }
    }
    // Call non future method
    if (!userIdList.isEmpty()) {
        FS_UserSyncRequest.oktaSync(userIdList);
    }    
}