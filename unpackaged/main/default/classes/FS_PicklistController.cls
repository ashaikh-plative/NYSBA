/**
 * Created by daweima on 2019-07-10.
 */

public with sharing class FS_PicklistController {
    private static String getPicklistJSONString(String objectApiName, String fieldApiName) {
        Map<String, Schema.SObjectType> sObjectsMap = Schema.getGlobalDescribe();
        if (!sObjectsMap.containsKey(objectApiName)) {
            System.debug('it does not contains: ' + objectApiName);
            return '';
        }

        Map<String, Schema.SObjectField> fieldMap = sObjectsMap.get(objectApiName).getDescribe().fields.getMap();

        if (fieldMap.containsKey(fieldApiName)) {
            List<Schema.PicklistEntry> fieldValues = fieldMap.get(fieldApiName).getDescribe().picklistValues;
            System.debug('it does contains: ' + objectApiName);
            System.debug('field values are: ');
            System.debug(fieldValues);
            return JSON.serialize(fieldValues);
        }
        return '';
    }

    @AuraEnabled
    public static String getPicklistValues(String customSettingName, String objectApiName,
            String fieldApiName, String objJSONString) {
        return getPicklistJSONString(objectApiName, fieldApiName);
    }
}