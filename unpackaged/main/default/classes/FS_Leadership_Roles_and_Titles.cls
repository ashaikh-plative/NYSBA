global class FS_Leadership_Roles_and_Titles extends Framework.Domain {

     public FS_Leadership_Roles_and_Titles(List<FS_Leadership_Role_and_Title__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Leadership_Roles_and_Titles(sObjectList);
          }
     }
}