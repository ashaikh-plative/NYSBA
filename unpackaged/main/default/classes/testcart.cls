public without sharing class testcart {
    public Id item_Id {get;set;}
    public List<OrderApi__Sales_Order_Line__c> getsalesorder()
    {
        List<OrderApi__Sales_Order_Line__c> items;
        items = [SELECT Id,OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__C =: item_Id 
                 AND OrderApi__Item__r.OrderApi__Is_Shipping_Rate__c = FALSE AND OrderApi__Item__r.OrderApi__Is_Tax__c = FALSE];
        return items;
    }

}