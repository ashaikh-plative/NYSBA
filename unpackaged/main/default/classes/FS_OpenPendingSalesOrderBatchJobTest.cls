@IsTest
public with sharing class FS_OpenPendingSalesOrderBatchJobTest {
    
    @IsTest
    private static void testDeleteOpenSalesOrders(){
        Account accntOne = new Account(Name='Test Account');
        insert  accntOne;
        Contact conOne = new Contact(AccountId=accntOne.Id, LastName='TestContact');
        insert conOne;
        
        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name='Test');
        insert busGroup;
        
         List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
         OrderApi__Sales_Order__c salesOrderOne = FS_TestUtils.createSalesOrder(conOne.Id, accntOne.Id, 'Receipt', 'open');
         salesOrderOne.OrderApi__Posting_Status__c = null;
         salesOrderOne.OrderApi__Status__c = 'Open';
         salesOrderOne.OrderApi__Business_Group__c = busGroup.Id;
         insert salesOrderOne;
        
      // Itemclass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('TestItem');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        // Item
        OrderApi__Item__c item = FS_TestUtils.createItem('Test Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Track_Inventory__c = true;
        insert item;
        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Sales_Order__c = salesOrderOne.Id,
                OrderApi__Is_Subscription__c = true);
        solList.add(salesOrderLine);
        OrderApi__Sales_Order_Line__c salesOrderLine2 = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Sales_Order__c = salesOrderOne.Id,
                OrderApi__Quantity__c = 9,
                OrderApi__Is_Subscription__c = true);
        solList.add(salesOrderLine2);

        insert solList;
        Test.startTest();
        OrderApi__Sales_Order__c salesOrderObj = [SELECT Id, Name FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:conOne.Id];
        System.assertEquals(salesOrderObj.Id, salesOrderOne.Id);
        
        FS_OpenPendingSalesOrderDeleteBatchJob batch = new FS_OpenPendingSalesOrderDeleteBatchJob();
        Database.executeBatch(batch);      
        String schTime = '0 0 0 * * ?';
        FS_OpenPendingSalesOrderDeleteBatchJob schJob = new FS_OpenPendingSalesOrderDeleteBatchJob();
        System.schedule('TestUpdateConAccJob', schTime, schJob);

        Test.stopTest();     
   }
    @IsTest
    private static void testDeleteClosedSalesOrders(){
        Account accnt = new Account(Name='Test Account');
        insert  accnt;
        
        Contact con = new Contact(AccountId=accnt.Id, LastName='Test Contact');
        insert con;
         //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name='Test');
        insert busGroup;
        
       
        //SalesOrder
         OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(con.Id, accnt.Id, 'Receipt','Closed');
         salesOrder.OrderApi__Business_Group__c = busGroup.Id;
         salesOrder.OrderApi__Posting_Status__c = 'Pending';
         insert salesOrder;
        
      // Itemclass
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Programs');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        // Item
        OrderApi__Item__c item = FS_TestUtils.createItem('Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Track_Inventory__c = true;
        insert item;
        List<OrderApi__Sales_Order_Line__c> solList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Is_Subscription__c = true);
        solList.add(salesOrderLine);
        OrderApi__Sales_Order_Line__c salesOrderLine2 = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Quantity__c = 9,
                OrderApi__Is_Subscription__c = TRUE);
        solList.add(salesOrderLine2);

        insert solList;
        Test.startTest();
         OrderApi__Sales_Order__c salesOrderObj = [SELECT Id, Name FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        System.assertEquals(salesOrderObj.Id, salesOrder.Id);
                      
                
        FS_OpenPendingSalesOrderDeleteBatchJob batch = new FS_OpenPendingSalesOrderDeleteBatchJob();
        Database.executeBatch(batch);      
        String schTime = '0 0 0 * * ?';
        FS_OpenPendingSalesOrderDeleteBatchJob schJob = new FS_OpenPendingSalesOrderDeleteBatchJob();
        System.schedule('TestUpdateConAccJob', schTime, schJob);
        Test.stopTest();        
   }
}