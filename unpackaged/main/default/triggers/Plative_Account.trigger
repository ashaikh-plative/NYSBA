/**
* Description : Trigger on Account object
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
trigger Plative_Account on Account (before insert, before update, after insert, after update)  { 

	Trigger_Settings__c setting = Trigger_Settings__c.getOrgDefaults();
    if (setting.Account__c && Plative_AccountTriggerHandler.runTrigger) {
		new Plative_AccountTriggerHandler(Trigger.newMap).run();
    }	

}