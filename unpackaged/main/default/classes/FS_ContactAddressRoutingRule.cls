/**
 *  @author:    cubiascaceres
 *  @date:      2019.Nov.08
 *  @desc:      Routing rule to sync OtherAddress & MailingAddress with their Known Address records
 *  @updated:   2020.Jan.17: Adding sync for County fields
 */
global without sharing class FS_ContactAddressRoutingRule extends Framework.Domain {

    public static final String HOME_ADDRESS = 'Home';
    public static final String WORK_ADDRESS = 'Work';
    public static Boolean routingRuleComplete = false;
    
    public FS_ContactAddressRoutingRule(List<Contact> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ContactAddressRoutingRule(sObjectList);
        }
    }

    public override virtual void afterInsert() {
        Framework.Log.push(FS_ContactAddressRoutingRule.class.getName(), 'afterInsert');
        // dont fire this routing rule yet. Will wait for smarty streets to finish validations
        if (!FS_KnownAddressRoutingRule.routingRuleComplete && !FS_ContactVerifyStatusRoutingRule.contactAddressChanged) {
            List<Contact> contactList = (List<Contact>) records;
            syncAddressesAfterInsert(contactList);
            routingRuleComplete = true;
        }
        Framework.Log.pop();
    }
    
    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ContactAddressRoutingRule.class.getName(), 'afterUpdate');
        // dont fire this routing rule yet. Will wait for smarty streets to finish validations
        if (!FS_KnownAddressRoutingRule.routingRuleComplete && !FS_ContactVerifyStatusRoutingRule.contactAddressChanged) {
            syncAddresses(records, (Map<Id, Contact>) existingRecords);
            routingRuleComplete = true;
        }
        Framework.Log.pop();
    }
    
    private void syncAddressesAfterInsert(List<Contact> contactList) {
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>();
        for(Contact contact : contactList) {
            if (String.isNotEmpty(contact.FS_API_Other_County__c) || String.isNotEmpty(contact.OtherStreet) ||
            String.isNotEmpty(contact.OtherCity) || String.isNotBlank(contact.OtherStateCode) ||
            String.isNotBlank(contact.OtherPostalCode) || String.isNotBlank(contact.OtherCountryCode)) {
                OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
                knownAddress.OrderApi__Street__c = contact.OtherStreet;
                knownAddress.OrderApi__City__c = contact.OtherCity;
                knownAddress.OrderApi__Province__c = contact.OtherStateCode;
                knownAddress.OrderApi__Postal_Code__c = contact.OtherPostalCode;
                knownAddress.OrderApi__Country__c = contact.OtherCountryCode;
                knownAddress.OrderApi__Type__c = HOME_ADDRESS;
                knownAddress.OrderApi__Contact__c = contact.Id;
                knownAddress.FS_County__c = contact.FS_API_Other_County__c;
                knownAddress.FS_Verified__c = contact.smartystreets__Other_Verified__c;
                knownAddress.FS_Last_Verified__c = contact.smartystreets__Other_Last_Verified__c;
                knownAddress.FS_Return_Code__c = contact.smartystreets__Other_Return_Code__c;
                knownAddressList.add(knownAddress);
            }
            if (String.isNotEmpty(contact.FS_API_Mailing_County__c) || String.isNotEmpty(contact.MailingStreet) ||
                    String.isNotEmpty(contact.MailingCity) || String.isNotBlank(contact.MailingStateCode) ||
                    String.isNotBlank(contact.MailingPostalCode) || String.isNotBlank(contact.MailingCountryCode)) {
                OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
                knownAddress.OrderApi__Street__c = contact.MailingStreet;
                knownAddress.OrderApi__City__c = contact.MailingCity;
                knownAddress.OrderApi__Province__c = contact.MailingStateCode;
                knownAddress.OrderApi__Postal_Code__c = contact.MailingPostalCode;
                knownAddress.OrderApi__Country__c = contact.MailingCountryCode;
                knownAddress.OrderApi__Type__c = WORK_ADDRESS;
                knownAddress.OrderApi__Contact__c = contact.Id;
                knownAddress.FS_County__c = contact.FS_API_Mailing_County__c;
                knownAddress.FS_Verified__c = contact.smartystreets__Mailing_Verified__c;
                knownAddress.FS_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
                knownAddress.FS_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
                knownAddressList.add(knownAddress);
            }
        }
        if (knownAddressList.size() > 0) {
            insert knownAddressList;
        }
        Set<Id> contactIdSet = (new Map<Id,SObject>(contactList)).keySet();        
        setDefaultKnownAddress(contactIdSet);
    }
    
    private void syncAddresses(List<sObject> records, Map<Id, Contact> existingContactMap) {
        Boolean isDeleted = false;
        Map<Id, SObject> contactMap = new Map<Id, SObject>(records);
        Set<Id> contactIdSet = contactMap.keySet();
        List<String> contactAddressKeyList = new List<String>();
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>();
        //	Validate if the address field has been deleted, delete the corresponding known address records
        Set<Id> deletedMailAddressSet = new Set<Id>();
        Set<Id> deletedOtherAddressSet = new Set<Id>();
        for (sObject contactObject : records) {
            Contact contact = (Contact) contactObject;
            if (String.isEmpty(contact.FS_API_Other_County__c) && String.isEmpty(contact.OtherStreet) &&
                    String.isEmpty(contact.OtherCity) && String.isEmpty(contact.OtherStateCode) &&
                    String.isEmpty(contact.OtherPostalCode) && String.isEmpty(contact.OtherCountryCode)) {
                deletedOtherAddressSet.add(contact.Id);
                isDeleted = true;
            }
            if (String.isEmpty(contact.FS_API_Mailing_County__c) && String.isEmpty(contact.MailingStreet) &&
                    String.isEmpty(contact.MailingCity) && String.isEmpty(contact.MailingStateCode) &&
                    String.isEmpty(contact.MailingPostalCode) && String.isEmpty(contact.MailingCountryCode)) {
                deletedMailAddressSet.add(contact.Id);
                isDeleted = true;
            }
        }
        List<OrderApi__Known_Address__c> knownAddressDeleteList = [
                SELECT Id, OrderApi__Type__c, OrderApi__Contact__c
                FROM OrderApi__Known_Address__c
                WHERE OrderApi__Contact__c IN :deletedMailAddressSet OR OrderApi__Contact__c IN :deletedOtherAddressSet];
        List<OrderApi__Known_Address__c> workKnownAddressList = new List<OrderApi__Known_Address__c>();
        List<OrderApi__Known_Address__c> homeKnownAddressList = new List<OrderApi__Known_Address__c>();
        for(OrderApi__Known_Address__c knownAddressDelete : knownAddressDeleteList) {
            if (knownAddressDelete.OrderApi__Type__c == HOME_ADDRESS && deletedOtherAddressSet.contains(knownAddressDelete.OrderApi__Contact__c)) {
                homeKnownAddressList.add(knownAddressDelete);
            }
            if (knownAddressDelete.OrderApi__Type__c == WORK_ADDRESS && deletedMailAddressSet.contains(knownAddressDelete.OrderApi__Contact__c)) {
                workKnownAddressList.add(knownAddressDelete);
            }
        }
        if (workKnownAddressList.size() > 0) {
            delete workKnownAddressList;
        }
        if (homeKnownAddressList.size() > 0) {
            delete homeKnownAddressList;
        }
        // Getting the last updated record by type
        Map<String, OrderApi__Known_Address__c> lastUpdatedAddressMap = new Map<String, OrderApi__Known_Address__c>();
        for (Contact contact : [
                SELECT Id, (SELECT Id, OrderApi__Type__c, LastModifiedDate, OrderApi__Is_Default__c FROM OrderApi__Known_Addresses__r)
                FROM Contact WHERE Id IN :contactIdSet]) {
            for (OrderApi__Known_Address__c contactKnownAddress : contact.OrderApi__Known_Addresses__r) {
                String key = contact.Id + '_' + contactKnownAddress.OrderApi__Type__c;
                OrderApi__Known_Address__c lastUpdatedAddress = lastUpdatedAddressMap.get(key);
                if (lastUpdatedAddress == null) {
                    lastUpdatedAddressMap.put(key, contactKnownAddress);
                } else if (lastUpdatedAddress.LastModifiedDate < contactKnownAddress.LastModifiedDate) {
                    lastUpdatedAddressMap.put(key, contactKnownAddress);
                }
            }
        }
        Set<Id> lastestKnownAddressIdList = (new Map<Id, SObject> (lastUpdatedAddressMap.values())).keySet();
        for (OrderApi__Known_Address__c knownAddress : [SELECT Id, OrderApi__Type__c, OrderApi__Contact__c,
                                                       OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, 
                                                       OrderApi__Postal_Code__c, OrderApi__Country__c, FS_County__c
                                                       FROM OrderApi__Known_Address__c WHERE Id IN :lastestKnownAddressIdList]) {
            Contact contact = (Contact) contactMap.get(knownAddress.OrderApi__Contact__c);
            contactAddressKeyList.add(contact.Id + '_' + knownAddress.OrderApi__Type__c);
            if (contact.smartystreets__Other_Return_Code__c != 'Changed' && knownAddress.OrderApi__Type__c == HOME_ADDRESS && hasOtherAddressChanged(contact, knownAddress)) {
                knownAddress.OrderApi__Street__c = contact.OtherStreet;
                knownAddress.OrderApi__City__c = contact.OtherCity;
                knownAddress.OrderApi__Province__c = contact.OtherStateCode;
                knownAddress.OrderApi__Postal_Code__c = contact.OtherPostalCode;
                knownAddress.OrderApi__Country__c = contact.OtherCountryCode;
                knownAddress.FS_County__c = contact.FS_API_Other_County__c;
                knownAddress.FS_Verified__c = contact.smartystreets__Other_Verified__c;
                knownAddress.FS_Last_Verified__c = contact.smartystreets__Other_Last_Verified__c;
                knownAddress.FS_Return_Code__c = contact.smartystreets__Other_Return_Code__c;
                knownAddressList.add(knownAddress);
            }
            if (contact.smartystreets__Mailing_Return_Code__c != 'Changed' && knownAddress.OrderApi__Type__c == WORK_ADDRESS && hasMailingAddressChanged(contact, knownAddress)) {
                knownAddress.OrderApi__Street__c = contact.MailingStreet;
                knownAddress.OrderApi__City__c = contact.MailingCity;
                knownAddress.OrderApi__Province__c = contact.MailingStateCode;
                knownAddress.OrderApi__Postal_Code__c = contact.MailingPostalCode;
                knownAddress.OrderApi__Country__c = contact.MailingCountryCode;
                knownAddress.FS_County__c = contact.FS_API_Mailing_County__c;
                knownAddress.FS_Verified__c = contact.smartystreets__Mailing_Verified__c;
                knownAddress.FS_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
                knownAddress.FS_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
                knownAddressList.add(knownAddress);
            }
        }
        for (sObject updatedObject : records) {
            Contact contact = (Contact) updatedObject;
            if (!contactAddressKeyList.contains(contact.Id + '_' + HOME_ADDRESS) &&
                    (String.isNotEmpty(contact.FS_API_Other_County__c) || String.isNotEmpty(contact.OtherStreet) ||
                        String.isNotEmpty(contact.OtherCity) || String.isNotBlank(contact.OtherStateCode) ||
                        String.isNotBlank(contact.OtherPostalCode) || String.isNotBlank(contact.OtherCountryCode))) {
                OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
                knownAddress.OrderApi__Street__c = contact.OtherStreet;
                knownAddress.OrderApi__City__c = contact.OtherCity;
                knownAddress.OrderApi__Province__c = contact.OtherStateCode;
                knownAddress.OrderApi__Postal_Code__c = contact.OtherPostalCode;
                knownAddress.OrderApi__Country__c = contact.OtherCountryCode;
                knownAddress.FS_County__c = contact.FS_API_Other_County__c;
                knownAddress.OrderApi__Type__c = HOME_ADDRESS;
                knownAddress.OrderApi__Contact__c = contact.Id;
                knownAddress.FS_Verified__c = contact.smartystreets__Other_Verified__c;
                knownAddress.FS_Last_Verified__c = contact.smartystreets__Other_Last_Verified__c;
                knownAddress.FS_Return_Code__c = contact.smartystreets__Other_Return_Code__c;
                knownAddressList.add(knownAddress);
            }
            if (!contactAddressKeyList.contains(contact.Id + '_' + WORK_ADDRESS) &&
                    (String.isNotEmpty(contact.FS_API_Mailing_County__c) || String.isNotEmpty(contact.MailingStreet) ||
                        String.isNotEmpty(contact.MailingCity) || String.isNotBlank(contact.MailingStateCode) ||
                        String.isNotBlank(contact.MailingPostalCode) || String.isNotBlank(contact.MailingCountryCode))) {
                OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
                knownAddress.OrderApi__Street__c = contact.MailingStreet;
                knownAddress.OrderApi__City__c = contact.MailingCity;
                knownAddress.OrderApi__Province__c = contact.MailingStateCode;
                knownAddress.OrderApi__Postal_Code__c = contact.MailingPostalCode;
                knownAddress.OrderApi__Country__c = contact.MailingCountryCode;
                knownAddress.FS_County__c = contact.FS_API_Mailing_County__c;
                knownAddress.OrderApi__Type__c = WORK_ADDRESS;
                knownAddress.OrderApi__Contact__c = contact.Id;
                knownAddress.FS_Verified__c = contact.smartystreets__Mailing_Verified__c;
                knownAddress.FS_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
                knownAddress.FS_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
                knownAddressList.add(knownAddress);
            }
        }
        if (knownAddressList.size() > 0 || isDeleted) {
            upsert knownAddressList;
            setDefaultKnownAddress(contactIdSet);
        }
    }
    
    private void setDefaultKnownAddress(Set<Id> contactIdSet) {
        List<OrderApi__Known_Address__c> defaultKnownAddressList = new List<OrderApi__Known_Address__c>();
        Set<Id> contactWOutDefaultIdSet = new Set<Id>();
        for(Contact contact : [
                SELECT Id, (SELECT Id FROM OrderApi__Known_Addresses__r WHERE OrderApi__Is_Default__c = true)
                FROM Contact
                WHERE Id IN :contactIdSet]) {
            if (contact.OrderApi__Known_Addresses__r.size() == 0) {
                contactWOutDefaultIdSet.add(contact.Id);
            }
        }
        for(Contact contact : [
                SELECT Id, (SELECT Id FROM OrderApi__Known_Addresses__r ORDER BY LastModifiedDate DESC LIMIT 1)
                FROM Contact
                WHERE Id IN :contactWOutDefaultIdSet]) {
            if (contact.OrderApi__Known_Addresses__r.size() > 0) {
                OrderApi__Known_Address__c defaultKnownAddress = contact.OrderApi__Known_Addresses__r.get(0);
                defaultKnownAddress.OrderApi__Is_Default__c = true;
                defaultKnownAddressList.add(defaultKnownAddress);                
            }
        }
        if (defaultKnownAddressList.size() > 0) {
            update defaultKnownAddressList;
        }
    }
    
    private Boolean hasMailingAddressChanged(Contact contact, OrderApi__Known_Address__c knownAddress) {
        Boolean hasChanged = contact.FS_API_Mailing_County__c != knownAddress.FS_County__c ||
                contact.MailingStreet != knownAddress.OrderApi__Street__c ||
                contact.MailingCity != knownAddress.OrderApi__City__c ||
                contact.MailingStateCode != knownAddress.OrderApi__Province__c ||
                contact.MailingPostalCode != knownAddress.OrderApi__Postal_Code__c ||
                contact.MailingCountryCode != knownAddress.OrderApi__Country__c;
        return hasChanged;
    }
    
    private Boolean hasOtherAddressChanged(Contact contact, OrderApi__Known_Address__c knownAddress) {
        Boolean hasChanged = contact.FS_API_Other_County__c != knownAddress.FS_County__c ||
                contact.OtherStreet != knownAddress.OrderApi__Street__c ||
                contact.OtherCity != knownAddress.OrderApi__City__c ||
                contact.OtherStateCode != knownAddress.OrderApi__Province__c ||
                contact.OtherPostalCode != knownAddress.OrderApi__Postal_Code__c ||
                contact.OtherCountryCode != knownAddress.OrderApi__Country__c;
        return hasChanged;
    }

    private Boolean isAfterMailingVerification(Contact contact, Contact existingContact) {
        return String.isBlank(existingContact.smartystreets__Mailing_Return_Code__c) &&
                !String.isBlank(contact.smartystreets__Mailing_Return_Code__c);
    }

    private Boolean isAfterOtherVerification(Contact contact, Contact existingContact) {
        return String.isBlank(existingContact.smartystreets__Other_Return_Code__c) &&
                !String.isBlank(contact.smartystreets__Other_Return_Code__c);
    }
}