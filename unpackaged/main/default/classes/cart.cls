public class cart {
    
    public Id recordId{get;set;}
    public List<String> itemList {get;set;}
    public String salesOrderId{get;set;}
    public cart(){
        
    }
    public void setRecord_Id(Id recordId) {
        salesOrderId  = recordId;
        
    }
    public Id getRecord_Id() {
        return salesOrderId;
    }
    public List<String> getitems(){
        // List<String> itemlist = new List<String>();
        
        List<OrderApi__Sales_Order_Line__c> item = [SELECT Id,OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__C =:salesOrderId];
        system.debug('item'+ item);
        for( OrderApi__Sales_Order_Line__c orders :item){
            itemList.add(orders.OrderApi__Item__r.Name);
        }
        
        system.debug('itemlist'+ itemList);
        return itemList;
    }
}