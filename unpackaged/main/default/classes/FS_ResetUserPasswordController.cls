/**
 * Created by Jason Cookman on 2/9/20.
 */

public without sharing class FS_ResetUserPasswordController {

    /**
     * Gets the OKTA Id of the user assoicated with this contact.
     *
     * @param ContactId - Id of the selected contact
     *
     * @return - OKTA Id of the User associated with this contact. If there is no OKTA Id, return null
     */
    @AuraEnabled
    public static String getOKTAIdOfContact(String ContactId) {

        List<User> okta = [
                SELECT Okta_ID__c
                FROM User
                WHERE ContactId = :ContactId
                AND IsActive = TRUE
                LIMIT 1
        ];

        if(okta.size() == 0) {
            return null;
        }

        return okta[0].Okta_ID__c;
    }


    /**
     * Calls out to BizHub to reset the password of the end user.
     *
     * @param OktaId - The OKTA id of the user whose password should be reset.
     *
     * @return An empty string in the event of success or the body of the response in the event of an error.
     */
    @AuraEnabled
    public static String resetUserPassword(String oktaId){
        return FS_UserSyncRequest.resetUserPassword(oktaId);
    }
}