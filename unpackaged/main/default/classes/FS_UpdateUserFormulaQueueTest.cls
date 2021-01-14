@IsTest
public class FS_UpdateUserFormulaQueueTest {

    @IsTest
    private static void testCallout() {
        FS_UpdateUserFormulaFieldsTest.runCallOut = true;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        FS_UpdateUserFormulaFieldsQueue queueable = new FS_UpdateUserFormulaFieldsQueue(new List<String>{'123'});
        queueable.execute(null);
        Test.stopTest();
        FS_UpdateUserFormulaFieldsTest.runCallOut = false;
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            System.debug('Received callout in mock');
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('POST', req.getMethod());
            // System.assert(req.getEndpoint().indexOf('123')>0);

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}