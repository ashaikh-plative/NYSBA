trigger FS_Event_BundlesTrigger on FS_Event_Bundle__c (before insert, before update,
                                                       before delete,after insert,
                                                       after update, after delete) {
	//Framework.Dispatcher.dispatchTrigger();
}