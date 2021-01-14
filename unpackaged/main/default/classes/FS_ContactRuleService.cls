public without sharing class FS_ContactRuleService {

//    public static void beforeInsert(List<Contact> records){
////        FS_ContactRuleServiceHelper.onBeforeInsert(records);
//        FS_ContactRuleServiceHelper.isDuplicateEmailOnUser((Contact[]) records, oldMap);
//    }

    public static void beforeUpdate(Contact[] records, Map<Id,SObject> oldMap){
        FS_ContactRuleServiceHelper.isDuplicateEmailOnUser((Contact[]) records, oldMap);
    }


    public static void afterUpdate(Contact[] records,Map<Id,SObject> oldMap){
        FS_ContactRuleServiceHelper.updateRelatedUserInfo((List<Contact>)records, (Map<Id,Contact>)oldMap);
    }


}