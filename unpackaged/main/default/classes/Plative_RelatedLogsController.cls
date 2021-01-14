/**
* Company     : Plative
* Description : Controller to the Plative_RelatedLogs lightning component
* [07.Dec.2020] Plative - Code Creation
*/
public class Plative_RelatedLogsController  {

	/*
	* Description : Query all Integration Log records for the given record
	*/
	@AuraEnabled
	public static List<Integration_Log__c> queryLogRecords(String relatedRecordId){
		
		List<Integration_Log__c> lstLogRecords = new List<Integration_Log__c>();
		try{
			lstLogRecords = [SELECT Id,Name,Job__c,Success__c,Error_Message__c, Response_Code__c,CreatedDate 
							 FROM Integration_Log__c 
							 WHERE Salesforce_Record_ID__c =:relatedRecordId 
							 ORDER BY CreatedDate DESC
							 LIMIT 10];

		}
		catch(Exception	e){
			System.debug('EXCEPTION'+e.getMessage()+e.getStackTraceString());
			return null;
		}
		return lstLogRecords;
	}

}