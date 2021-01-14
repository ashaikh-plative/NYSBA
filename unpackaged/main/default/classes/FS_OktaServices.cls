public class FS_OktaServices implements Queueable, Database.AllowsCallouts {
    private static final String POST = 'POST';
    private static final String ACCEPT = 'Accept';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String AUTHORIZATION = 'Authorization';

    public static final Integer INVOKE_OKTA =  1;
    public static final Integer OKTA_ID_FROM_EMAIL = 2;

    private String contactId;
    private String userId;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private String op;
    private Integer method;

    private static Boolean isSandbox = true;

    static {
        List<Organization> org = [SELECT IsSandbox FROM Organization LIMIT 1];
        if (!org.isEmpty()) {
            isSandbox = org[0].IsSandbox;
        }
    }

    public FS_OktaServices(String contactId, String userId, String firstName, String lastName, String email, String password, String op,
            Integer method) {
        this.contactId = contactId;
        this.userId = userId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.password = password;
        this.op = op;
        this.method = method;
    }


    public void execute(QueueableContext context) {
        if (method == INVOKE_OKTA) {
            doInvokeOkta(contactId, userId, firstName, lastName, email, password, op);
        } else if (method == OKTA_ID_FROM_EMAIL) {
            //getOktaIdFromEmail(userId, email);
        }
    }

    @future(callout=true)
    public static void doInvokeOkta(String contactId, String userId, String firstName, String lastName, String email, String password, String op) {
        System.debug('Creating provisioning request in OKTA');
        System.debug('password' + password);
        FS_Okta_Callout_Setting__mdt oktaCalloutSetting = null;
        String endpoint = '';

        if (isSandbox) {
            oktaCalloutSetting = [SELECT Id, Header_Authorization__c, Endpoint_URL__c, User_Group__c FROM FS_Okta_Callout_Setting__mdt WHERE DeveloperName = 'Okta_API_Sandbox'][0];
            endpoint = 'callout:Okta_Sandbox' + oktaCalloutSetting.Endpoint_URL__c;
        } else {
            oktaCalloutSetting = [SELECT Id, Header_Authorization__c, Endpoint_URL__c, User_Group__c FROM FS_Okta_Callout_Setting__mdt WHERE DeveloperName = 'Okta_API_Production'][0];
            endpoint = 'callout:Okta_Production' + oktaCalloutSetting.Endpoint_URL__c;
        }

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            request.setMethod(POST);
            request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
            request.setHeader(ACCEPT, APPLICATION_JSON);
            request.setHeader(AUTHORIZATION, oktaCalloutSetting.Header_Authorization__c);

            // Set the body as a JSON object
            if (op == 'insert') {
                request.setEndpoint(endpoint);
                if (password == '' || password == null) {
                    request.setBody(
                        '{' +
                            '"profile":{' +
                                '"firstName":"' + firstName + '",' +
                                '"lastName":"' + lastName + '",' +
                                '"email":"' + email + '",' +
                                '"login":"' + email + '",' +
                                '"contactId":"' + contactId + '"' +
                            '},' +
                            '"groupIds":["' + oktaCalloutSetting.User_Group__c + '"]' +
                        '}'
                    );
                } else {
                    request.setBody(
                        '{' +
                            '"profile":{' +
                                '"firstName":"' + firstName + '",' +
                                '"lastName":"' + lastName + '",' +
                                '"email":"' + email + '",' +
                                '"login":"' + email + '",' +
                                '"contactId":"' + contactId + '"' +
                            '},' +
                            '"credentials":{' +
                                '"password":' +
                                    '{"value":"' + password + '"}' +
                            '},' +
                            '"groupIds":[' +
                                '"' + oktaCalloutSetting.User_Group__c + '"' +
                            ']' +
                        '}'
                    );
                 }
            }
//            else if (op == 'update'){
//                request.setEndpoint(oCallOutSettings.EndpointURL__c + '/' + password); //https://naa.oktapreview.com/api/v1/users/${oktaUserId}
//                request.setBody('{"profile": {"login": "' + email + '","email": "' + email + '"}}');
//            }

            System.debug('oCallOutSettings.EndpointURL__c == ' + endpoint);
            System.debug('auth == ' + oktaCalloutSetting.Header_Authorization__c);
            System.debug('body == ' + request.getBody());
            System.debug('password' + password);

            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('OKTA status code returned was not expected: ' +
                        response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
                //oktaUpdateFailed(userId, 'User creation/update failed in OKTA: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
            } else {
                System.debug('User Created/Updated in OKTA:' + response.getBody());
                updateOktaToUser(userId, response.getBody());
            }
        } catch (Exception ex) {
            System.debug('User creation/update failed in OKTA:' + ex.getMessage());
            //oktaUpdateFailed(userId, 'User creation/update failed in OKTA: ' + ex.getMessage());
        }
        //once user is created update Okta userId on SF User object or flag a field once created in Okta
    }

//    @future(callout=true)
//    public static void getOktaIdFromEmail(String userId, String email) {
//        System.debug('email' + email);
//
//        FS_Okta_Callout_Setting__mdt oktaCalloutSetting = null;
//
//        if (isSandbox) {
//            oktaCalloutSetting = [SELECT Id FROM FS_Okta_Callout_Setting__mdt WHERE DeveloperName = 'Okta_API_Sandbox'][0];
//        } else {
//            oktaCalloutSetting = [SELECT Id FROM FS_Okta_Callout_Setting__mdt WHERE DeveloperName = 'Okta_API_Production'][0];
//        }

