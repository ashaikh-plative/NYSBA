/**
* Description : Helper class with utility methods for Sales Orders
* History     :
* [27.Oct.2020] Plative - Code Creation
*/
public class Plative_SalesOrderHelper  {

	/*
	* Description : Mark contacts associated to Sales Order for sync
	*/
	public static void markContactsForSync(Set<Id> setContacts){	
		List<Contact> lstContacts = new List<Contact>();
		for(Id contactId : setContacts){
			Contact newContact = new Contact();
			newContact.Id = contactId;
			newContact.Trigger_Sync_To_NetSuite__c = true;
			lstContacts.add(newContact);
		}
		update lstContacts;
	}
	
}