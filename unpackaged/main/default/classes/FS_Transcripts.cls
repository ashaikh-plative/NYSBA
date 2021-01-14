global class FS_Transcripts extends Framework.Domain {
 
    public FS_Transcripts(List<FS_Transcript__c> sObjectList) {
        super(sObjectList);
    }
 
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_Transcripts(sObjectList);
        }
    }
}