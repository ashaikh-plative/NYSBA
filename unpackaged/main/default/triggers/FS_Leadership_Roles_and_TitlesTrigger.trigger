/**
 * Created by Nikhil on 17-11-2019.
 */

trigger FS_Leadership_Roles_and_TitlesTrigger on FS_Leadership_Role_and_Title__c (before insert, before update, before delete,
							after insert, after update, after delete) {
	Framework.Dispatcher.dispatchTrigger();
}