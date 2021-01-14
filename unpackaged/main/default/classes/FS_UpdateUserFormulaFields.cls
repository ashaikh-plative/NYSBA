/**
 * Created by cmudd on 2020-01-17.
 */

public without sharing class FS_UpdateUserFormulaFields implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    public final static String TRUE_STRING = 'true';
    public final static String FALSE_STRING = 'false';
    private final static String NON_MEMBER = 'Non-Member';
    private final static String FORMER = 'Former';
    private final static String EMAIL = 'Email';
    private final static String REQUIRED_FIELD_MISSING = 'REQUIRED_FIELD_MISSING';

    @TestVisible
    private static List<ContactToUserFieldMapping__c> fieldMappings;
    // private static String debug = '';

    public Database.QueryLocator start(Database.BatchableContext param1) {
        Datetime last4Hours = System.now().addHours(-1);
        if (fieldMappings == null) {
            getFieldMappings();
        }
        if (fieldMappings.isEmpty()) {
        //    debug += 'returning null';
            System.debug('returning null');
            return null;
        }
        Set<String> contactFields = new Set<String>();
        for (ContactToUserFieldMapping__c fieldMapping : fieldMappings) {
            contactFields.add(fieldMapping.ContactField__c);
        }
        String query = 'SELECT Id,' + String.join(new List<String>(contactFields), ',') + ' FROM Contact WHERE LastModifiedDate >= :last4Hours';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext param1, List<SObject> param2) {

        List<User> usersToUpdate = new List<User>();

        try {

            Savepoint sp = Database.setSavepoint();
            if (fieldMappings == null) {
                getFieldMappings();
            }

            List<Contact> contactsList = (List<Contact>) param2;

            Map<Id, Contact> contactsMap = new Map<Id, Contact>();

            for (Contact con : contactsList) {
                contactsMap.put(con.Id, con);
            }
            //    debug += 'contact mappings' + contactsMap + '\n';
            System.debug('contact mappings' + contactsMap);
            Set<String> userFields = new Set<String>();
            for (ContactToUserFieldMapping__c fieldMapping : fieldMappings) {
                userFields.add(fieldMapping.UserField__c);
            }
            //    debug += 'field mappings' + fieldMappings + '\n';
            System.debug('field mappings' + fieldMappings);
            Set<Id> contactIds = contactsMap.keySet();

            String userQuery = 'SELECT Id,ContactId,' + String.join(new List<String>(userFields), ',') + ' FROM User WHERE ContactId IN :contactIds';
            List<User> usersToCheckUpdate = Database.query(userQuery);
            //    debug += 'users to check update' + usersToCheckUpdate + '\n';
            System.debug('users to check update' + usersToCheckUpdate);
            for (User usr : usersToCheckUpdate) {
                Contact relatedContact = contactsMap.get(usr.ContactId);
                for (ContactToUserFieldMapping__c fieldMapping : fieldMappings) {
                    if (usr.get(fieldMapping.UserField__c) != relatedContact.get(fieldMapping.ContactField__c)) {
                        usr.put(fieldMapping.UserField__c, relatedContact.get(fieldMapping.ContactField__c));
                    }
                }
                usersToUpdate.add(usr);
            }

            //    debug += 'users to update' + usersToUpdate + '\n';

            System.debug('users to update' + usersToUpdate);
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            if (Test.isRunningTest()) {
                System.runAs(new User(Id = UserInfo.getUserId())) {
                    results = Database.update(usersToUpdate, false);
                }
            } else {
                results = Database.update(usersToUpdate, false);
            }

            List<String> userIdsForErrors = new List<String>();
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug(result.getErrors());
                    List<Database.Error> errors = result.getErrors();
                    if (errors.size() > 1 || (errors.size() == 1 && (errors[0].getStatusCode() != System.StatusCode.REQUIRED_FIELD_MISSING
                            || errors[0].getMessage().substringAfter('[').substringBefore(']') != EMAIL))) {
                        userIdsForErrors.add(result.getId());
                    }

                }
            }
            if (!userIdsForErrors.isEmpty()) {
                //    debug += 'Rolling Back Changes\n';
                //    debug += userIdsForErrors.size() + ' error' + (userIdsForErrors.size() == 1 ? ' ' : 's ') +
                //    'occurred when updating users from related contacts. Users: ' + String.join(userIdsForErrors, ',') + '\n';
                System.debug('Rolling Back Changes');
                System.debug(userIdsForErrors.size() + ' error' + (userIdsForErrors.size() == 1 ? ' ' : 's ') +
                        'occurred when updating users from related contacts. Users: ' + String.join(userIdsForErrors, ','));
                Database.rollback(sp);
                throw new FS_CustomException(userIdsForErrors.size() + ' error' + (userIdsForErrors.size() == 1 ? ' ' : 's ') + 'occurred when updating users from related contacts. Users: ' + String.join(userIdsForErrors, ','));
            }


        } catch (Exception e) {
            //    debug += e.getLineNumber() + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());

        }

        List<String> userIdList = new List<String>();
        for (User usr : usersToUpdate) {
            try {
                if (!Test.isRunningTest() || FS_UpdateUserFormulaFieldsTest.runCallOut) {
                    userIdList.add(usr.Id);                    
                }
            } catch (Exception e) {
                //  debug += 'OKTA Error ===\n' + e.getLineNumber() + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
                System.debug('OKTA Error === ' + e.getLineNumber());
                System.debug('OKTA Error === ' + e.getMessage());
                System.debug('OKTA Error === ' + e.getMessage());
                System.debug('OKTA Error === ' + e.getStackTraceString());
            }
        }        
        if (!userIdList.isEmpty()) {
			System.enqueueJob(new FS_UpdateUserFormulaFieldsQueue(userIdList));
        }
    }

    public class FS_CustomException extends Exception {

    }

    public void finish(Database.BatchableContext param1) {

    }

    public void execute(SchedulableContext param1) {
        // Executing batch with batch size of 100.
        Database.executeBatch(new FS_UpdateUserFormulaFields(), 100);
    }

    private static void getFieldMappings() {
        fieldMappings = [
                SELECT Id,ContactField__c,UserField__c
                FROM ContactToUserFieldMapping__c
                WHERE IsActive__c = TRUE
        ];
        if (Test.isRunningTest()) {
            fieldMappings.addAll(new List<ContactToUserFieldMapping__c>{
                    new ContactToUserFieldMapping__c(ContactField__c = 'Email', UserField__c = 'Email', IsActive__c = true),
                    new ContactToUserFieldMapping__c(ContactField__c = 'Email', UserField__c = 'Username', IsActive__c = true),
                    new ContactToUserFieldMapping__c(ContactField__c = 'FirstName', UserField__c = 'FirstName', IsActive__c = true),
                    new ContactToUserFieldMapping__c(ContactField__c = 'LastName', UserField__c = 'LastName', IsActive__c = true)
            }
            );
        }
    }
}