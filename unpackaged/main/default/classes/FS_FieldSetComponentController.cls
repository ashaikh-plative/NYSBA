/**
 * Created by Nikhil on 01-07-2019.
 */

public with sharing class FS_FieldSetComponentController {


    @AuraEnabled
    public static String getProfilePageCSV(String urlPathPrefix) {
        String csvToReturn = '';
        system.debug('test urlpathprefix.....'+urlPathPrefix);
        List<Network> relevantNetworks = [SELECT Id FROM Network WHERE UrlPathPrefix = :urlPathPrefix];
        if(relevantNetworks != null && relevantNetworks.size() > 0) {

            // TODO check if we need to also query for the is published flag
            List<LTE__Site__c> relevantSites = [SELECT Id, LTE__Profile_Contact_Fieldset_CSV__c
                                                FROM LTE__Site__c
                                                WHERE LTE__Community_ID__c = :relevantNetworks[0].Id LIMIT 1];

            if (relevantSites.size() > 0) {
                csvToReturn = relevantSites[0].LTE__Profile_Contact_Fieldset_CSV__c;
            }


        }
        return csvToReturn;
    }

    @AuraEnabled
    public static Id getLoggedInContactId() {
        List<User> loggedInUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (loggedInUser != null && loggedInUser.size() > 0)
            return loggedInUser[0].ContactId;
        return '';
    }
}