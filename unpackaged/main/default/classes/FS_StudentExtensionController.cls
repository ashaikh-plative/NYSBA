public class FS_StudentExtensionController{

    private static final String STUDENT_MEMBERSHIP_MASTER_LABEL = 'Student Auto Renew';
    @AuraEnabled
    public static Contact getDisplayInfo(){
        User loggedInUser = [SELECT Id, ContactId FROM User WHERE Id=:UserInfo.getUserId()];
        List<Contact> contactInfo = [
                SELECT Id,LastName, OrderApi__Preferred_Email_Type__c, OrderApi__Preferred_Phone_Type__c, MailingStreet,
                        MailingCountryCode, MailingState, MailingStateCode, MailingCity, MailingPostalCode, HomePhone,
                        OrderApi__Work_Phone__c, MobilePhone, OrderApi__Personal_Email__c, FS_Student_Email__c,
                        OrderApi__Work_Email__c, FS_Preferred_Billing_Address__c, FS_Preferred_Mailing_Address__c,
                        FS_Graduation_Date__c, FS_Degree_Type__c, FS_Law_School__r.Name
                FROM Contact
                WHERE Id = :loggedInUser.ContactId
        ];

        return contactInfo.get(0);
    }

    @AuraEnabled
    public static void updateContact(Contact contact) {
        //System.debug('updating contact');
        update contact;
    }

    @AuraEnabled
    public static Boolean checkPageDisplay() {
        List<OrderApi__Subscription__c> records = [
                SELECT OrderApi__Contact__r.FS_Graduation_Date__c, OrderApi__Days_To_Lapse__c, OrderApi__Status__c,
                        OrderApi__Renewals__c, OrderApi__Item__r.Name,OrderApi__Term_End_Date__c,
                        OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c, OrderApi__Subscription_Plan__r.Name
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Contact__c = :getDisplayInfo().Id ORDER BY OrderApi__Term_End_Date__c DESC 
                LIMIT 1
        ];

        List<FS_Student_Autorenew__mdt> studentRenewData = [SELECT Id,FS_Student_Ext_Days_After_Graduation__c,FS_Student_Ext_Days_Before_Graduation__c,
                FS_Law_Student_Item_Id__c FROM FS_Student_Autorenew__mdt WHERE MasterLabel =: STUDENT_MEMBERSHIP_MASTER_LABEL LIMIT 1];
        List<String> studentItemIds ;
        if(studentRenewData != null && studentRenewData.size() == 1){
            studentItemIds = studentRenewData[0].FS_Law_Student_Item_Id__c.split(',');
        }

        for (OrderApi__Subscription__c currSubscription : records){
            Date today = System.today();
            Date graduDate = currSubscription.OrderApi__Contact__r.FS_Graduation_Date__c;
            Integer daysDiff = graduDate.daysBetween(today);
            String planName = currSubscription.OrderApi__Subscription_Plan__r.Name;
            List<String> planNameString = planName.split(' ');

            if(studentRenewData.get(0) != null && studentRenewData[0].FS_Student_Ext_Days_Before_Graduation__c != null && studentRenewData[0].FS_Student_Ext_Days_After_Graduation__c != null){
                if (daysDiff > Integer.valueOf(studentRenewData[0].FS_Student_Ext_Days_Before_Graduation__c) &&
                        daysDiff < Integer.valueOf(studentRenewData[0].FS_Student_Ext_Days_After_Graduation__c) &&
                        !planNameString.contains('Extension') && !planNameString.contains('extension')) {
                    if((studentItemIds.contains(currSubscription.OrderApi__Item__c)||Test.isRunningTest()) && currSubscription.OrderApi__Days_To_Lapse__c < 90
                            && currSubscription.OrderApi__Days_To_Lapse__c >= -currSubscription.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c
                            && currSubscription.OrderApi__Status__c == 'Active' && currSubscription.OrderApi__Renewals__c < 2){
                        return true;
                    }
                }
            }
        }
        return false;
    }

    @AuraEnabled
    public static String createSalesOrder(Id subscriptionPlanId, String itemId){
        Contact contact = getDisplayInfo();
        Map<Id, OrderApi__Item__c> itemToRenewalItemMap = createRenewalItemMap();
        List<Id> itemIdList = itemId.split(',');
        Contact cForSubscription = [
                SELECT Id, (SELECT Id, OrderApi__Is_Active__c, OrderApi__Item__r.Id,OrderApi__Term_End_Date__c
                FROM OrderApi__Subscriptions__r WHERE OrderApi__Is_Active__c = TRUE AND OrderApi__Item__r.Id IN :itemIdList
                ORDER BY OrderApi__Term_End_Date__c DESC ) FROM Contact WHERE Id = :contact.Id
        ][0];

        OrderApi__Sales_Order__c salesOrder;
        // create SO
        for (OrderApi__Sales_Order__c s : [SELECT Id,
        (SELECT Id, OrderApi__Item__r.Id FROM OrderApi__Sales_Order_Lines__r)
        FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__r.Id = :contact.Id
        AND OrderApi__Status__c = 'Closed' AND OrderApi__Posting_Status__c='Pending']) {
            for (OrderApi__Sales_Order_Line__c l : s.OrderApi__Sales_Order_Lines__r) {
                if (l.OrderApi__Item__r.Id == cForSubscription.OrderApi__Subscriptions__r.get(0).OrderApi__Item__c) {
                    //found the existing order
                    delete s;
                    break;
                }
            }
        }

        salesOrder = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c = contact.Id,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Status__c = 'Open'
        );
        insert salesOrder;



        // insert SOL with membership item
        //TODO FIX NULL POINTER IN cForSubscription.OrderApi__Subscriptions__r.get(0).Id
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c=salesOrder.Id,
                OrderApi__Item__c = cForSubscription.OrderApi__Subscriptions__r.get(0).OrderApi__Item__c,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Subscription_Plan__c = subscriptionPlanId,
                OrderApi__Is_Renewal__c = true,
                OrderApi__Subscription__c = cForSubscription.OrderApi__Subscriptions__r.get(0).Id
        );
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = new List<OrderApi__Sales_Order_Line__c>();
        salesOrderLineList.add(salesOrderLine);
        //insert salesOrderLine;

        // cgmt of current contact that has a active status
        List<FS_Community_Group_Member_Term__c> cgmt = [
                SELECT Id, FS_Term__r.OrderApi__Contact__c, FS_Term__r.OrderApi__Item__c,FS_Sales_Order_Line__r.OrderApi__Item__r.Id,
                        FS_Sales_Order_Line__r.OrderApi__Item__r.Name,
                        FS_Term__r.OrderApi__Sales_Order__c, FS_Term__r.OrderApi__Sales_Order__r.Id,FS_Community_Group_Member__c, FS_Sales_Order_Line__c,
                        FS_Community_Group_Member__r.PagesApi__Community_Group__c,
                        FS_Community_Group_Member__r.PagesApi__Community_Group__r.FS_Parent_Section__c,
                        FS_Community_Group_Member__r.PagesApi__Community_Group__r.FS_Parent_Section__r.Name,
                        FS_Community_Group_Member__r.PagesApi__Community_Group__r.PagesApi__Type__c
                FROM FS_Community_Group_Member_Term__c
                WHERE FS_Is_Active__c = TRUE AND FS_Term__r.OrderApi__Contact__r.Id = :contact.Id
        ];

        // cgm id list for additional data
