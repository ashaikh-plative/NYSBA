/**
 *  @author:        cubiascaceres
 *  @date:          2019.Nov.18
 *  @description:   used to wrap all objects required on the init method on Attorney Application Summary
 */
public class FS_AttorneySummaryWrapper {

    @AuraEnabled
    public List<FS_Membership_Join_Dues_Category__mdt> duesCategoryList {get; set;}

    @AuraEnabled
    public OrderApi__Sales_Order__c salesOrder {get; set;}

    @AuraEnabled
    public Double membershipBillAmount {get; set;}

    @AuraEnabled
    public Date effectiveUntil {get; set;}

    @AuraEnabled
    public Boolean hasVoluntaryCharitable {get; set;}

    @AuraEnabled
    public Double amountVoluntaryCharitable {get; set;}

    @AuraEnabled
    public Double totalSalesOrder {get; set;}
}