//        try {
//            Http http = new Http();
//            HttpRequest request = new HttpRequest();
//
//            request.setMethod(POST);
//            request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
//            request.setHeader(ACCEPT, APPLICATION_JSON);
//            request.setHeader(AUTHORIZATION, oCallOutSettings.Header_Authorization__c);
//            request.setEndpoint(oCallOutSettings.EndpointURL__c + '/' + email);
//            request.setBody('{}');
//            HttpResponse response = new HttpResponse();
//            System.debug(request);
//            System.debug('Endpoint: ' + request.getEndpoint());
//            System.debug('Auth token: ' + request.getHeader(AUTHORIZATION));
//            System.debug('Accept: ' + request.getHeader(ACCEPT));
//            System.debug('Content Type: ' + request.getHeader(CONTENT_TYPE));
//            if (!Test.isRunningTest()) response = http.send(request);
//            // Parse the JSON response
//            if (response.getStatusCode() != 200) {
//                System.debug('OKTA status code returned was not expected: ' +
//                        response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody() );
//            } else {
//                System.debug('User Created/Updated in OKTA:' + response.getBody());
//                updateOktaToUser( userId, response.getBody());
//            }
//        } catch (Exception ex) {
//            System.debug('User creation/update failed in OKTA:' + ex.getMessage());
//
//        }
//    }
//    public static boolean doFindOktaUser(String email) {
////        FS_CalloutConfig__c oCallOutSettings = FS_CalloutConfig__c.getValues('OktaUserApi');
//
//        FS_CalloutConfig__c oCallOutSettings = null;
//
//        if (isSandbox){
//            oCallOutSettings = FS_CalloutConfig__c.getValues('OktaUserApiSandbox');
//        } else {
//            oCallOutSettings = FS_CalloutConfig__c.getValues('OktaUserApiProduction');
//        }
//
//        System.debug(oCallOutSettings.EndpointURL__c + '   ' + oCallOutSettings.Header_Authorization__c);
//        try {
//            Http http = new Http();
//            HttpRequest request = new HttpRequest();
//            String endPointQuery = oCallOutSettings.EndpointURL__c + '?q=' + EncodingUtil.urlEncode(email, 'UTF-8') + '&limit=1';
//            System.debug('endPoint URL == ' + endPointQuery);
//            request.setEndpoint(endPointQuery); //'https://fusionspan.okta.com/api/v1/users?q=eric&limit=1';
//            request.setMethod('GET');
//            request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
//            request.setHeader(ACCEPT, APPLICATION_JSON);
//            request.setHeader(AUTHORIZATION, oCallOutSettings.Header_Authorization__c);//'SSWS 00XtvuSJLWvyCHPeww8pFWpOLu4Uf4Xn8s6nMM5wJU');//Authorization: SSWS ${api_token}
//            // Set the body as a JSON object
//            HttpResponse response;
//            if(!test.isRunningTest()) response = http.send(request);
//            if (response.getStatusCode() == 200) {
//                System.debug('User Created in OKTA:' + response.getBody());
//                //TODO: if resposne size > 0
//            } else {
//                System.debug('OKTA status code returned was not expected: ' +
//                        response.getStatusCode() + ' ' + response.getStatus());
//            }
//        } catch (Exception ex) {
//            System.debug('User search failed in OKTA:' + ex.getMessage());
//        }
//        return false;
//    }
//
//    public static void assignUserGrouptoOktaUser(String firstName, String lastName, String email, String login, String phone) {
////        FS_CalloutConfig__c oCallOutSettings = FS_CalloutConfig__c.getValues('OktaUserApi');
//
//        FS_CalloutConfig__c oCallOutSettings = null;
//
//        if (isSandbox){
//            oCallOutSettings = FS_CalloutConfig__c.getValues('OktaUserApiSandbox');
//        } else {
//            oCallOutSettings = FS_CalloutConfig__c.getValues('OktaUserApiProduction');
//        }
//
//        Http http = new Http();
//        HttpRequest request = new HttpRequest();
//        request.setEndpoint(oCallOutSettings.EndpointURL__c + '?activate=false'); //'https://fusionspan.okta.com/api/v1/users'
//        request.setMethod(POST);
//        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
//        request.setHeader(ACCEPT, APPLICATION_JSON);
//        request.setHeader(AUTHORIZATION, oCallOutSettings.Header_Authorization__c);//'SSWS 00XtvuSJLWvyCHPeww8pFWpOLu4Uf4Xn8s6nMM5wJU');//Authorization: SSWS ${api_token}
//
//        //('{"profile": {"firstName": ,  "lastName":,   "email":, "login": "'+ email + '" }}')
//
//        // Set the body as a JSON object
//        request.setBody('{"profile": {"firstName":"' + firstName + '","lastName": "' + lastName + '","email": "' + email + '","login": "' + login + '","mobilePhone": "' + phone + '"},"groupIds": ["' + oCallOutSettings.User_Group__c + '"]}');
//        HttpResponse response;
//        if(!test.isRunningTest()) response= http.send(request);
//        if (!test.isRunningTest() && response.getStatusCode() != 200) {
//            System.debug('response == ' + response.getBody());
//        }
//    }

    public static void updateOktaToUser(String userId, String response) {
        try {
            String oktaId = '';
            JSONParser parser = JSON.createParser(response);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                    parser.nextToken();
                    System.debug('parser.getIdValue() INSIDE IF => ' + parser.getText());
                    oktaId = parser.getText();
                    break;
                }
            }

            User user = new User(
                    Id = userId,
                    Okta_ID__c = oktaId
            );
            update user;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
        }
    }
//
//    public static void oktaUpdateFailed(String userId, String response) {
//        User oUser = new User(Id=(Id)userId, FS_Username_Update_Error__c=true,
//                FS_Username_Update_Error_Reason__c=response);
//        update oUser;
//    }
}