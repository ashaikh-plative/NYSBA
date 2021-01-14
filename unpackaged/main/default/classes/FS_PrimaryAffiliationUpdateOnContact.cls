public without sharing class FS_PrimaryAffiliationUpdateOnContact {

    private static final String ACTIVE = 'Active';
    private static final String INACTIVE = 'Inactive';
    private static final String PRIMARY_CONTACT_ERROR = 'A primary contact already exists for this account';
    private static final String PRIMARY_AFFILIATION_ERROR = 'This contact already has a primary affiliation.';

    public static void beforeInsert(List<FS_Affiliation__c> records) {
        Set<Id> accIdSet = new Set<Id>();
        for (FS_Affiliation__c affiliation : records) {
            if (affiliation.FS_PrimaryContact__c == true) {
                accIdSet.add(affiliation.FS_Parent_Account__c);
            }
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,OrderApi__Primary_Contact__c FROM Account WHERE Id IN :accIdSet AND OrderApi__Primary_Contact__c != NULL]);
        for (FS_Affiliation__c affiliation : records) {
            if (accIdSet.contains(affiliation.FS_Parent_Account__c) && null != accMap.get(affiliation.FS_Parent_Account__c) &&
                    affiliation.FS_Child_Contact__c != accMap.get(affiliation.FS_Parent_Account__c).OrderApi__Primary_Contact__c) {
                affiliation.FS_PrimaryContact__c.addError(PRIMARY_CONTACT_ERROR);
            }
        }
    }

    public static void primaryAffiliationOnBeforeInsert(List<FS_Affiliation__c> records) {
        Set<Id> conIdSet = new Set<Id>();
        // loop through each newly inserted record and check if it has the FS_Primary_Affiliation__c field checked.
        // if true, we need to uncheck all other Affiliation records for that contact.
        for (FS_Affiliation__c affiliation : records) {
            if (affiliation.FS_Primary_Affiliation__c == true) {
                conIdSet.add(affiliation.FS_Child_Contact__c);
            }
        }
        // Get all affiliation records to be unchecked
        List<FS_Affiliation__c> affiliationList = [SELECT Id FROM FS_Affiliation__c WHERE FS_Child_Contact__c IN :conIdSet AND FS_Primary_Affiliation__c = TRUE];
        for(FS_Affiliation__c affiliation : affiliationList) {
            affiliation.FS_Primary_Affiliation__c = false;
        }
        if (affiliationList.size() > 0) {
            update affiliationList;
        }
    }


    public static void afterInsert(List<FS_Affiliation__c> records) {
        List<Contact> conList = new List<Contact>();
        List<Account> accList = new List<Account>();
        for (FS_Affiliation__c affiliation : records) {
            if (affiliation.FS_Status__c == ACTIVE) {
                if (affiliation.FS_Primary_Affiliation__c) {
                    if (affiliation.FS_Child_Contact__c != null && affiliation.FS_Parent_Account__c != null) {
                        conList.add(new Contact(Id = affiliation.FS_Child_Contact__c, FS_Primary_Affiliation__c = affiliation.FS_Parent_Account__c,FS_Primary_Affiliation_Record__c = affiliation.Id));
                    }
                }
                if (affiliation.FS_PrimaryContact__c) {
                    if (affiliation.FS_Child_Contact__c != null && affiliation.FS_Parent_Account__c != null) {
                        accList.add(new Account(Id=affiliation.FS_Parent_Account__c,OrderApi__Primary_Contact__c=affiliation.FS_Child_Contact__c));
                    }
                }
            }
        }
        if (!conList.isEmpty()) {
            update conList;
        }
        if (!accList.isEmpty()) {
            update accList;
        }
    }

    public static void afterUpdate(List<FS_Affiliation__c> records, Map<Id, SObject> oldMap) {
        Set<Id> affiliationIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        for (FS_Affiliation__c affiliation : records) {
            affiliationIds.add(affiliation.Id);
            acctIds.add(affiliation.FS_Parent_Account__c);
            conIdSet.add(affiliation.FS_Child_Contact__c);
        }
        List<FS_Affiliation__c> affiliationsToCheck = [
                SELECT Id,FS_PrimaryContact__c,FS_Primary_Affiliation__c,FS_Status__c,
                        FS_Parent_Account__c,FS_Parent_Account__r.OrderApi__Primary_Contact__c,
                        FS_Child_Contact__c,FS_Child_Contact__r.FS_Primary_Affiliation__c
                FROM FS_Affiliation__c
                WHERE Id IN :affiliationIds
        ];
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Account> accountsToUpdate = new List<Account>();
        for (FS_Affiliation__c affiliation : affiliationsToCheck) {
            FS_Affiliation__c oldAff = (FS_Affiliation__c) oldMap.get(affiliation.Id);

            if(affiliation.FS_Child_Contact__c != null){
                if (oldAff.FS_Primary_Affiliation__c && (!affiliation.FS_Primary_Affiliation__c ||
                        (oldAff.FS_Status__c != affiliation.FS_Status__c && affiliation.FS_Status__c == INACTIVE))) {
                    // remove primary affiliation from Contact
                    contactsToUpdate.add(new Contact(Id = affiliation.FS_Child_Contact__c, FS_Primary_Affiliation__c = null,FS_Primary_Affiliation_Record__c = null));
                } else if (affiliation.FS_Primary_Affiliation__c && affiliation.FS_Parent_Account__c != null && (!oldAff.FS_Primary_Affiliation__c ||
                        (oldAff.FS_Status__c != affiliation.FS_Status__c && affiliation.FS_Status__c == ACTIVE))) {
                    // add primary affiliation to Contact
                    contactsToUpdate.add(new Contact(Id = affiliation.FS_Child_Contact__c, FS_Primary_Affiliation__c = affiliation.FS_Parent_Account__c,FS_Primary_Affiliation_Record__c = affiliation.Id));
                }
            }
            if(affiliation.FS_Parent_Account__c != null){
                if (oldAff.FS_PrimaryContact__c && (!affiliation.FS_PrimaryContact__c ||
                        (oldAff.FS_Status__c != affiliation.FS_Status__c && affiliation.FS_Status__c == INACTIVE))) {
                    // remove Primary Contact from Account
                    accountsToUpdate.add(new Account(Id = affiliation.FS_Parent_Account__c, OrderApi__Primary_Contact__c = null));
                } else if (affiliation.FS_PrimaryContact__c && affiliation.FS_Child_Contact__c != null && (!oldAff.FS_PrimaryContact__c || (oldAff.FS_Status__c != affiliation.FS_Status__c && affiliation.FS_Status__c == ACTIVE))) {
                    // add Primary Contact to Account
                    accountsToUpdate.add(new Account(Id = affiliation.FS_Parent_Account__c, OrderApi__Primary_Contact__c = affiliation.FS_Child_Contact__c));
                }
            }

        }
        System.debug(accountsToUpdate);
        System.debug(contactsToUpdate);
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public static void beforeUpdatePrimary(List<FS_Affiliation__c> records, Map<Id, SObject> oldMap) {
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> acctIdSet = new Set<Id>();
        // Get Id set of all updated records
        Set<Id> affiliationIdSet = (new Map<Id, SObject>(records)).keySet();
        for (FS_Affiliation__c affiliation : records) {
            if (affiliation.FS_Primary_Affiliation__c) {
                conIdSet.add(affiliation.FS_Child_Contact__c);
            }
            if (affiliation.FS_PrimaryContact__c) {
                acctIdSet.add(affiliation.FS_Parent_Account__c);
            }
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,OrderApi__Primary_Contact__c FROM Account WHERE Id = :acctIdSet AND OrderApi__Primary_Contact__c != NULL]);

        for (FS_Affiliation__c affiliation : records) {
            if (affiliation.FS_Status__c == ACTIVE && affiliation.FS_PrimaryContact__c &&
                    acctIdSet.contains(affiliation.FS_Parent_Account__c) &&
                    null != accMap.get(affiliation.FS_Parent_Account__c) &&
                    affiliation.FS_Child_Contact__c != accMap.get(affiliation.FS_Parent_Account__c).OrderApi__Primary_Contact__c) {
                affiliation.FS_PrimaryContact__c.addError(PRIMARY_CONTACT_ERROR);
            }
        }
        // Get all affiliation records to be unchecked (exclude current records, since we don't want to set them as false)
        List<FS_Affiliation__c> affiliationList = [SELECT Id FROM FS_Affiliation__c WHERE FS_Child_Contact__c IN :conIdSet AND Id NOT IN :affiliationIdSet AND FS_Primary_Affiliation__c = TRUE];
        for(FS_Affiliation__c affiliation : affiliationList) {
            affiliation.FS_Primary_Affiliation__c = false;
        }
        if (affiliationList.size() > 0) {
            update affiliationList;
        }

    }

    public static void beforeUpdate(List<FS_Affiliation__c> records, Map<Id, SObject> oldMap) {
        for (FS_Affiliation__c affiliation : records) {
            FS_Affiliation__c oldAffiliation = (FS_Affiliation__c) oldMap.get(affiliation.Id);
            if (oldAffiliation.FS_Status__c != affiliation.FS_Status__c && affiliation.FS_Status__c == INACTIVE) {
                affiliation.FS_Primary_Affiliation__c = false;
            }
        }
    }
}