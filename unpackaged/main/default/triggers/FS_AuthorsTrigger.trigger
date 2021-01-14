trigger FS_AuthorsTrigger on FS_Authors__c (before insert, before update, before delete,
                                                  after insert, after update, after delete) {
              Framework.Dispatcher.dispatchTrigger();
}