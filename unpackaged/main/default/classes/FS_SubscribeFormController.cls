/**
 * Created by dfitzgerald on 1/6/20.
 */

public without sharing class FS_SubscribeFormController {

    //get list of countries to populate drop-down on form - begin with blank entry, followed by US, followed by other
    //countries in alphabetical order
    @AuraEnabled
    public static List<Object> getJSONCountries() {
        List<Map<String, String>> countryInfo = new List<Map<String, String>>();

        countryInfo.add(new Map<String, String>{'value' => 'US', 'label' => 'United States'});

        Schema.DescribeFieldResult countryFieldInfo = User.countrycode.getDescribe();
        List<Schema.PicklistEntry> countryValues = countryFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry countryValue : countryValues) {
            if (countryValue.getValue() != 'US') {
                countryInfo.add(new Map<String, String>{
                        'value' => countryValue.getValue(), 'label' => countryValue.getLabel()
                });
            }
        }

        return countryInfo;
    }

    //process subscription form - create contact if valid
    @AuraEnabled
    public static Object processSubscription(String firstName, String lastName, String email, String countryCode, String ownerId) {
        Contact contact;
        List<Contact> contacts = getContactsWithEmail(email);

        //validation/duplicate check
        if (contacts.isEmpty()) {
            contact = createContact(firstName, lastName, email, countryCode, ownerId);
            return new Map<String, String>
            {'contactId' => contact.Id,
            'isGDPRCountry' => String.valueOf(isGDPRCountry(contact)),
            'userExists' => 'false'};
        }
        //if duplicate exists, check if user record also exists
        if (contactsHaveUser(contacts)) {
            return new Map<String, String>{'contactId' => '', 'isGDPRCountry' => 'false', 'userExists' => 'true'};
        }
        return new Map<String, String>{'contactId' => '', 'isGDPRCountry' => 'false', 'userExists' => 'false'};
    }

    //update GDPR opt in field to true
    @AuraEnabled
    public static void optInGDPR(Id contactId) {
        List<Contact> contacts = [SELECT Id, FS_GDPR_OptIn__c FROM Contact WHERE Contact.Id = :contactId LIMIT 1];
        if (!contacts.isEmpty()) {
            contacts[0].FS_GDPR_OptIn__c = true;
            update contacts;
        }
    }

    //check if contact is in a GDPR country (based on formula field)
    private static Boolean isGDPRCountry(Contact contact) {
        return [SELECT FS_GDPR_Country__c FROM Contact WHERE Contact.Id = :contact.Id LIMIT 1][0].FS_GDPR_Country__c;
    }

    //get all contacts with given email
    private static List<Contact> getContactsWithEmail(String email) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE OrderApi__Preferred_Email__c = :email];
        return contacts;
    }

    //determine whether any active user records exist that are associated with given contact list
    private static Boolean contactsHaveUser(List<Contact> contacts) {
        Integer count = [SELECT COUNT() FROM User WHERE ContactId IN :contacts AND IsActive = TRUE];
        return (count > 0);
    }

    //create new contact
    private static Contact createContact(String firstName, String lastName, String email, String countryCode, String ownerId) {
        Contact contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                MailingCountryCode = countryCode,
                OrderApi__Work_Email__c = email,
                OrderApi__Preferred_Email_Type__c = 'Work',
                FS_Source__c = 'Subscribe Form',
                FS_GDPR_OptIn__c = true,
                FS_General_NYSBA_Notice__c = true,
                FS_Sales_Email_One_to_One__c = true,
                FS_CLE_Advertisement__c = true,
                FS_Publications_Books_Forms_Updates__c = true,
                FS_Section_Member_Notice__c = true,
                FS_Global_eNewsletter__c = true,
                FS_Student_Newsletter__c = true,
                FS_Career_Center_Job_Opportunities__c = true,
                FS_NYSBA_Weekly_News__c = true,
                FS_CasePrepPlus__c = true,
                FS_GP_Section_webrief_eNewsletter__c = true);


        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        Database.SaveResult sr = Database.insert(contact, dml);

        //update account owner
        contact = [SELECT Id, AccountId FROM Contact WHERE Id = :contact.Id];
        Account account = [SELECT OwnerId FROM Account WHERE Id = :contact.AccountId][0];
        account.OwnerId = ownerId;

        update account;

        return contact;
    }

}