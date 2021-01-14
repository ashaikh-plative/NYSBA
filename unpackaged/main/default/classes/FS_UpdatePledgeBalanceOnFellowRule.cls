/**
 * Created by cloudwebsolutions on 05-02-2020.
 */

global class FS_UpdatePledgeBalanceOnFellowRule extends Framework.Domain {


    public FS_UpdatePledgeBalanceOnFellowRule(List<FS_Fellow__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_UpdatePledgeBalanceOnFellowRule(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_UpdatePledgeBalanceOnFellowRule.class.getName(),'Before Insert');
        updatePledgeBalanceToZero((List<FS_Fellow__c>) records);
        Framework.Log.pop();
    }

    public override  void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_UpdatePledgeBalanceOnFellowRule.class.getName(),'Before update');
        updatePledgeBalanceToZero((List<FS_Fellow__c>) records);
        Framework.Log.pop();
    }

    private static void updatePledgeBalanceToZero(List<FS_Fellow__c> fellows){ 

        for(FS_Fellow__c fellow : fellows){
            if(fellow.FS_Paid_Life__c == true){
                if(fellow.FS_Pledge_Amount__c != null){
                    Decimal pledgeAmount = fellow.FS_Pledge_Amount__c;
                    fellow.FS_Pledge_Amount_Paid__c = pledgeAmount;
                }
            }
        }
    }
}