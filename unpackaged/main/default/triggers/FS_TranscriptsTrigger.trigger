trigger FS_TranscriptsTrigger on FS_Transcript__c (before insert, before update, before delete,
                                   after insert, after update, after delete) {
	Framework.Dispatcher.dispatchTrigger();
}