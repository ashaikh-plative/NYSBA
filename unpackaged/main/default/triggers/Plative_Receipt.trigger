/**
* Description : Trigger on Receipt object
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
trigger Plative_Receipt on OrderApi__Receipt__c (after update)  { 

	Trigger_Settings__c setting = Trigger_Settings__c.getOrgDefaults();
    if (setting.Receipt__c && Plative_ReceiptTriggerHandler.runTrigger) {
		new Plative_ReceiptTriggerHandler(Trigger.newMap).run();
    }
}