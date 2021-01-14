/**
 * Created by santhosh on 16-09-2020.
 */

global without sharing class FS_CLECreditsSOLRoutingRule extends Framework.Domain {
    public FS_CLECreditsSOLRoutingRule(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_CLECreditsSOLRoutingRule(sObjectList);
        }
    }
    /**
     *Assumptions:
     *From community portal, We can't change the item on sales order line, we can only delete the sales order line and create new sales order line
     *From back end, When we change the CLE Eligible item on sales order line, we are removing the credits through the following method
     *From back end, We can't apply the credits
     */
    public override void beforeUpdate(Map<Id, SObject> oldRecords) {
        Framework.Log.push(OrderApi__Sales_Order_Line__c.class.getName(),'after update');
        List<OrderApi__Sales_Order_Line__c> recordsTobeProcessed= new List<OrderApi__Sales_Order_Line__c>();
        for(OrderApi__Sales_Order_Line__c sol : (List<OrderApi__Sales_Order_Line__c>)records){
            if(sol.OrderApi__Item__c != ((OrderApi__Sales_Order_Line__c)oldRecords.get(sol.Id)).OrderApi__Item__c){
                recordsTobeProcessed.add(sol);
            }
        }
        if(!recordsTobeProcessed.isEmpty()){
            FS_CLECreditsUtil.removeCredits(recordsTobeProcessed, (Map<Id, OrderApi__Sales_Order_Line__c>)oldRecords);
        }
        Framework.Log.pop();
    }

    public override void beforeDelete(){
        Framework.Log.push(OrderApi__Sales_Order_Line__c.class.getName(), 'after delete');
        FS_CLECreditsUtil.removeCredits((List<OrderApi__Sales_Order_Line__c>) records, null, true);
        Framework.Log.pop();
    }
}