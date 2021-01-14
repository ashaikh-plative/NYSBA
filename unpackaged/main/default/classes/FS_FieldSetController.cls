/**
* Created by daweima on 2019-06-26.
*/

public class FS_FieldSetController {

    @AuraEnabled
    public static Id getUserId() {
        Id currUserId = UserInfo.getUserId();
        User currContact = [
                SELECT ContactId
                FROM User
                WHERE  Id = :currUserId
        ];

        return currContact.ContactId;
    }

    @AuraEnabled
    public static FieldSetForm getForm(String recordId, String objectName, String fieldSetName, String objApiName) {
        FieldSetForm form = new FieldSetForm();

        form.Fields = getFields(recordId, objectName, fieldSetName, objApiName);
        form.Record = getRecord(recordId, objectName, form.Fields);

        return form;
    }

    @AuraEnabled
    public static void upsertRecord(SObject recordToUpsert, String[] requiredArray) {
        Boolean containEmpty = false;
        if (!requiredArray.isEmpty()) {
            for (String api : requiredArray) {
                if (recordToUpsert.get(api) == null || recordToUpsert.get(api) == '') {
                    containEmpty = true;
                    break;
                }
            }
        }
        
        if (!containEmpty) {
            try {
                if (recordToUpsert.getSObjectType().getDescribe().getName() == 'Contact') {
                    Contact newContact = (Contact) recordToUpsert;
                    if (newContact.getPopulatedFieldsAsMap().containsKey('MailingCountryCode')) {
                        if (((Contact) recordToUpsert).MailingCountryCode == null || ((Contact) recordToUpsert).MailingCountryCode == '') {
                            ((Contact) recordToUpsert).MailingCountryCode = 'US';
                        }
                    }
                    update recordToUpsert;
                }
            } catch (DmlException e) {
                String msg = e.getMessage();
                if (msg.contains('TOO_MANY_ENUM_VALUE')) {
                    msg = 'You can only select 100 picklist values per field';
                }
                System.debug(e.getStackTraceString());
                if (!Test.isRunningTest()) {
                    throw new AuraHandledException(msg);
                }
            }
        } else {
            throw new AuraHandledException('At least one required field is not filled in.');
        }
    }

    @AuraEnabled
    public static void updateUser(SObject recordToUpsert, String[] requiredArray) {
        Boolean containEmpty = false;
        if (!requiredArray.isEmpty()) {
            for (String api : requiredArray) {
                if (recordToUpsert.get(api) == null || recordToUpsert.get(api) == '') {
                    containEmpty = true;
                    break;
                }
            }
        }

        if (!containEmpty) {
            try {
                if (recordToUpsert.getSObjectType().getDescribe().getName() == 'Contact') {
                    Contact newContact = (Contact) recordToUpsert;
                    Map<String, Object> populatedFields = newContact.getPopulatedFieldsAsMap();
                    if (populatedFields.containsKey('OrderApi__Preferred_Email_Type__c')) {
                        User u = [SELECT Id, Email FROM User WHERE ContactId = :newContact.Id];
                        if (populatedFields.containsKey('OrderApi__Personal_Email__c') && newContact.OrderApi__Preferred_Email_Type__c == 'Personal') {
                            if (u.Email != newContact.OrderApi__Personal_Email__c) {
                                u.Email = newContact.OrderApi__Personal_Email__c;
                                if (!Test.isRunningTest()) {
                                    u.Username = newContact.OrderApi__Personal_Email__c;
                                }
                            }
                            update u;
                        } else if (populatedFields.containsKey('OrderApi__Assistant_Email__c') && newContact.OrderApi__Preferred_Email_Type__c == 'Assistant') {
                            if (u.Email != newContact.OrderApi__Assistant_Email__c) {
                                u.Email = newContact.OrderApi__Assistant_Email__c;
                                u.Username = newContact.OrderApi__Assistant_Email__c;
                            }
                            update u;
                        } else if (populatedFields.containsKey('OrderApi__Other_Email__c') && newContact.OrderApi__Preferred_Email_Type__c == 'Other') {
                            if (u.Email != newContact.OrderApi__Other_Email__c) {
                                u.Email = newContact.OrderApi__Other_Email__c;
                                u.Username = newContact.OrderApi__Other_Email__c;
                            }
                            update u;
                        } else if (populatedFields.containsKey('OrderApi__Work_Email__c') && newContact.OrderApi__Preferred_Email_Type__c == 'Work') {
                            if (u.Email != newContact.OrderApi__Work_Email__c) {
                                u.Email = newContact.OrderApi__Work_Email__c;
                                u.Username = newContact.OrderApi__Work_Email__c;
                            }
                            update u;
                        }
                    }
                }
            } catch (DmlException e) {
                String msg = e.getMessage();
                if (msg.contains('TOO_MANY_ENUM_VALUE')) {
                    msg = 'You can only select 100 picklist values per field';
                }
                System.debug(e.getStackTraceString());
                if (!Test.isRunningTest()) {
                    throw new AuraHandledException(msg);
                }
            }
        } else {
            throw new AuraHandledException('At least one required field is not filled in.');
        }
    }

    @AuraEnabled
    public static String getFieldSetLabel(Id recordId,String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;

        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }

        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();

        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        return fieldSet.getLabel();
    }

    @AuraEnabled
    public static SObject getLookup(String sObjectName, String recordId) {
        String recordSOQL = 'SELECT Id, Name ' +
                '  FROM ' + sObjectName +
                ' WHERE Id = :recordId';

        List<SObject> record = Database.query(recordSOQL);
        return record[0];
    }

    private static List<FS_FieldSetMember> getFields(Id recordId, String objectName, String fieldSetName, String objApiName) {
        Schema.SObjectType objectType = null;

        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }

        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        List<FS_FieldSetMember> fields = new List<FS_FieldSetMember>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            FS_FieldSetMember f = new FS_FieldSetMember(fsm,objApiName);
            if (f.Type == 'REFERENCE') {
                if (f.Label.contains('Account'))
                    f.Label = 'Account';
                if (f.Label.contains('Contact'))
                    f.Label = 'Contact';
            }

            if (f.Type == 'TEXTAREA') {
                if (f.label.contains('Mailing')) {
                    f.Label = 'MailingStreet';
                }
            }


            fields.add(f);
        }

        return fields;
    }

    private static SObject getRecord(Id recordId, String objectName, List<FS_FieldSetMember> fields) {
        if (recordId == null) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            return objectType.newSObject();
        }

        List<String> fieldsToQuery = new List<String>();
        for (FS_FieldSetMember f : fields) {
            fieldsToQuery.add(f.APIName);
        }

        Schema.SObjectType objectType = recordId.getSobjectType();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        String objectAPIName = objectDescribe.getName();

        String recordSOQL = 'SELECT ' + String.join(fieldsToQuery, ',') +
                '  FROM ' + objectAPIName +
                ' WHERE Id = :recordId';

        SObject record = Database.query(recordSOQL);

        return record;
    }

    public class MyPickListInfo {
        public String validFor;
    }

    public class FieldSetForm {
        @AuraEnabled
        public List<FS_FieldSetMember> Fields { get; set; }

        @AuraEnabled
        public SObject Record { get; set; }

        public FieldSetForm() {
            Fields = new List<FS_FieldSetMember>();
        }
    }
}