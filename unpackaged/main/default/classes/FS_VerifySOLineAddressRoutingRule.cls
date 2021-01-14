/**
 * Created by dfitzgerald on 11/5/19.
 */

global without sharing class FS_VerifySOLineAddressRoutingRule extends Framework.Domain {
    final String NEW_YORK_STRING = 'NY';
    final String NEW_YORK_CODE_STRING = 'NY';
    final String OUT_OF_STATE_STRING = 'Out of State';
    private final static String WORK_OR_SCHOOL_STRING = 'Work/School';
    private final static String HOME_STRING = 'Home';

    public static Boolean skipCallout = false;

	
    public FS_VerifySOLineAddressRoutingRule(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_VerifySOLineAddressRoutingRule(sObjectList);
        }
    }

    //before insert, update all sales order line addresses that match contact address
    public override void beforeInsert() {
        Framework.Log.push(FS_VerifySOLineAddressRoutingRule.class.getName(),'beforeInsert');
        beforeInsertExec();
        Framework.Log.pop();
    }

    //if sales order addresses have not been verified yet after insert, verify (callout to smartystreets)
    public override void afterInsert() {
        Framework.Log.push(FS_VerifySOLineAddressRoutingRule.class.getName(),'afterInsert');
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = (List<OrderApi__Sales_Order_Line__c>) records;
        List<OrderApi__Sales_Order_Line__c> salesOrderLinesToBeVerified = new List<OrderApi__Sales_Order_Line__c>();

        //only sales order addresses that have not been verified
        for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLines) {
            if (!salesOrderLine.FS_Shipping_Address_Verified__c && salesOrderLine.FS_Shipping_County__c == null) {
                salesOrderLinesToBeVerified.add(salesOrderLine);
            }
        }
        if(!skipCallout) {
            makeCallouts(salesOrderLinesToBeVerified);
        }
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_VerifySOLineAddressRoutingRule.class.getName(),'beforeUpdate');
        List<OrderApi__Sales_Order_Line__c> salesOrderLinesToBeVerified = new List<OrderApi__Sales_Order_Line__c>();
        Set<Id> salesOrderIdSet = new Set<Id>();
