/**
 * Created by Nikhil on 21-07-2020.
 */

public without sharing class FS_SubscriptionsController {
    /**
         * Pulls all Contact Subscriptions for the associated logged in User.
         *
         *
         * @param currentUser
         *
         * @return
         */
    private static List<SubscriptionWrapper> getContactSubscriptions(User currentUser) {

        List<OrderApi__Subscription__c> contactSubscriptions = [
                SELECT Id, OrderApi__Item__r.Name, OrderApi__Paid_Through_Date__c, OrderApi__Item__r.OrderApi__Display_Name__c,OrderApi__Item__r.FSP_FonMPP__Hide_Expired_Subscription__c,
                        OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Account__r.Name, OrderApi__Term_Start_Date__c, OrderApi__Entity__c, FSP_FonMPP__Within_Renewal_Time_Frame__c,
                        FSP_FonMPP__Customer_Name__c, OrderApi__Activated_Date__c, OrderApi__Term_End_Date__c, OrderApi__Days_To_Lapse__c,
                        OrderApi__Status__c, (
                        SELECT OrderApi__Sales_Order__r.OrderApi__Posting_Status__c, OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c,
                                OrderApi__Sales_Order__r.OrderApi__Status__c
                        FROM OrderApi__Sales_Orders__r )
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Entity__c = 'Contact'
                AND OrderApi__Contact__c = :currentUser.ContactId
                AND OrderApi__Hide_In_Portal__c != TRUE
                AND OrderApi__Status__c != 'Cancelled'
        ];

        List<SubscriptionWrapper> allSubscriptions = new List<SubscriptionWrapper>();

        for (OrderApi__Subscription__c currSub : contactSubscriptions) {
            Boolean pExists = false;
            if (currSub.OrderApi__Sales_Orders__r != null) {
                for (OrderApi__Sales_Order_Line__c salesOrderLine : currSub.OrderApi__Sales_Orders__r) {
                    if (salesOrderLine.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c == 'Receipt' && salesOrderLine.OrderApi__Sales_Order__r.OrderApi__Posting_Status__c == 'Pending' && salesOrderLine.OrderApi__Sales_Order__r.OrderApi__Status__c == 'Closed') {
                        pExists = true;
                        break;
                    }
                }
            }

            if (!currSub.OrderApi__Item__r.FSP_FonMPP__Hide_Expired_Subscription__c || currSub.OrderApi__Status__c != 'Expired') {
                SubscriptionWrapper temp = new SubscriptionWrapper(currSub, currSub.FSP_FonMPP__Within_Renewal_Time_Frame__c, false,
                        currSub.OrderApi__Term_End_Date__c,currSub.OrderApi__Term_Start_Date__c, currSub.OrderApi__Paid_Through_Date__c, pExists);
                allSubscriptions.add(temp);

            } else if (currSub.FSP_FonMPP__Within_Renewal_Time_Frame__c) {
                SubscriptionWrapper temp = new SubscriptionWrapper(currSub, currSub.FSP_FonMPP__Within_Renewal_Time_Frame__c, false, currSub.OrderApi__Term_End_Date__c,currSub.OrderApi__Term_Start_Date__c, currSub.OrderApi__Paid_Through_Date__c, pExists);
                allSubscriptions.add(temp);

            }

        }


        return allSubscriptions;
    }

    /**
     * Pulls all Subscriptions associated with the Account that the logged in User is the Primary Contact of. The
     * subscriptions must be visible to Primary contact for them to appear in portal.
     *
     * @param currentUser
     *
     * @return
     */
    public static List<SubscriptionWrapper> getPrimaryContactSubscriptions(User currentUser) {

        List<OrderApi__Subscription__c> Subscriptions = [
                SELECT Id, OrderApi__Item__r.Name, OrderApi__Paid_Through_Date__c, OrderApi__Item__r.OrderApi__Display_Name__c,OrderApi__Item__r.FSP_FonMPP__Hide_Expired_Subscription__c,
                        OrderApi__Account__r.Name, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Entity__c, OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c,
                        FSP_FonMPP__Within_Renewal_Time_Frame__c, OrderApi__Activated_Date__c, OrderApi__Term_End_Date__c, OrderApi__Term_Start_Date__c,
                        OrderApi__Days_To_Lapse__c, OrderApi__Status__c, FSP_FonMPP__Customer_Name__c, (
                        SELECT OrderApi__Sales_Order__r.OrderApi__Posting_Status__c,
                                OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c, OrderApi__Sales_Order__r.OrderApi__Status__c
                        FROM OrderApi__Sales_Orders__r)
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Account__r.OrderApi__Primary_Contact__c = :currentUser.ContactId
                AND OrderApi__Entity__c = 'Account'
                AND OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Visible__c INCLUDES ('Primary Contact')
                AND OrderApi__Hide_In_Portal__c != TRUE
                AND OrderApi__Status__c != 'Cancelled'
        ];

        List<SubscriptionWrapper> subscriptionWrappers = createAccountSubscriptionWrappers(Subscriptions,'Primary Contact');
        return subscriptionWrappers;

    }

    /**
     * Pulls all Subscriptions associated with the Account that the logged in User is a part of. The subscriptions
     * must be visible to Account Contacts for them to appear in portal.
     *
     * @param currentUser
     *
     * @return
     */
    public static List<SubscriptionWrapper> getAccountSubscriptions(User currentUser) {

        List<OrderApi__Subscription__c> Subscriptions = [
                SELECT Id, OrderApi__Item__r.Name, OrderApi__Paid_Through_Date__c, OrderApi__Item__r.OrderApi__Display_Name__c,OrderApi__Item__r.FSP_FonMPP__Hide_Expired_Subscription__c,
                        OrderApi__Account__r.Name, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Entity__c, OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c,
                        FSP_FonMPP__Within_Renewal_Time_Frame__c, OrderApi__Activated_Date__c, OrderApi__Term_End_Date__c, OrderApi__Term_Start_Date__c,
                        OrderApi__Days_To_Lapse__c, OrderApi__Status__c, FSP_FonMPP__Customer_Name__c, (
                        SELECT OrderApi__Sales_Order__r.OrderApi__Posting_Status__c, OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c,
                                OrderApi__Sales_Order__r.OrderApi__Status__c
                        FROM OrderApi__Sales_Orders__r
                )
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Entity__c = 'Account'
                AND OrderApi__Account__c = :currentUser.Contact.AccountId
                AND OrderApi__Account__r.OrderApi__Primary_Contact__c != :currentUser.ContactId
                AND OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Visible__c INCLUDES ('Account Contacts')
                AND OrderApi__Hide_In_Portal__c != TRUE
                AND OrderApi__Status__c != 'Cancelled'
        ];

        List<SubscriptionWrapper> subscriptionWrappers = createAccountSubscriptionWrappers(Subscriptions,'Account Contacts');
        return subscriptionWrappers;

    }

    /**
     * Pulls all Subscriptions associated with Parent Accounts of the logged in User. The subscriptions
     * must be visible to Child Account Contacts for them to appear in portal.
     *
     *
     * @param currentUser
     *
     * @return
     */
    private static List<SubscriptionWrapper> getParentAccountSubscriptions(User currentUser) {

        List<Id> AccountIds = new List<Id>();
        AccountIds.add(currentUser.Contact.AccountId);

        List<Account> accounts = [SELECT Id, ParentId FROM Account WHERE Id = :currentUser.Contact.AccountId];
        Account currAccount = accounts[0];

        while (currAccount.ParentId != null) {
            AccountIds.add(currAccount.ParentId);
            accounts = [SELECT Id, ParentId FROM Account WHERE Id = :currAccount.ParentId];
            currAccount = accounts[0];
        }


        List<OrderApi__Subscription__c> Subscriptions = [
                SELECT Id, OrderApi__Item__r.Name, OrderApi__Paid_Through_Date__c, OrderApi__Item__r.OrderApi__Display_Name__c,OrderApi__Item__r.FSP_FonMPP__Hide_Expired_Subscription__c,
                        OrderApi__Account__r.Name, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Entity__c, OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c,
                        FSP_FonMPP__Within_Renewal_Time_Frame__c, OrderApi__Activated_Date__c, OrderApi__Term_End_Date__c, OrderApi__Term_Start_Date__c,
                        OrderApi__Days_To_Lapse__c, OrderApi__Status__c, FSP_FonMPP__Customer_Name__c, (
                        SELECT OrderApi__Sales_Order__r.OrderApi__Posting_Status__c, OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c,
                                OrderApi__Sales_Order__r.OrderApi__Status__c
                        FROM OrderApi__Sales_Orders__r
                )
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Entity__c = 'Account'
                AND OrderApi__Account__c != :currentUser.Contact.AccountId
                AND OrderApi__Account__c IN :AccountIds
                AND OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Visible__c INCLUDES ('Child Account Contacts')
                AND OrderApi__Hide_In_Portal__c != TRUE
                AND OrderApi__Status__c != 'Cancelled'
        ];

        List<SubscriptionWrapper> subscriptionWrappers = createAccountSubscriptionWrappers(Subscriptions,'Child Account Contacts');
        return subscriptionWrappers;

    }

    private static List<SubscriptionWrapper> createAccountSubscriptionWrappers(List<OrderApi__Subscription__c> Subscriptions, String contactFilter) {

        List<SubscriptionWrapper> subscriptionWrappers = new List<SubscriptionWrapper>();
        for (OrderApi__Subscription__c currSub : Subscriptions) {
            Boolean pExists = false;
            if (currSub.OrderApi__Sales_Orders__r != null) {
                for (OrderApi__Sales_Order_Line__c salesOrderLine : currSub.OrderApi__Sales_Orders__r) {

                    if (salesOrderLine.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c == 'Receipt' && salesOrderLine.OrderApi__Sales_Order__r.OrderApi__Posting_Status__c == 'Pending' && salesOrderLine.OrderApi__Sales_Order__r.OrderApi__Status__c == 'Closed') {
                        pExists = true;
                        break;
                    }
                }
            }

            if (!currSub.OrderApi__Item__r.FSP_FonMPP__Hide_Expired_Subscription__c || currSub.OrderApi__Status__c != 'Expired') {
                if (currSub.OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c != null) {
                    SubscriptionWrapper temp = new SubscriptionWrapper(currSub,
                            (currSub.OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c.contains(contactFilter) && currSub.FSP_FonMPP__Within_Renewal_Time_Frame__c), true,
                            currSub.OrderApi__Term_End_Date__c, currSub.OrderApi__Term_Start_Date__c, currSub.OrderApi__Paid_Through_Date__c, pExists);
                    subscriptionWrappers.add(temp);
                } else {
                    SubscriptionWrapper temp = new SubscriptionWrapper(currSub, false, true, currSub.OrderApi__Term_End_Date__c, currSub.OrderApi__Term_Start_Date__c, currSub.OrderApi__Paid_Through_Date__c, pExists);
                    subscriptionWrappers.add(temp);
                }
            } else if (currSub.FSP_FonMPP__Within_Renewal_Time_Frame__c && currSub.OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c != null){
                if (currSub.OrderApi__Item__r.FSP_FonMPP__Account_Subscriptions_Renew__c.contains(contactFilter)) {
                    SubscriptionWrapper temp = new SubscriptionWrapper(currSub, true, true, currSub.OrderApi__Term_End_Date__c, currSub.OrderApi__Term_Start_Date__c, currSub.OrderApi__Paid_Through_Date__c, pExists);
                    subscriptionWrappers.add(temp);
                }
            }
        }
        return subscriptionWrappers;
    }

    @AuraEnabled
    public static List<SubscriptionWrapper> getAllSubscriptions() {

        List<User> loggedInUser = [SELECT ContactId, Contact.AccountId, Contact.Account.ParentId FROM User WHERE Id = :UserInfo.getUserId()];
        if (loggedInUser.size() > 0 && loggedInUser.get(0).ContactId != null) {
            User currentUser = loggedInUser.get(0);

            List<SubscriptionWrapper> allSubscriptions = new List<SubscriptionWrapper>();


            allSubscriptions.addAll(getContactSubscriptions(currentUser));
            allSubscriptions.addAll(getPrimaryContactSubscriptions(currentUser));
            allSubscriptions.addAll(getAccountSubscriptions(currentUser));
            allSubscriptions.addAll(getParentAccountSubscriptions(currentUser));

            return allSubscriptions;

        }
        return null;
    }

    @AuraEnabled
    public static String getProformaURL(String siteURL) {
        List<LTE__Menu_Item__c> menuItem = [SELECT Id, LTE__URL__c FROM LTE__Menu_Item__c WHERE LTE__Profile_Menu_Item_Component__c LIKE '%PfInvoices%' AND LTE__URL__c LIKE :siteURL LIMIT 1];
        if (menuItem.size() != 0 && menuItem[0].LTE__URL__c != null) {
            return menuItem[0].LTE__URL__c;
        }
        return '';
    }

    @AuraEnabled
    public static String getSubInstruction(String siteURL) {
        List<LTE__Site__c> sites = [SELECT Id, LTE__Manage_Subscription_Instructions__c, LTE__Site_URL__c FROM LTE__Site__c];

        for (LTE__Site__c s : sites) {
            if (siteURL.contains(s.LTE__Site_URL__c)) {
                return s.LTE__Manage_Subscription_Instructions__c;
            }
        }
        return '';
    }

    @TestVisible
    private class SubscriptionWrapper{
        @AuraEnabled
        public OrderApi__Subscription__c subscription;
        @AuraEnabled
        public Boolean renew;
        @AuraEnabled
        public Boolean accountSubPrimary;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String paidThroughDate;
        @AuraEnabled
        public Boolean proformaExists;

        public SubscriptionWrapper(OrderApi__Subscription__c sub, Boolean ren, Boolean accSubPrimary, Datetime termEnd, Datetime termStart, Datetime paidThroughDate, Boolean pExists) {
            this.subscription = sub;
            this.renew = ren;
            this.accountSubPrimary = accSubPrimary;
            this.proformaExists = pExists;

            if(sub.OrderApi__Status__c == 'Active') {
                this.status = 'activeSub';
            } else if(sub.OrderApi__Status__c == 'Expired' && sub.FSP_FonMPP__Within_Renewal_Time_Frame__c == true) {
                this.status = 'graceSub';
            } else {
                this.status = 'expiredSub';
            }


            this.endDate = (termEnd != null) ? termEnd.dateGmt().format() : null;

            this.startDate = (termStart != null) ? termStart.dateGmt().format() : null;

            this.paidThroughDate = (paidThroughDate != null) ? paidThroughDate.dateGmt().format() : null;


        }

    }
}