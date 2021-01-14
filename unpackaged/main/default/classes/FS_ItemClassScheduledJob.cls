/**
 * Created by daweima on 6/30/20.
 */

public without sharing class FS_ItemClassScheduledJob implements Schedulable {
    List<Id> relatedItemClass;

    public FS_ItemClassScheduledJob(List<Id> relatedItemClass) {
        this.relatedItemClass = relatedItemClass;
    }

    public void execute(SchedulableContext param1) {
        if (!relatedItemClass.isEmpty()){
            List<OrderApi__Item_Class__c> relatedClasses = [SELECT Id, OrderApi__Is_Active__c FROM OrderApi__Item_Class__c WHERE Id IN :relatedItemClass];
            for (OrderApi__Item_Class__c currClass : relatedClasses){
                currClass.OrderApi__Is_Active__c = true;
            }

            update relatedClasses;
        }
        Id cronTriggerId = param1.getTriggerId();
        System.abortJob(cronTriggerId);
    }
}