@IsTest
public class FS_UserTriggerTest {
    private static String userId = 'notSet';
    private static Integer mockUserServiceCounter = 0;
    public static Boolean runCallOut = false;

    @TestSetup
    static void initData() {
        Account communityAccount = new Account(name = 'communityAccount');//create a portal account first
        insert communityAccount;
        Contact  communityContact  = new contact(LastName = 'communityContact', AccountId = communityAccount.Id); //create a portal contact
        insert communityContact;
    }

    @IsTest 
    static void testCreateCommunityUser() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        User newUser = createUserWithProfile('%Customer Community Login%');

        Test.stopTest();

        System.assertEquals(1, mockUserServiceCounter);
    }

    @IsTest 
    static void testUpdate() {
        runCallOut = true;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        User newUser = createUserWithProfile('%Customer Community Login%');

        //have to do this to avoid mixed DML error
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            update newUser;
        }

        Test.stopTest();

        System.assertEquals(1, mockUserServiceCounter);
        runCallOut = false;
    }


    private static User createUserWithProfile(String profileName){
        runCallOut = true;
        Account communityAccount = [SELECT Id, Name FROM Account WHERE Name = 'communityAccount'];
        Contact  communityContact  = [SELECT Id, LastName FROM Contact WHERE LastName = 'communityContact' AND AccountId = :communityAccount.Id];


        User newUser = new User(
                ProfileId = [SELECT Id,name FROM Profile where name like :profileName Limit 1].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ContactId = communityContact.Id);

        insert newUser;
        userId = newUser.Id;
        runCallOut = false;
        return newUser;
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            System.debug('Received callout in mock');
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('POST', req.getMethod());
            // System.assert(req.getEndpoint().indexOf(userId)>0);
            //log that the hub user service received a request
            mockUserServiceCounter++;

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}