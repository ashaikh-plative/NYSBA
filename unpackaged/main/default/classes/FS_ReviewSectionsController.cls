public without sharing class FS_ReviewSectionsController {
    @AuraEnabled
    public static Map<String, Object> setup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()][0].ContactId;
            result.put('contactId', contactId);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }
}