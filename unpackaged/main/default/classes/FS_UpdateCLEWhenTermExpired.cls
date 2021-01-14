/**
 * Created by Seshu on 14-09-2020.
 */

global without sharing class FS_UpdateCLEWhenTermExpired extends Framework.Domain {
    
    private static final String ACTIVE_STATUS = 'Active';
    private static final String CANCELLED_STATUS = 'Cancelled';

    public FS_UpdateCLEWhenTermExpired(List<OrderApi__Subscription__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_UpdateCLEWhenTermExpired(sObjectList);
        }
    }

    public override void afterUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_UpdateCLEWhenTermExpired.class.getName(), 'afterUpdate');
        updateCLEWhenMembershipExpired((List<OrderApi__Subscription__c>) records,(Map<Id,OrderApi__Subscription__c>) oldMap);
        Framework.Log.pop();
    }

    private static void updateCLEWhenMembershipExpired(List<OrderApi__Subscription__c> subscriptions,Map<Id,OrderApi__Subscription__c> oldMap){
        Set<Id> subscriptionIds = new Set<Id>();
        List<OrderApi__Renewal__c> renewalsToUpdate = new List<OrderApi__Renewal__c>();
        Map<Id,Contact> contactsByIds = new Map<Id,Contact>();
        for(OrderApi__Subscription__c subscription: subscriptions){
            if(oldMap.get(subscription.Id).OrderApi__Status__c == ACTIVE_STATUS &&
                    (subscription.OrderApi__Status__c == CANCELLED_STATUS)){
                subscriptionIds.add(subscription.Id);
            }
        }

        //Retrieving the subscription related terms
        Map<Id,OrderApi__Subscription__c> subscriptionsByIds = getSubscriptionsByIds(subscriptionIds);

        for(OrderApi__Subscription__c subscription: subscriptionsByIds.values()){
            for(OrderApi__Renewal__c renewal: subscription.OrderApi__Renewals__r){
                //Added condition to confirm membership term get's expired
                if(renewal.FS_Term_Credits_Consumed__c < renewal.FS_Term_Credits_Gained__c){
                    Decimal expiredCredits = renewal.FS_Term_Credits_Gained__c - renewal.FS_Term_Credits_Consumed__c - renewal.FS_Term_Credits_Expired__c;
                    //Checking expired credits are not negative
                    if(expiredCredits >= 0){
                        renewalsToUpdate.add(new OrderApi__Renewal__c(Id = renewal.Id,FS_Term_Credits_Expired__c = expiredCredits));
                        if(contactsByIds.containsKey(renewal.OrderApi__Contact__c)){
                            contactsByIds.put(renewal.OrderApi__Contact__c,new Contact(Id = renewal.OrderApi__Contact__c,
                                    FS_Credits_Expired__c = contactsByIds.get(renewal.OrderApi__Contact__c).FS_Credits_Expired__c + expiredCredits));
                        }else{
                            contactsByIds.put(renewal.OrderApi__Contact__c,new Contact(Id = renewal.OrderApi__Contact__c,
                                    FS_Credits_Expired__c = renewal.OrderApi__Contact__r.FS_Credits_Expired__c != null ?
                                            renewal.OrderApi__Contact__r.FS_Credits_Expired__c + expiredCredits : expiredCredits));
                        }
                    }
                }
            }
        }

        update renewalsToUpdate;
        update contactsByIds.values();

    }

    private static Map<Id,OrderApi__Subscription__c> getSubscriptionsByIds(Set<Id> subscriptionIds){
        Map<Id, OrderApi__Subscription__c> subscriptionsByIds = new Map<Id, OrderApi__Subscription__c>([
                SELECT Id, (
                        SELECT Id,OrderApi__Contact__c,
                                OrderApi__Term_End_Date__c,OrderApi__Grace_Period_End_Date__c,FS_Term_Credits_Gained__c,FS_Term_Credits_Consumed__c,FS_Term_Credits_Expired__c,
                                OrderApi__Contact__r.FS_Credits_Expired__c
                        FROM OrderApi__Renewals__r
                        WHERE FS_Term_Credits_Gained__c != NULL AND OrderApi__Term_End_Date__c > TODAY
                        AND (OrderApi__Grace_Period_End_Date__c = NULL OR OrderApi__Grace_Period_End_Date__c > TODAY )
                )
                FROM OrderApi__Subscription__c
                WHERE Id IN:subscriptionIds
        ]);
        return subscriptionsByIds;
    }
}