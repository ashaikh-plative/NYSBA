trigger FS_Orders_TrackingTrigger on FS_Order_Tracking__c (before insert, before update, before delete,after insert, after update, after delete) {
Framework.Dispatcher.dispatchTrigger();
}