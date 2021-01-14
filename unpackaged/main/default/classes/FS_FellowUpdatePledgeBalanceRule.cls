/**
 * Created by cmudd on 2/4/20.
 * Description : This is to update the pledgeamountpaid with pledgeAmount on checking the paid life checkbox.
 */

global without sharing class FS_FellowUpdatePledgeBalanceRule extends Framework.Domain {

    public FS_FellowUpdatePledgeBalanceRule(List<FS_Fellow__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_FellowUpdatePledgeBalanceRule(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_FellowUpdatePledgeBalanceRule.class.getName(),'Before Insert');
        updatePledgeBalanceToZero((List<FS_Fellow__c>) records);
        Framework.Log.pop();
    }

    global virtual override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_FellowUpdatePledgeBalanceRule.class.getName(), 'beforeUpdate');
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