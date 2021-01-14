//FS_OpportunitiesTrigger,Opportunity
trigger FS_OpportunitiesTrigger on Opportunity (before insert, before update, before delete,
                                                after insert, after update, after delete) {
                                                    Framework.Dispatcher.dispatchTrigger();
                                                }