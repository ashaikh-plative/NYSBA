/**
 * Created by Jason Cookman on 9/28/20.
 */
@IsTest
private class FS_ProformaFinishProcessTest {
    @TestSetup
    private static void insertRecords(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(LastName = 'Test',Email = 'test1@gmail.com',AccountId = acc.Id);
        insert con;
    }

    @IsTest
    private static void testSalesOrder(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name = 'Test Item Class';
        insert itemClass;

        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Test Item';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        insert item1;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.FS_Proforma_Job_In_Progress__c = true;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'Open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        salesOrderLine.OrderApi__Quantity__c = 1;
        salesOrderLine.OrderApi__Sale_Price__c = 10;
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        Test.startTest();
        Database.executeBatch(new FS_ProformaFinishProcess());
        Test.stopTest();

        OrderApi__Sales_Order__c sOrder = [SELECT Id,OrderApi__Posting_Status__c,FS_Proforma_Job_In_Progress__c,
                FS_Processed_By_Batch_Job__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder.Id];
        System.assertEquals('Pending', sOrder.OrderApi__Posting_Status__c);
        System.assertEquals(false, sOrder.FS_Proforma_Job_In_Progress__c);
        System.assertEquals(true, sOrder.FS_Processed_By_Batch_Job__c);

    }
    @IsTest
    private static void deleteInvoices(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name = 'Test Item Class';
        insert itemClass;

        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Test Item';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        insert item1;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.FS_Proforma_Job_In_Progress__c = true;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'Open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c();
        invoice.OrderApi__Account__c = acc.Id;
        invoice.OrderApi__Contact__c = con.Id;
        invoice.OrderApi__Status__c = 'Draft';
        invoice.OrderApi__Sales_Order__c = salesOrder.Id;
        insert invoice;

        Datetime invoiceCreatedDate = Datetime.now().addDays(-1);
        Test.setCreatedDate(invoice.Id, invoiceCreatedDate);

        Test.startTest();
        Database.executeBatch(new FS_ProformaFinishProcess());
        Test.stopTest();

        OrderApi__Sales_Order__c sOrderData = [SELECT Id,OrderApi__Posting_Status__c,FS_Proforma_Job_In_Progress__c,
                FS_Processed_By_Batch_Job__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder.Id];


        System.assertEquals('Posted', sOrderData.OrderApi__Posting_Status__c);
        System.assertEquals(false, sOrderData.FS_Proforma_Job_In_Progress__c);
        System.assertEquals(true, sOrderData.FS_Processed_By_Batch_Job__c);

        List<OrderApi__Invoice__c> invoiceList = [SELECT Id,OrderApi__Sales_Order__c FROM OrderApi__Invoice__c WHERE
                OrderApi__Sales_Order__c =: salesOrder.Id];
        System.assertEquals(0, invoiceList.size());
    }

    @IsTest
    private static void salesOrderwithZeroTotal(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name = 'Test Item Class';
        insert itemClass;

        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Test Item';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        insert item1;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.FS_Proforma_Job_In_Progress__c = true;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'Open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        salesOrderLine.OrderApi__Quantity__c = 1;
        salesOrderLine.OrderApi__Sale_Price__c = 0;
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        Test.startTest();
        Database.executeBatch(new FS_ProformaFinishProcess());
        Test.stopTest();

        OrderApi__Sales_Order__c sOrder = [SELECT Id,OrderApi__Posting_Status__c,FS_Proforma_Job_In_Progress__c,
                FS_Processed_By_Batch_Job__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder.Id];
        System.assertEquals('Posted', sOrder.OrderApi__Posting_Status__c);
        System.assertEquals(false, sOrder.FS_Proforma_Job_In_Progress__c);
        System.assertEquals(true, sOrder.FS_Processed_By_Batch_Job__c);
    }
    @IsTest
    private static void createScheduldePaymentLine(){

        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];

        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name = 'Test Item Class';
        insert itemClass;

        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Test Item';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        insert item1;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.FS_Proforma_Job_In_Progress__c = true;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'Open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        salesOrderLine.OrderApi__Quantity__c = 1;
        salesOrderLine.OrderApi__Sale_Price__c = 10;
        salesOrderLine.OrderApi__Item_Class__c = itemClass.Id;
        insert salesOrderLine;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        update salesOrder;

        //Inserting invoices
        OrderApi__Invoice__c invoice = new OrderApi__Invoice__c();
        invoice.OrderApi__Account__c = acc.Id;
        invoice.OrderApi__Contact__c = con.Id;
        invoice.OrderApi__Status__c = 'Draft';
        invoice.OrderApi__Sales_Order__c = salesOrder.Id;
        insert invoice;

        OrderApi__Payment_Method__c paymentMethod = new OrderApi__Payment_Method__c();
        insert paymentMethod;

        OrderApi__Scheduled_Payment__c sPayment = new OrderApi__Scheduled_Payment__c ();
        sPayment.OrderApi__Sales_Order__c = salesOrder.Id;
        sPayment.OrderApi__Invoice__c = invoice.Id;
        sPayment.OrderApi__Payment_Method__c = paymentMethod.Id;
        insert sPayment;

        Test.startTest();
        Database.executeBatch(new FS_ProformaFinishProcess());
        Test.stopTest();

        OrderApi__Sales_Order__c sOrder = [SELECT Id,OrderApi__Posting_Status__c,FS_Proforma_Job_In_Progress__c,
                FS_Processed_By_Batch_Job__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrder.Id];
        System.assertEquals('Pending', sOrder.OrderApi__Posting_Status__c);
        System.assertEquals(false, sOrder.FS_Proforma_Job_In_Progress__c);
        System.assertEquals(true, sOrder.FS_Processed_By_Batch_Job__c);
    }
}