global class FS_Authors extends Framework.Domain {

     public FS_Authors(List<FS_Authors__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Authors(sObjectList);
          }
     }
}