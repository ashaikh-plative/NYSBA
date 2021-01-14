public class FS_ContactWrapper {

    @AuraEnabled
    public Contact userContact {get; set;}

    @AuraEnabled
    public String userContactPreferredPhone {get; set;}

    @AuraEnabled
    public String userContactPreferredEmail {get; set;}

    @AuraEnabled
    public String preferredMailAddress {get; set;}

    @AuraEnabled
    public String preferredBillAddress {get; set;}

    @AuraEnabled
    public Boolean isYoungLawyer {get; set;}

    @AuraEnabled
    public String lawStudentItemId {get; set;}

}