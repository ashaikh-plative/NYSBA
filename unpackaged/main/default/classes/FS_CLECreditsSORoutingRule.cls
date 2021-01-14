/**
 * Created by santhosh on 16-09-2020.
 */

global without sharing class FS_CLECreditsSORoutingRule  extends Framework.Domain {
    public FS_CLECreditsSORoutingRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_CLECreditsSORoutingRule(sObjectList);
        }
    }

    public override void beforeDelete(){
        Framework.Log.push(OrderApi__Sales_Order_Line__c.class.getName(), 'after delete');
        Set<Id> soIds = new Set<Id>();
        for(OrderApi__Sales_Order__c so : (List<OrderApi__Sales_Order__c>)records){
            if(so.OrderApi__Posting_Status__c != 'Posted'){
                soIds.add(so.Id);
            }
        }
        List<OrderApi__Sales_Order_Line__c> recordsTobeProcessed= [SELECT Id, FS_Additional_Data__c, OrderApi__Contact__c,
                                                                    OrderApi__Item__c, FS_CLE_Credits_Applied__c
                                                                    FROM OrderApi__Sales_Order_Line__c
                                                                    WHERE OrderApi__Sales_Order__c IN :soIds];

        if(!recordsTobeProcessed.isEmpty()){
            FS_CLECreditsUtil.removeCredits(recordsTobeProcessed, null, true);
        }

        Framework.Log.pop();
    }

}