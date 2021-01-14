trigger FS_Sponsoring_Community_GroupsTrigger on FS_Sponsoring_Community_Groups__c (before insert, before update, before delete,
																				after insert, after update, after delete) {
			Framework.Dispatcher.dispatchTrigger();
}