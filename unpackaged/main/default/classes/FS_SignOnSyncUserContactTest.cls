@IsTest
public class FS_SignOnSyncUserContactTest{
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @IsTest
    private static void isActiveUser(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        ContactToUserFieldMapping__c oContactCustomSettings = new ContactToUserFieldMapping__c();
        oContactCustomSettings.Name = 'lastNameField';
        oContactCustomSettings.Is_Formula_Field__c = false ;
        oContactCustomSettings.IsActive__c= true ;
        oContactCustomSettings.UserField__c = 'LastName' ;
        oContactCustomSettings.ContactField__c = 'LastName';
        insert oContactCustomSettings;
        
        Account a = FS_TestUtils.createAccount('TestAccountFS');
        insert a;
        Account a2 = FS_TestUtils.createAccount('Ravi Test1 Household');
        insert a2;
        
        List<Contact> oContactList  = new List<Contact>();
        Contact oContact1 = FS_TestUtils.createContact('testoContact1','fsSubsTest2@exampleFS.com');
        oContact1.AccountId =a.Id;
        oContact1.OrderApi__Preferred_Email_Type__c = 'Personal';
        oContact1.OrderApi__Personal_Email__c = 'test98@FS1.com';
        oContact1.OrderApi__Work_Email__c = 'testWorkEmail48@FS2.com';
        oContact1.Email = 'test88@FS.com';
        oContactList.add(oContact1);
        System.debug('LL29');
        Contact oContact2 = FS_TestUtils.createContact('testing123','ravitest+test@fs.com');
        oContact2.AccountId =a2.Id;
        oContact2.OrderApi__Preferred_Email_Type__c = 'Personal';
        oContact2.OrderApi__Personal_Email__c = 'test@FS5.com';
        oContact2.OrderApi__Work_Email__c = 'testWorkEmail3@FS6.com';
        oContactList.add(oContact2);
        
        insert oContactList;
        
        ID adminProfileId = [SELECT Id,Name FROM Profile WHERE Name='System Administrator'].ID;  
        ID communityProfileId = [SELECT Id,Name FROM Profile WHERE Name='Fonteva Customer Community Login User'].ID;
        
        List<User> oUserList = new List<User>();
        User u1 = createTestUser( adminProfileId, 'fusion889', 'Test889');
        oUserList.add( u1 );
        User u21 = createTestUser( adminProfileId, 'fusion78898', 'Test45545');
        oUserList.add(u21);
        User ucc =  createTestUser(communityProfileId, 'prathik2233', 'fusionspan152');
        ucc.ContactId =oContact2.Id;
        ucc.userName = oContact2.Email;
        oUserList.add( ucc); 
        
        insert oUserList;
          system.runAs(u1){
            
            List<Contact> oContact_NewList = new List<Contact>();
            oContact1.Email = 'New_'+oContact1.Email;            
            oContact1.OrderApi__Personal_Email__c = 'New_'+oContact1.OrderApi__Personal_Email__c;
            oContact1.OrderApi__Work_Email__c = 'New_'+oContact1.OrderApi__Work_Email__c;
            oContact1.AccountId = a2.Id;
            oContact_NewList.add(oContact1);
            oContact2.Email = 'New_'+oContact2.Email;            
            oContact2.OrderApi__Personal_Email__c = 'New_'+oContact2.OrderApi__Personal_Email__c;
            oContact2.OrderApi__Work_Email__c = 'New_'+oContact2.OrderApi__Work_Email__c;
            oContact2.AccountId = a2.Id;
            oContact_NewList.add(oContact2); 
            update oContact_NewList;          
        }           
        
        List<User> userList= [SELECT Id, ContactId, IsActive from User where  ContactId =:oContact2.Id];
        System.assertEquals(userList[0].Id, ucc.Id);
        FS_SignOnSyncUserContact.getUserIdOfContact(oContact2.Id);
        FS_SignOnSyncUserContact.processSyncUser(userList[0].Id);
        Test.stopTest();
    }
    private static User createTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = 
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              //email ='ravi+test@fs.com',
                              Username = uniqueName + '@test' + orgId + '.org',
                              //Username ='ravi+test@fs.com',
                              EmailEncodingKey = 'ISO-8859-1',
                              //Alias = uniqueName.substring(18, 23),
                              Alias = 'ravi',
                              // TimeZoneSidKey = 'America/Los_Angeles',
                              TimeZoneSidKey ='America/Panama',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId);
        return tuser;
    }
    
}