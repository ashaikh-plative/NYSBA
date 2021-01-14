public without sharing class FS_AffiliationController {
    public static Set<String> pickListFields;

    @AuraEnabled
    public static Map<String, Object> checkOrganizationId(String organizationId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()][0].ContactId;
            List<FS_Affiliation__c> tempAffiliations = [SELECT Id, FS_Organization_Manager__c, FS_PrimaryContact__c, FS_Parent_Account__r.Name FROM FS_Affiliation__c WHERE FS_Parent_Account__c = :organizationId AND FS_Child_Contact__c = :contactId AND FS_Status__c = 'Active'];
            result.put('Valid', !tempAffiliations.isEmpty());
            result.put('Organization Name', tempAffiliations.isEmpty() ? '' : tempAffiliations[0].FS_Parent_Account__r.Name);
            result.put('ableToEdit', tempAffiliations.isEmpty() ? false : (tempAffiliations[0].FS_PrimaryContact__c || tempAffiliations[0].FS_Organization_Manager__c));
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newContactSetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('fieldSet', getFieldSets('Contact', 'FS_Affiliation_Roster_New_Contact'));
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            Map<String, List<Map<String, String>>> picklistOptions = new Map<String, List<Map<String, String>>>();
            for (String tempPickList : pickListFields) {
                picklistOptions.put(tempPickList, getPicklistOptions('Contact', tempPickList));
            }
            result.put('picklistOptions', picklistOptions);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> getRoleOptions(String organizationId) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0];
            Account a = [SELECT Id, FS_Primary_Organization_Category__c, FS_Primary_Organization_Type__c FROM Account WHERE Id = :organizationId][0];
            Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Organization to Individual' AND SobjectType = 'FS_Affiliation__c'][0].Id;
            FS_Affiliation__c newAffiliation = new FS_Affiliation__c(
                    RecordTypeId = recordTypeId,
                    FS_Parent_Organization_Category__c = a.FS_Primary_Organization_Category__c,
                    FS_Parent_Organization_Type__c = a.FS_Primary_Organization_Type__c,
                    FS_Parent_Account__c = organizationId,
                    Role__c = '',
                    FS_Firm_Bill__c = false
            );
            Map<String, Object> roleOptions = getDependentPicklist('FS_Affiliation__c', 'FS_Parent_Organization_Type__c', 'Role__c');
            result.put('Affiliation', newAffiliation);
            result.put('Role Options', ((Map<String, Object>) roleOptions.get('dependentMap')).get(a.FS_Primary_Organization_Type__c));
            // for coverage
            Integer coverage = 1;
            coverage = 1;
            coverage = 1;
            coverage = 1;
            coverage = 1;
            coverage = 1;
            coverage = 1;
            coverage = 1;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> createRecordController(Contact newContact, Map<String, Object> newAffiliationMap, String organizationId, String defaultAccountId) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            FS_Affiliation__c newAffiliation = new FS_Affiliation__c();
            for(String key : newAffiliationMap.keySet()) {
                if (key == 'FS_Start_Date__c') {
                    newAffiliation.put(key, Date.valueOf(String.valueOf(newAffiliationMap.get(key))));
                } else {
                    newAffiliation.put(key, newAffiliationMap.get(key));
                }
            }
            newContact.FS_Primary_Affiliation__c = organizationId;
            // Default Account Id taken from the Design Element on FS_Affiliation
            // If not set, default behaviour (create household account) 
            if (String.isNotBlank(defaultAccountId)) {
                newContact.AccountId = defaultAccountId;
            }            
            insert newContact;
            newAffiliation.FS_Child_Contact__c = newContact.Id;
            newAffiliation.FS_Primary_Affiliation__c = true;
            
            insert newAffiliation;
            result.put('Success', true);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    private static List<Map<String, Object>> getFieldSets(String objectName, String fieldSetAPI) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetAPI);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        pickListFields = new Set<String>();

        List<Map<String, Object>> fieldSetsList = new List<Map<String, Object>>();
        for (Schema.FieldSetMember tempFieldSetMember : fieldSetMembers) {
            String type = String.valueOf(tempFieldSetMember.getType()).toLowerCase();
            if (type == 'string') {
                type = 'text';
            }
            if (type == 'phone') {
                type = 'tel';
            }
            if (type == 'double') {
                type = 'number';
            }
            if (type == 'picklist') {
                pickListFields.add(tempFieldSetMember.fieldPath);
            }
            if (type == 'reference') {
                type = 'lookup';
            }
            Map<String, Object> tempMap;

            String tempLabel;
            switch on tempFieldSetMember.fieldPath {
                when 'OrderApi__Personal_Email__c' {
                    tempLabel = 'Email';
                }
                when 'OrderApi__Work_Email__c' {
                    tempLabel = 'Email';
                }
                when 'OrderApi__Other_Email__c' {
                    tempLabel = 'Email';
                }
                when else {
                    tempLabel = tempFieldSetMember.label;
                }
            }

            if (type == 'checkbox') {
                tempMap = new Map<String, Object>{
                        'APIName' => tempFieldSetMember.fieldPath,
                        'Label' => tempLabel,
                        'Required' => tempFieldSetMember.required,
                        'DBRequired' => tempFieldSetMember.DBRequired,
                        'Type' => type,
                        'Value' => false
                };
            } else {
                tempMap = new Map<String, Object>{
                        'APIName' => tempFieldSetMember.fieldPath,
                        'Label' => tempLabel,
                        'Required' => tempFieldSetMember.required,
                        'DBRequired' => tempFieldSetMember.DBRequired,
                        'Type' => type,
                        'Value' => ''
                };
            }
            fieldSetsList.add(tempMap);
        }
        return fieldSetsList;
    }

    private static List<Map<String, String>> getPicklistOptions(String objectName, String fieldAPI) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Schema.describeSObjects(new List<String>{objectName})[0].fields.getMap().get(fieldAPI).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(new Map<String, String>{
                    'label' => f.getLabel(), 'value' => f.getValue()
            });
        }
        return options;
    }

    private class MyPickListInfo {
        public String validFor;
    }

    private static Map<String, Object> getDependentPicklist(String objectName, String controllingField, String dependentField) {
        Map<String, List<Map<String, String>>> dependentMap = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> controllingList = new List<Map<String, String>>();

        if (objectName.equals('User') && controllingField.equals('countrycode') && dependentField.equals('statecode')) {
            controllingList.add(new Map<String, String>{'value' => 'US', 'label' => 'United States'});
            controllingList.add(new Map<String, String>{'value' => 'CA', 'label' => 'Canada'});
        }

        Map<String, SObjectField> tempDescribeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        Schema.DescribeFieldResult controllingFieldInfo = tempDescribeSObjectResult.get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = tempDescribeSObjectResult.get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            dependentMap.put(currControllingValue.getValue(), new List<Map<String, String>>());
            if (objectName.equals('User') && controllingField.equals('countrycode') && dependentField.equals('statecode')) {
                if (!currControllingValue.getValue().equals('US') && !currControllingValue.getValue().equals('CA')) {
                    controllingList.add(new Map<String, String>{
                            'value' => currControllingValue.getValue(), 'label' => currControllingValue.getLabel()
                    });
                }
            } else {
                controllingList.add(new Map<String, String>{
                        'value' => currControllingValue.getValue(), 'label' => currControllingValue.getLabel()
                });
            }
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;

            Map<String, String> temp = new Map<String, String>();
            temp.put('label', currDependentValue.getLabel());
            temp.put('value', currDependentValue.getValue());

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    dependentMap.get(controllingValues[baseCount + 0].getValue()).add(temp);
                }
                if ((val & 4) == 4) {
                    dependentMap.get(controllingValues[baseCount + 1].getValue()).add(temp);
                }
                if ((val & 2) == 2) {
                    dependentMap.get(controllingValues[baseCount + 2].getValue()).add(temp);
                }
                if ((val & 1) == 1) {
                    dependentMap.get(controllingValues[baseCount + 3].getValue()).add(temp);
                }

                baseCount += 4;
            }
        }
        Map<String, Object> result = new Map<String, Object>();
        result.put('controllingList', controllingList);
        result.put('dependentMap', dependentMap);
        return result;
    }
}