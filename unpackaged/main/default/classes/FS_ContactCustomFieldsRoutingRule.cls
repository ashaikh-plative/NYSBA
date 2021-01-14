/**
* Created by santhosh on 10-02-2020.
*/

global without sharing class FS_ContactCustomFieldsRoutingRule extends Framework.Domain {
    private static final String CONTACT_STRING = 'Contact';
    private static final String EXPIRED_STRING = 'Expired';
    private static final String NON_MEMBER_STRING = 'Non-Member';
    private static final String ACTIVE_STATUS_STRING = 'Active';
    private static final String PENDING_STATUS_STRING = 'Pending';
    private static final String LAW_STUDENT_MEMBERSHIP_NAME = 'Law Student';

    public FS_ContactCustomFieldsRoutingRule(List<OrderApi__Subscription__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ContactCustomFieldsRoutingRule(sObjectList);
        }
    }

    public override void afterInsert() {
        Framework.Log.push(FS_ContactCustomFieldsRoutingRule.class.getName(), 'afterInsert');
        updateContactFromSubscription((List<OrderApi__Subscription__c>) records, null);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id, SObject> oldRecords) {
        Framework.Log.push(FS_ContactCustomFieldsRoutingRule.class.getName(), 'afterUpdate');
        updateContactFromSubscription((List<OrderApi__Subscription__c>) records, oldRecords);
        Framework.Log.pop();
    }

    private static void updateContactFromSubscription(List<OrderApi__Subscription__c> records, Map<Id, SObject> oldRecords) {
        Map<Id, OrderApi__Subscription__c> subsByContactId = new Map<Id, OrderApi__Subscription__c>();
        for (OrderApi__Subscription__c sub : records) {
            if (sub.OrderApi__Entity__c == CONTACT_STRING) {
                subsByContactId.put(sub.OrderApi__Contact__c, sub);
            }
        }
        
        Map<Id, OrderApi__Subscription__c> subsMapForTerm = new Map<Id, OrderApi__Subscription__c>([
                SELECT Id,OrderApi__Account__c,OrderApi__Item__c,OrderApi__Paid_Through_Date__c,Membership_Type__c, OrderApi__Grace_Period_End_Date__c,OrderApi__Contact__r.FS_Active_Subscription__c,OrderApi__Contact__c,
                        OrderApi__Item__r.OrderApi__Display_Name__c, OrderApi__Is_Active__c,OrderApi__Activated_Date__c, OrderApi__Status__c,
                (
                        SELECT Id,OrderApi__Grace_Period_End_Date__c,OrderApi__Term_Start_Date__c, OrderApi__Term_End_Date__c
                        FROM OrderApi__Renewals__r
                        ORDER BY OrderApi__Term_End_Date__c DESC
                )
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Contact__c IN:subsByContactId.keySet() AND OrderApi__Item__r.FS_Is_Membership__c = TRUE
                AND OrderApi__Item__r.OrderApi__Is_Subscription__c = TRUE
                AND (OrderApi__Status__c = :ACTIVE_STATUS_STRING OR OrderApi__Status__c = :PENDING_STATUS_STRING OR OrderApi__Status__c = :EXPIRED_STRING)
                AND OrderApi__Entity__c = :CONTACT_STRING
        ]);
        List<Contact> contactsToProcess = [
                SELECT Id,FS_Contact_Member_Status__c, FS_Active_Subscription__c,
                        FS_Original_Join_Date__c, FS_Membership_Type__c, FS_Membership_Days_to_Expire__c,
                        FS_Membership_Expiry_Date__c, FS_Member_Continuous_Since__c, FS_Membership_Grace_Period_End_Date__c,
                (SELECT Id,OrderApi__Item__r.OrderApi__Display_Name__c, OrderApi__Status__c,OrderApi__Activated_Date__c,OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c
                FROM OrderApi__Subscriptions__r WHERE OrderApi__Item__r.FS_Is_Membership__c = TRUE
                AND OrderApi__Item__r.OrderApi__Is_Subscription__c = TRUE
                AND (OrderApi__Status__c = :ACTIVE_STATUS_STRING OR OrderApi__Status__c = :PENDING_STATUS_STRING OR OrderApi__Status__c = :EXPIRED_STRING)
                AND OrderApi__Entity__c = :CONTACT_STRING)
                FROM Contact
                WHERE Id IN :subsByContactId.keySet()
        ];
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for (Contact conToUpdate : contactsToProcess) {
            if(subsByContactId.get(conToUpdate.Id) != null && subsMapForTerm.get(subsByContactId.get(conToUpdate.Id).Id) != null){
                OrderApi__Subscription__c sub = subsMapForTerm.get(subsByContactId.get(conToUpdate.Id).Id);
                //Condition 1 - If Membership type on contact is blank or null then update contact details accordingly
                //Condition 2 - If Membership type on contact is other than Law Student(Ex:Attorney) and purchases/renews Law Student then do not update contact custom fields
                // and if purchases/renews any other membership then update contact details accordingly
                //Condition 3 - If Contact renews to the membership same as Membership type on contact then update contact details accordingly

                if ( String.isBlank(conToUpdate.FS_Membership_Type__c)
                        || (conToUpdate.FS_Membership_Type__c != sub.OrderApi__Item__r.OrderApi__Display_Name__c && sub.OrderApi__Item__r.OrderApi__Display_Name__c != LAW_STUDENT_MEMBERSHIP_NAME)
                        || (conToUpdate.FS_Membership_Type__c == sub.OrderApi__Item__r.OrderApi__Display_Name__c)) {
                    if (sub.OrderApi__Status__c == ACTIVE_STATUS_STRING) {
                        Contact con = new Contact(Id = conToUpdate.Id);
                        if (conToUpdate.FS_Original_Join_Date__c != null) {

                            if (conToUpdate.FS_Contact_Member_Status__c == EXPIRED_STRING || conToUpdate.FS_Contact_Member_Status__c == NON_MEMBER_STRING) {

                                if (subsMapForTerm != null && subsMapForTerm.get(sub.Id) != null && subsMapForTerm.get(sub.Id).OrderApi__Renewals__r != null
                                        && subsMapForTerm.get(sub.Id).OrderApi__Renewals__r.size() > 0) {
                                    //  OrderApi__Subscription__c subDateToUpdate = subsMapForTerm.get(sub.Id);
                                    con.FS_Member_Continuous_Since__c = sub.OrderApi__Activated_Date__c;
                                    con.FS_Active_Subscription__c = sub.Id;

                                    if (con.FS_Membership_Type__c == '' || con.FS_Membership_Type__c == null || (con.FS_Membership_Type__c != sub.OrderApi__Item__r.OrderApi__Display_Name__c && sub.OrderApi__Item__r.OrderApi__Display_Name__c != LAW_STUDENT_MEMBERSHIP_NAME)) {
                                        con.FS_Membership_Type__c = sub.OrderApi__Item__r.OrderApi__Display_Name__c;
                                    }
                                }
                            } else if (conToUpdate.FS_Contact_Member_Status__c == ACTIVE_STATUS_STRING && !conToUpdate.OrderApi__Subscriptions__r.isEmpty()) {
                                for (OrderApi__Subscription__c subscription : conToUpdate.OrderApi__Subscriptions__r) {
                                    if (subscription.Id != sub.Id && subsMapForTerm != null && subsMapForTerm.get(sub.Id) != null && subsMapForTerm.get(sub.Id).OrderApi__Renewals__r != null && subsMapForTerm.get(sub.Id).OrderApi__Renewals__r.size() == 1) {
                                        if (oldRecords == null || (oldRecords.get(sub.Id) != null && ((OrderApi__Subscription__c) oldRecords.get(sub.Id)).OrderApi__Term_Start_Date__c == null)) {
                                            con.FS_Member_Continuous_Since__c = sub.OrderApi__Activated_Date__c;
                                            con.FS_Membership_Type__c = sub.OrderApi__Item__r.OrderApi__Display_Name__c;
                                            con.FS_Active_Subscription__c = sub.Id;
                                            break;
                                        }
                                    }
                                }
                            }
                        } else if (conToUpdate.FS_Original_Join_Date__c == null) {
                            con.FS_Original_Join_Date__c = sub.OrderApi__Activated_Date__c;
                            con.FS_Membership_Type__c = sub.OrderApi__Item__r.OrderApi__Display_Name__c;
                            con.FS_Active_Subscription__c = sub.Id;
                        }
                        contactsToUpdate.put(con.Id, con);
                    }else if(sub.OrderApi__Status__c == EXPIRED_STRING && sub.Id ==  conToUpdate.FS_Active_Subscription__c){
                        Contact co = new Contact(Id = sub.OrderApi__Contact__c, FS_Active_Subscription__c = null);
                        contactsToUpdate.put(co.Id,co);
                    }
                }
                Date expiryDate = null;
                Date gracePeriodDate = null;
                if (conToUpdate.OrderApi__Subscriptions__r != null) {
                    for (OrderApi__Subscription__c subscription : conToUpdate.OrderApi__Subscriptions__r) {
                        if (subsMapForTerm != null && subsMapForTerm.get(subscription.Id) != null && subsMapForTerm.get(subscription.Id).OrderApi__Renewals__r != null && subsMapForTerm.get(subscription.Id).OrderApi__Renewals__r.size() > 0) {
                            for(OrderApi__Renewal__c term :subsMapForTerm.get(subscription.Id).OrderApi__Renewals__r){
                                if (expiryDate == null || expiryDate < term.OrderApi__Term_End_Date__c) {
                                    expiryDate = term.OrderApi__Term_End_Date__c;
                                }
                            }
                            if (gracePeriodDate == null || gracePeriodDate < subscription.OrderApi__Grace_Period_End_Date__c) {
                                gracePeriodDate = subscription.OrderApi__Grace_Period_End_Date__c;
                            }
                        }
                    }
                } else if (conToUpdate.OrderApi__Subscriptions__r == null || conToUpdate.OrderApi__Subscriptions__r.isEmpty()) {
                    Contact con = null;
                    if (contactsToUpdate.get(conToUpdate.Id) != null) {
                        con = contactsToUpdate.get(conToUpdate.Id);
                    } else {
                        con = new Contact(Id = conToUpdate.Id);
                    }
                    if (con != null) {
                        con.FS_Membership_Type__c = '';
                        contactsToUpdate.put(con.Id, con);
                    }
                }
                if (expiryDate != null || gracePeriodDate != null) {
                    Contact con = null;
                    if (contactsToUpdate.get(conToUpdate.Id) != null) {
                        con = contactsToUpdate.get(conToUpdate.Id);

                    } else {
                        con = new Contact(Id = conToUpdate.Id);
                    }
                    if (expiryDate != null) {
                        con.FS_Membership_Expiry_Date__c = expiryDate;
                    }
                    if (gracePeriodDate != null) {
                        con.FS_Membership_Grace_Period_End_Date__c = gracePeriodDate;
                    }
                    if (con != null) {
                        contactsToUpdate.put(con.Id, con);
                    }
                }
            }
        }
        if(!contactsToUpdate.isEmpty()){
            System.debug('contactsToUpdate.values()::'+contactsToUpdate.values());
            update contactsToUpdate.values();
        }
    }
}