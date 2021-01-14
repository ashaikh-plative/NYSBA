/**
 * Created by Jason Cookman on 2/24/19.
 */

global without sharing class FS_TermRoutingRule extends Framework.Domain {

    private static final String SALES_ORDER_STATUS_CLOSED = 'Closed';
    private static final String ADDITIONAL_DATA_SECTIONS_COMMITTEES_KEY = 'sectionCommittees';
    private static final String ADDITIONAL_DATA_STATUS_KEY = 'status';

    public FS_TermRoutingRule(List<OrderApi__Renewal__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_TermRoutingRule(sObjectList);
        }
    }


    public override void afterInsert() {
        Framework.Log.push(FS_TermRoutingRule.class.getName(), 'afterInsert');
        createCommunityGroupTermsIfNeeded((List<OrderApi__Renewal__c>) records);
        Framework.Log.pop();
    }


    // Note: we are assuming 1 term per contact in a sales order
    // if there are multiple terms generated for the same contact in the sales order, it will
    // not be easy to determine which one to assign the section/division terms to.
    // in this case, the sections and division terms will be linked to one at random
    private void createCommunityGroupTermsIfNeeded(List<OrderApi__Renewal__c> termsCreatedOrModified) {
        Set<Id> salesOrderIds = new Set<Id>();
        Map<String, OrderApi__Renewal__c> contactIdSalesOrderIdToTerm = new Map<String, OrderApi__Renewal__c>();

        Set<Id> contactIds = new Set<Id>();
        Set<Id> communityGroupIds = new Set<Id>();

        Map<Id, OrderApi__Renewal__c> salesOrderLineToTerm = new Map<Id, OrderApi__Renewal__c>();
        for (OrderApi__Renewal__c currTerm : termsCreatedOrModified) {

            contactIds.add(currTerm.OrderApi__Contact__c);
            salesOrderIds.add(currTerm.OrderApi__Sales_Order__c);
            contactIdSalesOrderIdToTerm.put(String.valueOf(currTerm.OrderApi__Contact__c) + '' +
                    String.valueOf(currTerm.OrderApi__Sales_Order__c),
                    currTerm);
            salesOrderLineToTerm.put(currTerm.OrderApi__Sales_Order_Line__c, currTerm);


        }
        List<OrderApi__Sales_Order_Line__c> relevantSalesOrderLines
                = [SELECT Id, OrderApi__Item__r.FS_Linked_Community_Group__c,
                OrderApi__Contact__c, OrderApi__Sales_Order__c, OrderApi__Item_Class__c,
                OrderApi__Item_Class__r.Name, FS_Additional_Data__c
        FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c IN :salesOrderIds
        AND OrderApi__Sales_Order__r.OrderApi__Status__c = :SALES_ORDER_STATUS_CLOSED
        AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = 'Posted'
        AND OrderApi__Item__r.FS_Linked_Community_Group__c != NULL];

        List<OrderApi__Subscription__c> membershipsToBeMarkedAsPending = new List<OrderApi__Subscription__c>();

        // need list of community group members
        for(OrderApi__Sales_Order_Line__c currSalesOrderLine : relevantSalesOrderLines) {
            communityGroupIds.add(currSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c);
            if (currSalesOrderLine.FS_Additional_Data__c != null) {
                Map<String, Object> tempAdditionalData = (Map<String, Object>) JSON.deserializeUntyped(currSalesOrderLine.FS_Additional_Data__c);
//                if(tempAdditionalData.containsKey('membership')) {
//                    Map<String, Object> tempAdditionalDataSub =
//                            (Map<String, Object>) JSON.deserializeUntyped((String)tempAdditionalData.get('membership'));
//
//                    if(tempAdditionalDataSub.containsKey('status')) {
//                        String memStatus = (String) tempAdditionalDataSub.get('status');
//                        if(memStatus == 'pending') {
//                            OrderApi__Renewal__c relevantRenewal = salesOrderLineToTerm.get(currSalesOrderLine.Id);
//                            if (relevantRenewal != null) {
//                            // add this membership to be marked as pending
//                                membershipsToBeMarkedAsPending.add(new OrderApi__Subscription__c(Id = relevantRenewal.OrderApi__Subscription__c,
//                                    OrderApi__Current_Term_Start_Date__c = Date.today().addYears(100)));
//                            }
//                        }
//                    }
//                }


                String tempStatus = null;
                if (tempAdditionalData.containsKey(ADDITIONAL_DATA_STATUS_KEY)) {
                    tempStatus = (String) tempAdditionalData.get(ADDITIONAL_DATA_STATUS_KEY);
                }
                if (tempAdditionalData.containsKey(ADDITIONAL_DATA_SECTIONS_COMMITTEES_KEY)) {
                    for (Object tempId : (List<Object>) tempAdditionalData.get(ADDITIONAL_DATA_SECTIONS_COMMITTEES_KEY)) {
                        communityGroupIds.add((String) tempId);
                    }
                }
            }
        }

        System.debug(communityGroupIds);

        Map<String, PagesApi__Community_Group_Member__c> contactIdToCGIdToCGM =
                new Map<String, PagesApi__Community_Group_Member__c>();

        List<PagesApi__Community_Group_Member__c> relevantCommunityGroupMembers =
        [SELECT Id, PagesApi__Contact__c, PagesApi__Community_Group__c,FS_Term_Start_Date__c,FS_Grace_Period_End_Date__c,FS_Re_Join_Date__c FROM PagesApi__Community_Group_Member__c
        WHERE PagesApi__Contact__c IN :contactIds AND PagesApi__Community_Group__c IN :communityGroupIds];

        for(PagesApi__Community_Group_Member__c currCGM : relevantCommunityGroupMembers) {
            contactIdToCGIdToCGM.put(String.valueOf(currCGM.PagesApi__Contact__c) + '' + String.valueOf(currCGM.PagesApi__Community_Group__c), currCGM);
        }
        List<CommunityGroupWrapper> communityGroupWrapperList = new List<CommunityGroupWrapper>();

        for(OrderApi__Sales_Order_Line__c currSalesOrderLine : relevantSalesOrderLines) {
            String contactIdSalesOrderIdToTermKey = String.valueOf(currSalesOrderLine.OrderApi__Contact__c) + ''
                    + String.valueOf(currSalesOrderLine.OrderApi__Sales_Order__c);
            OrderApi__Renewal__c relevantTerm = contactIdSalesOrderIdToTerm.get(contactIdSalesOrderIdToTermKey);
            // we should only look at the sales order lines that are also associated to terms. This if statement does this
            if(relevantTerm != null) {
                String groupMemberKey = String.valueOf(currSalesOrderLine.OrderApi__Contact__c )+ ''
                        + String.valueOf(currSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c);
                PagesApi__Community_Group_Member__c groupMember = contactIdToCGIdToCGM.get(groupMemberKey);
                communityGroupWrapperList.add(new CommunityGroupWrapper(relevantTerm, groupMember, currSalesOrderLine, currSalesOrderLine.OrderApi__Item__r.FS_Linked_Community_Group__c));
                if (currSalesOrderLine.FS_Additional_Data__c != null) {
                    Map<String, Object> tempAdditionalData = (Map<String, Object>) JSON.deserializeUntyped(currSalesOrderLine.FS_Additional_Data__c);
                    String tempStatus = null;
                    if (tempAdditionalData.containsKey(ADDITIONAL_DATA_STATUS_KEY)) {
                        tempStatus = (String) tempAdditionalData.get(ADDITIONAL_DATA_STATUS_KEY);
                    }

                    if (tempAdditionalData.containsKey(ADDITIONAL_DATA_SECTIONS_COMMITTEES_KEY)) {
                        for (Object tempId : (List<Object>) tempAdditionalData.get(ADDITIONAL_DATA_SECTIONS_COMMITTEES_KEY)) {
                            String groupMemberKeyTemp = String.valueOf(currSalesOrderLine.OrderApi__Contact__c) + ''
                                    + String.valueOf((String) tempId);
                            PagesApi__Community_Group_Member__c groupMemberTemp = contactIdToCGIdToCGM.get(groupMemberKeyTemp);

                            communityGroupWrapperList.add(new CommunityGroupWrapper(relevantTerm, groupMemberTemp, currSalesOrderLine, (String) tempId));
                        }
                    }
                }
            }

        }
        System.debug(communityGroupWrapperList);

        if(communityGroupWrapperList.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            try {
                List<PagesApi__Community_Group_Member__c> groupMembersToUpsert = new List<PagesApi__Community_Group_Member__c>();
                for (CommunityGroupWrapper currWrapper : communityGroupWrapperList) {
                    groupMembersToUpsert.add(currWrapper.buildCommunityGroupMember());
                }
                upsert groupMembersToUpsert;

                List<FS_Community_Group_Member_Term__c> communityTermsToInsert = new List<FS_Community_Group_Member_Term__c>();
                for (CommunityGroupWrapper currWrapper : communityGroupWrapperList) {
                    communityTermsToInsert.add(currWrapper.createCommunityTerm());
                }
                insert communityTermsToInsert;
            } catch (Exception e) {
                System.debug('Exception caught');
                System.debug(e.getMessage());
                System.debug(e.getLineNumber());
                System.debug(e.getCause());
                Database.rollback(sp);
            }
        }

    }


    public class CommunityGroupWrapper {
        public OrderApi__Renewal__c term;
        public PagesApi__Community_Group_Member__c communityGroupMember;
        public OrderApi__Sales_Order_Line__c salesOrderLine;
        public String communityGroupId;


        public CommunityGroupWrapper(OrderApi__Renewal__c term, PagesApi__Community_Group_Member__c communityGroupMember,
                OrderApi__Sales_Order_Line__c salesOrderLine, String communityGroupId) {
            this.term = term;
            this.communityGroupMember = communityGroupMember;
            this.salesOrderLine = salesOrderLine;
            this.communityGroupId = communityGroupId;
        }

        public PagesApi__Community_Group_Member__c buildCommunityGroupMember() {
            // if this community group member needs to be inserted
            if(communityGroupMember == null) {

                communityGroupMember = new PagesApi__Community_Group_Member__c (
                        FS_Term_Start_Date__c = term.OrderApi__Term_Start_Date__c,
                        FS_Term_End_Date__c = term.OrderApi__Term_End_Date__c,
                        FS_Grace_Period_End_Date__c = term.OrderApi__Grace_Period_End_Date__c,
                        PagesApi__Contact__c = term.OrderApi__Contact__c,
                        PagesApi__Community_Group__c = communityGroupId
                );
            } else {
                if (communityGroupMember.FS_Term_Start_Date__c == null) {
                    communityGroupMember.FS_Term_Start_Date__c = term.OrderApi__Term_Start_Date__c;
                }

                  if(communityGroupMember.FS_Grace_Period_End_Date__c < term.OrderApi__Term_Start_Date__c){
                    communityGroupMember.FS_Re_Join_Date__c = term.OrderApi__Term_Start_Date__c;
                }
                communityGroupMember.FS_Term_End_Date__c = term.OrderApi__Term_End_Date__c;
                communityGroupMember.FS_Grace_Period_End_Date__c = term.OrderApi__Grace_Period_End_Date__c;
               communityGroupMember.FS_Paid_Through_Date__c =term.OrderApi__Term_End_Date__c;
            }
            return communityGroupMember;
        }

        public FS_Community_Group_Member_Term__c createCommunityTerm() {
            if(communityGroupMember == null || communityGroupMember.Id == null) {
//                throw new NullPointerException('communityGroupMember must be set. ' +
//                        'Be sure to call buildCommuntyGroupMember and insert/update ' +
//                        'those records before calling this one');
            }
            FS_Community_Group_Member_Term__c communityTerm;
            if (salesOrderLine != null) {
                communityTerm = new FS_Community_Group_Member_Term__c(
                        FS_Term_Start_Date__c = term.OrderApi__Term_Start_Date__c,
                        FS_Term_End_Date__c = term.OrderApi__Term_End_Date__c,
                        FS_Term_Grace_Period_End_Date__c = term.OrderApi__Grace_Period_End_Date__c,
                        FS_Community_Group_Member__c = communityGroupMember.Id,
                        FS_Term__c = term.Id,
                        FS_Sales_Order_Line__c = salesOrderLine.Id
                    
                );
            } else {
                communityTerm = new FS_Community_Group_Member_Term__c(
                        FS_Term_Start_Date__c = term.OrderApi__Term_Start_Date__c,
                        FS_Term_End_Date__c = term.OrderApi__Term_End_Date__c,
                        FS_Term_Grace_Period_End_Date__c = term.OrderApi__Grace_Period_End_Date__c,
                        FS_Community_Group_Member__c = communityGroupMember.Id,
                        FS_Term__c = term.Id
                );
            }
//            FS_Subscription_Term__c = term.Id,
            return communityTerm;
        }
    }
}