trigger FS_Order_FulfillmentsTrigger on FS_Order_Fulfillment__c (before insert, before update, before delete,
                                                             after insert, after update, after delete) {
       Framework.Dispatcher.dispatchTrigger();

}