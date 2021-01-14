/**
 * Created by Nikhil on 17-11-2019.
 */

trigger FS_Opportunity_Product_BenefitsTrigger on Opportunity_Product_Benefits__c (before insert, before update, before delete,
        after insert, after update, after delete) {
    Framework.Dispatcher.dispatchTrigger();
}