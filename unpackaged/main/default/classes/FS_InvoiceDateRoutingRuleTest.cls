/**
 * Created by daweima on 6/12/20.
 */
@IsTest
public without sharing class FS_InvoiceDateRoutingRuleTest {
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
        routingRule.apexClass = FS_InvoiceDateRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Invoice__c';
        routingRule.executionOrder = 10;
        rules.add(routingRule);
        Framework.Config.push(rules);

    }
    @IsTest
    public static void testInvoicePostDateExpectedToday(){
        OrderApi__Receipt__c r = new OrderApi__Receipt__c(OrderApi__Type__c='Refund',OrderApi__Is_Refund__c=true,
                OrderApi__Is_Posted__c=false, OrderApi__Date__c=System.today());
        insert r;

        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();
        insert pm;

        OrderApi__Scheduled_Payment__c sp = new OrderApi__Scheduled_Payment__c(OrderApi__Payment_Method__c = pm.Id);
        insert sp;

        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c(OrderApi__Invoice_Date__c = System.today());
        insert invoice;

        invoice.OrderApi__Paid_Date__c = System.today()-1;
        invoice.OrderApi__Status__c = 'Paid';
        invoice.OrderApi__Scheduled_Payment__c = sp.Id;

        update invoice;

        System.assertEquals(System.today(), invoice.OrderApi__Invoice_Date__c);
    }

    @IsTest
    public static void testReceiptDateToToday(){
        OrderApi__Receipt__c r = new OrderApi__Receipt__c(OrderApi__Type__c='Refund',OrderApi__Is_Refund__c=true,
                OrderApi__Is_Posted__c=false, OrderApi__Date__c=System.today());
        insert r;

        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();
        insert pm;

        OrderApi__Scheduled_Payment__c sp = new OrderApi__Scheduled_Payment__c(OrderApi__Payment_Method__c = pm.Id);
        insert sp;

        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c(OrderApi__Invoice_Date__c = System.today());
        insert invoice;

        invoice.OrderApi__Paid_Date__c = System.today()-1;
        invoice.OrderApi__Status__c = 'Paid';
        invoice.OrderApi__Scheduled_Payment__c = sp.Id;

        update invoice;

        OrderApi__Receipt__c updateR = [SELECT OrderApi__Date__c FROM OrderApi__Receipt__c WHERE Id = :r.Id];
        System.assertEquals(System.today(), updateR.OrderApi__Date__c);
    }

    @IsTest
    public static void testTransAndLineDateEqualToday(){
        OrderApi__Receipt__c r = new OrderApi__Receipt__c(OrderApi__Type__c='Refund',OrderApi__Is_Refund__c=true,
                OrderApi__Is_Posted__c=false, OrderApi__Date__c=System.today());
        insert r;

        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();
        insert pm;

        OrderApi__Scheduled_Payment__c sp = new OrderApi__Scheduled_Payment__c(OrderApi__Payment_Method__c = pm.Id);
        insert sp;

        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c(OrderApi__Invoice_Date__c = System.today());
        insert invoice;

        OrderApi__Receipt_Line__c rl = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c = r.Id, OrderApi__Invoice__c = invoice.Id);
        insert rl;

        OrderApi__Transaction__c trans = new OrderApi__Transaction__c(OrderApi__Date__c=System.today()-1, OrderApi__Receipt__c = r.Id, OrderApi__Invoice__c = invoice.Id);
        insert trans;

        OrderApi__Transaction_Line__c transLine = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c = trans.Id, OrderApi__Invoice__c = invoice.Id);
        insert transLine;

        invoice.OrderApi__Paid_Date__c = System.today()-1;
        invoice.OrderApi__Status__c = 'Paid';
        invoice.OrderApi__Scheduled_Payment__c = sp.Id;

        update invoice;

        OrderApi__Transaction__c updatedTransaction = [SELECT OrderApi__Date__c FROM OrderApi__Transaction__c WHERE Id = :trans.Id][0];
        OrderApi__Transaction_Line__c updatedTransactionLine = [SELECT OrderApi__Date__c FROM OrderApi__Transaction_Line__c WHERE Id = :transLine.Id][0];

        System.assertEquals(System.today(), updatedTransaction.OrderApi__Date__c);
        System.assertEquals(System.today(), updatedTransactionLine.OrderApi__Date__c);
    }
}