trigger FS_Pledge_InstallmentsTrigger on FS_Pledge_Installments__c (before insert, before update, before delete,after insert, after update, after delete) {
	Framework.Dispatcher.dispatchTrigger();
}