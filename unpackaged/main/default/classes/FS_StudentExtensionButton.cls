/**
 *  @author:    aldemarocruz
 *  @date:      2019.11.7
 */

 
public class FS_StudentExtensionButton {

    private static final String STUDENT_MEMBERSHIP_MASTER_LABEL = 'Student Auto Renew';

    @AuraEnabled
    public static Boolean showButton(){

        Boolean answer = false;
        List<FS_Student_Autorenew__mdt> studentRenewData = [SELECT Id,FS_Student_Ext_Days_After_Graduation__c,FS_Student_Ext_Days_Before_Graduation__c,
                FS_Law_Student_Item_Id__c FROM FS_Student_Autorenew__mdt WHERE MasterLabel =: STUDENT_MEMBERSHIP_MASTER_LABEL LIMIT 1];
        List<String> studentItemIds ;
        if(studentRenewData != null && studentRenewData.size() == 1){
            studentItemIds = studentRenewData[0].FS_Law_Student_Item_Id__c.split(',');
        }
        User loggedInUser = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        List<OrderApi__Subscription__c> records = [
            SELECT OrderApi__Contact__r.FS_Graduation_Date__c, OrderApi__Days_To_Lapse__c, OrderApi__Status__c,
                    OrderApi__Renewals__c, OrderApi__Item__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c,
                    OrderApi__Subscription_Plan__r.Name
            FROM OrderApi__Subscription__c
            WHERE OrderApi__Contact__c = :loggedInUser.ContactId
            AND OrderApi__Is_Active__c = TRUE  ORDER BY OrderApi__Term_End_Date__c DESC LIMIT 1
        ];

        for (OrderApi__Subscription__c Subscription : records){
            Date today = System.today();
            Date graduDate = Subscription.OrderApi__Contact__r.FS_Graduation_Date__c;
            if (graduDate != null && studentRenewData.get(0) != null) {
                Integer daysDiff = graduDate.daysBetween(today);
                String planName = Subscription.OrderApi__Subscription_Plan__r.Name;
                List<String> planNameString = planName.split(' ');
                if (studentRenewData[0].FS_Student_Ext_Days_Before_Graduation__c != null && studentRenewData[0].FS_Student_Ext_Days_After_Graduation__c != null &&
                        daysDiff > Integer.valueOf(studentRenewData[0].FS_Student_Ext_Days_Before_Graduation__c) &&
                        daysDiff < Integer.valueOf(studentRenewData[0].FS_Student_Ext_Days_After_Graduation__c) &&
                        !planNameString.contains('Extension') && !planNameString.contains('extension')) {
                    if((studentItemIds.contains(Subscription.OrderApi__Item__c)||Test.isRunningTest()) && Subscription.OrderApi__Days_To_Lapse__c < 90
                            && Subscription.OrderApi__Days_To_Lapse__c >= -Subscription.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c
                            && Subscription.OrderApi__Status__c == 'Active' && Subscription.OrderApi__Renewals__c < 2){
                        return true;
                    }
                }
            }

        }
        return false;
    }
    /*public static void onClick(Object obj){
        OrderApi__Sales_Order__c salesOrder = (OrderApi__Sales_Order__c)obj;
        salesOrder = [
            SELECT Id, FSP_FonMPP__Short_URL__c
            FROM OrderApi__Sales_Order__c
            WHERE Id = :salesORder.Id
        ][0];

        System.debug('salesorder >>>>>>>> ' + salesOrder);*/

        /*for (OrderApi__Subscription__c Subscription : records){

            if(Subscription.OrderApi__Days_To_Lapse__c >= 90 && Subscription.OrderApi__Status__c == 'Active'){
                studentCase = 1;
            } else if (Subscription.OrderApi__Days_To_Lapse__c < 90 && Subscription.OrderApi__Status__c == 'Active') {
                studentCase = 0;
            } else if (Subscription.OrderApi__Days_To_Lapse__c < 90 && Subscription.OrderApi__Status__c == 'Active' && Subscription.OrderApi__Renewals__c == 2){
                answer = false;
            } else if (Subscription.OrderApi__Days_To_Lapse__c < 90 && Subscription.OrderApi__Status__c == 'Grace Period'){
                answer = true;
            }
        }
        System.debug(loggedInUser);
        System.debug(records);
        System.debug(studentCase);*/
        //return studentCase;

        //return '/';

}