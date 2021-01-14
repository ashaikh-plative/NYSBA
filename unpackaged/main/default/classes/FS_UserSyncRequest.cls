public class FS_UserSyncRequest {
    
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    @future(callout=true)
    public static void oktaSync(List<String> userIdList) {
        oktaSyncWorker(userIdList);
    }

    /**
     * This is a non future method for calls in Batch Classes.
     *
     * @param userIdList
     */
    public static void oktaSyncWorker(List<String> userIdList) {
        // If no Ids are provided, exit process
        if (userIdList.isEmpty()) {
            return;
        }
        String userApibaseUrl = 'callout:FS_Hub_user_api_live';

        if (isSandbox()) {
            userApibaseUrl =  'callout:FS_Hub_user_api_staging';            
        }
        String endpoint = userApibaseUrl + '/users/createOrUpdate/';

        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);
        String userIdAsArray = JSON.serialize(userIdList);
        request.setBody(userIdAsArray);

        //set the API KEY
        request.setHeader('api_key', '{!$Credential.Password}');
        // Set the HTTP verb to POST.
        request.setMethod('POST');
        // Send the HTTP request and get the response.
        HttpResponse response = new HTTP().send(request);
    }

    /**
     * Calls out to BizHub to reset the password of the end user.
     *
     * @param OktaId - The OKTA id of the user whose password should be reset.
     *
     * @return An empty string in the event of success or the body of the response in the event of an error.
     */
    public static String resetUserPassword(String OktaId){
        String userApibaseUrl;

        if (!isSandbox()) {
            userApibaseUrl =  'callout:FS_Hub_user_api_live';
        } else {
            userApibaseUrl =  'callout:FS_Hub_user_api_staging';
        }

        String endpoint = userApibaseUrl + '/users/resetPassword/' + OktaId;

        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);

        //set the API KEY
        request.setHeader('api_key', '{!$Credential.Password}');

        request.setMethod('POST');
        // Send the HTTP request and get the response.
        HttpResponse response = new HTTP().send(request);

        if(response.getStatusCode() != 200) {
            System.debug(LoggingLevel.ERROR, 'Error occurred when resetting password: ' + response.getStatusCode());
            System.debug(LoggingLevel.ERROR, response.getBody());
            return response.getBody();
        } else {
            return '';
        }

    }
}