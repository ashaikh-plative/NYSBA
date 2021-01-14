/**
 *  @author:        cubiascaceres
 *  @date:          2019.09.16
 *  @description:   Controller class for Membership Join Process Lightning components
 */
public without sharing class  FS_MembershipJoinController {

    private static final String ORDER_STATUS = 'Open';
    private static final String ORDER_ENTITY = 'Contact';
    private static final String ORDER_STATUS_CLOSED = 'Closed';
    private static final String ORDER_POST_STATUS_PENDING = 'Pending';


    @AuraEnabled
    public static String getLookupFilterMap() {
        Map<String, String> lookupFilterMap = FS_AttorneyController.getLookupFilterMap();
        return lookupFilterMap.get('law_school');
    }

    @AuraEnabled
    public static Map<String, Object> getJSONCountriesAndStates() {
        Map<String, Object> countryStateMap = FS_AttorneyController.getJSONCountriesAndStates();
        return countryStateMap;
    }

    @AuraEnabled
    public static Boolean isAttorneyEnabled(String attorneyItemId) {
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        // check for any previous attorney membership.
        List<OrderApi__Subscription__c> contactMembershipList = [SELECT Id FROM OrderApi__Subscription__c 
                                                                WHERE OrderApi__Contact__c = :loggedInUser.ContactId
                                                                AND OrderApi__Item__c IN :attorneyItemId.split(',')];
        // Check for a sales order that has a status of Closed and posting status of Pending 
        // with sales order line containing the Attorney Membership item
        List<OrderApi__Sales_Order_Line__c> contactSalesOrderLineList = [SELECT Id FROM OrderApi__Sales_Order_Line__c
                                                                WHERE OrderApi__Sales_Order__r.OrderApi__Status__c = :ORDER_STATUS_CLOSED
                                                                AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = :ORDER_POST_STATUS_PENDING
                                                                AND OrderApi__Sales_Order__r.OrderApi__Contact__c = :loggedInUser.ContactId
                                                                AND OrderApi__Is_Renewal__c = TRUE
                                                                AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                                                                AND OrderApi__Subscription_Plan__c != NULL
                                                                AND OrderApi__Item__c IN :attorneyItemId.split(',')];
        return contactMembershipList.isEmpty() || !contactSalesOrderLineList.isEmpty();
    }

    @AuraEnabled
    public static String getSalesOrderId(String attorneyItemId) {
        String salesOrderId;
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        // check for any previous attorney membership.
        List<OrderApi__Subscription__c> contactMembershipList = [SELECT Id FROM OrderApi__Subscription__c 
                                                                WHERE OrderApi__Contact__c = :loggedInUser.ContactId
                                                                AND OrderApi__Item__c IN :attorneyItemId.split(',')];
        // Check for a sales order that has a status of Closed and posting status of Pending 
        // with sales order line containing the Attorney Membership item
        List<OrderApi__Sales_Order_Line__c> contactSalesOrderLineList = [SELECT Id, OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c
                                                                WHERE OrderApi__Sales_Order__r.OrderApi__Status__c = :ORDER_STATUS_CLOSED
                                                                AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = :ORDER_POST_STATUS_PENDING
                                                                AND OrderApi__Sales_Order__r.OrderApi__Contact__c = :loggedInUser.ContactId
                                                                AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                                                                AND OrderApi__Is_Renewal__c = :!contactMembershipList.isEmpty()
                                                                AND OrderApi__Item__c IN :attorneyItemId.split(',')];
        if (!contactSalesOrderLineList.isEmpty()) {
            salesOrderId = contactSalesOrderLineList.get(0).OrderApi__Sales_Order__c;
        }
        return salesOrderId;
    }

    @AuraEnabled
    public static Boolean isStudentEnabled(String lawStudentItemId, String attorneyItemId) {
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        // check for any previous Student/Attorney membership.
        List<OrderApi__Subscription__c> subscriptionList = [SELECT Id FROM OrderApi__Subscription__c 
                                                                WHERE OrderApi__Contact__c = :loggedInUser.ContactId
                                                                AND (OrderApi__Item__c IN :lawStudentItemId.split(',')
                                                                OR OrderApi__Item__c IN :attorneyItemId.split(','))];

        List<OrderApi__Sales_Order_Line__c> contactSalesOrderLineList = [
                SELECT Id FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__r.OrderApi__Status__c = :ORDER_STATUS_CLOSED
                AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = :ORDER_POST_STATUS_PENDING
                AND OrderApi__Sales_Order__r.OrderApi__Contact__c = :loggedInUser.ContactId
                AND OrderApi__Is_Renewal__c = TRUE
                AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                AND OrderApi__Subscription_Plan__c != NULL
                AND OrderApi__Item__c IN :lawStudentItemId.split(',')];
        return subscriptionList.isEmpty() || !contactSalesOrderLineList.isEmpty();
    }

    /**
     *  @description:   based on the user type, determine if the user is logged in or not
     */
    @AuraEnabled
    public static Boolean isLoggedIn() {
        String userType = UserInfo.getUserType();
        return !userType.contains('Guest');
    }

    /**
     *  @description:   return the list of available user type options
     */
    @AuraEnabled
    public static List<FS_Membership_Join_User_Type__mdt> getUserTypeList() {
        return [SELECT DeveloperName, FS_Description__c, FS_Sort_Order__c FROM FS_Membership_Join_User_Type__mdt ORDER BY FS_Sort_Order__c asc];
    }

    @AuraEnabled
    public static Map<String, String> getDegreeTypeList() {
        try {
            Map<String, String> optionsMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Contact.FS_Degree_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                optionsMap.put(f.getValue(), f.getLabel());
            }
            return optionsMap;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }        
    }

    /**
     *  @desc:  get all Items to be displayed on the Sections on the Enrolled Student Application Page
     */
    @AuraEnabled
    public static List<OrderApi__Item__c> getSectionDuesItemList() {
        return [SELECT Id, Name FROM OrderApi__Item__c 
                WHERE 
                OrderApi__Is_Active__c = TRUE AND
                FS_Linked_Community_Group__c != NULL AND
                FS_Hidden_From_Student_Membership__c = FALSE AND
                FS_Linked_Community_Group__r.PagesApi__Type__c = 'Section' AND
                FS_Linked_Community_Group__r.PagesApi__Is_Published__c = TRUE];
    }

    	/**
     *  @desc:  Get the contact record associated with the logged in User
     */
    @AuraEnabled
    public static FS_ContactWrapper getContact() {
        FS_ContactWrapper contactWrap = new FS_ContactWrapper();
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact loggedContact = [SELECT Id, FS_Degree_Type__c, Birthdate,
                                    OrderApi__Preferred_Phone_Type__c, OrderApi__Preferred_Phone__c,
                                    OrderApi__Preferred_Email_Type__c, OrderApi__Preferred_Email__c,
                                    FS_Preferred_Mailing_Address__c, FS_Preferred_Billing_Address__c,
                                    MailingAddress, OtherAddress,
                                    OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode,
                                    MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode, 
                                    OrderApi__Work_Email__c,
                                    FS_Graduation_Date__c, FS_Law_School__c
                                    FROM Contact 
                                    WHERE Id = :loggedInUser.ContactId];
        contactWrap.userContact = loggedContact;
        // wrapper property is needed since fields are type: formulas, hence, no update can be performed upon them
        contactWrap.userContactPreferredPhone = loggedContact.OrderApi__Preferred_Phone__c;
        contactWrap.userContactPreferredEmail = loggedContact.OrderApi__Preferred_Email__c;
        contactWrap.isYoungLawyer = true;
        if (loggedContact.FS_Preferred_Mailing_Address__c != null) {
            contactWrap.preferredMailAddress = loggedContact.FS_Preferred_Mailing_Address__c;
        }
        if (loggedContact.FS_Preferred_Billing_Address__c != null) {
            contactWrap.preferredBillAddress = loggedContact.FS_Preferred_Billing_Address__c;
        }
        return contactWrap;
    }

    @AuraEnabled
    public static FS_ContactWrapper updateContact(FS_ContactWrapper contactWrapper) {
        try {
            // Update Contact Properties as needed
            switch on contactWrapper.userContact.OrderApi__Preferred_Phone_Type__c {
                when 'Home' {
                    contactWrapper.userContact.HomePhone = contactWrapper.userContactPreferredPhone;
                }
                when 'Mobile' {
                    contactWrapper.userContact.MobilePhone = contactWrapper.userContactPreferredPhone;
                }
                when 'Work' {
                    contactWrapper.userContact.OrderApi__Work_Phone__c = contactWrapper.userContactPreferredPhone;
                }
            }

            switch on contactWrapper.userContact.OrderApi__Preferred_Email_Type__c {
                when 'Personal' {
                    contactWrapper.userContact.OrderApi__Personal_Email__c = contactWrapper.userContactPreferredEmail;
                }
                when 'Work' {
                    contactWrapper.userContact.OrderApi__Work_Email__c = contactWrapper.userContactPreferredEmail;
                }
            }
            contactWrapper.userContact.FS_Preferred_Mailing_Address__c = contactWrapper.preferredMailAddress;
            contactWrapper.userContact.FS_Preferred_Billing_Address__c = contactWrapper.preferredBillAddress;
            
            update contactWrapper.userContact;
            return contactWrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Internal Error Server: '+ e.getMessage());
        }                            
    }

    @AuraEnabled
    public static Map<String, String> getExistingSalesOrderId(String studentLawMembershipId) {
        Map<String, String> response = new Map<String, String>();
        User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<OrderApi__Sales_Order__c> salesOrderList = [SELECT Id,
                                                            (SELECT Id 
                                                                FROM OrderApi__Sales_Order_Lines__r 
                                                                WHERE OrderApi__Item__c = :studentLawMembershipId
                                                            )
                                                        FROM OrderApi__Sales_Order__c 
                                                        WHERE 
                                                            OrderApi__Contact__c = :loggedInUser.ContactId
                                                            AND OrderApi__Status__c = 'Closed'
                                                            AND OrderApi__Posting_Status__c = 'Pending'];
        if (salesOrderList.size() > 0) {
            OrderApi__Sales_Order__c existingSalesOrder = salesOrderList[0];
            //  Assumption: there would be just one Close/Pending Sales order
            if (existingSalesOrder.OrderApi__Sales_Order_Lines__r.size() > 0) {
                response.put('salesOrderId', existingSalesOrder.Id);
            }            
        }
        return response;
    }

    /**
     *  @desc: Create sales order and order lines 
     */
    @AuraEnabled
    public static String createSalesOrder(FS_ContactWrapper contactWrapper) {
        try {
            //Get account from Logged in user -> Contact
            User loggedInUser = [SELECT Id, username, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
            Contact userContact = [SELECT Id, Name, AccountId FROM Contact WHERE Id =: loggedInUser.ContactId];

            // Update Contact Properties as needed
            switch on contactWrapper.userContact.OrderApi__Preferred_Phone_Type__c {
                when 'Home' {
                    contactWrapper.userContact.HomePhone = contactWrapper.userContactPreferredPhone;
                }
                when 'Mobile' {
                    contactWrapper.userContact.MobilePhone = contactWrapper.userContactPreferredPhone;
                }
                when 'Work' {
                    contactWrapper.userContact.OrderApi__Work_Phone__c = contactWrapper.userContactPreferredPhone;
                }
            }

            switch on contactWrapper.userContact.OrderApi__Preferred_Email_Type__c {
                when 'Personal' {
                    contactWrapper.userContact.OrderApi__Personal_Email__c = contactWrapper.userContactPreferredEmail;
                }
                when 'Work' {
                    contactWrapper.userContact.OrderApi__Work_Email__c = contactWrapper.userContactPreferredEmail;
                }
            }
            contactWrapper.userContact.FS_Preferred_Mailing_Address__c = contactWrapper.preferredMailAddress;
            contactWrapper.userContact.FS_Preferred_Billing_Address__c = contactWrapper.preferredBillAddress;
            update contactWrapper.userContact;

            // Create the Sales Order
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
            if (userContact.AccountId != null) {
                salesOrder.OrderApi__Account__c = userContact.AccountId;
            }
            if (userContact.Id != null) {
                salesOrder.OrderApi__Contact__c = userContact.Id;
            }
            salesOrder.OrderApi__Entity__c = ORDER_ENTITY;
            salesOrder.OrderApi__Status__c = ORDER_STATUS;
            salesOrder.OrderApi__Date__c = System.today();
            insert salesOrder;
            
            List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
            // create the sales order line containing the membership item
            OrderApi__Sales_Order_Line__c membershipOrderLine = new OrderApi__Sales_Order_Line__c();
            membershipOrderLine.OrderApi__Item__c = contactWrapper.lawStudentItemId;
            membershipOrderLine.OrderApi__Sales_Order__c = salesOrder.ID;
            membershipOrderLine.OrderApi__Entity__c = ORDER_ENTITY;
            membershipOrderLine.OrderApi__Contact__c = userContact.Id;
            solList.add(membershipOrderLine);            
            insert solList;
            
            return salesOrder.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());
        }                
    }    
}