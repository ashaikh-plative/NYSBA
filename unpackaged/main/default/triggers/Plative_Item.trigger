/**
* Description : Trigger on item object
* History     :
* [27.Oct.2020] Plative - Code Creation
*/

trigger Plative_Item on OrderApi__Item__c (before update, after update)  { 

    Trigger_Settings__c setting = Trigger_Settings__c.getOrgDefaults();
    if (setting.Item__c && Plative_ItemTriggerHandler.runTrigger) {
        new Plative_ItemTriggerHandler(Trigger.newMap).run();
    }
}