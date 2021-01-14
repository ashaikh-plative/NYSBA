global class FS_Sponsoring_Community_Groups extends Framework.Domain {

     public FS_Sponsoring_Community_Groups(List<FS_Sponsoring_Community_Groups__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Sponsoring_Community_Groups(sObjectList);
          }
     }
}