/**
 * Created by Anvesh on 02-Sep-20.
 */

global class FS_Event_Bundles extends Framework.Domain {
    public FS_Event_Bundles(List<FS_Event_Bundle__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_Event_Bundles(sObjectList);
        }
    }
}