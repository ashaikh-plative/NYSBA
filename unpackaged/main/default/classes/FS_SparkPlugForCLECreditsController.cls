/**
 * Created by Ravi on 09-09-2020.
 */

public without sharing class FS_SparkPlugForCLECreditsController {
    //This method is used to display the items which are eligible for CLE Credits on the check out page.
    @AuraEnabled
    public static  List<OrderApi__Sales_Order_Line__c> getItemsEligibleForCleCredits(String orderNumberParam){
        User loggedInUser = [SELECT Id, ContactId, Contact.FS_Credits_Available__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        List<OrderApi__Sales_Order_Line__c> solItemsToBeDisplayed = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> soLineList = [SELECT Id,OrderApi__Price_Override__c,OrderApi__Item__r.Name,
                                                              OrderApi__Item__r.OrderApi__Price__c,OrderApi__Item__r.FS_Total_Credits__c,
                                                              FS_Additional_Data__c,OrderApi__Contact__r.FS_Credits_Available__c,OrderApi__Sale_Price__c
                                                              FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c	= :orderNumberParam AND
                                                              OrderApi__Item__r.FS_Allow_purchase_for_CLE_credits__c = TRUE AND OrderApi__Item__r.FS_Total_Credits__c > 0
                                                              AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c != 'Posted' ];
        for(OrderApi__Sales_Order_Line__c soLine :soLineList) {
            if ((loggedInUser.Contact.FS_Credits_Available__c <= 0 && (soLine.FS_Additional_Data__c != null && soLine.FS_Additional_Data__c.contains('termCredits'))) ||
                    (loggedInUser.Contact.FS_Credits_Available__c > 0 &&
                            ( soLine.OrderApi__Sale_Price__c > 0 || ( soLine.FS_Additional_Data__c != null && soLine.FS_Additional_Data__c.contains('termCredits'))))){
                solItemsToBeDisplayed.add(soLine);
            }
        }

        return solItemsToBeDisplayed;
    }
    //This method is used to update the CLE Credits calculation on the fields for SOLine and Term,Contact objects when we click on apply credits button from the check out page.
    @AuraEnabled
    public static  List<OrderApi__Sales_Order_Line__c> applyCredits(String soLineNumberParam){
        try {
           User loggedInUser = [SELECT Id, ContactId, Contact.FS_Credits_Available__c,Contact.FS_Credits_Consumed__c
                               FROM User
                               WHERE Id = :UserInfo.getUserId()];
            Contact loggedInCon = new Contact(Id = loggedInUser.ContactId);
            Boolean priceOverride;
            Decimal contCreditConsumed = loggedInUser.Contact.FS_Credits_Consumed__c == null ? 0 : loggedInUser.Contact.FS_Credits_Consumed__c;
            List<OrderApi__Sales_Order_Line__c> soList = new List<OrderApi__Sales_Order_Line__c>();
            Decimal salesPrice;
            if (loggedInUser.Contact.FS_Credits_Available__c > 0) {
                List<OrderApi__Sales_Order_Line__c> soLineList = [SELECT Id,OrderApi__Price_Override__c,OrderApi__Sale_Price__c,FS_CLE_Credits_Applied__c,
                                FS_Additional_Data__c,OrderApi__Item__r.Name,OrderApi__Item__r.OrderApi__Price__c,
                                OrderApi__Item__r.FS_Total_Credits__c FROM OrderApi__Sales_Order_Line__c
                                WHERE Id = :soLineNumberParam AND OrderApi__Item__r.FS_Allow_purchase_for_CLE_credits__c = TRUE
                                AND OrderApi__Item__r.FS_Total_Credits__c > 0
                ];

                Decimal totalSOLConsumed = 0 ;
                List<OrderApi__Renewal__c> updateTermCredits = new List<OrderApi__Renewal__c>();
                Decimal totalItemCredits = soLineList[0].OrderApi__Item__r.FS_Total_Credits__c;
                Map<String, Decimal> termCreditsMap = new Map<String, Decimal>();
                for(OrderApi__Renewal__c term : [SELECT Id, Name,FS_Term_Credits_Consumed__c, FS_Term_Credits_Expired__c,OrderApi__Item__r.FS_Total_Credits__c,
                                                FS_Term_Credits_Gained__c,FS_Term_Credits_Formula__c
                                                FROM OrderApi__Renewal__c
                                                WHERE   OrderApi__Term_End_Date__c >=: System.today() AND OrderApi__Contact__c = :loggedInCon.Id
                                                ORDER BY OrderApi__Term_End_Date__c ASC]){//New Change for feature terms

                    if(totalSOLConsumed < totalItemCredits ){
                        Decimal creditsGained = term.FS_Term_Credits_Gained__c;
                        Decimal creditsConsumed = 0;
                        Decimal termAvailable = creditsGained - term.FS_Term_Credits_Consumed__c;
                        if(termAvailable > 0){
                            if(termAvailable < (totalItemCredits - totalSOLConsumed)){
                                creditsConsumed = termAvailable;
                                totalSOLConsumed = totalSOLConsumed + termAvailable;
                            }else{
                                creditsConsumed = totalItemCredits - totalSOLConsumed;
                                totalSOLConsumed = totalItemCredits;
                            }
                            term.FS_Term_Credits_Consumed__c = term.FS_Term_Credits_Consumed__c + creditsConsumed;
                            updateTermCredits.add(term);
                            termCreditsMap.put(term.Id, creditsConsumed);
                            if(totalSOLConsumed == totalItemCredits){
                                break;
                            }
                        }
                    }
                }
                if (!updateTermCredits.isEmpty()) {
                    update updateTermCredits;
                }
                //SOLine Related Calculation
                for (OrderApi__Sales_Order_Line__c soLine : soLineList) {
                    salesPrice = soLine.OrderApi__Sale_Price__c;
                    priceOverride = soLine.OrderApi__Price_Override__c;
                    soLine.OrderApi__Price_Override__c = true;
                    soLine.FS_CLE_Credits_Applied__c = totalSOLConsumed;
				
                    if (soLine.OrderApi__Sale_Price__c != null && soLine.OrderApi__Item__r.FS_Total_Credits__c != null && soLine.FS_CLE_Credits_Applied__c != null) {
                        soLine.OrderApi__Sale_Price__c = soLine.OrderApi__Sale_Price__c / soLine.OrderApi__Item__r.FS_Total_Credits__c
                                * (soLine.OrderApi__Item__r.FS_Total_Credits__c - soLine.FS_CLE_Credits_Applied__c);
                    }
                    if(soLine.FS_CLE_Credits_Applied__c != null){
                        contCreditConsumed = contCreditConsumed + soLine.FS_CLE_Credits_Applied__c;
                        loggedInCon.FS_Credits_Consumed__c = contCreditConsumed;
                    }
                    soList.add(soLine);
                }
                if (!soList.isEmpty()) {
                    update soList;
                }
                if (loggedInCon != null) {
                    update loggedInCon;
                }

                Boolean price_Override;
                Decimal originalSalesPrice;
                price_Override = priceOverride ;
                originalSalesPrice = salesPrice;
                FS_TermCredit termCredits = new FS_TermCredit();
                termCredits.termCredits = termCreditsMap;
                termCredits.originalPriceOverride = price_Override;
                termCredits.originalSalesPrice = originalSalesPrice;
                String termCreditsString = Json.serialize(termCredits);
                if(soLineNumberParam != null){
                    //Here the Additional Data would be like {termId1:creditsConsumed,termId2:creditsConsumed}, originalPriceOverride:false, originalSalesPrice: <original sales price> }
                    OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c (Id = soLineNumberParam, FS_Additional_Data__c = termCreditsString);
                    update soLine;
                }
            }
           return soList;
        }
       catch(Exception e){
            List<OrderApi__Sales_Order_Line__c> soList=new List<OrderApi__Sales_Order_Line__c>();
            return soList;
        }
    }
    //This method is used to clear the fields on the SOLine and Term,Contact objects when we click on remove credits button from the check out page.
    @AuraEnabled
    public static void removeSOLCredits(String soLineNumberParam){
        List<OrderApi__Sales_Order_Line__c> soList = [SELECT Id,Name,OrderApi__Price_Override__c,OrderApi__Sale_Price__c,FS_CLE_Credits_Applied__c,
                FS_Additional_Data__c,OrderApi__Item__r.Name,OrderApi__Item__r.OrderApi__Price__c,OrderApi__Item__r.FS_Allow_purchase_for_CLE_credits__c,
                OrderApi__Item__r.FS_Total_Credits__c, OrderApi__Item__c ,OrderApi__Contact__c FROM OrderApi__Sales_Order_Line__c WHERE Id = :soLineNumberParam];

        FS_CLECreditsUtil.removeCredits(soList,null);

        List<OrderApi__Sales_Order_Line__c> solLineList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c();
        soLine.Id =soLineNumberParam;
        soLine.OrderApi__Price_Override__c = false ;
        soLine.OrderApi__Sale_Price__c= soList[0].OrderApi__Sale_Price__c / soList[0].OrderApi__Item__r.FS_Total_Credits__c
                * (soList[0].OrderApi__Item__r.FS_Total_Credits__c + soList[0].FS_CLE_Credits_Applied__c);
        soLine.FS_CLE_Credits_Applied__c = 0;
        soLine.FS_Additional_Data__c = '';
        solLineList.add(soLine);
        if(!solLineList.isEmpty()){
            update solLineList;
        }

    }

}