trigger Plative_Opportunity on Opportunity (after update)  { 

	Plative_SFToNSSyncUtility.processForRealTimeSync('Opportunity', Trigger.newMap);

}