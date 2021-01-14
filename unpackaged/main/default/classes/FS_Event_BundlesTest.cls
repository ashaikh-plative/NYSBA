/**
 * Created by Anvesh on 02-Sep-20.
 */
@IsTest
public with sharing class FS_Event_BundlesTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_EventBundleRule = new Framework.RoutingRule();
        FS_EventBundleRule.apexClass = FS_Event_Bundles.class.getName();
        FS_EventBundleRule.namespace = '';
        FS_EventBundleRule.isEnabled = true;
        FS_EventBundleRule.sObjectName = 'FS_Event_Bundle__c';
        FS_EventBundleRule.executionOrder = 10;
        rules.add(FS_EventBundleRule);
        Framework.Config.push(rules);
    }
    @IsTest
    static void eventBundleTestInsert(){

        //Inserting Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
                Name = 'SSC');
        insert itemClass;

        List<OrderApi__Item__c> itemsList = new List<OrderApi__Item__c>();
        //Inserting Items
        OrderApi__Item__c item = new OrderApi__Item__c(
                Name = 'TextBooks',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Event__c = true);
        itemsList.add(item);

        OrderApi__Item__c item1 = new OrderApi__Item__c(
                Name = 'TextEvent',
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Event__c = true);
        itemsList.add(item1);
        insert itemsList;

        FS_Event_Bundle__c eventBundle = new FS_Event_Bundle__c (FS_Parent_Item__c = item.Id);
        insert eventBundle;

        List<FS_Event_Bundle__c>  eventBundleList = [SELECT Id,FS_Parent_Item__c FROM FS_Event_Bundle__c WHERE Id =: eventBundle.Id];

        FS_Event_Bundles fsEventBundles = new FS_Event_Bundles (eventBundleList);
        FS_Event_Bundles.Constructor cons = new FS_Event_Bundles.Constructor();
        cons.construct(eventBundleList);
        Framework.Dispatcher.dispatchTrigger();
    }
}