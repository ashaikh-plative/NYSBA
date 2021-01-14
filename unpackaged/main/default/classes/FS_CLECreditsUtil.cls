/**
 * Created by santhosh on 16-09-2020.
 */

public without sharing class FS_CLECreditsUtil {
    private static final String TERM_CREDITS_SEARCH_STRING = 'termCredits';

    public static void removeCredits(List<OrderApi__Sales_Order_Line__c> salesOrderLineList, Map<Id, OrderApi__Sales_Order_Line__c> oldRecords){
        removeCredits(salesOrderLineList, oldRecords, false);
    }

    public static void removeCredits(List<OrderApi__Sales_Order_Line__c> salesOrderLineList, Map<Id, OrderApi__Sales_Order_Line__c> oldRecords, Boolean isDelete){
        if(salesOrderLineList != null && !salesOrderLineList.isEmpty()){
            Map<Id, FS_TermCredit> termCreditBySolIdMap = new Map<Id, FS_TermCredit>();
            Map<Id, Id> solIdItemItMap = new Map<Id, Id>();
            Set<String> termIds = new Set<String>();
            Map<Id, Decimal> conCreditsConsumedById = new Map<Id, Decimal>();
            List<OrderApi__Sales_Order_Line__c> toBeProcessedSOLList = new List<OrderApi__Sales_Order_Line__c>();
            Map<Id, OrderApi__Sales_Order_Line__c> openSalesOrderLinesByIds = getOpenSOLListMap(salesOrderLineList);
            for (OrderApi__Sales_Order_Line__c sol : salesOrderLineList) {
                OrderApi__Sales_Order_Line__c openSOL = openSalesOrderLinesByIds.get(sol.Id);
                if(openSOL != null && openSOL.OrderApi__Sales_Order__r.OrderApi__Posting_Status__c != 'Posted' &&
                        String.isNotBlank(sol.FS_Additional_Data__c) && sol.FS_Additional_Data__c.contains(TERM_CREDITS_SEARCH_STRING)){
                    FS_TermCredit termCredit;
                    try{
                        termCredit = FS_TermCredit.parse(sol.FS_Additional_Data__c);
                    }catch(Exception e){
                        System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());
                        System.debug(LoggingLevel.ERROR,
                                'Unable to parse the sales order line additional data field value of termCredits JSON string:'+sol.FS_Additional_Data__c);
                    }
                    if(termCredit != null){
                        if(termCredit.termCredits != null){
                            termIds.addAll(termCredit.termCredits.keySet());
                            toBeProcessedSOLList.add(sol);
                            termCreditBySolIdMap.put(sol.Id, termCredit);
                            conCreditsConsumedById.put(sol.OrderApi__Contact__c, openSOL.OrderApi__Contact__r.FS_Credits_Consumed__c);

                            if(oldRecords != null){
                                solIdItemItMap.put(sol.Id, oldRecords.get(sol.Id).OrderApi__Item__c);
                            }else{
                                solIdItemItMap.put(sol.Id, sol.OrderApi__Item__c);
                            }
                        }
                    }
                }
            }

            if(!toBeProcessedSOLList.isEmpty()){
                updateConsumedCreditsOnContactAndTerm(toBeProcessedSOLList, termCreditBySolIdMap, termIds,  solIdItemItMap, conCreditsConsumedById, isDelete);
            }
        }
    }

    private static void updateConsumedCreditsOnContactAndTerm(List<OrderApi__Sales_Order_Line__c> toBeProcessedSOLList,
                                                                Map<Id, FS_TermCredit> termCreditBySolIdMap,
                                                                Set<String> termIds, Map<Id, Id> solIdItemIdMap,
                                                                Map<Id, Decimal> conCreditsConsumedById,
                                                                Boolean isDelete){
        Map<Id, List<OrderApi__Renewal__c>> orderedTermsByConId = getOrderedTermsByContactId(termIds);
        if(!orderedTermsByConId.isEmpty() ){
            Map<Id, OrderApi__Item__c> itemMap = getItemMap(solIdItemIdMap.values());
            Map<Id, OrderApi__Renewal__c> termsToBeUpdated = new Map<Id, OrderApi__Renewal__c>();
            Map<Id, Contact> contactsToBeUpdated = new Map<Id, Contact>();

            for(OrderApi__Sales_Order_Line__c sol: toBeProcessedSOLList){
                List<OrderApi__Renewal__c> terms = orderedTermsByConId.get(sol.OrderApi__Contact__c);
                FS_TermCredit termCredit = termCreditBySolIdMap.get(sol.Id);
                Map<String, Decimal> termIdAmountMap = termCredit.termCredits;
                Decimal originalPrice = termCredit.originalSalesPrice;
                OrderApi__Item__c item = itemMap.get(solIdItemIdMap.get(sol.Id));
                if(terms != null && !terms.isEmpty() && termIdAmountMap != null && item != null && termCredit != null){

                    for(OrderApi__Renewal__c term : terms){
                        Decimal credits = termIdAmountMap.get(term.Id);
                        if(credits != null && credits > 0){
                            if(termsToBeUpdated.containsKey(term.Id)){
                                termsToBeUpdated.get(term.Id).FS_Term_Credits_Consumed__c = termsToBeUpdated.get(term.Id).FS_Term_Credits_Consumed__c - credits;
                            }else{
                                Decimal termCredits = 0;
                                if(term.FS_Term_Credits_Consumed__c != null){
                                    termCredits = term.FS_Term_Credits_Consumed__c;
                                }
                                termsToBeUpdated.put(term.Id, new OrderApi__Renewal__c(Id = term.Id,
                                        FS_Term_Credits_Consumed__c = termCredits - credits));
                            }
                        }
                    }
                    if(sol.FS_CLE_Credits_Applied__c > 0 ){
                        if(contactsToBeUpdated.containsKey(sol.OrderApi__Contact__c)){
                            contactsToBeUpdated.get(sol.OrderApi__Contact__c).FS_Credits_Consumed__c = contactsToBeUpdated.get(sol.OrderApi__Contact__c).FS_Credits_Consumed__c - sol.FS_CLE_Credits_Applied__c;
                        }else{
                            Decimal conCredits = 0;
                            if(conCreditsConsumedById.get(sol.OrderApi__Contact__c) != null){
                                conCredits = conCreditsConsumedById.get(sol.OrderApi__Contact__c);
                            }
                            contactsToBeUpdated.put(sol.OrderApi__Contact__c, new Contact(Id = sol.OrderApi__Contact__c,
                                    FS_Credits_Consumed__c = conCredits - sol.FS_CLE_Credits_Applied__c));
                        }
                    }
                }

                if(!isDelete){
                    sol.FS_Additional_Data__c = '';
                }

                if(!termsToBeUpdated.isEmpty()){
                    update termsToBeUpdated.values();
                }
                if(!contactsToBeUpdated.isEmpty()){
                    update contactsToBeUpdated.values();
                }
            }
        }
    }

    private static Map<Id, OrderApi__Sales_Order_Line__c> getOpenSOLListMap(List<OrderApi__Sales_Order_Line__c> salesOrderLineList){
        return new Map<Id, OrderApi__Sales_Order_Line__c>([SELECT Id, OrderApi__Sales_Order__r.OrderApi__Posting_Status__c, OrderApi__Contact__r.FS_Credits_Consumed__c
                                                            FROM OrderApi__Sales_Order_Line__c
                                                            WHERE Id IN :salesOrderLineList AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c != 'Posted']);
    }

    private static Map<Id, OrderApi__Item__c> getItemMap(List<Id> itemIds){
        return new Map<Id, OrderApi__Item__c>([SELECT Id, FS_Total_Credits__c FROM OrderApi__Item__c
                                                WHERE Id IN :itemIds AND FS_Total_Credits__c != NULL
                                                AND FS_Total_Credits__c > 0]);
    }

    private static Map<Id, List<OrderApi__Renewal__c>> getOrderedTermsByContactId(Set<String> termIds){
        Map<Id, List<OrderApi__Renewal__c>> orderedTermsByConId = new Map<Id, List<OrderApi__Renewal__c>>();

        for (OrderApi__Renewal__c term : [SELECT Id, Name, FS_Term_Credits_Gained__c, FS_Term_Credits_Consumed__c,
                                                FS_Term_Credits_Expired__c, OrderApi__Contact__c
                                                FROM OrderApi__Renewal__c
                                                WHERE FS_Term_Credits_Gained__c != NULL AND FS_Term_Credits_Consumed__c != NULL
                                                        AND OrderApi__Contact__c != NULL
                                                        AND Id IN :termIds ORDER BY OrderApi__Term_End_Date__c ASC
            ]){
            if(orderedTermsByConId.containsKey(term.OrderApi__Contact__c)){
                orderedTermsByConId.get(term.OrderApi__Contact__c).add(term);
            }else{
                List<OrderApi__Renewal__c> termsList = new List<OrderApi__Renewal__c>();
                termsList.add(term);
                orderedTermsByConId.put(term.OrderApi__Contact__c, termsList);
            }
        }
        return orderedTermsByConId;
    }
}