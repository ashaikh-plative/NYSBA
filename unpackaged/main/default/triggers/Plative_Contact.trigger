/**
* Description : Trigger on Contact object
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
trigger Plative_Contact on Contact (before insert, before update, after insert, after update){ 

	Trigger_Settings__c setting = Trigger_Settings__c.getOrgDefaults();
    if (setting.Contact__c && Plative_ContactTriggerHandler.runTrigger) {
		new Plative_ContactTriggerHandler(Trigger.newMap).run();
    }	

}