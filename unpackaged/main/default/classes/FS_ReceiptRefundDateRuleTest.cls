/**
 * Created by daweima on 6/4/20.
 */

@IsTest
public without sharing class FS_ReceiptRefundDateRuleTest {

    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        ROEApi.PackageScripts.install();
        CPBase.PackageScripts.install();
        LTE.PackageScripts.install();
        FDService.BUPackageScripts.install();
        DonorApi.PackageScripts.install();
        joinapi.PackageScripts.install();
        PriceApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_ReceiptRefundDateRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Receipt__c';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);

    }
    @IsTest
    public static void test(){
        OrderApi__Receipt__c r = new OrderApi__Receipt__c(OrderApi__Type__c='Refund',OrderApi__Is_Refund__c=true,
        OrderApi__Is_Posted__c=false, OrderApi__Date__c=System.today());
        insert r;

        r.OrderApi__Is_Posted__c = true;
        update r;

    }
}