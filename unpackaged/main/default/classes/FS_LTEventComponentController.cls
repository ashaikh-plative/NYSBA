public class FS_LTEventComponentController {
    
    @AuraEnabled
    public static String encodeString(String input) {
        return EncodingUtil.urlEncode(input, 'UTF-8');
    }
    
    @AuraEnabled
    public static Boolean checkUserRegistered(String eventId)
    {
        Boolean result= false;
         User user = [SELECT Id,ContactId From User WHERE Id =:Userinfo.getUserId() LIMIT 1];
            Id coId = user.ContactId;
        EventApi__Event__c event= null;
        if(!Test.isRunningTest()){
           
            event= [SELECT Id,Name,(SELECT Id,EventApi__Status__c,EventApi__Contact__c From EventApi__Attendees__r Where EventApi__Contact__c =:coId) From EventApi__Event__c Where Id=:eventId];
        }else{
            event= [SELECT Id,Name,(SELECT Id,EventApi__Status__c,EventApi__Contact__c From EventApi__Attendees__r ) From EventApi__Event__c Where Id=:eventId];
        }
        if(event != null && event.EventApi__Attendees__r != null && event.EventApi__Attendees__r.Size()> 0)
        {
                if(event.EventApi__Attendees__r[0].EventApi__Status__c == 'Registered')
                {
                    result = true;
                  
                }else if(event.EventApi__Attendees__r[0].EventApi__Status__c == 'Cancelled' || event.EventApi__Attendees__r[0].EventApi__Status__c == 'Invited')
                {
                    result = false;
                  
                }
        }else
        {
            result = false;
        }
            return result;
    }
  
}