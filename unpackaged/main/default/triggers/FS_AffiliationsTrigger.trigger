trigger FS_AffiliationsTrigger on FS_Affiliation__c (before insert, before update, before delete,
                                   after insert, after update, after delete) {
	Framework.Dispatcher.dispatchTrigger();
}