global class FS_ContactCountyRoutingRule extends Framework.Domain {
    private static final String CONFIRMED = 'Confirmed';
    private static final String NEW_YORK_STATE = 'New York State';
    private static final String NEW_YORK_STRING = 'New York';
    public FS_ContactCountyRoutingRule(List<Contact> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<Contact> sObjectList) {
            return new FS_ContactCountyRoutingRule(sObjectList);
        }
    }
    public override void beforeInsert() {
        Framework.Log.push(FS_ContactCountyRoutingRule.class.getName(),'Before Insert');
        for(Contact con : (Contact[]) records){
            updateCounty(con);
        }
        Framework.Log.pop();
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_ContactCountyRoutingRule.class.getName(),'Before update');
        List<Contact> contactList = (List<Contact>) records;
        for (Contact con : contactList) {
            Contact oldCon = (Contact)oldMap.get(con.Id);

            if(oldCon.smartystreets__Mailing_Return_Code__c != null
                    || (con.smartystreets__Mailing_Return_Code__c != oldCon.smartystreets__Mailing_Return_Code__c)
                    || (con.smartystreets__Other_Return_Code__c != oldCon.smartystreets__Other_Return_Code__c)
                    || oldCon.smartystreets__Other_Return_Code__c != null
                    || con.MailingState == NEW_YORK_STRING || con.OtherState == NEW_YORK_STRING){
                updateCounty(con);
            }
        }
    }
    private static void updateCounty(Contact con){
        if((con.MailingState == NEW_YORK_STRING) && (con.smartystreets__Mailing_Return_Code__c != CONFIRMED )&& (con.FS_API_Mailing_County__c == null)){
                con.FS_API_Mailing_County__c = NEW_YORK_STATE;
        }
        if((con.OtherState == NEW_YORK_STRING) && (con.smartystreets__Other_Return_Code__c != CONFIRMED )&& (con.FS_API_Other_County__c == null)){
                con.FS_API_Other_County__c= NEW_YORK_STATE;
        }
    }
}