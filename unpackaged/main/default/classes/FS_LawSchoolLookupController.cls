public without sharing class FS_LawSchoolLookupController {

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {

        //string lawSchool = 'Law School';
        
        List<RecordType> recordTypeId = [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Account' 
            AND RecordType.DeveloperName = 'FS_Educational_Institution' 
            AND IsActive = TRUE
        ]; //Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FS_Educational_Institution').getRecordTypeId();

        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        //String sQuery =  'select id, Name from ' + ObjectName + ' where  LIKE: searchKey order by createdDate DESC limit 5';
        String sQuery = 'SELECT Id, Name FROM ' + ObjectName + ' WHERE RecordTypeId=\'' + recordTypeId[0].Id + '\' AND FS_Accredited__c=true AND FS_School_Type__c=\'Law School\' AND Name LIKE ' + '\'%' + searchKey + '%\'order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static Account getRecord(String accId) {
        Account a = [SELECT Id, Name FROM Account WHERE Id = :accId];

        return a;
    }
}



//SELECT Id, Name FROM account WHERE FS_Accredited__c=true AND FS_School_Type__c='Law School' HAVING RecordTypeId='0121U000000WtUHQA0' order by createdDate DESC limit 5