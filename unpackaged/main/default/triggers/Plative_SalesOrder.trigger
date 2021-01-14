/**
* Description : Trigger on Sales Order object
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
trigger Plative_SalesOrder on OrderApi__Sales_Order__c (before insert, before update, after insert, after update)  { 

	Trigger_Settings__c setting = Trigger_Settings__c.getOrgDefaults();
    if (setting.Sales_Order__c && Plative_SalesOrderTriggerHandler.runTrigger) {
		new Plative_SalesOrderTriggerHandler(Trigger.newMap).run();
    }

}