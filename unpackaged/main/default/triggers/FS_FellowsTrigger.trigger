trigger FS_FellowsTrigger on FS_Fellow__c (before insert, before update, before delete,after insert, after update, after delete) {
       Framework.Dispatcher.dispatchTrigger();
}