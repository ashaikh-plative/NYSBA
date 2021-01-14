global class FS_Affiliations extends Framework.Domain {
 
    public FS_Affiliations(List<FS_Affiliation__c> sObjectList) {
        super(sObjectList);
    }
 
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_Affiliations(sObjectList);
        }
    }
}