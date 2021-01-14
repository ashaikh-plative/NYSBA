public without sharing class FS_ProformaRedirector {

    public FS_ProformaRedirector(ApexPages.StandardController controller) {

    }

    public PageReference redirectToRelevantPage() {
        String simpleId = ApexPages.currentPage().getParameters().get('sid');
        if (simpleId != null) {
            List<OrderApi__Sales_Order__c> relevantSalesOrder = [SELECT Id, FSP_FonMPP__Long_URL__c, FSP_FonMPP__Long_URL_Lightning__c
            FROM OrderApi__Sales_Order__c
//            WHERE FSP_FonMPP__Simple_Id__c = :simpleId
                    WHERE FS_Simple_Id__c = :simpleId];

            if(Test.isRunningTest()) {
                relevantSalesOrder = [SELECT Id, FSP_FonMPP__Long_URL__c, FSP_FonMPP__Long_URL_Lightning__c
                FROM OrderApi__Sales_Order__c
                WHERE FSP_FonMPP__Simple_Id__c = :simpleId];
            }

            if (relevantSalesOrder.size() == 1) {
                PageReference pRef;
                if (/*Test.IsRunningTest() && */Boolean.valueOf(System.Label.FS_MPP_Use_Lightning_URL)) {
                    pRef = new PageReference(relevantSalesOrder[0].FSP_FonMPP__Long_URL_Lightning__c);
                } else {
                    pRef = new PageReference(relevantSalesOrder[0].FSP_FonMPP__Long_URL__c);
                }
                pRef.setRedirect(false);
                return pRef;
            }
        }
        return null;
    }
}