global class FS_Orders_Tracking extends Framework.Domain {

     public FS_Orders_Tracking(List<FS_Order_Tracking__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Orders_Tracking(sObjectList);
          }
     }
}