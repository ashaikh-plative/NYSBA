/**
 * Created by Seshu on 08-09-2020.
 */

global without sharing class FS_UpdateCLEOnContactRule extends Framework.Domain {

    private static final Date TODAY = System.today();
    public FS_UpdateCLEOnContactRule(List<OrderApi__Renewal__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor { 
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_UpdateCLEOnContactRule(sObjectList);
        }
    }

    public override void afterInsert() {
        Framework.Log.push(FS_UpdateCLEOnContactRule.class.getName(), 'afterInsert');
        updateCLECreditsOnContactWhenTermCreated((OrderApi__Renewal__c[]) records);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_UpdateCLEOnContactRule.class.getName(), 'afterUpdate');
        updateCLECreditsOnContactWhenTermUpdate((List<OrderApi__Renewal__c>) records,(Map<Id,OrderApi__Renewal__c>) oldMap);
        updateCLECreditsOnContactWhenTermFieldsUpdatesManually((List<OrderApi__Renewal__c>) records,(Map<Id,OrderApi__Renewal__c>) oldMap);
        Framework.Log.pop();
    }

    private static void updateCLECreditsOnContactWhenTermCreated(List<OrderApi__Renewal__c> renewals){
        Map<Id,Contact> contactsByIds = new Map<Id,Contact>();
        List<OrderApi__Renewal__c> renewalsToUpdate = new List<OrderApi__Renewal__c>();

        //Checking term end date and grace period end date both are not passed(assumption: code should able to handle if we data load term records)
        for(OrderApi__Renewal__c renewal: [SELECT Id,OrderApi__Contact__c,FS_Term_Credits_Formula__c,OrderApi__Contact__r.FS_Credits_Gained__c,
                FS_Term_Credits_Gained__c,FS_Term_Credits_Consumed__c,FS_Term_Credits_Expired__c
                FROM OrderApi__Renewal__c WHERE Id=:renewals AND FS_Term_Credits_Formula__c != NULL AND
                (OrderApi__Term_End_Date__c > TODAY OR OrderApi__Grace_Period_End_Date__c > TODAY)]){

            Decimal termCreditsGained = renewal.FS_Term_Credits_Formula__c;
            renewalsToUpdate.add(new OrderApi__Renewal__c(Id = renewal.Id,FS_Term_Credits_Gained__c = termCreditsGained,FS_Term_Credits_Consumed__c = 0,FS_Term_Credits_Expired__c = 0));
            if(contactsByIds.containsKey(renewal.OrderApi__Contact__c)){
                contactsByIds.put(renewal.OrderApi__Contact__c, new Contact(Id = renewal.OrderApi__Contact__c,
                        FS_Credits_Gained__c = contactsByIds.get(renewal.OrderApi__Contact__c).FS_Credits_Gained__c + termCreditsGained));
            }else{
                contactsByIds.put(renewal.OrderApi__Contact__c, new Contact(Id = renewal.OrderApi__Contact__c,
                        FS_Credits_Gained__c = renewal.OrderApi__Contact__r.FS_Credits_Gained__c != null ? renewal.OrderApi__Contact__r.FS_Credits_Gained__c + termCreditsGained : termCreditsGained));
            }
        }

        update renewalsToUpdate;
        update contactsByIds.values();
    }


    private static void updateCLECreditsOnContactWhenTermUpdate(List<OrderApi__Renewal__c> renewals,Map<Id,OrderApi__Renewal__c> oldMap) {
            Set<Id> renewalIds = new Set<Id>();
            Map<Id, Contact> contactsByIds = new Map<Id, Contact>();
            List<OrderApi__Renewal__c> renewalsToUpdate = new List<OrderApi__Renewal__c>();

            for (OrderApi__Renewal__c renewal : renewals) {
                if (isTermDeactivated(renewal,oldMap)) {
                    renewalIds.add(renewal.Id);
                }
            }

            for (OrderApi__Renewal__c renewal : [SELECT Id,OrderApi__Contact__c,OrderApi__Contact__r.FS_Credits_Expired__c,
                    FS_Term_Credits_Gained__c,FS_Term_Credits_Consumed__c,FS_Term_Credits_Expired__c FROM OrderApi__Renewal__c WHERE Id IN:renewalIds]) {
                if (renewal.FS_Term_Credits_Consumed__c < renewal.FS_Term_Credits_Gained__c && renewal.FS_Term_Credits_Expired__c == 0) {
                    Decimal expiredCredits = renewal.FS_Term_Credits_Gained__c - renewal.FS_Term_Credits_Consumed__c;
                    //Checking expired credits are not negative
                    if(expiredCredits >= 0){
                        renewalsToUpdate.add(new OrderApi__Renewal__c(Id = renewal.Id, FS_Term_Credits_Expired__c = expiredCredits));
                        if(contactsByIds.containsKey(renewal.OrderApi__Contact__c)){
                            contactsByIds.put(renewal.OrderApi__Contact__c, new Contact(Id = renewal.OrderApi__Contact__c,
                                    FS_Credits_Expired__c = contactsByIds.get(renewal.OrderApi__Contact__c).FS_Credits_Expired__c + expiredCredits));
                        }else{
                            contactsByIds.put(renewal.OrderApi__Contact__c, new Contact(Id = renewal.OrderApi__Contact__c,
                                    FS_Credits_Expired__c = renewal.OrderApi__Contact__r.FS_Credits_Expired__c != null ?
                                            renewal.OrderApi__Contact__r.FS_Credits_Expired__c + expiredCredits : expiredCredits));
                        }
                    }
                }
            }


            update renewalsToUpdate;
            update contactsByIds.values();
    }
    private static void updateCLECreditsOnContactWhenTermFieldsUpdatesManually(List<OrderApi__Renewal__c> termsList , Map<Id, OrderApi__Renewal__c> oldMap){
        Set<Id> termIds = new Set<Id>();
        Set<Id> contIds = new Set<Id>();
        for(OrderApi__Renewal__c terms : termsList){
            if(terms.FS_Term_Credits_Consumed__c != oldMap.get(terms.Id).FS_Term_Credits_Consumed__c || terms.FS_Term_Credits_Gained__c != oldMap.get(terms.Id).FS_Term_Credits_Gained__c ||
                    terms.FS_Term_Credits_Expired__c != oldMap.get(terms.Id).FS_Term_Credits_Expired__c ){
                termIds.add(terms.Id);
                contIds.add(terms.OrderApi__Contact__c);
            }
        }

        Map<Id, Contact> contMap = new Map<Id, Contact>([ SELECT Id,FS_Credits_Expired__c,FS_Credits_Consumed__c,FS_Credits_Gained__c FROM Contact WHERE Id IN: contIds ]);
        Map<Id, Contact> contToMap = new Map<Id, Contact>();
        for(OrderApi__Renewal__c renewal :[SELECT Id,OrderApi__Contact__c,
                OrderApi__Contact__r.FS_Credits_Expired__c,OrderApi__Contact__r.FS_Credits_Consumed__c,
                OrderApi__Contact__r.FS_Credits_Gained__c,FS_Term_Credits_Gained__c,FS_Term_Credits_Consumed__c,
                FS_Term_Credits_Expired__c FROM OrderApi__Renewal__c WHERE OrderApi__Term_End_Date__c > TODAY
                AND Id IN:termIds]){
            Contact con = contMap.get(renewal.OrderApi__Contact__c);
            if(renewal.FS_Term_Credits_Consumed__c != null && (oldMap.get(renewal.Id).FS_Term_Credits_Consumed__c) != null &&
                    renewal.OrderApi__Contact__r.FS_Credits_Consumed__c != null){

                con.FS_Credits_Consumed__c = con.FS_Credits_Consumed__c + renewal.FS_Term_Credits_Consumed__c - oldMap.get(renewal.Id).FS_Term_Credits_Consumed__c;
                contToMap.put(renewal.OrderApi__Contact__c,con);
            }
            if(renewal.FS_Term_Credits_Gained__c != null && (oldMap.get(renewal.Id).FS_Term_Credits_Gained__c) != null &&
                    renewal.OrderApi__Contact__r.FS_Credits_Gained__c != null){
                con.FS_Credits_Gained__c = con.FS_Credits_Gained__c + renewal.FS_Term_Credits_Gained__c - oldMap.get(renewal.Id).FS_Term_Credits_Gained__c;
                contToMap.put(renewal.OrderApi__Contact__c,con);
            }
            if(renewal.FS_Term_Credits_Expired__c != null && (oldMap.get(renewal.Id).FS_Term_Credits_Expired__c) != null &&
                    renewal.OrderApi__Contact__r.FS_Credits_Expired__c != null){
                con.FS_Credits_Expired__c = con.FS_Credits_Expired__c + renewal.FS_Term_Credits_Expired__c - oldMap.get(renewal.Id).FS_Term_Credits_Expired__c;
                contToMap.put(renewal.OrderApi__Contact__c,con);
            }
        }

        if(!contToMap.values().isEmpty()){
            update contToMap.values();
        }
    }

    private static Boolean isTermDeactivated(OrderApi__Renewal__c renewal,Map<Id,OrderApi__Renewal__c> oldMap){
        return renewal.OrderApi__Term_End_Date__c < TODAY && renewal.OrderApi__Grace_Period_End_Date__c < TODAY &&
                oldMap.get(renewal.Id).OrderApi__Is_Active__c && !renewal.OrderApi__Is_Active__c;
    }
}