//        Map<Id, Contact> contactMap = getContactMap(records);

        //updateShippingAndBillingAddressFields(records, contactMap);
        for (OrderApi__Sales_Order_Line__c salesOrderLine : (List<OrderApi__Sales_Order_Line__c>) records) {
            salesOrderIdSet.add(salesOrderLine.OrderApi__Sales_Order__c);
        }
        Map<Id, OrderApi__Sales_Order__c> salesOrderMap = new Map<Id, OrderApi__Sales_Order__c>([
                SELECT Id,OrderApi__Entity__c,
                        OrderApi__Status__c,OrderApi__Posting_Status__c, OrderApi__Shipping_Street__c, OrderApi__Shipping_City__c,
                        FS_Shipping_County__c, OrderApi__Shipping_State__c, OrderApi__Shipping_Country__c, OrderApi__Shipping_Postal_Code__c
                FROM OrderApi__Sales_Order__c
                WHERE Id IN :salesOrderIdSet
        ]);

        for (OrderApi__Sales_Order_Line__c salesOrderLine : (List<OrderApi__Sales_Order_Line__c>) records) {
            OrderApi__Sales_Order_Line__c existingSalesOrderLine = (OrderApi__Sales_Order_Line__c) existingRecords.get(salesOrderLine.Id);

            //if shipping address has changed, reset county and verification fields
            if (!shippingAddressesMatch(salesOrderLine, existingSalesOrderLine)) {
                resetShippingVerificationFields(salesOrderLine, salesOrderMap.get(salesOrderLine.OrderApi__Sales_Order__c));
            }

            //only known addresses that have not been verified
            if (salesOrderLine.FS_Shipping_Address_Verified__c == false
                    && salesOrderLine.FS_Shipping_County__c == null) {
                salesOrderLinesToBeVerified.add(salesOrderLine);
            }
        }

        if(!skipCallout) {
            makeCallouts(salesOrderLinesToBeVerified);
        }

        Framework.Log.pop();
    }

    public void beforeInsertExec() {
        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>();

        //only sales orders with addresses that have not been verified
        for (OrderApi__Sales_Order_Line__c salesOrderLine : (List<OrderApi__Sales_Order_Line__c>) records) {
            if (salesOrderLine.FS_Shipping_Address_Verified__c == false) {
                salesOrderLines.add(salesOrderLine);
            }
        }
        Map<Id, Contact> contactMap = getContactMap(salesOrderLines);
		
        updateShippingAndBillingAddressFields(salesOrderLines, contactMap);

        //check if address matches contact address (all contact addresses should already be verified)
        for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLines) {
            Contact associatedContact = contactMap.get(salesOrderLine.OrderApi__Contact__c);
            if (!salesOrderLine.FS_Shipping_Address_Verified__c &&
                    shippingAddressMatchesContact(salesOrderLine, associatedContact)) {
                syncShippingFields(salesOrderLine, associatedContact);
            } else {
                if (String.isBlank(salesOrderLine.OrderApi__Shipping_State__c) ||
                        salesOrderLine.OrderApi__Shipping_State__c != NEW_YORK_STRING) {
                    salesOrderLine.FS_Shipping_County__c = OUT_OF_STATE_STRING;
                }
            }
        }
    }

     //Begin for NYSBA-445 Populate Sales Order and Sales Order Lines with Appropriate Addresses
    private Map<Id, Contact> getContactMap(List<OrderApi__Sales_Order_Line__c> salesOrderLines){
        List<Id> contactIds = new List<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
		
        //get all relevant contact ids
        for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLines) {
            contactIds.add(salesOrderLine.OrderApi__Contact__c);
        }

        //get all relevant contacts
        for (Contact contact : [
                SELECT Id,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingStateCode,
                        MailingCountry,
                        MailingPostalCode,
                        FS_Mailing_County__c,
                        OtherStreet,
                        OtherCity,
                        OtherState,
                        OtherStateCode,
            			OtherCountry,
            			OtherPostalCode,
                        smartystreets__Mailing_Verified__c,
                        smartystreets__Mailing_Return_Code__c,
                        smartystreets__Mailing_Last_Verified__c,
                        smartystreets__Mailing_Address_Status__c,
                        smartystreets__Other_Verified__c,
                        smartystreets__Other_Return_Code__c,
                        smartystreets__Other_Last_Verified__c,
                        smartystreets__Other_Address_Status__c,
                        FS_Other_County__c,
                        FS_Preferred_Mailing_Address__c,
                        FS_Preferred_Billing_Address__c
                FROM Contact
                WHERE Id IN :contactIds
        ]) {
            contactMap.put(contact.Id, contact);
        }
        return contactMap;
    }

    private void updateShippingAndBillingAddressFields(List<OrderApi__Sales_Order_Line__c> salesOrderLines, Map<Id, Contact> contactMap){
        Set<Id> salesOrderIdSet=new Set<Id>();
        for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLines) {
            Contact associatedContact = contactMap.get(salesOrderLine.OrderApi__Contact__c);
            if(associatedContact != null && isSOLShippingAddressMatchesContact(salesOrderLine, associatedContact)){
                salesOrderIdSet.add(salesOrderLine.OrderApi__Sales_Order__c);
            }
        }
        if(!salesOrderIdSet.isEmpty()){
            Map<Id,OrderApi__Sales_Order__c> salesOrderMap = new Map<Id,OrderApi__Sales_Order__c>([SELECT Id,OrderApi__Entity__c,
                        OrderApi__Status__c,OrderApi__Posting_Status__c, OrderApi__Shipping_Street__c, OrderApi__Shipping_City__c,
                        FS_Shipping_County__c, OrderApi__Shipping_State__c, OrderApi__Shipping_Country__c, OrderApi__Shipping_Postal_Code__c
                        FROM OrderApi__Sales_Order__c WHERE Id IN :salesOrderIdSet
                        AND OrderApi__Entity__c = 'Contact' AND OrderApi__Posting_Status__c != 'Posted']);
                        
            for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLines) {
                Contact associatedContact = contactMap.get(salesOrderLine.OrderApi__Contact__c);
                OrderApi__Sales_Order__c so = salesOrderMap.get(salesOrderLine.OrderApi__Sales_Order__c);
                if (associatedContact != null && so != null) {
//                    if (associatedContact.FS_Preferred_Mailing_Address__c == WORK_OR_SCHOOL_STRING) {
//                        salesOrderLine.OrderApi__Shipping_Street__c = associatedContact.MailingStreet;
//                        salesOrderLine.OrderApi__Shipping_City__c = associatedContact.MailingCity;
//                        salesOrderLine.FS_Shipping_County__c = associatedContact.FS_Mailing_County__c;
//                        salesOrderLine.OrderApi__Shipping_State__c = associatedContact.MailingStateCode;
//                        salesOrderLine.OrderApi__Shipping_Country__c = associatedContact.MailingCountry;
//                        salesOrderLine.OrderApi__Shipping_Postal_Code__c = associatedContact.MailingPostalCode;
//                        salesOrderLine.OrderApi__Calculate_Shipping_Details__c = false;
//                    } else if (associatedContact.FS_Preferred_Mailing_Address__c == HOME_STRING) {
//                        salesOrderLine.OrderApi__Shipping_Street__c = associatedContact.OtherStreet;
//                        salesOrderLine.OrderApi__Shipping_City__c = associatedContact.OtherCity;
//                        salesOrderLine.FS_Shipping_County__c = associatedContact.FS_Other_County__c;
//                        salesOrderLine.OrderApi__Shipping_State__c = associatedContact.OtherStateCode;
//                        salesOrderLine.OrderApi__Shipping_Country__c = associatedContact.OtherCountry;
//                        salesOrderLine.OrderApi__Shipping_Postal_Code__c = associatedContact.OtherPostalCode;
//                        salesOrderLine.OrderApi__Calculate_Shipping_Details__c = false;
//                    }
                    salesOrderLine.OrderApi__Shipping_Street__c = so.OrderApi__Shipping_Street__c;
                    salesOrderLine.OrderApi__Shipping_City__c = so.OrderApi__Shipping_City__c;
                    salesOrderLine.FS_Shipping_County__c = so.FS_Shipping_County__c;
                    salesOrderLine.OrderApi__Shipping_State__c = so.OrderApi__Shipping_State__c;
                    salesOrderLine.OrderApi__Shipping_Country__c = so.OrderApi__Shipping_Country__c;
                    salesOrderLine.OrderApi__Shipping_Postal_Code__c = so.OrderApi__Shipping_Postal_Code__c;
                    salesOrderLine.OrderApi__Calculate_Shipping_Details__c = false;
                }
            }
        }
    }

    private Boolean isSOLShippingAddressMatchesContact(OrderApi__Sales_Order_Line__c salesOrderLine, Contact associatedContact){
        return (associatedContact.FS_Preferred_Mailing_Address__c == WORK_OR_SCHOOL_STRING &&
                (
                    salesOrderLine.OrderApi__Shipping_Street__c != associatedContact.MailingStreet ||
                    salesOrderLine.OrderApi__Shipping_City__c != associatedContact.MailingCity ||
                    salesOrderLine.FS_Shipping_County__c != associatedContact.FS_Mailing_County__c ||
                    salesOrderLine.OrderApi__Shipping_State__c != associatedContact.MailingStateCode ||
                    salesOrderLine.OrderApi__Shipping_Country__c != associatedContact.MailingCountry ||
                    salesOrderLine.OrderApi__Shipping_Postal_Code__c != associatedContact.MailingPostalCode
                )
            ) ||
            ( associatedContact.FS_Preferred_Mailing_Address__c == HOME_STRING &&
                (
                    salesOrderLine.OrderApi__Shipping_Street__c != associatedContact.OtherStreet ||
                    salesOrderLine.OrderApi__Shipping_City__c != associatedContact.OtherCity ||
                    salesOrderLine.FS_Shipping_County__c != associatedContact.FS_Other_County__c ||
                    salesOrderLine.OrderApi__Shipping_State__c != associatedContact.OtherStateCode ||
                    salesOrderLine.OrderApi__Shipping_Country__c != associatedContact.OtherCountry ||
                    salesOrderLine.OrderApi__Shipping_Postal_Code__c != associatedContact.OtherPostalCode
                )
            );
    }

     //End for NYSBA-445 Populate Sales Order and Sales Order Lines with Appropriate Addresses

    private void syncShippingFields(OrderApi__Sales_Order_Line__c salesOrderLine,
            Contact contact) {
        salesOrderLine.FS_Shipping_Address_Verified__c = contact.smartystreets__Mailing_Verified__c;
        salesOrderLine.FS_Shipping_Address_Return_Code__c = contact.smartystreets__Mailing_Return_Code__c;
        salesOrderLine.FS_Shipping_Address_Last_Verified__c = contact.smartystreets__Mailing_Last_Verified__c;
        ////Added below code as part of NYSBA-720 starts here
       salesOrderLine.FS_Shipping_County__c = contact.FS_Mailing_County__c;
        ////Added below code as part of NYSBA-720 starts here
    }

    //check if contact's address fields are not null
    private Boolean contactAddressNotNull(Contact contact) {
        if (!String.isBlank(contact.MailingStreet) &&
                !String.isBlank(contact.MailingCity) &&
                !String.isBlank(contact.MailingState)) {
        } else {
        }
        return (!String.isBlank(contact.MailingStreet) &&
                !String.isBlank(contact.MailingCity) &&
                !String.isBlank(contact.MailingState));
    }

    private Boolean shippingFieldsNotNull(OrderApi__Sales_Order_Line__c salesOrderLine) {
        if (!String.isBlank(salesOrderLine.OrderApi__Shipping_Street__c) &&
                !String.isBlank(salesOrderLine.OrderApi__Shipping_City__c) &&
                !String.isBlank(salesOrderLine.OrderApi__Shipping_State__c)) {
        } else {
        }
        return (!String.isBlank(salesOrderLine.OrderApi__Shipping_Street__c) &&
                !String.isBlank(salesOrderLine.OrderApi__Shipping_City__c) &&
                !String.isBlank(salesOrderLine.OrderApi__Shipping_State__c));
    }

    private Boolean shippingAddressMatchesContact(OrderApi__Sales_Order_Line__c salesOrderLine, Contact contact) {
        return (shippingFieldsNotNull(salesOrderLine) && contactAddressNotNull(contact) &&
                salesOrderLine.OrderApi__Shipping_Street__c.trim() == contact.MailingStreet.trim() &&
                salesOrderLine.OrderApi__Shipping_City__c.trim() == contact.MailingCity.trim() &&
                (salesOrderLine.OrderApi__Shipping_State__c.trim() == contact.MailingState.trim() ||
                        salesOrderLine.OrderApi__Shipping_State__c.trim() == contact.MailingStateCode.trim()));
    }

    private Boolean shippingAddressesMatch(OrderApi__Sales_Order_Line__c sol1, OrderApi__Sales_Order_Line__c sol2) {
        return (shippingFieldsNotNull(sol1) && shippingFieldsNotNull(sol2) &&
                sol1.OrderApi__Shipping_Street__c.trim() == sol2.OrderApi__Shipping_Street__c.trim() &&
                sol1.OrderApi__Shipping_City__c.trim() == sol2.OrderApi__Shipping_City__c.trim() &&
                sol1.OrderApi__Shipping_State__c.trim() == sol2.OrderApi__Shipping_State__c.trim());
    }

    private void resetShippingVerificationFields(OrderApi__Sales_Order_Line__c salesOrderLine, OrderApi__Sales_Order__c salesOrder) {
        Datetime currentDatetime = Datetime.now();
        salesOrderLine.FS_Shipping_County__c = null;
        salesOrderLine.FS_Shipping_Address_Verified__c = false;
        salesOrderLine.FS_Shipping_Address_Last_Verified__c = null;
        salesOrderLine.FS_Shipping_Address_Return_Code__c = null;
        if (salesOrderLine.OrderApi__Shipping_State__c != NEW_YORK_STRING) {
            salesOrderLine.FS_Shipping_County__c = OUT_OF_STATE_STRING;
        }

        if (salesOrderLine.OrderApi__Shipping_State__c == NEW_YORK_STRING) {
            if (salesOrderLine.OrderApi__Shipping_City__c == salesOrder.OrderApi__Shipping_City__c
                    && salesOrderLine.OrderApi__Shipping_State__c == salesOrder.OrderApi__Shipping_State__c
                    && String.isNotBlank(salesOrderLine.OrderApi__Shipping_Postal_Code__c)
                    && String.isNotBlank(salesOrder.OrderApi__Shipping_Postal_Code__c)
                    && salesOrderLine.OrderApi__Shipping_Postal_Code__c.left(5) == salesOrder.OrderApi__Shipping_Postal_Code__c.left(5)) {
                salesOrderLine.FS_Shipping_County__c = salesOrder.FS_Shipping_County__c;
                salesOrderLine.FS_Shipping_Address_Verified__c = true;
                salesOrderLine.FS_Shipping_Address_Last_Verified__c = currentDatetime;
            }
        }
    }

    private void makeCallouts(List<OrderApi__Sales_Order_Line__c> salesOrderLinesToBeVerified) {
        if(!System.isBatch() ||(System.isBatch() && Limits.getQueueableJobs() < 1)) {
            for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLinesToBeVerified) {
                FS_GetCountyFromSS calloutJob = new FS_GetCountyFromSS(salesOrderLine);
                Id jobId = System.enqueueJob(calloutJob);
            }
        } else {
            String ids = '';
            for (OrderApi__Sales_Order_Line__c salesOrderLine : salesOrderLinesToBeVerified) {
                ids += salesOrderLine.Id + '\n';
            }
            System.debug(LoggingLevel.WARN, 'Unable to sync county information for the following records:\n' + ids);

        }
    }
}