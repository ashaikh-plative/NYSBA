global class FS_Opportunity_Product_Benefits extends Framework.Domain {

     public FS_Opportunity_Product_Benefits(List<Opportunity_Product_Benefits__c> sObjectList) {
          super(sObjectList);
     }

     global class Constructor implements Framework.Domain.DomainConstructor {
          public Framework.Domain construct(List<SObject> sObjectList) {
          return new FS_Opportunity_Product_Benefits(sObjectList);
          }
     }
}