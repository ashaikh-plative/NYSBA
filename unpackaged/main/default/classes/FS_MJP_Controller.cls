public without sharing class FS_MJP_Controller {
    private static final String ORDER_STATUS_CLOSED = 'Closed';
    private static final String ORDER_POST_STATUS_PENDING = 'Pending';

    @AuraEnabled
    public static Map<String, Object> qualifyingQuestionsSetup(String attorneyItemIds, String lawStudentItemIds) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('UserTypeList', [SELECT DeveloperName, FS_Description__c, FS_Sort_Order__c FROM FS_Membership_Join_User_Type__mdt ORDER BY FS_Sort_Order__c ASC]);

            User loggedInUser = [SELECT Id, Username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

            List<OrderApi__Subscription__c> contactMembershipList = [
                    SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = :loggedInUser.ContactId AND OrderApi__Item__c IN :attorneyItemIds.split(',')];
            List<OrderApi__Sales_Order_Line__c> contactSalesOrderLineList = [
                    SELECT
                            Id
                    FROM
                            OrderApi__Sales_Order_Line__c
                    WHERE
                            OrderApi__Sales_Order__r.OrderApi__Status__c = :ORDER_STATUS_CLOSED AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = :ORDER_POST_STATUS_PENDING
                            AND OrderApi__Sales_Order__r.OrderApi__Contact__c = :loggedInUser.ContactId
                            AND OrderApi__Is_Renewal__c = TRUE
                            AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                            AND OrderApi__Subscription_Plan__c != NULL
                            AND OrderApi__Item__c IN :attorneyItemIds.split(',')
            ];
            result.put('isAttorneyEnabled', contactMembershipList.isEmpty() || !contactSalesOrderLineList.isEmpty());

            List<OrderApi__Subscription__c> subscriptionList = [
                    SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = :loggedInUser.ContactId AND (OrderApi__Item__c IN :lawStudentItemIds.split(',') OR OrderApi__Item__c IN :attorneyItemIds.split(','))];
            result.put('isStudentEnabled', subscriptionList.isEmpty());

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'FS_ERROR: ' + e.getCause());
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString());
        }
        return result;
    }

    public class MyPickListInfo {
        public String validFor;
    }

    @AuraEnabled
    public static Map<String, Object> getJSONCountriesAndStates() {
        Map<String, List<Map<String, String>>> controllingInfo = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> countriesInfo = new List<Map<String, String>>();

        countriesInfo.add(new Map<String, String>{'value' => 'US', 'label' => 'United States'});
        countriesInfo.add(new Map<String, String>{'value' => 'CA', 'label' => 'Canada'});

        Schema.DescribeFieldResult controllingFieldInfo = User.countrycode.getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = User.statecode.getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();


        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getValue(), new List<Map<String, String>>());
            if (!currControllingValue.getValue().equals('US') && !currControllingValue.getValue().equals('CA')) {
                countriesInfo.add(new Map<String, String>{'value' => currControllingValue.getValue(), 'label' => currControllingValue.getLabel()});
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
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(temp);
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(temp);
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(temp);
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(temp);
                }
                baseCount += 4;
            }
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('countriesInfo', countriesInfo);
        result.put('statesInfo', controllingInfo);
        return result;
    }

    @AuraEnabled
    public static Map<String, String> getPracticeInterestOptions() {
        try {
            Map<String, String> practiceInterestMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Contact.FS_Practice_Interests__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                practiceInterestMap.put(f.getValue(), f.getLabel());
            }
            return practiceInterestMap;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getLookupFilterMap() {
        Map<String, String> lookupFilterMap = new Map<String, String>();
        // build filters for Company Name Lookup
        Id organizationId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FS_Organization').getRecordTypeId();
        Id lawFirmId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FS_Law_firm').getRecordTypeId();
        Id barAssocId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FS_Bar_Association').getRecordTypeId();
        String conditionClause = ' AND FS_Hide_From_Portal__c = FALSE AND (RecordTypeId = \''+ organizationId + '\' OR RecordTypeId = \''+ lawFirmId + '\' OR RecordTypeId = \''+ barAssocId + '\')';
        conditionClause += ' AND (NOT Name LIKE \'%Household\')';
        lookupFilterMap.put('company', conditionClause);
        // build filters for Company Name Lookup
        Id eduInst = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FS_Educational_Institution').getRecordTypeId();
        conditionClause = ' AND FS_Accredited__c = TRUE AND FS_School_Type__c = \'Law School\' AND FS_Hide_From_Portal__c = False AND RecordTypeId = \'' + eduInst + '\'';
        lookupFilterMap.put('law_school', conditionClause);
        return lookupFilterMap;
    }

    @AuraEnabled
    public static Contact getContact() {
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact loggedContact = [SELECT Id, Name, Salutation, FirstName, MiddleName, LastName, DonorApi__Suffix__c,
                FS_Designation__c, MailingAddress, OtherAddress, FS_Preferred_Mailing_Address__c, FS_Preferred_Billing_Address__c,
                OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode,
                MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode,
                OrderApi__Preferred_Email_Type__c, OrderApi__Work_Email__c, OrderApi__Personal_Email__c,
                OrderApi__Work_Phone__c, HomePhone, OrderApi__Preferred_Phone_Type__c, MobilePhone,
                FS_Graduation_Date__c, Birthdate, FS_Practice_Interests__c, FS_Primary_Affiliation__c, FS_Law_School__c,
                FS_Out_of_State_First_Admit_Date__c, FS_NYS_Admission_Date__c, FS_Link_to_Proof_Attorney_Status__c,
                FS_NYS_Attorney_Registration_Number__c, FS_Country_Admitted__c, FS_State_Admitted__c,
        (SELECT Id, Title, ContentDocumentId FROM AttachedContentDocuments)
        FROM Contact WHERE Id = :loggedInUser.ContactId];
        loggedContact.FS_Country_Admitted__c = getCountryCodeByName(loggedContact.FS_Country_Admitted__c);
        loggedContact.FS_State_Admitted__c = getStateCodeByName(loggedContact.FS_State_Admitted__c);
        return loggedContact;
    }

    private static String getCountryCodeByName(String name) {
        String code = null;
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            if (name == f.getLabel()) {
                code = f.getValue();
            }
        }
        return code;
    }

    private static String getStateCodeByName(String name) {
        String code = null;
        Schema.DescribeFieldResult fieldResult = User.StateCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            if (name == f.getLabel()) {
                code = f.getValue();
            }
        }
        return code;
    }

    @AuraEnabled
    public static Map<String, String> getSuffixOptionList() {
        try {
            Map<String, String> optionsMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Contact.DonorApi__Suffix__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                optionsMap.put(f.getValue(), f.getLabel());
            }
            return optionsMap;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getDesignationOptionList() {
        try {
            Map<String, String> optionsMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Contact.FS_Designation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                optionsMap.put(f.getValue(), f.getLabel());
            }
            return optionsMap;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getSalutationOptionList() {
        try {
            Map<String, String> optionsMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                optionsMap.put(f.getValue(), f.getLabel());
            }
            return optionsMap;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateContact(Contact contact) {
        try {
            contact.FS_Country_Admitted__c = getCountryNameByCode(contact.FS_Country_Admitted__c);
            contact.FS_State_Admitted__c = getStateNameByCode(contact.FS_State_Admitted__c);
            update contact;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }
    }

    private static String getCountryNameByCode(String countryCode) {
        String countryName = countryCode;
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            if (countryCode == f.getValue()) {
                countryName = f.getLabel();
            }
        }
        return countryName;
    }

    private static String getStateNameByCode(String code) {
        String name = code;
        Schema.DescribeFieldResult fieldResult = User.StateCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            if (code == f.getValue()) {
                name = f.getLabel();
            }
        }
        return name;
    }

    @AuraEnabled
    public static Map<String, Object> getExistingSalesOrderId(String attorneyItemIds, String contactId) {
        Map<String, Object> response = new Map<String, String>();

        // check for any previous attorney membership.
        List<OrderApi__Subscription__c> contactMembershipList = [SELECT Id FROM OrderApi__Subscription__c
        WHERE OrderApi__Contact__c = :contactId
        AND OrderApi__Item__c IN :attorneyItemIds.split(',')];

        List<OrderApi__Sales_Order_Line__c> contactSalesOrderLineList = [SELECT Id, OrderApi__Sales_Order__r.Id
        FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Sales_Order__r.OrderApi__Status__c = 'Closed'
        AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = 'Pending'
        AND OrderApi__Sales_Order__r.OrderApi__Contact__c = :contactId
        AND OrderApi__Is_Renewal__c = :!contactMembershipList.isEmpty()
        AND OrderApi__Item__c IN :attorneyItemIds.split(',')
        AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
        ORDER BY LastModifiedDate DESC];
        if (contactSalesOrderLineList.size() > 0) {
            //  Assumption: If there are more than one SLO including the membership Item, take the first record
            OrderApi__Sales_Order_Line__c existingSalesOrderLine = contactSalesOrderLineList[0];
            response.put('isRenewal', !contactMembershipList.isEmpty());
            response.put('salesOrderId', existingSalesOrderLine.OrderApi__Sales_Order__r.Id);
        }
        return response;
    }

    @AuraEnabled
    public static Boolean hasPastFreeAttorneyMembership() {
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<OrderApi__Sales_Order_Line__c> subscriptionLastYear = [SELECT Id FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Subscription__c != NULL AND
        OrderApi__Sales_Order__r.OrderApi__Contact__c = :loggedInUser.ContactId AND
        OrderApi__Subscription__r.Membership_Type__c = 'Attorney' AND
        OrderApi__Subscription__r.OrderApi__Status__c != 'Cancelled' AND
        OrderApi__Sales_Order__r.OrderApi__Date__c = LAST_N_DAYS:365];
        return subscriptionLastYear.size() > 0;
    }

    @AuraEnabled
    public static String deleteContactAttachmentById(String id) {
        List<ContentDocument> docList = [SELECT Id FROM ContentDocument WHERE Id = :id];
        delete docList;
        return id;
    }
}