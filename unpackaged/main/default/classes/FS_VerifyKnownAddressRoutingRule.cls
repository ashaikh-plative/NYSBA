/**
 * Created by dfitzgerald on 10/29/19.
 */

global without sharing class FS_VerifyKnownAddressRoutingRule extends Framework.Domain {
    final String NEW_YORK_STRING = 'New York';
    final String NEW_YORK_CODE_STRING = 'NY';
    final String OUT_OF_STATE_STRING = 'Out of State';
    final String HOME_TYPE = 'Home';
    final String WORK_TYPE = 'Work';

    public FS_VerifyKnownAddressRoutingRule(List<OrderApi__Known_Address__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_VerifyKnownAddressRoutingRule(sObjectList);
        }
    }

    //before insert, update all known addresses that match contact address
    public override void beforeInsert() {
        Framework.Log.push(FS_VerifyKnownAddressRoutingRule.class.getName(),'beforeInsert');

        List<OrderApi__Known_Address__c> knownAddresses = new List<OrderApi__Known_Address__c>();
        List<Id> contactIds = new List<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        //only known addresses that have not been verified and not missing fields and not home or other type
        for (OrderApi__Known_Address__c knownAddress : (List<OrderApi__Known_Address__c>) records) {
            if (!autoverifiedType(knownAddress) && knownAddress.FS_Verified__c == false && knownAddressNotNull(knownAddress)) {
                knownAddresses.add(knownAddress);
            }
        }

        //get all relevant contact ids
        for (OrderApi__Known_Address__c knownAddress : knownAddresses) {
            contactIds.add(knownAddress.OrderApi__Contact__c);
        }

        //get all relevant contacts
        for (Contact contact : [
                SELECT Id,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingStateCode,
                        smartystreets__Mailing_Verified__c,
                        smartystreets__Mailing_Return_Code__c,
                        smartystreets__Mailing_Last_Verified__c,
                        FS_API_Mailing_County__c,
                        FS_Mailing_County__c,
                        OtherStreet,
                        OtherCity,
                        OtherState,
                        OtherStateCode,
                        smartystreets__Other_Verified__c,
                        smartystreets__Other_Return_Code__c,
                        smartystreets__Other_Last_Verified__c,
                        FS_API_Other_County__c,
                        FS_Other_County__c
                FROM Contact
                WHERE Id IN :contactIds
        ]) {
            contactMap.put(contact.Id, contact);
        }

        //sync matching known address verification fields
        for (OrderApi__Known_Address__c knownAddress : knownAddresses) {
            Contact associatedContact = contactMap.get(knownAddress.OrderApi__Contact__c);
            if (addressMatchesContact(knownAddress, associatedContact)) {
                syncVerificationFields(knownAddress, associatedContact);
            } else {
                if (!isNewYorkState(knownAddress.OrderApi__Province__c)) {
                    knownAddress.FS_County__c = OUT_OF_STATE_STRING;
                }
            }
        }

        Framework.Log.pop();
    }

    //if known address has not been verified yet after insert, verify (callout to smartystreets)
    public override void afterInsert() {
        Framework.Log.push(FS_VerifyKnownAddressRoutingRule.class.getName(),'afterInsert');
        List<OrderApi__Known_Address__c> knownAddresses = (List<OrderApi__Known_Address__c>) records;
        List<OrderApi__Known_Address__c> knownAddressesToBeVerified = new List<OrderApi__Known_Address__c>();

        //only known addresses that have not been verified
        for (OrderApi__Known_Address__c knownAddress : knownAddresses) {
            if (!autoverifiedType(knownAddress) && addressNeedsVerification(knownAddress)) {
                knownAddressesToBeVerified.add(knownAddress);
            }
        }

        makeCallouts(knownAddressesToBeVerified);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecordsMap) {
        Framework.Log.push(FS_VerifyKnownAddressRoutingRule.class.getName(),'beforeUpdate');
        List<OrderApi__Known_Address__c> knownAddressesToBeVerified = new List<OrderApi__Known_Address__c>();

        for (OrderApi__Known_Address__c knownAddress : (List<OrderApi__Known_Address__c>) records) {
            OrderApi__Known_Address__c existingKnownAddress = (OrderApi__Known_Address__c) existingRecordsMap.get(knownAddress.Id);

            if (!autoverifiedType(knownAddress)) {
                //if address has changed, reset county and verification fields
                if (!isNewVerification(knownAddress, existingKnownAddress) && !knownAddressesMatch(knownAddress, existingKnownAddress)) {
                    resetVerificationFields(knownAddress);
                }

                //set county if not in NY
                if (!isNewYorkState(knownAddress.OrderApi__Province__c)) {
                    knownAddress.FS_County__c = OUT_OF_STATE_STRING;
                }

                //only known addresses that have not been verified and no county
                if (knownAddress.FS_Verified__c == false && knownAddress.FS_County__c == null) {
                    knownAddressesToBeVerified.add(knownAddress);
                }
            }
        }

        if (knownAddressesToBeVerified.size() > 0) {
            makeCallouts(knownAddressesToBeVerified);
        }
        Framework.Log.pop();
    }

    //requirements for verification (not verified and in New York)
    private Boolean addressNeedsVerification(OrderApi__Known_Address__c knownAddress) {
        return (knownAddress.FS_Verified__c == false && isNewYorkState(knownAddress.OrderApi__Province__c));
    }

    //sync known address's verification status fields with its associated contact
    private void syncVerificationFields(OrderApi__Known_Address__c knownAddress,
            Contact contact) {
            knownAddress.FS_Verified__c = contact.smartystreets__Mailing_Verified__c;
            knownAddress.FS_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
            knownAddress.FS_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
            knownAddress.FS_County__c = contact.FS_Mailing_County__c;
    }

    //check if the knownaddress is a type that will be auto-verified after being auto-synced (currently home and work)
    private Boolean autoverifiedType(OrderApi__Known_Address__c knownAddress) {
        return (knownAddress.OrderApi__Type__c == HOME_TYPE || knownAddress.OrderApi__Type__c == WORK_TYPE);
    }

    //check if known address address fields are not null
    private Boolean knownAddressNotNull(OrderApi__Known_Address__c knownAddress) {
        return (!String.isBlank(knownAddress.OrderApi__Street__c) &&
                !String.isBlank(knownAddress.OrderApi__City__c) &&
                !String.isBlank(knownAddress.OrderApi__Province__c));
    }

    //check if known address matches contact
    private Boolean addressMatchesContact(OrderApi__Known_Address__c knownAddress, Contact contact) {
        Boolean mailingAddressNotNull, otherAddressNotNull, mailingAddressMatches, otherAddressMatches;

        mailingAddressNotNull = !String.isBlank(contact.MailingStreet) && !String.isBlank(contact.MailingCity) &&
                !String.isBlank(contact.MailingState);

        otherAddressNotNull = !String.isBlank(contact.OtherStreet) && !String.isBlank(contact.OtherCity) &&
                !String.isBlank(contact.OtherState);

        mailingAddressMatches = mailingAddressNotNull &&
                knownAddress.OrderApi__Street__c.trim() == contact.MailingStreet.trim() &&
                knownAddress.OrderApi__City__c.trim() == contact.MailingCity.trim() &&
                (knownAddress.OrderApi__Province__c.trim() == contact.MailingState.trim() ||
                        knownAddress.OrderApi__Province__c.trim() == contact.MailingStateCode.trim());

        otherAddressMatches = otherAddressNotNull &&
                knownAddress.OrderApi__Street__c.trim() == contact.OtherStreet.trim() &&
                knownAddress.OrderApi__City__c.trim() == contact.OtherCity.trim() &&
                (knownAddress.OrderApi__Province__c.trim() == contact.OtherState.trim() ||
                        knownAddress.OrderApi__Province__c.trim() == contact.OtherStateCode.trim());

        return mailingAddressMatches || otherAddressMatches;

    }

    private Boolean isNewVerification(OrderApi__Known_Address__c newKA, OrderApi__Known_Address__c oldKA) {
        return (newKA.FS_Last_Verified__c != null &&
                (oldKA.FS_Last_Verified__c == null || newKA.FS_Last_Verified__c > oldKA.FS_Last_Verified__c));
    }

    //check if two known addresses match
    private Boolean knownAddressesMatch(OrderApi__Known_Address__c ka1, OrderApi__Known_Address__c ka2) {
        return (ka1.OrderApi__Street__c.trim() == ka2.OrderApi__Street__c.trim() &&
                ka1.OrderApi__City__c.trim() == ka2.OrderApi__City__c.trim() &&
                ka1.OrderApi__Province__c.trim() == ka2.OrderApi__Province__c.trim());
    }

    //reset known address's verification status fields
    private void resetVerificationFields(OrderApi__Known_Address__c knownAddress) {
        knownAddress.FS_County__c = null;
        knownAddress.FS_Verified__c = false;
        knownAddress.FS_Last_Verified__c = null;
        knownAddress.FS_Return_Code__c = null;
    }

    private Boolean isNewYorkState(String state) {
        return (state == NEW_YORK_STRING || state == NEW_YORK_CODE_STRING);
    }

    private void makeCallouts(List<OrderApi__Known_Address__c> knownAddressesToBeVerified) {
        for (OrderApi__Known_Address__c knownAddress : knownAddressesToBeVerified) {
            FS_GetCountyFromSS calloutJob = new FS_GetCountyFromSS(knownAddress);
            Id jobId = System.enqueueJob(calloutJob);
        }
    }
}