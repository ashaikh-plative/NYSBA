public class FS_HeaderController {

    @AuraEnabled
    public static String decodeString(String input) {
        return EncodingUtil.urlDecode(input, 'UTF-8');
    }

    @AuraEnabled
    public static String encodeString(String input) {
        return EncodingUtil.urlEncode(input, 'UTF-8');
    }
    
    private static final String ACTIVE_STRING = 'Active';
    private static final String EXPIRED_STRING = 'Expired';
    private static final String GRACE_STRING = 'Grace';
    private static final String LAW_STUDENT_STRING = 'Law student';

    @AuraEnabled
    public static Map<String, Object> isJoinMembershipUser(String userIdParam){
        Map<String, Object> result = new Map<String, Object>();
        Boolean isRenew = false;
        Boolean isJoinRenew = true;
        Boolean hasProforma = true;

        if(String.isNotBlank(userIdParam)){
            List<User> userList=[SELECT Id, ContactId, FirstName FROM User WHERE Id =:userIdParam LIMIT 1];

            if(userList != null && userList.size() == 1 && String.isNotBlank(userList[0].ContactId)){
                result.put('currentUser', String.isNotBlank(userList[0].FirstName) ? userList[0].FirstName : '');
                List<OrderApi__Sales_Order__c> salesOrderList = [SELECT Id,(SELECT Id,OrderApi__Is_Renewal__c,
                                    OrderApi__Subscription_Plan__c,OrderApi__Item__c FROM OrderApi__Sales_Order_Lines__r WHERE OrderApi__Is_Renewal__c = TRUE AND
                                    OrderApi__Subscription_Plan__c != NULL AND OrderApi__Item__r.OrderApi__Is_Subscription__c = TRUE) FROM OrderApi__Sales_Order__c WHERE 
                                    OrderApi__Contact__c =:userList[0].ContactId AND OrderApi__Status__c ='Closed' AND OrderApi__Posting_Status__c ='Pending'];

                for(OrderApi__Sales_Order__c salesOrder : salesOrderList) {
                    if (salesOrder.OrderApi__Sales_Order_Lines__r.size()>0) {
                        hasProforma=true;
                        break;
                    }
                }
                if(salesOrderList.isEmpty()){
                    hasProforma=false;
                }

                for(Contact con:[SELECT Id,FS_CountryofOrigin__c,FS_Contact_Member_Status__c,FS_Membership_Days_to_Expire__c,FS_Membership_Expiry_Date__c,
                        FS_Membership_Type__c,(SELECT Id,OrderApi__Paid_Through_Date__c,OrderApi__Days_To_Lapse__c FROM OrderApi__Subscriptions__r)
                FROM Contact WHERE Id=:userList[0].ContactId]){
                    if(con.FS_Membership_Type__c == LAW_STUDENT_STRING){
                        isJoinRenew = false;
                    }else if((con.FS_Contact_Member_Status__c == ACTIVE_STRING && hasProforma) || (con.FS_Contact_Member_Status__c == GRACE_STRING) ){
                        isRenew = true;
                    }else if(con.FS_Contact_Member_Status__c == ACTIVE_STRING && !hasProforma){
                        isJoinRenew = false;
                    }
                    else if(con.FS_Contact_Member_Status__c == EXPIRED_STRING || con.FS_Contact_Member_Status__c == NULL){
                        isRenew = false;
                    }
                }


            }
        }
        result.put('isRenew', isRenew);
        result.put('isJoinRenew', isJoinRenew);
        return result;
    }
}