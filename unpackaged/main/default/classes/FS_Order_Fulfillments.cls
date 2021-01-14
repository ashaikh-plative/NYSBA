global class FS_Order_Fulfillments extends Framework.Domain {
    
    public FS_Order_Fulfillments(List<FS_Order_Fulfillment__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_Order_Fulfillments(sObjectList);
        }
    }
    
    
    
}