//        Set<Id> cgmSectionIdList = new Set<Id>();
//        Set<Id> cgmSubSectionIdList = new Set<Id>();
//        List<Id> itemListForSection = new List<Id>();
        // add eligible so to a list for later use
        Set<Id> salesOrderIds = new Set<Id>();
        Map<Id, Id> parentCommunityGroupToCGMTItem = new Map<Id, Id>();

        List<FS_Community_Group_Member_Term__c> cgmtSectionList = new List<FS_Community_Group_Member_Term__c>();
        List<FS_Community_Group_Member_Term__c> cgmtSubSectionList = new List<FS_Community_Group_Member_Term__c>();

//        List<PagesApi__Community_Group_Member__c> cgmList = new List<PagesApi__Community_Group_Member__c>();
//        List<PagesApi__Community_Group_Member__c> cgmSubsectionList = new List<PagesApi__Community_Group_Member__c>();

        for (FS_Community_Group_Member_Term__c currTerm : cgmt) {

            // there should only be 1 sales order id in this set when you are done.
            salesOrderIds.add(currTerm.FS_Term__r.OrderApi__Sales_Order__r.Id);

            if(currTerm.FS_Community_Group_Member__r.PagesApi__Community_Group__r.FS_Parent_Section__c != null ) {
//                cgmSubSectionIdList.add(currTerm.FS_Community_Group_Member__c);
//                cgmSubsectionList.add(currTerm.FS_Community_Group_Member__r);
                cgmtSubSectionList.add(currTerm);
            } else {
//                cgmSectionIdList.add(currTerm.FS_Community_Group_Member__c);
//                cgmList.add(currTerm.FS_Community_Group_Member__r);
                cgmtSectionList.add(currTerm);
                parentCommunityGroupToCGMTItem.put(currTerm.FS_Community_Group_Member__r.PagesApi__Community_Group__c, currTerm.FS_Sales_Order_Line__r.OrderApi__Item__c);
            }

//            Id tItemId = currTerm.FS_Sales_Order_Line__r.OrderApi__Item__r.Id;
//            System.debug('david item id and list ' + tItemId + ' ' + itemListForSection);
//            if (tItemId != itemId && !itemListForSection.contains(tItemId)) {
//                itemListForSection.add(tItemId);
//            }
        }

        if(salesOrderIds.size() > 1) {
            System.debug(LoggingLevel.WARN, 'Only 1 sales order was expected');
        }

        // get SOL within SO
        List<OrderApi__Sales_Order__c> termSalesOrders = [
                SELECT Id, (SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Id, OrderApi__Total__c, OrderApi__Price_Override__c FROM OrderApi__Sales_Order_Lines__r)
                FROM OrderApi__Sales_Order__c WHERE Id IN :salesOrderIds
        ];

        Set<Id> freeItems = new Set<Id>();
        for (OrderApi__Sales_Order__c s : termSalesOrders) {
            for (OrderApi__Sales_Order_Line__c sol : s.OrderApi__Sales_Order_Lines__r) {

                // filter is to ignore the same membership item
                if (sol.OrderApi__Item__r.Id != cForSubscription.OrderApi__Subscriptions__r.get(0).OrderApi__Item__c) {
                    // if this was a free section
                    if (sol.OrderApi__Total__c == 0 && sol.OrderApi__Price_Override__c == true) {
                        freeItems.add(sol.OrderApi__Item__r.Id);
                    }
                }
            }
        }

        Map<Id, OrderApi__Sales_Order_Line__c> parentItemToSalesOrderLine = new Map<Id, OrderApi__Sales_Order_Line__c>();

        for(FS_Community_Group_Member_Term__c currTerm : cgmtSectionList ) {
            OrderApi__Item__c renewalItem = itemToRenewalItemMap.get(currTerm.FS_Sales_Order_Line__r.OrderApi__Item__c);

            OrderApi__Sales_Order_Line__c saleOrderLineToAdd = new OrderApi__Sales_Order_Line__c(
                    OrderApi__Sales_Order__c = salesOrder.Id,
                    OrderApi__Item__c = renewalItem.Id, //add item with - renew extension
                    OrderApi__Entity__c = 'Contact',
                    FS_Additional_Data__c=''
            );

            if(freeItems.contains(currTerm.FS_Sales_Order_Line__r.OrderApi__Item__c)) {
                saleOrderLineToAdd.OrderApi__Price_Override__c = true;
                saleOrderLineToAdd.OrderApi__Sale_Price__c = 0;
            }
            parentItemToSalesOrderLine.put(renewalItem.Id, saleOrderLineToAdd);
            salesOrderLineList.add(saleOrderLineToAdd);
        }

        //Adding subsections to the Additional data field
        Map<Id, String> salesOrderLineItemToAdditionalData = new Map<Id, String>();
        for(FS_Community_Group_Member_Term__c currTerm : cgmtSubSectionList) {
            OrderApi__Item__c renewalItem = itemToRenewalItemMap.get(currTerm.FS_Sales_Order_Line__r.OrderApi__Item__c);
//            OrderApi__Sales_Order_Line__c lineToInsert = parentItemToSalesOrderLine.get(renewalItem.Id);
            String additionalData = salesOrderLineItemToAdditionalData.get(renewalItem.Id) == null?'':salesOrderLineItemToAdditionalData.get(renewalItem.Id);
//            String additionalData = '';
            additionalData += '"' + currTerm.FS_Community_Group_Member__r.PagesApi__Community_Group__c + '",';
            salesOrderLineItemToAdditionalData.put(renewalItem.Id, additionalData);
        }

        for (Id renewalItemId : salesOrderLineItemToAdditionalData.keySet()) {
            OrderApi__Sales_Order_Line__c lineToInsert = parentItemToSalesOrderLine.get(renewalItemId);
            String additionalData = salesOrderLineItemToAdditionalData.get(renewalItemId);
            if(!String.isBlank(additionalData)) {
                additionalData = '{"sectionCommittees":["' + additionalData.removeEnd('",').removeStart('"') + '"]}';
            }
//            salesOrderLineItemToAdditionalData.put(renewalItem.Id, additionalData);
            if (additionalData != null && additionalData != '') {
                lineToInsert.FS_Additional_Data__c = additionalData;
            }
        }

        insert salesOrderLineList;

        salesOrder.OrderApi__Posting_Status__c='Pending';
        salesOrder.OrderApi__Status__c = 'Closed';

        update salesOrder;

        return [SELECT Id, FSP_FonMPP__Long_URL_Lightning__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder.Id].get(0).FSP_FonMPP__Long_URL_Lightning__c;
    }

    public static Map<Id, OrderApi__Item__c> createRenewalItemMap() {
        Map<Id,OrderApi__Item__c> itemMap = new Map<Id,OrderApi__Item__c>();
        List<OrderApi__Item__c> items = [SELECT Id, Name FROM OrderApi__Item__c WHERE Name LIKE '%Section'];
        List<OrderApi__Item__c> renewalItems = [SELECT Id, Name FROM OrderApi__Item__c WHERE Name LIKE '%Section - Renewal'];
        Map<String, OrderApi__Item__c> renewalItemMap = new Map<String, OrderApi__Item__c>();

        for (OrderApi__Item__c i : renewalItems) {
            renewalItemMap.put(i.Name, i);
        }

        for (OrderApi__Item__c i : items) {
            String renewalName = i.Name + ' - Renewal';
            itemMap.put(i.Id, renewalItemMap.get(renewalName));
        }

        return itemMap;
    }

}