global class FS_Fellows extends Framework.Domain {

     public FS_Fellows(List<FS_Fellow__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Fellows(sObjectList);
          }
     }
}