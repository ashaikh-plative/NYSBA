/**
 * Company     : Plative
 * Description : 
 * ****************************************************************************************
 * Test class for Integration log classes
 * ****************************************************************************************
 * History     : 
 * [13.Aug.2019] Anisa Shaikh - Code Creation 
*/
@isTest
private class Plative_IntegrationLogTest {

    static testMethod void testWrapperClass() {
        test.startTest();

            Plative_IntegrationLog log1 = new Plative_IntegrationLog();     
            log1.endpoint = '';
            log1.job= '';
            log1.reqHeader = '';
            log1.reqBody = '';
            log1.respCode = '';
            log1.respBody = '';
            log1.errMsg = '';
            log1.success= false;
			log1.relatedRecordId = '';
            Plative_IntegrationLog log2 = new Plative_IntegrationLog('', '', '', '', '', '', '', false,'');        
        test.stopTest();
    }

    static testMethod void testController() {
            Integration_Log__c logObject = new Integration_Log__c();
            logObject.Endpoint__c= '';
            logObject.Job__c= 'TEST';
            logObject.Request_Header__c='';
            logObject.Request_Body__c='';
            logObject.Response_Code__c='';
            logObject.Response_Body__c='';
            logObject.Error_Message__c='';
            logObject.Success__c =false;
			logObject.Salesforce_Record_ID__c = 'test';         
            insert logObject;
			Test.startTest();
				List<Integration_Log__c> lstLogs = Plative_RelatedLogsController.queryLogRecords('test');
            Test.stopTest();
			System.assertEquals(1, lstLogs.size());
    }

	static testMethod void testPurging() {

            Integration_Log__c logObject = new Integration_Log__c();
            logObject.Endpoint__c= '';
            logObject.Job__c= 'TEST';
            logObject.Request_Header__c='';
            logObject.Request_Body__c='';
            logObject.Response_Code__c='';
            logObject.Response_Body__c='';
            logObject.Error_Message__c='';
            logObject.Success__c =false;
			logObject.Salesforce_Record_ID__c = 'test';         
            insert logObject;
			Test.startTest();
				Plative_PurgeLogsSchedulable purgeLogs = new Plative_PurgeLogsSchedulable();
				purgeLogs.execute(null);
            Test.stopTest();


	}
}