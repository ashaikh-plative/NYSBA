@isTest
public class FS_UserSyncRequestTest {

    @TestVisible
    private static final String OKTA_USER_ID = '225y3455';

    @IsTest
    private static void testOktaSyncExpectNoExceptionsThrown() {
        Test.setMock(HttpCalloutMock.class, new MockOKTASyncHttpResponseGenerator());
        FS_UserSyncRequest.oktaSync(new List<String>{OKTA_USER_ID});
    }


    @IsTest
    private static void oktaResetPasswordValidUserExpectSuccess() {

        Test.setMock(HttpCalloutMock.class, new MockPasswordResetResponseGenerator());
        String response = FS_UserSyncRequest.resetUserPassword(OKTA_USER_ID);

        System.assert(response == '');

    }

    @IsTest
    private static void oktaResetPasswordBadUserExpectSuccess() {

        Test.setMock(HttpCalloutMock.class, new MockPasswordResetResponseGenerator());
        String response = FS_UserSyncRequest.resetUserPassword('382345');

        System.assert(response != '');

    }

    @TestVisible
    private class MockOKTASyncHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('Received callout in mock');
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('POST', req.getMethod());
            // System.assert(req.getEndpoint().indexOf(OKTA_USER_ID) > 0);

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestVisible
    private class MockPasswordResetResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('Received callout in mock');
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('POST', req.getMethod());

            if(req.getEndpoint().indexOf(OKTA_USER_ID) > 0) {
                // Create a fake success response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{}');
                res.setStatusCode(200);
                return res;
            } else {
                // Create a fake failure response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{' +
                        '"errorCauses": [], ' +
                        '"errorCode": "E0000007",' +
                        '"errorId": "oaeyw9EwsYJTva0icVdf76s4A",' +
                        '"errorLink": "E0000007",' +
                        '"errorSummary": "Not found: Resource not found: 00upn4w5xioaPtOha0h8 (User)"' +
                        '}'
                );
                res.setStatusCode(404);

                return res;
            }
        }
    }
}