global class FS_Awards  extends Framework.Domain{
 	public FS_Awards (List<FS_Awards__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Awards(sObjectList);
          }
     }
}