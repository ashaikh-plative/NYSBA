/**
 *  @author:        cubiascaceres
 *  @date:          2019.10.03
 *  @desciption:    Test Class for FS_CustomLookupController
 */
@isTest
public class FS_CustomLookupControllerTest {

    @TestSetup
    static void initData() {
        List<Account> universityList = new List<Account>();
        Account chicagoUniversity = new Account();
        chicagoUniversity.Name = 'Chicago University';
        universityList.add(chicagoUniversity);
        Account virginiaUniversity = new Account();
        virginiaUniversity.Name = 'Virginia University';
        universityList.add(virginiaUniversity);
        Account hardvardUniversity = new Account();
        hardvardUniversity.Name = 'Hardavard University';
        universityList.add(hardvardUniversity);
        insert universityList;
    }

    @IsTest
    static void fetchRecordsByIdTest() {        
        Test.startTest();
        Account chicagoUniversity = [SELECT Id FROM Account WHERE Name = 'Chicago University' LIMIT 1];
        List<FS_CustomLookupController.RecordsData> returnList = FS_CustomLookupController.fetchRecords('Account', 'Name', 'University', chicagoUniversity.Id, null);
        Test.stopTest();     
        System.assertEquals(1, returnList.size(), 'Chicago University record not found');   
    }

    @IsTest
    static void fetchRecordsExceptionTest(){
        Test.startTest();
        String errorType;
        try {
            List<FS_CustomLookupController.RecordsData> returnList = FS_CustomLookupController.fetchRecords('TablesDoesNotExists', 'Name', 'University', null, null);
        } catch (Exception e) {
            errorType = e.getTypeName();
        }              
        Test.stopTest();
        System.assertEquals('System.AuraHandledException', errorType);
    }

    @IsTest
    static void fetchRecordsByNameTest(){
        
        Test.startTest();
        List<FS_CustomLookupController.RecordsData> returnList = FS_CustomLookupController.fetchRecords('Account', 'Name', 'University', null, null);
        Test.stopTest();
        System.assertEquals(3, returnList.size(), 'Three records should be returned');
        
    }
}