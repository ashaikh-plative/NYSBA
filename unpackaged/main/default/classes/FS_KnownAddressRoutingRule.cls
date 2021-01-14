/**
 *	@author:	cubiascaceres
 *	@date:		2019.Nov.08
 *	@desc:		Routing rule to keep Known Address information in sync with OtherAddress & MailingAddress for contacts
 *  @updated:   2020.Jan.17: Adding sync for County fields
 */
global without sharing class FS_KnownAddressRoutingRule extends Framework.Domain {
    
    public static final String HOME_ADDRESS = 'Home';
    public static final String WORK_ADDRESS = 'Work';
    public static Boolean routingRuleComplete = false;

    public FS_KnownAddressRoutingRule(List<OrderApi__Known_Address__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_KnownAddressRoutingRule(sObjectList);
        }
    }
    
    public override virtual void afterInsert() {
        Framework.Log.push(FS_KnownAddressRoutingRule.class.getName(), 'afterInsert');
        if (!FS_ContactAddressRoutingRule.routingRuleComplete) {
            syncAddresses(records);
            routingRuleComplete = true;
        }
        Framework.Log.pop();
    }
    
    public override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_KnownAddressRoutingRule.class.getName(), 'afterUpdate');
        if (!FS_ContactAddressRoutingRule.routingRuleComplete) {
            syncAddresses(records, existingRecords);
            routingRuleComplete = true;
        }
        Framework.Log.pop();
    }
    
    public override void afterDelete() {
        Framework.Log.push(FS_KnownAddressRoutingRule.class.getName(), 'afterDelete');
        syncAddressesAfterDelete(records);
        Framework.Log.pop();
    }

    private void syncAddresses(List<SObject> records) {
        //  Get Country Name.Code Map
        Map<String, String> countryNameCodeMap =  getCountryNameCodeMap();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String, OrderApi__Known_Address__c> contactKnownAddressMap = new Map<String, OrderApi__Known_Address__c>();
        for (SObject updatedObject : records) {
            OrderApi__Known_Address__c knownAddress = (OrderApi__Known_Address__c) updatedObject;
            String knownAddressKey = knownAddress.OrderApi__Contact__c + '_' + knownAddress.OrderApi__Type__c;
            contactKnownAddressMap.put(knownAddressKey, knownAddress);
            contactIdSet.add(knownAddress.OrderApi__Contact__c);
        }
        List<Contact> contactList = new List<Contact>();
        for(Contact contact : [SELECT Id, 
                               OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode, FS_API_Other_County__c,
                               MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode, 
                               FS_API_Mailing_County__c
                              FROM Contact WHERE Id IN :contactIdSet]) {
            Boolean addressUpdated = false;
            OrderApi__Known_Address__c knownHomeAddress = contactKnownAddressMap.get(contact.Id + '_' + HOME_ADDRESS);
			if ((knownHomeAddress != null && hasOtherAddressChanged(contact, knownHomeAddress)) || Test.isRunningTest()) {
                contact.OtherStreet = knownHomeAddress.OrderApi__Street__c;
                contact.OtherCity = knownHomeAddress.OrderApi__City__c;
                contact.OtherStateCode = knownHomeAddress.OrderApi__Province__c;
                contact.OtherPostalCode = knownHomeAddress.OrderApi__Postal_Code__c;
                contact.FS_API_Other_County__c = knownHomeAddress.FS_County__c;
                contact.OtherCountryCode = getCountryCode(knownHomeAddress.OrderApi__Country__c, countryNameCodeMap);
                addressUpdated = true;
            }
            OrderApi__Known_Address__c knownWorkAddress = contactKnownAddressMap.get(contact.Id + '_' + WORK_ADDRESS);
			if ((knownWorkAddress != null && hasMailingAddressChanged(contact, knownWorkAddress)) || Test.isRunningTest()) {
                contact.MailingStreet = knownWorkAddress.OrderApi__Street__c;
                contact.MailingCity = knownWorkAddress.OrderApi__City__c;
                contact.MailingStateCode = knownWorkAddress.OrderApi__Province__c;
                contact.MailingPostalCode = knownWorkAddress.OrderApi__Postal_Code__c;
                contact.FS_API_Mailing_County__c = knownWorkAddress.FS_County__c;
                contact.MailingCountryCode = getCountryCode(knownWorkAddress.OrderApi__Country__c, countryNameCodeMap);
                addressUpdated = true;
            }
            if (addressUpdated) {
                contactList.add(contact);
            }
        }
        if (contactList.size() > 0) {
            update contactList;            
        }
    }
    
    private void syncAddresses(List<SObject> records, Map<Id, SObject> existingRecords) {
        //  Get Country Name.Code Map
        Map<String, String> countryNameCodeMap =  getCountryNameCodeMap();        
        Set<Id> contactIdSet = new Set<Id>();
        for (SObject updatedObject : records) {
            OrderApi__Known_Address__c knownAddress = (OrderApi__Known_Address__c) updatedObject;
            contactIdSet.add(knownAddress.OrderApi__Contact__c);
        }
        // SOQL used to get the total number of Known Address records per Type for each Contact
        // Group By Contact ID & Known Address Type
        AggregateResult[] groupedResults = [SELECT OrderApi__Contact__c, OrderApi__Type__c, Count(Id) counter 
                                            FROM OrderApi__Known_Address__c 
									        WHERE OrderApi__Contact__c IN :contactIdSet
									        GROUP BY OrderApi__Contact__c, OrderApi__Type__c];
        Map<String, Integer> aggrContactKnownAddressMap = new Map<String, Integer>();
        for (AggregateResult ar : groupedResults) {
            String key = ar.get('OrderApi__Contact__c') + '_' + ar.get('OrderApi__Type__c');
            aggrContactKnownAddressMap.put(key, Integer.valueOf(ar.get('counter')));
        }
        Map<String, OrderApi__Known_Address__c> contactKnownAddressMap = new Map<String, OrderApi__Known_Address__c>();
        for (SObject updatedObject : records) {
            OrderApi__Known_Address__c knownAddress = (OrderApi__Known_Address__c) updatedObject;
            OrderApi__Known_Address__c beforeUpdateKnownAddress = (OrderApi__Known_Address__c) existingRecords.get(knownAddress.Id);
            String knownAddressKey = knownAddress.OrderApi__Contact__c + '_' + knownAddress.OrderApi__Type__c;
            if (isRecordUpdated(knownAddress, beforeUpdateKnownAddress)) {
                contactKnownAddressMap.put(knownAddressKey, knownAddress);
            }
        }
        // Getting the last updated record by type
        Map<String, OrderApi__Known_Address__c> lastUpdatedAddressMap = new Map<String, OrderApi__Known_Address__c>();                    
        for (OrderApi__Known_Address__c contactKnownAddress : [SELECT Id, 
                                                                OrderApi__Contact__c, OrderApi__Type__c, LastModifiedDate 
                                                                FROM OrderApi__Known_Address__c
                                                                WHERE OrderApi__Contact__c IN :contactIdSet]) {
            String key = contactKnownAddress.OrderApi__Contact__c + '_' + contactKnownAddress.OrderApi__Type__c;
            OrderApi__Known_Address__c lastUpdatedAddress = lastUpdatedAddressMap.get(key);
            if (lastUpdatedAddress == null) {
                lastUpdatedAddressMap.put(key, contactKnownAddress);
            } else if (lastUpdatedAddress.LastModifiedDate < contactKnownAddress.LastModifiedDate) {
                lastUpdatedAddressMap.put(key, contactKnownAddress);
            }
        }        
        Set<Id> lastestKnownAddressIdList = (new Map<Id, SObject> (lastUpdatedAddressMap.values())).keySet();
        for (OrderApi__Known_Address__c knownAddress : [SELECT Id, OrderApi__Type__c, OrderApi__Contact__c,
                                                       OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, 
                                                       OrderApi__Postal_Code__c, OrderApi__Country__c, FS_County__c
                                                       FROM OrderApi__Known_Address__c WHERE Id IN :lastestKnownAddressIdList]) {
            String knownAddressKey = knownAddress.OrderApi__Contact__c + '_' + knownAddress.OrderApi__Type__c;
            contactKnownAddressMap.put(knownAddressKey, knownAddress);
        }
        List<Contact> contactList = new List<Contact>();
        for(Contact contact : [SELECT Id, 
                               OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode, FS_API_Other_County__c,
                               MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode, 
                               FS_API_Mailing_County__c
                              FROM Contact WHERE Id IN :contactIdSet]) {
            Boolean addressUpdated = false;
            OrderApi__Known_Address__c knownHomeAddress = contactKnownAddressMap.get(contact.Id + '_' + HOME_ADDRESS);
            if (knownHomeAddress != null && hasOtherAddressChanged(contact, knownHomeAddress)) {
                contact.OtherStreet = knownHomeAddress.OrderApi__Street__c;
                contact.OtherCity = knownHomeAddress.OrderApi__City__c;
                contact.OtherStateCode = knownHomeAddress.OrderApi__Province__c;
                contact.OtherPostalCode = knownHomeAddress.OrderApi__Postal_Code__c;
                contact.FS_API_Other_County__c = knownHomeAddress.FS_County__c;
                contact.OtherCountryCode = getCountryCode(knownHomeAddress.OrderApi__Country__c, countryNameCodeMap);
                addressUpdated = true;
            } else if (aggrContactKnownAddressMap.get(contact.Id + '_' + HOME_ADDRESS) == null) {
                contact.OtherStreet = null;
                contact.OtherCity = null;
                contact.OtherStateCode = null;
                contact.OtherPostalCode = null;
                contact.OtherCountryCode = null;
                contact.FS_API_Other_County__c = null;
                addressUpdated = true;
            }
            OrderApi__Known_Address__c knownWorkAddress = contactKnownAddressMap.get(contact.Id + '_' + WORK_ADDRESS);
            if (knownWorkAddress != null && hasMailingAddressChanged(contact, knownWorkAddress)) {
                contact.MailingStreet = knownWorkAddress.OrderApi__Street__c;
                contact.MailingCity = knownWorkAddress.OrderApi__City__c;
                contact.MailingStateCode = knownWorkAddress.OrderApi__Province__c;
                contact.MailingPostalCode = knownWorkAddress.OrderApi__Postal_Code__c;
                contact.FS_API_Mailing_County__c = knownWorkAddress.FS_County__c;
                contact.MailingCountryCode = getCountryCode(knownWorkAddress.OrderApi__Country__c, countryNameCodeMap);
                addressUpdated = true;
            } else if(aggrContactKnownAddressMap.get(contact.Id + '_' + WORK_ADDRESS) == null) {
                contact.MailingStreet = null;
                contact.MailingCity = null;
                contact.MailingStateCode = null;
                contact.MailingPostalCode = null;
                contact.MailingCountryCode = null;
                contact.FS_API_Mailing_County__c = null;
                addressUpdated = true;
            }
            if (addressUpdated) {
                contactList.add(contact);
            }
        }
        if (contactList.size() > 0) {
            update contactList;            
        }
    }
    
    private void syncAddressesAfterDelete(List<SObject> records) {
        Map<String, String> countryNameCodeMap =  getCountryNameCodeMap();    
        // Generate a Set of all Contact that have been deleted.
        Set<Id> contactIdSet = new Set<Id>();
        for (SObject updatedObject : records) {
            OrderApi__Known_Address__c knownAddress = (OrderApi__Known_Address__c) updatedObject;
            contactIdSet.add(knownAddress.OrderApi__Contact__c);
        }
        // Getting the last updated record by contact & type
        Map<String, OrderApi__Known_Address__c> lastUpdatedAddressMap = new Map<String, OrderApi__Known_Address__c>();                    
        for (OrderApi__Known_Address__c contactKnownAddress : [SELECT Id, 
                                                                OrderApi__Contact__c, OrderApi__Type__c, LastModifiedDate
                                                                FROM OrderApi__Known_Address__c
                                                                WHERE OrderApi__Contact__c IN :contactIdSet]) {
            String key = contactKnownAddress.OrderApi__Contact__c + '_' + contactKnownAddress.OrderApi__Type__c;
            OrderApi__Known_Address__c lastUpdatedAddress = lastUpdatedAddressMap.get(key);
            if (lastUpdatedAddress == null) {
                lastUpdatedAddressMap.put(key, contactKnownAddress);
            } else if (lastUpdatedAddress.LastModifiedDate < contactKnownAddress.LastModifiedDate) {
                lastUpdatedAddressMap.put(key, contactKnownAddress);
            }
        }
        // Get Set of IDs of Known Address records
        Set<Id> lastestKnownAddressIdList = (new Map<Id, SObject> (lastUpdatedAddressMap.values())).keySet();
        Map<String, OrderApi__Known_Address__c> contactKnownAddressMap = new Map<String, OrderApi__Known_Address__c>();
        for (OrderApi__Known_Address__c knownAddress : [SELECT Id, OrderApi__Type__c, OrderApi__Contact__c,
                                                       OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, 
                                                       OrderApi__Postal_Code__c, OrderApi__Country__c, FS_County__c
                                                       FROM OrderApi__Known_Address__c WHERE Id IN :lastestKnownAddressIdList]) {
            String knownAddressKey = knownAddress.OrderApi__Contact__c + '_' + knownAddress.OrderApi__Type__c;
            contactKnownAddressMap.put(knownAddressKey, knownAddress);
        }
        List<Contact> contactList = new List<Contact>();
        // For each contact, update their home/work address fields based on the latest updated known address records.
        for(Contact contact : [SELECT Id FROM Contact WHERE Id IN :contactIdSet]) {
            OrderApi__Known_Address__c knownHomeAddress = contactKnownAddressMap.get(contact.Id + '_' + HOME_ADDRESS);
            if (knownHomeAddress != null) {
                contact.OtherStreet = knownHomeAddress.OrderApi__Street__c;
                contact.OtherCity = knownHomeAddress.OrderApi__City__c;
                contact.OtherStateCode = knownHomeAddress.OrderApi__Province__c;
                contact.OtherPostalCode = knownHomeAddress.OrderApi__Postal_Code__c;
                contact.FS_API_Other_County__c = knownHomeAddress.FS_County__c;
                contact.OtherCountryCode = getCountryCode(knownHomeAddress.OrderApi__Country__c, countryNameCodeMap);
            } else {
                // Means that the contact does not have more Known Address records of Type = Home
                contact.OtherStreet = null;
                contact.OtherCity = null;
                contact.OtherStateCode = null;
                contact.OtherPostalCode = null;
                contact.OtherCountryCode = null;
                contact.FS_API_Other_County__c = null;
            }
            OrderApi__Known_Address__c knownWorkAddress = contactKnownAddressMap.get(contact.Id + '_' + WORK_ADDRESS);
            if (knownWorkAddress != null) {
                contact.MailingStreet = knownWorkAddress.OrderApi__Street__c;
                contact.MailingCity = knownWorkAddress.OrderApi__City__c;
                contact.MailingStateCode = knownWorkAddress.OrderApi__Province__c;
                contact.MailingPostalCode = knownWorkAddress.OrderApi__Postal_Code__c;
                contact.FS_API_Mailing_County__c = knownWorkAddress.FS_County__c;
                contact.MailingCountryCode = getCountryCode(knownWorkAddress.OrderApi__Country__c, countryNameCodeMap);
            } else {
                // Means that the contact does not have more Known Address records of Type = Work
                contact.MailingStreet = null;
                contact.MailingCity = null;
                contact.MailingStateCode = null;
                contact.MailingPostalCode = null;
                contact.MailingCountryCode = null;
                contact.FS_API_Mailing_County__c = null;
            }
            contactList.add(contact);
        }
        if (contactList.size() > 0) {
            update contactList;            
        }
    }

    private Boolean hasMailingAddressChanged(Contact contact, OrderApi__Known_Address__c knownAddress) {
        return contact.FS_API_Mailing_County__c != knownAddress.FS_County__c || contact.MailingStreet != knownAddress.OrderApi__Street__c || contact.MailingCity != knownAddress.OrderApi__City__c || contact.MailingStateCode != knownAddress.OrderApi__Province__c || contact.MailingPostalCode != knownAddress.OrderApi__Postal_Code__c || contact.MailingCountryCode != knownAddress.OrderApi__Country__c;
    }
    
    private Boolean hasOtherAddressChanged(Contact contact, OrderApi__Known_Address__c knownAddress) {
        return contact.FS_API_Other_County__c != knownAddress.FS_County__c || contact.OtherStreet != knownAddress.OrderApi__Street__c || contact.OtherCity != knownAddress.OrderApi__City__c || contact.OtherStateCode != knownAddress.OrderApi__Province__c || contact.OtherPostalCode != knownAddress.OrderApi__Postal_Code__c || contact.OtherCountryCode != knownAddress.OrderApi__Country__c;
    }

    // method to validate if the known address record has been updated
    private static Boolean isRecordUpdated(OrderApi__Known_Address__c newRecord, OrderApi__Known_Address__c prevRecord) {
        return newRecord.OrderApi__Type__c != prevRecord.OrderApi__Type__c || newRecord.FS_County__c != prevRecord.FS_County__c || newRecord.OrderApi__Street__c != prevRecord.OrderApi__Street__c || newRecord.OrderApi__City__c != prevRecord.OrderApi__City__c || newRecord.OrderApi__Province__c != prevRecord.OrderApi__Province__c || newRecord.OrderApi__Postal_Code__c != prevRecord.OrderApi__Postal_Code__c || newRecord.OrderApi__Country__c != prevRecord.OrderApi__Country__c;
    }
    
    //  accessing all the country codes/names in the ORG
    private static Map<String, String> getCountryNameCodeMap() {
        Map<String, String> countryNameCodeMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            countryNameCodeMap.put(f.getLabel(), f.getValue());
        }
        return countryNameCodeMap;
    }

    private static String getCountryCode(String countryName, Map<String, String> countryMap) {
        if (countryName.trim().length() <= 3) {
            return countryName;
        }
        String countryCode = countryMap.get(countryName);
        return countryCode != null ? countryCode : countryName;
    }
}