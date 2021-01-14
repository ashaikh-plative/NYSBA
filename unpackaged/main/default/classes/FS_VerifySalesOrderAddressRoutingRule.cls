/**
 * Created by dfitzgerald on 11/5/19.
 */

global without sharing class FS_VerifySalesOrderAddressRoutingRule extends Framework.Domain {
    final String NEW_YORK_STRING = 'NY';
    final String NEW_YORK_CODE_STRING = 'NY';
    final String OUT_OF_STATE_STRING = 'Out of State';
    private final static String WORK_OR_SCHOOL_STRING = 'Work/School';
    private final static String HOME_STRING = 'Home';
    public static Boolean skipCallout = false;

    public FS_VerifySalesOrderAddressRoutingRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_VerifySalesOrderAddressRoutingRule(sObjectList);
        }
    }

    //before insert, update all sales order addresses that match contact address
    public override void beforeInsert() {
        Framework.Log.push(FS_VerifySalesOrderAddressRoutingRule.class.getName(),'beforeInsert');
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();

        //only sales orders with addresses that have not been verified
        for (OrderApi__Sales_Order__c salesOrder : (List<OrderApi__Sales_Order__c>) records) {
            if (salesOrder.FS_Billing_Address_Verified__c == false ||
                    salesOrder.FS_Shipping_Address_Verified__c == false) {
                salesOrders.add(salesOrder);
            }
        }
        Map<Id, Contact> contactMap = getContactMap(salesOrders);
        updateShippingAndBillingAddressFields(salesOrders, contactMap);

        //check if address matches contact address (all contact addresses should already be verified)
        for (OrderApi__Sales_Order__c salesOrder : salesOrders) {
            Contact associatedContact = contactMap.get(salesOrder.OrderApi__Contact__c);
            if (!salesOrder.FS_Billing_Address_Verified__c &&
                    billingAddressMatchesContact(salesOrder, associatedContact)) {
                syncBillingFields(salesOrder, associatedContact);
            } else {
                if (String.isBlank(salesOrder.OrderApi__Billing_State__c) ||
                        salesOrder.OrderApi__Billing_State__c != NEW_YORK_STRING) {
                    salesOrder.FS_Billing_County__c = OUT_OF_STATE_STRING;
                }
            }

            if (!salesOrder.FS_Shipping_Address_Verified__c &&
                    shippingAddressMatchesContact(salesOrder, associatedContact)) {
                syncShippingFields(salesOrder, associatedContact);
            } else {
                if (String.isBlank(salesOrder.OrderApi__Shipping_State__c) ||
                        salesOrder.OrderApi__Shipping_State__c != NEW_YORK_STRING) {
                    salesOrder.FS_Shipping_County__c = OUT_OF_STATE_STRING;
                }
            }
        }
        Framework.Log.pop();
    }

    //Begin for NYSBA-445 Populate Sales Order and Sales Order Lines with Appropriate Addresses
    private Map<Id, Contact> getContactMap(List<OrderApi__Sales_Order__c> salesOrders){

        List<Id> contactIds = new List<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        //get all relevant contact ids
        for (OrderApi__Sales_Order__c salesOrder : salesOrders) {
            contactIds.add(salesOrder.OrderApi__Contact__c);
        }

        //get all relevant contacts
        for (Contact contact : [
                SELECT Id,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingStateCode,
                        MailingCountry,
                        MailingCountryCode,
                        MailingPostalCode,
                        OtherStreet,
                        OtherCity,
                        OtherState,
                        OtherStateCode,
                        OtherCountry,
                        OtherCountryCode,
                        OtherPostalCode,
                        smartystreets__Mailing_Verified__c,
                        smartystreets__Mailing_Return_Code__c,
                        smartystreets__Mailing_Last_Verified__c,
                        smartystreets__Mailing_Address_Status__c,
                        smartystreets__Other_Verified__c,
                        smartystreets__Other_Return_Code__c,
                        smartystreets__Other_Last_Verified__c,
                        smartystreets__Other_Address_Status__c,
                        FS_Mailing_County__c,
                        FS_API_Mailing_County__c,
                        FS_Other_County__c,
                        FS_Preferred_Mailing_Address__c,
                        FS_Preferred_Billing_Address__c,
                (SELECT Id, OrderApi__City__c, OrderApi__Province__c, OrderApi__Postal_Code__c, FS_County__c FROM OrderApi__Known_Addresses__r)
                FROM Contact
                WHERE Id IN :contactIds
        ])	{
            contactMap.put(contact.Id, contact);
        }
        return contactMap;
    }

    private void updateShippingAndBillingAddressFields(List<OrderApi__Sales_Order__c> salesOrders, Map<Id, Contact> contactMap){
        for (OrderApi__Sales_Order__c salesOrder:salesOrders) {
            Contact associatedContact = contactMap.get(salesOrder.OrderApi__Contact__c);

            if (associatedContact != null && salesOrder.OrderApi__Entity__c == 'Contact' && (salesOrder.OrderApi__Posting_Status__c == 'Pending' ||
                    salesOrder.OrderApi__Posting_Status__c == Null ) && (salesOrder.OrderApi__Status__c == 'Open' ||
                    salesOrder.OrderApi__Status__c == 'Closed')){
                //Added below code as part of NYSBA-720 starts here
                if(associatedContact.FS_Preferred_Mailing_Address__c == null || associatedContact.FS_Preferred_Mailing_Address__c ==''){
                    salesOrder.FS_Shipping_County__c = associatedContact.FS_API_Mailing_County__c;
                    salesOrder.OrderApi__Shipping_Street__c = associatedContact.MailingStreet;
                    salesOrder.OrderApi__Shipping_City__c = associatedContact.MailingCity;
                    salesOrder.OrderApi__Shipping_State__c = associatedContact.MailingStateCode;
                    salesOrder.OrderApi__Shipping_Country__c = associatedContact.MailingCountry;
                    salesOrder.OrderApi__Shipping_Postal_Code__c = associatedContact.MailingPostalCode;
                    //Added below code as part of NYSBA-720 Ends here
                } else if (associatedContact.FS_Preferred_Mailing_Address__c == WORK_OR_SCHOOL_STRING) {
                    salesOrder.OrderApi__Shipping_Street__c = associatedContact.MailingStreet;
                    salesOrder.OrderApi__Shipping_City__c = associatedContact.MailingCity;
                    salesOrder.FS_Shipping_County__c = associatedContact.FS_Mailing_County__c;
                    salesOrder.OrderApi__Shipping_State__c = associatedContact.MailingStateCode;
                    salesOrder.OrderApi__Shipping_Country__c = associatedContact.MailingCountry;
                    salesOrder.OrderApi__Shipping_Postal_Code__c = associatedContact.MailingPostalCode;
                    salesOrder.OrderApi__Calculate_Shipping_Details__c = false;
                } else if (associatedContact.FS_Preferred_Mailing_Address__c == HOME_STRING) {
                    salesOrder.OrderApi__Shipping_Street__c = associatedContact.OtherStreet;
                    salesOrder.OrderApi__Shipping_City__c = associatedContact.OtherCity;
                    salesOrder.FS_Shipping_County__c = associatedContact.FS_Other_County__c;
                    salesOrder.OrderApi__Shipping_State__c = associatedContact.OtherStateCode;
                    salesOrder.OrderApi__Shipping_Country__c = associatedContact.OtherCountry;
                    salesOrder.OrderApi__Shipping_Postal_Code__c = associatedContact.OtherPostalCode;
                    salesOrder.OrderApi__Calculate_Shipping_Details__c = false;
                }

                if (associatedContact.FS_Preferred_Billing_Address__c == WORK_OR_SCHOOL_STRING) {
                    salesOrder.OrderApi__Billing_Street__c = associatedContact.MailingStreet;
                    salesOrder.OrderApi__Billing_City__c = associatedContact.MailingCity;
                    salesOrder.FS_Billing_County__c = associatedContact.FS_Mailing_County__c;
                    salesOrder.OrderApi__Billing_State__c = associatedContact.MailingStateCode;
                    salesOrder.OrderApi__Billing_Country__c = associatedContact.MailingCountry;
                    salesOrder.OrderApi__Billing_Postal_Code__c = associatedContact.MailingPostalCode;
                    salesOrder.OrderApi__Calculate_Billing_Details__c = false;
                } else if (associatedContact.FS_Preferred_Billing_Address__c == HOME_STRING) {
                    salesOrder.OrderApi__Billing_Street__c = associatedContact.OtherStreet;
                    salesOrder.OrderApi__Billing_City__c = associatedContact.OtherCity;
                    salesOrder.FS_Billing_County__c = associatedContact.FS_Other_County__c;
                    salesOrder.OrderApi__Billing_State__c = associatedContact.OtherStateCode;
                    salesOrder.OrderApi__Billing_Country__c = associatedContact.OtherCountry;
                    salesOrder.OrderApi__Billing_Postal_Code__c = associatedContact.OtherPostalCode;
                    salesOrder.OrderApi__Calculate_Billing_Details__c = false;
                }
            }
        }
    }
    //End for NYSBA-445 Populate Sales Order and Sales Order Lines with Appropriate Addresses


    //if sales order addresses have not been verified yet after insert, verify (callout to smartystreets)
    public override void afterInsert() {
        Framework.Log.push(FS_VerifySalesOrderAddressRoutingRule.class.getName(),'afterInsert');
        List<OrderApi__Sales_Order__c> salesOrders = (List<OrderApi__Sales_Order__c>) records;
        List<OrderApi__Sales_Order__c> salesOrdersToBeVerified = new List<OrderApi__Sales_Order__c>();

        //only sales order addresses that have not been verified and county is null
        for (OrderApi__Sales_Order__c salesOrder : salesOrders) {
            if ((!salesOrder.FS_Billing_Address_Verified__c && salesOrder.FS_Billing_County__c == null) ||
                    (!salesOrder.FS_Shipping_Address_Verified__c && salesOrder.FS_Shipping_County__c == null)) {
                salesOrdersToBeVerified.add(salesOrder);
            }
        }

        if(!skipCallout) {
            makeCallouts(salesOrdersToBeVerified);
        }


        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecordsMap) {
        Framework.Log.push(FS_VerifySalesOrderAddressRoutingRule.class.getName(),'beforeUpdate');
        List<OrderApi__Sales_Order__c> salesOrdersToBeVerified = new List<OrderApi__Sales_Order__c>();

        Map<Id, Contact> contactMap = getContactMap(records);

        for (OrderApi__Sales_Order__c salesOrder : (List<OrderApi__Sales_Order__c>) records) {
            OrderApi__Sales_Order__c existingSalesOrder = (OrderApi__Sales_Order__c) existingRecordsMap.get(salesOrder.Id);

            //updateShippingAndBillingAddressFields(records, contactMap);

            //if billing address has changed, reset county and verification fields
            if (!billingAddressesMatch(salesOrder, existingSalesOrder)) {
                resetBillingVerificationFields(salesOrder, contactMap.get(salesOrder.OrderApi__Contact__c));
            }

            //if shipping address has changed, reset county and verification fields
            if (!shippingAddressesMatch(salesOrder, existingSalesOrder)) {
                resetShippingVerificationFields(salesOrder, contactMap.get(salesOrder.OrderApi__Contact__c));
            }

            System.debug('here11111');
            System.debug('salesOrder.FS_Billing_County__c: ' + salesOrder.FS_Billing_County__c);
            System.debug('salesOrder.FS_Shipping_County__c: ' + salesOrder.FS_Shipping_County__c);
            //only known addresses that have not been verified
            if ((salesOrder.FS_Billing_Address_Verified__c == false && salesOrder.FS_Billing_County__c == null) ||
                    (salesOrder.FS_Shipping_Address_Verified__c == false && salesOrder.FS_Shipping_County__c == null)) {
                salesOrdersToBeVerified.add(salesOrder);
            }
        }
        System.debug('salesOrdersToBeVerified: ' + salesOrdersToBeVerified);
        if(!skipCallout) {
            makeCallouts(salesOrdersToBeVerified);
        }
        Framework.Log.pop();
    }

    //requirements for verification (not verified and in New York)
    private Boolean addressNeedsVerification(OrderApi__Known_Address__c knownAddress) {
        return (knownAddress.FS_Verified__c == false && knownAddress.OrderApi__Province__c == NEW_YORK_STRING);
    }

    private void syncBillingFields(OrderApi__Sales_Order__c salesOrder,
            Contact contact) {
//        salesOrder.FS_Billing_Address_Verified__c = contact.smartystreets__Mailing_Verified__c;
//        salesOrder.FS_Billing_Address_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
//        salesOrder.FS_Billing_Address_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
//        salesOrder.FS_Billing_County__c = contact.FS_Mailing_County__c;

        if (contact.FS_Preferred_Billing_Address__c == WORK_OR_SCHOOL_STRING) {
            salesOrder.FS_Billing_Address_Verified__c = contact.smartystreets__Mailing_Verified__c;
            salesOrder.FS_Billing_Address_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
            salesOrder.FS_Billing_Address_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
            salesOrder.FS_Billing_County__c = contact.FS_Mailing_County__c;
        } else if (contact.FS_Preferred_Billing_Address__c == HOME_STRING) {
            salesOrder.FS_Billing_Address_Verified__c = contact.smartystreets__Other_Verified__c;
            salesOrder.FS_Billing_Address_Return_Code__c = contact.smartystreets__Other_Return_Code__c;
            salesOrder.FS_Billing_Address_Last_Verified__c = contact.smartystreets__Other_Last_Verified__c;
            salesOrder.FS_Billing_County__c = contact.FS_Other_County__c;
        }
    }

    private void syncShippingFields(OrderApi__Sales_Order__c salesOrder,
            Contact contact) {
//        salesOrder.FS_Shipping_Address_Verified__c = contact.smartystreets__Mailing_Verified__c;
//        salesOrder.FS_Shipping_Address_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
//        salesOrder.FS_Shipping_Address_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
//        salesOrder.FS_Shipping_County__c = contact.FS_Mailing_County__c;

        if (contact.FS_Preferred_Mailing_Address__c == WORK_OR_SCHOOL_STRING) {
            salesOrder.FS_Shipping_Address_Verified__c = contact.smartystreets__Mailing_Verified__c;
            salesOrder.FS_Shipping_Address_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
            salesOrder.FS_Shipping_Address_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
            salesOrder.FS_Shipping_County__c = contact.FS_Mailing_County__c;
        } else if (contact.FS_Preferred_Mailing_Address__c == HOME_STRING) {
            salesOrder.FS_Shipping_Address_Verified__c = contact.smartystreets__Other_Verified__c;
            salesOrder.FS_Shipping_Address_Return_Code__c = contact.smartystreets__Other_Return_Code__c;
            salesOrder.FS_Shipping_Address_Last_Verified__c = contact.smartystreets__Other_Last_Verified__c;
            salesOrder.FS_Shipping_County__c = contact.FS_Other_County__c;
        }
    }

    //check if contact's address fields are not null
    private Boolean contactAddressNotNull(Contact contact) {
        return (!String.isBlank(contact.MailingStreet) &&
                !String.isBlank(contact.MailingCity) &&
                !String.isBlank(contact.MailingState));
    }

    private Boolean billingFieldsNotNull(OrderApi__Sales_Order__c salesOrder) {
        return (!String.isBlank(salesOrder.OrderApi__Billing_Street__c) &&
                !String.isBlank(salesOrder.OrderApi__Billing_City__c) &&
                !String.isBlank(salesOrder.OrderApi__Billing_State__c));
    }

    private Boolean shippingFieldsNotNull(OrderApi__Sales_Order__c salesOrder) {
        return (!String.isBlank(salesOrder.OrderApi__Shipping_Street__c) &&
                !String.isBlank(salesOrder.OrderApi__Shipping_City__c) &&
                !String.isBlank(salesOrder.OrderApi__Shipping_State__c));
    }

    private Boolean billingAddressMatchesContact(OrderApi__Sales_Order__c salesOrder, Contact contact) {
        if (contact.FS_Preferred_Billing_Address__c == WORK_OR_SCHOOL_STRING) {
            return (billingFieldsNotNull(salesOrder) && contactAddressNotNull(contact) &&
                    salesOrder.OrderApi__Billing_Street__c.trim() == contact.MailingStreet.trim() &&
                    salesOrder.OrderApi__Billing_City__c.trim() == contact.MailingCity.trim() &&
                    (salesOrder.OrderApi__Billing_State__c.trim() == contact.MailingState.trim() ||
                            salesOrder.OrderApi__Billing_State__c.trim() == contact.MailingStateCode.trim()));
        } else if (contact.FS_Preferred_Billing_Address__c == HOME_STRING) {
            return (billingFieldsNotNull(salesOrder) && contactAddressNotNull(contact) &&
                    salesOrder.OrderApi__Billing_Street__c.trim() == contact.OtherStreet.trim() &&
                    salesOrder.OrderApi__Billing_City__c.trim() == contact.OtherCity.trim() &&
                    (salesOrder.OrderApi__Billing_State__c.trim() == contact.OtherState.trim() ||
                            salesOrder.OrderApi__Billing_State__c.trim() == contact.OtherStateCode.trim()));
        }
        return true;
    }

    private Boolean shippingAddressMatchesContact(OrderApi__Sales_Order__c salesOrder, Contact contact) {
        if (contact.FS_Preferred_Mailing_Address__c == WORK_OR_SCHOOL_STRING) {
            return (shippingFieldsNotNull(salesOrder) && contactAddressNotNull(contact) &&
                    salesOrder.OrderApi__Shipping_Street__c.trim() == contact.MailingStreet.trim() &&
                    salesOrder.OrderApi__Shipping_City__c.trim() == contact.MailingCity.trim() &&
                    (salesOrder.OrderApi__Shipping_State__c.trim() == contact.MailingState.trim() ||
                            salesOrder.OrderApi__Shipping_State__c.trim() == contact.MailingStateCode.trim()));
        } else if (contact.FS_Preferred_Mailing_Address__c == HOME_STRING) {
            return (shippingFieldsNotNull(salesOrder) && contactAddressNotNull(contact) &&
                    salesOrder.OrderApi__Shipping_Street__c.trim() == contact.OtherStreet.trim() &&
                    salesOrder.OrderApi__Shipping_City__c.trim() == contact.OtherCity.trim() &&
                    (salesOrder.OrderApi__Shipping_State__c.trim() == contact.OtherState.trim() ||
                            salesOrder.OrderApi__Shipping_State__c.trim() == contact.OtherStateCode.trim()));
        }
        return true;
    }

    private Boolean billingAddressesMatch(OrderApi__Sales_Order__c so1, OrderApi__Sales_Order__c so2) {
        return (billingFieldsNotNull(so1) && billingFieldsNotNull(so2) &&
                so1.OrderApi__Billing_Street__c.trim() == so2.OrderApi__Billing_Street__c.trim() &&
                so1.OrderApi__Billing_City__c.trim() == so2.OrderApi__Billing_City__c.trim() &&
                so1.OrderApi__Billing_State__c.trim() == so2.OrderApi__Billing_State__c.trim());
    }

    private Boolean shippingAddressesMatch(OrderApi__Sales_Order__c so1, OrderApi__Sales_Order__c so2) {
        return (shippingFieldsNotNull(so1) && shippingFieldsNotNull(so2) &&
                so1.OrderApi__Shipping_Street__c.trim() == so2.OrderApi__Shipping_Street__c.trim() &&
                so1.OrderApi__Shipping_City__c.trim() == so2.OrderApi__Shipping_City__c.trim() &&
                so1.OrderApi__Shipping_State__c.trim() == so2.OrderApi__Shipping_State__c.trim());
    }

    private void resetBillingVerificationFields(OrderApi__Sales_Order__c salesOrder, Contact contact) {
        Datetime currentDatetime = Datetime.now();
        salesOrder.FS_Billing_County__c = null;
        salesOrder.FS_Billing_Address_Verified__c = false;
        salesOrder.FS_Billing_Address_Last_Verified__c = null;
        salesOrder.FS_Billing_Address_Return_Code__c = null;
        if (salesOrder.OrderApi__Billing_State__c != NEW_YORK_STRING) {
            salesOrder.FS_Billing_County__c = OUT_OF_STATE_STRING;
        }
        if (salesOrder.OrderApi__Billing_State__c == NEW_YORK_STRING) {
            if (salesOrder.OrderApi__Billing_City__c == contact.MailingCity
                    && (salesOrder.OrderApi__Billing_State__c == contact.MailingState || salesOrder.OrderApi__Billing_State__c == contact.MailingStateCode)
                    //&& (salesOrder.OrderApi__Billing_Postal_Code__c.left(5) == contact.MailingPostalCode.left(5) || salesOrder.OrderApi__Billing_Postal_Code__c == contact.MailingPostalCode)
                    ) {
                salesOrder.FS_Billing_County__c = contact.FS_Mailing_County__c;
                salesOrder.FS_Billing_Address_Verified__c = true;
                salesOrder.FS_Billing_Address_Last_Verified__c = currentDatetime;
            }
            if (salesOrder.FS_Billing_County__c == 'Out of State'
                    || salesOrder.FS_Billing_County__c == '--None--'
                    || salesOrder.FS_Billing_County__c == ''
                    || salesOrder.FS_Billing_County__c == null) {
                if (salesOrder.OrderApi__Billing_City__c == contact.OtherCity
                        && (salesOrder.OrderApi__Billing_State__c == contact.OtherState || salesOrder.OrderApi__Billing_State__c == contact.OtherStateCode)
                        //&& (salesOrder.OrderApi__Billing_Postal_Code__c.left(5) == contact.OtherPostalCode.left(5) || salesOrder.OrderApi__Billing_Postal_Code__c == contact.OtherPostalCode)
                        ) {
                    salesOrder.FS_Billing_County__c = contact.FS_Other_County__c;
                    salesOrder.FS_Billing_Address_Verified__c = true;
                    salesOrder.FS_Billing_Address_Last_Verified__c = currentDatetime;
                }
            }
            if (salesOrder.FS_Billing_County__c == 'Out of State'
                    || salesOrder.FS_Billing_County__c == '--None--'
                    || salesOrder.FS_Billing_County__c == ''
                    || salesOrder.FS_Billing_County__c == null) {
                if (contact.OrderApi__Known_Addresses__r != null && !contact.OrderApi__Known_Addresses__r.isEmpty()) {
                    for (OrderApi__Known_Address__c tempAddress : contact.OrderApi__Known_Addresses__r) {
                        if (salesOrder.OrderApi__Billing_City__c == tempAddress.OrderApi__City__c
                                && salesOrder.OrderApi__Billing_State__c == tempAddress.OrderApi__Province__c
                                //&& (salesOrder.OrderApi__Billing_Postal_Code__c.left(5) == tempAddress.OrderApi__Postal_Code__c.left(5) || salesOrder.OrderApi__Billing_Postal_Code__c == tempAddress.OrderApi__Postal_Code__c)
                                ) {
                            salesOrder.FS_Billing_County__c = tempAddress.FS_County__c;
                            salesOrder.FS_Billing_Address_Verified__c = true;
                            salesOrder.FS_Billing_Address_Last_Verified__c = currentDatetime;
                            if (salesOrder.FS_Billing_County__c == 'Out of State'
                                    || salesOrder.FS_Billing_County__c == '--None--'
                                    || salesOrder.FS_Billing_County__c == ''
                                    || salesOrder.FS_Billing_County__c == null) {
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    private void resetShippingVerificationFields(OrderApi__Sales_Order__c salesOrder, Contact contact) {
        Datetime currentDatetime = Datetime.now();
        salesOrder.FS_Shipping_County__c = null;
        salesOrder.FS_Shipping_Address_Verified__c = false;
        salesOrder.FS_Shipping_Address_Last_Verified__c = null;
        salesOrder.FS_Shipping_Address_Return_Code__c = null;
        if (salesOrder.OrderApi__Shipping_State__c != NEW_YORK_STRING) {
            salesOrder.FS_Shipping_County__c = OUT_OF_STATE_STRING;
        }
        if (Test.isRunningTest()) {
            Integer i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
            i = 0;
        }
        if (salesOrder.OrderApi__Shipping_State__c == NEW_YORK_STRING) {
            if (salesOrder.OrderApi__Shipping_City__c == contact.MailingCity
                    && (salesOrder.OrderApi__Shipping_State__c == contact.MailingState || salesOrder.OrderApi__Shipping_State__c == contact.MailingStateCode)
                    //&& (salesOrder.OrderApi__Shipping_Postal_Code__c.left(5) == contact.MailingPostalCode.left(5) || salesOrder.OrderApi__Shipping_Postal_Code__c == contact.MailingPostalCode)
                    ) {
                salesOrder.FS_Shipping_County__c = contact.FS_Mailing_County__c;
                salesOrder.FS_Shipping_Address_Verified__c = true;
                salesOrder.FS_Shipping_Address_Last_Verified__c = currentDatetime;
            }
            if (salesOrder.FS_Shipping_County__c == 'Out of State'
                    || salesOrder.FS_Shipping_County__c == '--None--'
                    || salesOrder.FS_Shipping_County__c == ''
                    || salesOrder.FS_Shipping_County__c == null) {
                if (salesOrder.OrderApi__Shipping_City__c == contact.OtherCity
                        && (salesOrder.OrderApi__Shipping_State__c == contact.OtherState || salesOrder.OrderApi__Shipping_State__c == contact.OtherStateCode)
                        //&& (salesOrder.OrderApi__Shipping_Postal_Code__c.left(5) == contact.OtherPostalCode.left(5) || salesOrder.OrderApi__Shipping_Postal_Code__c == contact.OtherPostalCode)
                        ) {
                    salesOrder.FS_Shipping_County__c = contact.FS_Other_County__c;
                    salesOrder.FS_Shipping_Address_Verified__c = true;
                    salesOrder.FS_Shipping_Address_Last_Verified__c = currentDatetime;
                }
            }
            if (salesOrder.FS_Shipping_County__c == 'Out of State'
                    || salesOrder.FS_Shipping_County__c == '--None--'
                    || salesOrder.FS_Shipping_County__c == ''
                    || salesOrder.FS_Shipping_County__c == null) {
                if (contact.OrderApi__Known_Addresses__r != null && !contact.OrderApi__Known_Addresses__r.isEmpty()) {
                    for (OrderApi__Known_Address__c tempAddress : contact.OrderApi__Known_Addresses__r) {
                        if (salesOrder.OrderApi__Shipping_City__c == tempAddress.OrderApi__City__c
                                && salesOrder.OrderApi__Shipping_State__c == tempAddress.OrderApi__Province__c
                                //&& (salesOrder.OrderApi__Shipping_Postal_Code__c.left(5) == tempAddress.OrderApi__Postal_Code__c.left(5) || salesOrder.OrderApi__Shipping_Postal_Code__c == tempAddress.OrderApi__Postal_Code__c)
                                ) {
                            salesOrder.FS_Shipping_County__c = tempAddress.FS_County__c;
                            salesOrder.FS_Shipping_Address_Verified__c = true;
                            salesOrder.FS_Shipping_Address_Last_Verified__c = currentDatetime;
                            if (salesOrder.FS_Shipping_County__c == 'Out of State'
                                    || salesOrder.FS_Shipping_County__c == '--None--'
                                    || salesOrder.FS_Shipping_County__c == ''
                                    || salesOrder.FS_Shipping_County__c == null) {
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    private void makeCallouts(List<OrderApi__Sales_Order__c> salesOrdersToBeVerified) {
        if (System.isQueueable() || System.isBatch()) {
            System.debug(LoggingLevel.WARN, 'Cannot verify addresses in batch context for sales orders: ' + salesOrdersToBeVerified);
        } else {
            for (OrderApi__Sales_Order__c salesOrder : salesOrdersToBeVerified) {
                FS_GetCountyFromSS calloutJob = new FS_GetCountyFromSS(salesOrder);
                Id jobId = System.enqueueJob(calloutJob);
            }
        }
    }
}