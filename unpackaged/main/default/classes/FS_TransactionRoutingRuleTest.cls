/**
 * Created by Seshu on 13-10-2020.
 */

@IsTest
private class FS_TransactionRoutingRuleTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule transactionRule = new Framework.RoutingRule();
        transactionRule.apexClass = FS_TransactionRoutingRule.class.getName();
        transactionRule.namespace = ' ';
        transactionRule.isEnabled = true;
        transactionRule.sObjectName = SObjectType.OrderApi__Transaction__c.getName();
        transactionRule.executionOrder = 20;
        rules.add(transactionRule);
        Framework.Config.push(rules);

        //Account
        Account acc=FS_TestUtils.createAccount('Testing');
        insert acc;

        //Contact
        Contact contact = FS_TestUtils.createContact('TestContact','test@gmail.com');
        insert contact;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(contact.Id,acc.Id,'Receipt','Open');
        insert salesOrder;

        //ItemClass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('TestItemClass');
        insert itemClass;

        //item
        OrderApi__Item__c item = FS_TestUtils.createItem('TestItem',itemClass.Id);
        insert item;

        //salesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = FS_TestUtils.createSalesOrderLine(item.Id,salesOrder.Id,contact.Id,acc.Id);
        insert salesOrderLine;
    }

    @IsTest
    private  static void updateTransactionDateWithCaptureEpayment(){
        Test.startTest();
        Account account = [SELECT Id FROM Account WHERE Name='Testing' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName='TestContact' LIMIT 1];
        OrderApi__Sales_Order__c salesOrder = [SELECT Id,OrderApi__Status__c,OrderApi__Posting_Status__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:contact.Id LIMIT 1];
        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        OrderApi__EPayment__c ePaymentOne = new OrderApi__EPayment__c();
        ePaymentOne.OrderApi__Transaction_Type__c = 'Authorization';
        ePaymentOne.OrderApi__Sales_Order__c = salesOrder.Id;
        ePaymentOne.OrderApi__Date__c = System.today().addMonths(1);
        insert ePaymentOne;

        //epayment
        OrderApi__EPayment__c ePaymentTwo = new OrderApi__EPayment__c();
        ePaymentTwo.OrderApi__Transaction_Type__c = 'Capture';
        ePaymentTwo.OrderApi__Sales_Order__c = salesOrder.Id;
        ePaymentTwo.OrderApi__Date__c = System.today().addMonths(1);
        ePaymentTwo.OrderApi__EPayment__c = ePaymentOne.Id;
        insert ePaymentTwo;

        //Receipt
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Account__c = account.Id;
        receipt.OrderApi__Contact__c = contact.Id;
        receipt.OrderApi__EPayment__c = ePaymentTwo.Id;
        insert receipt;

        //Transaction
        OrderApi__Transaction__c dealing = new OrderApi__Transaction__c();
        dealing.OrderApi__Sales_Order__c = salesOrder.Id;
        dealing.OrderApi__Receipt__c = receipt.Id;
        dealing.OrderApi__Date__c = System.today();
        insert dealing;
        update dealing;
        OrderApi__Transaction__c updatedTransaction = [SELECT Id,OrderApi__Date__c FROM OrderApi__Transaction__c WHERE Id=:dealing.Id LIMIT 1];
        System.assert(updatedTransaction != null);
        System.assertEquals(System.today().addMonths(1),updatedTransaction.OrderApi__Date__c); 
        Test.stopTest();
    }
}