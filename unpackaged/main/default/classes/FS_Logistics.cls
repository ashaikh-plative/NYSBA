global class FS_Logistics extends Framework.Domain {

     public FS_Logistics(List<Logistics__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Logistics(sObjectList);
          }
     }
}