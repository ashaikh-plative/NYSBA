/**
 * Created by Anvesh on 07-Dec-20.
 */

public class FS_CalendarInviteController {

    public String getSummary() {
        return summary;
    }

    public String getEndDate() {
        return endDate;
    }
    public String getStartDate() {
        return startDate;
    }

    private static String startDate;
    private static String endDate;
    private static String summary;
   
    public FS_CalendarInviteController(){
        ApexPages.currentPage().getHeaders().put('content-disposition','inline; filename = CalendarEvent.ics');
        try{
            String currentParam = ApexPages.currentPage().getParameters().get('Id');
            if(currentParam != null){
                EventApi__Event__c event  = [SELECT Id,Name,EventApi__Start_Date_Time__c,EventApi__End_Date_Time__c FROM EventApi__Event__c WHERE Id =: currentParam];

                startDate = event.EventApi__Start_Date_Time__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
                endDate = event.EventApi__End_Date_Time__c.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
                summary = event.Name;
            }
        }catch (Exception e){
            System.debug('Error in finding the event details'+e.getMessage());
        }
    }
}