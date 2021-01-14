/**
 * Created by Admin on 09-10-2019.
 */

global class FS_Opportunities extends Framework.Domain {

    public FS_Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_Opportunities(sObjectList);
        }
    }
}