public without sharing class FS_SignOnSyncUserContact {

    @AuraEnabled
    public static String getUserIdOfContact(String contactId) {

        List<User> userList = [
                SELECT Id
                FROM User
                WHERE ContactId = :contactId
                AND IsActive = TRUE
                LIMIT 1
        ];

        if(userList.size() == 0) {
            return null;
        }

        return userList[0].Id;
    }

    @AuraEnabled
    public static String processSyncUser(String userIdParam) {
        String result = null;
        try{
            Set<Id> usersIdsWithUpdatedContacts = new  Set<Id>();
            usersIdsWithUpdatedContacts.add(userIdParam);
            new FS_ContactRuleServiceHelper.UpdateUserInformation(usersIdsWithUpdatedContacts).execute(null);
            List<String> str = new List<String>();
            str.add(userIdParam);
            FS_UserSyncRequest.oktaSync(str);
            result = 'Success';
        }catch (Exception e){
            result = e.getMessage(); 
        }
        return result;
    }

}