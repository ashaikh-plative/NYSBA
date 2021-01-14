global class FS_Pledge_Installments extends Framework.Domain {

     public FS_Pledge_Installments(List<FS_Pledge_Installments__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Pledge_Installments(sObjectList);
          }
     }
}