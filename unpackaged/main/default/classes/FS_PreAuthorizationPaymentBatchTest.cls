/**
 * Created by cloudwebsolutions on 16-12-2019.
 */

@IsTest
private class FS_PreAuthorizationPaymentBatchTest {
    @IsTest
    private static void validateBatch(){
        Test.startTest();
        Account acc=FS_TestUtils.createAccount('Testing');
        insert acc;

        Contact con=FS_TestUtils.createContact('Test','test@gmail.com');
        insert con;

        List<OrderApi__Business_Group__c> businessGroups = new List<OrderApi__Business_Group__c>();
        OrderApi__Business_Group__c businessGroup1 = FS_TestUtils.createBusinessGroup('ShippingTrue');
        businessGroup1.OrderApi__Enable_Shipping_By_Order_Total__c = true;
        businessGroups.add(businessGroup1);
        OrderApi__Business_Group__c businessGroup2 = FS_TestUtils.createBusinessGroup('ShippingTrue');
        businessGroup2.OrderApi__Enable_Shipping_By_Order_Total__c = false;
        businessGroups.add(businessGroup2);
        insert businessGroups;

        List<OrderApi__Item_Class__c> itemClasses = new List<OrderApi__Item_Class__c>();
        OrderApi__Item_Class__c itemClass=FS_TestUtils.createItemClass('TestItemclass');
        //itemClass.Display_Name__c = 'TestItemclass';
        itemClasses.add(itemClass);
        OrderApi__Item_Class__c itemTaxClass=FS_TestUtils.createItemClass('TestItemTaxclass');
        //itemTaxClass.Display_Name__c = 'TestItemTaxclass';
        itemTaxClass.OrderApi__Is_Tax__c = true;
        itemClasses.add(itemTaxClass);
        OrderApi__Item_Class__c itemShippingClass=FS_TestUtils.createItemClass('TestItemShipclass');
        //itemShippingClass.Display_Name__c = 'TestItemShipclass';
        itemShippingClass.OrderApi__Is_Shipping_Carrier__c = true;
        itemClasses.add(itemShippingClass);
        insert itemClasses;

        OrderApi__Item__c item=FS_TestUtils.createItem('testItem1',itemClass.Id);
        item.OrderApi__Require_PreAuthorized_Payment__c = true;
        item.OrderApi__Price__c = 783.51;
        OrderApi__Item__c item1=FS_TestUtils.createItem('testItem2',itemClass.Id);
        item1.OrderApi__Require_PreAuthorized_Payment__c = true;
        item1.OrderApi__Price__c = 450;
        OrderApi__Item__c item2=FS_TestUtils.createItem('testItem3',itemClass.Id);
        item2.OrderApi__Require_PreAuthorized_Payment__c = true;
        item2.OrderApi__Price__c = 631.33;

        OrderApi__Item__c taxItem = FS_TestUtils.createItem('testTaxItem',itemTaxClass.Id);
        taxItem.OrderApi__Is_Tax__c = true;
        taxItem.OrderApi__Is_Default_Tax_Rate__c = true;
        taxItem.OrderApi__Tax_Percent__c = 7;

        OrderApi__Item__c shippingItem = FS_TestUtils.createItem('testShippingItem',itemShippingClass.Id);
        shippingItem.OrderApi__Price__c = 30;
        shippingItem.OrderApi__Is_Shipping_Rate__c = true;

        List<OrderApi__Item__c> insertItems = new List<OrderApi__Item__c>();
        insertItems.add(item);
        insertItems.add(item1);
        insertItems.add(item2);
        insertItems.add(taxItem);
        insertItems.add(shippingItem);
        insert insertItems;

        OrderApi__Sales_Order__c salesOrder =FS_TestUtils.createSalesOrder(con.Id,acc.Id,'Receipt','open');
        salesOrder.OrderApi__Business_Group__c = businessGroup1.Id;
        OrderApi__Sales_Order__c salesOrder2 =FS_TestUtils.createSalesOrder(con.Id,acc.Id,'Receipt','open');
        salesOrder2.OrderApi__Business_Group__c = businessGroup1.Id;
        OrderApi__Sales_Order__c salesOrder3 =FS_TestUtils.createSalesOrder(con.Id,acc.Id,'Receipt','open');
        salesOrder3.OrderApi__Business_Group__c = businessGroup2.Id;
        OrderApi__Sales_Order__c salesOrder4 =FS_TestUtils.createSalesOrder(con.Id,acc.Id,'Receipt','open');
        salesOrder4.OrderApi__Business_Group__c = businessGroup2.Id;
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();
        salesOrders.add(salesOrder);
        salesOrders.add(salesOrder2);
        salesOrders.add(salesOrder3);
        salesOrders.add(salesOrder4);
        insert salesOrders;

        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLine=FS_TestUtils.createSalesOrderLine(item.Id,salesOrder.Id,con.Id,acc.Id);
        salesOrderLine.OrderApi__Quantity__c = 6;
        salesOrderLine.OrderApi__Sale_Price__c = 783.51;
        salesOrderLines.add(salesOrderLine);
        OrderApi__Sales_Order_Line__c salesOrderLine2=FS_TestUtils.createSalesOrderLine(item1.Id,salesOrder2.Id,con.Id,acc.Id);
        salesOrderLine2.OrderApi__Quantity__c = 6;
        salesOrderLine2.OrderApi__Sale_Price__c = 450;
        salesOrderLines.add(salesOrderLine2);
        OrderApi__Sales_Order_Line__c salesOrderLine3=FS_TestUtils.createSalesOrderLine(item.Id,salesOrder3.Id,con.Id,acc.Id);
        salesOrderLine3.OrderApi__Quantity__c = 6;
        salesOrderLine3.OrderApi__Sale_Price__c = 783.51;
        salesOrderLines.add(salesOrderLine3);
        OrderApi__Sales_Order_Line__c salesOrderLine4=FS_TestUtils.createSalesOrderLine(item1.Id,salesOrder3.Id,con.Id,acc.Id);
        salesOrderLine4.OrderApi__Quantity__c = 6;
        salesOrderLine4.OrderApi__Sale_Price__c = 450;
        salesOrderLines.add(salesOrderLine4);
        OrderApi__Sales_Order_Line__c salesOrderLine5=FS_TestUtils.createSalesOrderLine(item.Id,salesOrder4.Id,con.Id,acc.Id);
        salesOrderLine5.OrderApi__Quantity__c = 2;
        salesOrderLine5.OrderApi__Sale_Price__c = 783.51;
        salesOrderLines.add(salesOrderLine5);
        OrderApi__Sales_Order_Line__c salesOrderLine6=FS_TestUtils.createSalesOrderLine(item1.Id,salesOrder4.Id,con.Id,acc.Id);
        salesOrderLine6.OrderApi__Quantity__c = 2;
        salesOrderLine6.OrderApi__Sale_Price__c = 450;
        salesOrderLines.add(salesOrderLine6);

        OrderApi__Sales_Order_Line__c salesOrderLineShip1=FS_TestUtils.createSalesOrderLine(shippingItem.Id,salesOrder.Id,con.Id,acc.Id);
        salesOrderLineShip1.OrderApi__Quantity__c = 1;
        salesOrderLineShip1.OrderApi__Sale_Price__c = 30;
        salesOrderLines.add(salesOrderLineShip1);
        OrderApi__Sales_Order_Line__c salesOrderLineShip2=FS_TestUtils.createSalesOrderLine(shippingItem.Id,salesOrder2.Id,con.Id,acc.Id);
        salesOrderLineShip2.OrderApi__Quantity__c = 1;
        salesOrderLineShip2.OrderApi__Sale_Price__c = 30;
        salesOrderLines.add(salesOrderLineShip2);
        OrderApi__Sales_Order_Line__c salesOrderLineShip3=FS_TestUtils.createSalesOrderLine(shippingItem.Id,salesOrder3.Id,con.Id,acc.Id);
        salesOrderLineShip3.OrderApi__Quantity__c = 1;
        salesOrderLineShip3.OrderApi__Sale_Price__c = 30;
        salesOrderLines.add(salesOrderLineShip3);
        OrderApi__Sales_Order_Line__c salesOrderLineShip4=FS_TestUtils.createSalesOrderLine(shippingItem.Id,salesOrder4.Id,con.Id,acc.Id);
        salesOrderLineShip4.OrderApi__Quantity__c = 1;
        salesOrderLineShip4.OrderApi__Sale_Price__c = 30;
        salesOrderLines.add(salesOrderLineShip4);
        insert salesOrderLines;

        List<OrderApi__Sales_Order_Line__c> taxSalesOrderLines = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c taxSalesOrderLine=FS_TestUtils.createSalesOrderLine(taxItem.Id,salesOrder.Id,con.Id,acc.Id);
        taxSalesOrderLine.OrderApi__Quantity__c = 1;
        taxSalesOrderLine.OrderApi__Sales_Order_Line__c = salesOrderLine.Id;
        taxSalesOrderLine.OrderApi__Sale_Price__c = 329.07;
        OrderApi__Sales_Order_Line__c taxSalesOrderLine2=FS_TestUtils.createSalesOrderLine(taxItem.Id,salesOrder2.Id,con.Id,acc.Id);
        taxSalesOrderLine2.OrderApi__Quantity__c = 1;
        taxSalesOrderLine2.OrderApi__Sales_Order_Line__c = salesOrderLine2.Id;
        taxSalesOrderLine2.OrderApi__Sale_Price__c = 189;
        OrderApi__Sales_Order_Line__c taxSalesOrderLine3=FS_TestUtils.createSalesOrderLine(taxItem.Id,salesOrder3.Id,con.Id,acc.Id);
        taxSalesOrderLine3.OrderApi__Quantity__c = 1;
        taxSalesOrderLine3.OrderApi__Sales_Order_Line__c = salesOrderLine3.Id;
        taxSalesOrderLine3.OrderApi__Sale_Price__c = 329.07;
        OrderApi__Sales_Order_Line__c taxSalesOrderLine4=FS_TestUtils.createSalesOrderLine(taxItem.Id,salesOrder3.Id,con.Id,acc.Id);
        taxSalesOrderLine4.OrderApi__Quantity__c = 1;
        taxSalesOrderLine4.OrderApi__Sales_Order_Line__c = salesOrderLine4.Id;
        taxSalesOrderLine4.OrderApi__Sale_Price__c = 189;
        OrderApi__Sales_Order_Line__c taxSalesOrderLine5=FS_TestUtils.createSalesOrderLine(taxItem.Id,salesOrder4.Id,con.Id,acc.Id);
        taxSalesOrderLine5.OrderApi__Quantity__c = 1;
        taxSalesOrderLine5.OrderApi__Sales_Order_Line__c = salesOrderLine5.Id;
        taxSalesOrderLine5.OrderApi__Sale_Price__c = 109.69;
        OrderApi__Sales_Order_Line__c taxSalesOrderLine6=FS_TestUtils.createSalesOrderLine(taxItem.Id,salesOrder4.Id,con.Id,acc.Id);
        taxSalesOrderLine6.OrderApi__Quantity__c = 1;
        taxSalesOrderLine6.OrderApi__Sales_Order_Line__c = salesOrderLine6.Id;
        taxSalesOrderLine6.OrderApi__Sale_Price__c = 63;
        taxSalesOrderLines.add(taxSalesOrderLine);
        taxSalesOrderLines.add(taxSalesOrderLine2);
        taxSalesOrderLines.add(taxSalesOrderLine3);
        taxSalesOrderLines.add(taxSalesOrderLine4);
        taxSalesOrderLines.add(taxSalesOrderLine5);
        taxSalesOrderLines.add(taxSalesOrderLine6);
        insert taxSalesOrderLines;

        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c ='Posted';
        salesOrder2.OrderApi__Status__c = 'Closed';
        salesOrder2.OrderApi__Posting_Status__c ='Posted';
        salesOrder3.OrderApi__Status__c = 'Closed';
        salesOrder3.OrderApi__Posting_Status__c ='Posted';
        salesOrder4.OrderApi__Status__c = 'Closed';
        salesOrder4.OrderApi__Posting_Status__c ='Posted';
        update salesOrders;

        OrderApi__EPayment__c ePayment = new OrderApi__EPayment__c();
        ePayment.OrderApi__Transaction_Type__c = 'Authorization';
        ePayment.OrderApi__Sales_Order__c = salesOrder.Id;
        OrderApi__EPayment__c ePayment2 = new OrderApi__EPayment__c();
        ePayment2.OrderApi__Transaction_Type__c = 'Authorization';
        ePayment2.OrderApi__Sales_Order__c = salesOrder2.Id;
        OrderApi__EPayment__c ePayment3 = new OrderApi__EPayment__c();
        ePayment3.OrderApi__Transaction_Type__c = 'Authorization';
        ePayment3.OrderApi__Sales_Order__c = salesOrder3.Id;
        OrderApi__EPayment__c ePayment4 = new OrderApi__EPayment__c();
        ePayment4.OrderApi__Transaction_Type__c = 'Authorization';
        ePayment4.OrderApi__Sales_Order__c = salesOrder4.Id;
        List<OrderApi__EPayment__c> ePayments = new List<OrderApi__EPayment__c>();
        ePayments.add(ePayment);
        ePayments.add(ePayment2);
        ePayments.add(ePayment3);
        ePayments.add(ePayment4);
        insert ePayments;

        List<OrderApi__EPayment__c> ePaymentsCloned = new List<OrderApi__EPayment__c>();
        OrderApi__EPayment__c ePaymentCloned = new OrderApi__EPayment__c();
        ePaymentCloned.OrderApi__Sales_Order__c = salesOrder.Id;
        ePaymentCloned.OrderApi__EPayment__c = ePayment.Id;
        OrderApi__EPayment__c ePayment2Cloned = new OrderApi__EPayment__c();
        ePayment2Cloned.OrderApi__Sales_Order__c = salesOrder2.Id;
        ePayment2Cloned.OrderApi__EPayment__c = ePayment2.Id;
        ePaymentsCloned.add(ePaymentCloned);
        ePaymentsCloned.add(ePayment2Cloned);
        insert ePaymentsCloned;

        OrderApi__EPayment_Line__c ePaymentLine1 = new OrderApi__EPayment_Line__c();
        ePaymentLine1.OrderApi__EPayment__c = ePayment.Id;
        ePaymentLine1.OrderApi__Item__c = item.Id;
        ePaymentLine1.OrderApi__Quantity__c = 6;
        ePaymentLine1.OrderApi__Sales_Order_Line__c = salesOrderLine.Id;
        ePaymentLine1.OrderApi__Sale_Price__c = 783.51;
        OrderApi__EPayment_Line__c ePaymentLine2 = new OrderApi__EPayment_Line__c();
        ePaymentLine2.OrderApi__EPayment__c = ePayment2.Id;
        ePaymentLine2.OrderApi__Item__c = item1.Id;
        ePaymentLine2.OrderApi__Quantity__c = 6;
        ePaymentLine2.OrderApi__Sales_Order_Line__c = salesOrderLine2.Id;
        ePaymentLine2.OrderApi__Sale_Price__c = 450;
        OrderApi__EPayment_Line__c ePaymentLine3 = new OrderApi__EPayment_Line__c();
        ePaymentLine3.OrderApi__EPayment__c = ePayment3.Id;
        ePaymentLine3.OrderApi__Item__c = item.Id;
        ePaymentLine3.OrderApi__Quantity__c = 6;
        ePaymentLine3.OrderApi__Sales_Order_Line__c = salesOrderLine3.Id;
        ePaymentLine3.OrderApi__Sale_Price__c = 783.51;
        OrderApi__EPayment_Line__c ePaymentLine4 = new OrderApi__EPayment_Line__c();
        ePaymentLine4.OrderApi__EPayment__c = ePayment3.Id;
        ePaymentLine4.OrderApi__Item__c = item1.Id;
        ePaymentLine4.OrderApi__Quantity__c = 6;
        ePaymentLine4.OrderApi__Sales_Order_Line__c = salesOrderLine4.Id;
        ePaymentLine4.OrderApi__Sale_Price__c = 450;
        OrderApi__EPayment_Line__c ePaymentLine5 = new OrderApi__EPayment_Line__c();
        ePaymentLine5.OrderApi__EPayment__c = ePayment4.Id;
        ePaymentLine5.OrderApi__Item__c = item.Id;
        ePaymentLine5.OrderApi__Quantity__c = 2;
        ePaymentLine5.OrderApi__Sales_Order_Line__c = salesOrderLine5.Id;
        ePaymentLine5.OrderApi__Sale_Price__c = 783.51;
        OrderApi__EPayment_Line__c ePaymentLine6 = new OrderApi__EPayment_Line__c();
        ePaymentLine6.OrderApi__EPayment__c = ePayment4.Id;
        ePaymentLine6.OrderApi__Item__c = item1.Id;
        ePaymentLine6.OrderApi__Quantity__c = 2;
        ePaymentLine6.OrderApi__Sales_Order_Line__c = salesOrderLine6.Id;
        ePaymentLine6.OrderApi__Sale_Price__c = 450;

        OrderApi__EPayment_Line__c ePaymentLineShip1 = new OrderApi__EPayment_Line__c();
        ePaymentLineShip1.OrderApi__EPayment__c = ePayment.Id;
        ePaymentLineShip1.OrderApi__Item__c = shippingItem.Id;
        ePaymentLineShip1.OrderApi__Quantity__c = 1;
        ePaymentLineShip1.OrderApi__Sales_Order_Line__c = salesOrderLineShip1.Id;
        ePaymentLineShip1.OrderApi__Sale_Price__c = 30;
        OrderApi__EPayment_Line__c ePaymentLineShip2 = new OrderApi__EPayment_Line__c();
        ePaymentLineShip2.OrderApi__EPayment__c = ePayment2.Id;
        ePaymentLineShip2.OrderApi__Item__c = shippingItem.Id;
        ePaymentLineShip2.OrderApi__Quantity__c = 1;
        ePaymentLineShip2.OrderApi__Sales_Order_Line__c = salesOrderLineShip2.Id;
        ePaymentLineShip2.OrderApi__Sale_Price__c = 30;
        OrderApi__EPayment_Line__c ePaymentLineShip3 = new OrderApi__EPayment_Line__c();
        ePaymentLineShip3.OrderApi__EPayment__c = ePayment3.Id;
        ePaymentLineShip3.OrderApi__Item__c = shippingItem.Id;
        ePaymentLineShip3.OrderApi__Quantity__c = 1;
        ePaymentLineShip3.OrderApi__Sales_Order_Line__c = salesOrderLineShip3.Id;
        ePaymentLineShip3.OrderApi__Sale_Price__c = 30;
        OrderApi__EPayment_Line__c ePaymentLineShip4 = new OrderApi__EPayment_Line__c();
        ePaymentLineShip4.OrderApi__EPayment__c = ePayment4.Id;
        ePaymentLineShip4.OrderApi__Item__c = shippingItem.Id;
        ePaymentLineShip4.OrderApi__Quantity__c = 1;
        ePaymentLineShip4.OrderApi__Sales_Order_Line__c = salesOrderLineShip4.Id;
        ePaymentLineShip4.OrderApi__Sale_Price__c = 30;

        List<OrderApi__EPayment_Line__c> ePaymentLines = new List<OrderApi__EPayment_Line__c>();
        ePaymentLines.add(ePaymentLine1);
        ePaymentLines.add(ePaymentLine2);
        ePaymentLines.add(ePaymentLine3);
        ePaymentLines.add(ePaymentLine4);
        ePaymentLines.add(ePaymentLine5);
        ePaymentLines.add(ePaymentLine6);
        ePaymentLines.add(ePaymentLineShip1);
        ePaymentLines.add(ePaymentLineShip2);
        ePaymentLines.add(ePaymentLineShip3);
        ePaymentLines.add(ePaymentLineShip4);
        insert ePaymentLines;

        OrderApi__EPayment_Line__c ePaymentLineCloned = new OrderApi__EPayment_Line__c();
        ePaymentLineCloned.OrderApi__EPayment__c = ePaymentCloned.Id;
        ePaymentLineCloned.OrderApi__Item__c = item.Id;
        ePaymentLineCloned.OrderApi__Quantity__c = 1;
        ePaymentLineCloned.OrderApi__Sales_Order_Line__c = salesOrderLine.Id;
        ePaymentLineCloned.OrderApi__Sale_Price__c = 783.51;
        ePaymentLineCloned.OrderApi__EPayment_Line__c = ePaymentLine1.Id;
        OrderApi__EPayment_Line__c ePaymentLine2Cloned = new OrderApi__EPayment_Line__c();
        ePaymentLine2Cloned.OrderApi__EPayment__c = ePayment2Cloned.Id;
        ePaymentLine2Cloned.OrderApi__Item__c = item1.Id;
        ePaymentLine2Cloned.OrderApi__Quantity__c = 1;
        ePaymentLine2Cloned.OrderApi__Sales_Order_Line__c = salesOrderLine2.Id;
        ePaymentLine2Cloned.OrderApi__Sale_Price__c = 450;
        ePaymentLine2Cloned.OrderApi__EPayment_Line__c = ePaymentLine2.Id;
        List<OrderApi__EPayment_Line__c> ePaymentLinesCloned = new List<OrderApi__EPayment_Line__c>();
        ePaymentLinesCloned.add(ePaymentLineCloned);
        ePaymentLinesCloned.add(ePaymentLine2Cloned);
        insert ePaymentLinesCloned;

        OrderApi__EPayment_Line__c taxEPaymentLine = new OrderApi__EPayment_Line__c();
        taxEPaymentLine.OrderApi__EPayment__c = ePayment.Id;
        taxEPaymentLine.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine.OrderApi__Quantity__c = 1;
        taxEPaymentLine.OrderApi__Sales_Order_Line__c = taxSalesOrderLine.Id;
        taxEPaymentLine.OrderApi__EPayment_Line__c = ePaymentLine1.Id;
        taxEPaymentLine.OrderApi__Is_Tax__c = true;
        taxEPaymentLine.OrderApi__Sale_Price__c = 329.07;
        OrderApi__EPayment_Line__c taxEPaymentLine2 = new OrderApi__EPayment_Line__c();
        taxEPaymentLine2.OrderApi__EPayment__c = ePayment2.Id;
        taxEPaymentLine2.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine2.OrderApi__Quantity__c = 1;
        taxEPaymentLine2.OrderApi__Sales_Order_Line__c = taxSalesOrderLine2.Id;
        taxEPaymentLine2.OrderApi__EPayment_Line__c = ePaymentLine2.Id;
        taxEPaymentLine2.OrderApi__Is_Tax__c = true;
        taxEPaymentLine2.OrderApi__Sale_Price__c = 189;
        OrderApi__EPayment_Line__c taxEPaymentLine3 = new OrderApi__EPayment_Line__c();
        taxEPaymentLine3.OrderApi__EPayment__c = ePayment3.Id;
        taxEPaymentLine3.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine3.OrderApi__Quantity__c = 1;
        taxEPaymentLine3.OrderApi__Sales_Order_Line__c = taxSalesOrderLine3.Id;
        taxEPaymentLine3.OrderApi__EPayment_Line__c = ePaymentLine3.Id;
        taxEPaymentLine3.OrderApi__Is_Tax__c = true;
        taxEPaymentLine3.OrderApi__Sale_Price__c = 329.07;
        OrderApi__EPayment_Line__c taxEPaymentLine4 = new OrderApi__EPayment_Line__c();
        taxEPaymentLine4.OrderApi__EPayment__c = ePayment3.Id;
        taxEPaymentLine4.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine4.OrderApi__Quantity__c = 1;
        taxEPaymentLine4.OrderApi__Sales_Order_Line__c = taxSalesOrderLine4.Id;
        taxEPaymentLine4.OrderApi__EPayment_Line__c = ePaymentLine4.Id;
        taxEPaymentLine4.OrderApi__Is_Tax__c = true;
        taxEPaymentLine4.OrderApi__Sale_Price__c = 189;
        OrderApi__EPayment_Line__c taxEPaymentLine5 = new OrderApi__EPayment_Line__c();
        taxEPaymentLine5.OrderApi__EPayment__c = ePayment4.Id;
        taxEPaymentLine5.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine5.OrderApi__Quantity__c = 1;
        taxEPaymentLine5.OrderApi__Sales_Order_Line__c = taxSalesOrderLine5.Id;
        taxEPaymentLine5.OrderApi__EPayment_Line__c = ePaymentLine5.Id;
        taxEPaymentLine5.OrderApi__Is_Tax__c = true;
        taxEPaymentLine5.OrderApi__Sale_Price__c = 109.69;
        OrderApi__EPayment_Line__c taxEPaymentLine6 = new OrderApi__EPayment_Line__c();
        taxEPaymentLine6.OrderApi__EPayment__c = ePayment4.Id;
        taxEPaymentLine6.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine6.OrderApi__Quantity__c = 1;
        taxEPaymentLine6.OrderApi__Sales_Order_Line__c = taxSalesOrderLine6.Id;
        taxEPaymentLine6.OrderApi__EPayment_Line__c = ePaymentLine6.Id;
        taxEPaymentLine6.OrderApi__Is_Tax__c = true;
        taxEPaymentLine6.OrderApi__Sale_Price__c = 63;
        List<OrderApi__EPayment_Line__c> taxEPaymentLines = new List<OrderApi__EPayment_Line__c>();
        taxEPaymentLines.add(taxEPaymentLine);
        taxEPaymentLines.add(taxEPaymentLine2);
        taxEPaymentLines.add(taxEPaymentLine3);
        taxEPaymentLines.add(taxEPaymentLine4);
        taxEPaymentLines.add(taxEPaymentLine5);
        taxEPaymentLines.add(taxEPaymentLine6);
        insert taxEPaymentLines;

        OrderApi__EPayment_Line__c taxEPaymentLineCloned = new OrderApi__EPayment_Line__c();
        taxEPaymentLineCloned.OrderApi__EPayment__c = ePaymentCloned.Id;
        taxEPaymentLineCloned.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLineCloned.OrderApi__Quantity__c = 1;
        taxEPaymentLineCloned.OrderApi__Sales_Order_Line__c = taxSalesOrderLine.Id;
        taxEPaymentLineCloned.OrderApi__EPayment_Line__c = ePaymentLineCloned.Id;
        taxEPaymentLineCloned.OrderApi__Is_Tax__c = true;
        taxEPaymentLineCloned.OrderApi__Sale_Price__c = 54.85;
        OrderApi__EPayment_Line__c taxEPaymentLine2Cloned = new OrderApi__EPayment_Line__c();
        taxEPaymentLine2Cloned.OrderApi__EPayment__c = ePayment2Cloned.Id;
        taxEPaymentLine2Cloned.OrderApi__Item__c = taxItem.Id;
        taxEPaymentLine2Cloned.OrderApi__Quantity__c = 1;
        taxEPaymentLine2Cloned.OrderApi__Sales_Order_Line__c = taxSalesOrderLine2.Id;
        taxEPaymentLine2Cloned.OrderApi__EPayment_Line__c = ePaymentLine2Cloned.Id;
        taxEPaymentLine2Cloned.OrderApi__Is_Tax__c = true;
        taxEPaymentLine2Cloned.OrderApi__Sale_Price__c = 31.5;
        List<OrderApi__EPayment_Line__c> taxEPaymentLinesCloned = new List<OrderApi__EPayment_Line__c>();
        taxEPaymentLinesCloned.add(taxEPaymentLineCloned);
        taxEPaymentLinesCloned.add(taxEPaymentLine2Cloned);
        insert taxEPaymentLinesCloned;

        FS_Order_Tracking__c orderTracking1 = new FS_Order_Tracking__c();
        orderTracking1.FS_Sales_Order__c = salesOrder.Id;
        orderTracking1.FS_Sales_Order_Line__c = salesOrderLine.Id;
        orderTracking1.FS_Quantity__c = '6';
        //shipIntLine1.FS_Bundled_Sales_Order_Line_ID__c = solBundleItem1.Id;
        FS_Order_Tracking__c orderTracking2 = new FS_Order_Tracking__c();
        orderTracking2.FS_Sales_Order__c = salesOrder.Id;
        orderTracking2.FS_Sales_Order_Line__c = salesOrderLine.Id;
        orderTracking2.FS_Quantity__c = '6';

        //shipIntLine2.FS_Bundled_Sales_Order_Line_ID__c = solBundleItem2.Id;
        FS_Order_Tracking__c orderTracking3 = new FS_Order_Tracking__c();
        orderTracking3.FS_Sales_Order__c = salesOrder2.Id;
        orderTracking3.FS_Sales_Order_Line__c = salesOrderLine2.Id;
        orderTracking3.FS_Quantity__c = '6';

        FS_Order_Tracking__c orderTracking4 = new FS_Order_Tracking__c();
        orderTracking4.FS_Sales_Order__c = salesOrder3.Id;
        orderTracking4.FS_Sales_Order_Line__c = salesOrderLine3.Id;
        orderTracking4.FS_Quantity__c = '6';

        //shipIntLine4.FS_Bundled_Sales_Order_Line_ID__c = solBundleItem3.Id;
        FS_Order_Tracking__c orderTracking5 = new FS_Order_Tracking__c();
        orderTracking5.FS_Sales_Order__c = salesOrder3.Id;
        orderTracking5.FS_Sales_Order_Line__c = salesOrderLine3.Id;
        orderTracking5.FS_Quantity__c = '6';

        //shipIntLine5.FS_Bundled_Sales_Order_Line_ID__c = solBundleItem4.Id;
        FS_Order_Tracking__c orderTracking6 = new FS_Order_Tracking__c();
        orderTracking6.FS_Sales_Order__c = salesOrder3.Id;
        orderTracking6.FS_Sales_Order_Line__c = salesOrderLine4.Id;
        orderTracking6.FS_Quantity__c = '6';

        FS_Order_Tracking__c orderTracking7 = new FS_Order_Tracking__c();
        orderTracking7.FS_Sales_Order__c = salesOrder4.Id;
        orderTracking7.FS_Sales_Order_Line__c = salesOrderLine5.Id;
        orderTracking7.FS_Quantity__c = '6';

        //shipIntLine7.FS_Bundled_Sales_Order_Line_ID__c = solBundleItem5.Id;
        FS_Order_Tracking__c orderTracking8 = new FS_Order_Tracking__c();
        orderTracking8.FS_Sales_Order__c = salesOrder4.Id;
        orderTracking8.FS_Sales_Order_Line__c = salesOrderLine5.Id;
        orderTracking8.FS_Quantity__c = '2';

        //shipIntLine8.FS_Bundled_Sales_Order_Line_ID__c = solBundleItem6.Id;
        FS_Order_Tracking__c orderTracking9 = new FS_Order_Tracking__c();
        orderTracking9.FS_Sales_Order__c = salesOrder4.Id;
        orderTracking9.FS_Sales_Order_Line__c = salesOrderLine6.Id;
        orderTracking9.FS_Quantity__c = '2';

        List<FS_Order_Tracking__c> orderTrackings = new List<FS_Order_Tracking__c>();
        orderTrackings.add(orderTracking1);
        orderTrackings.add(orderTracking2);
        orderTrackings.add(orderTracking3);
        orderTrackings.add(orderTracking4);
        orderTrackings.add(orderTracking5);
        orderTrackings.add(orderTracking6);
        orderTrackings.add(orderTracking7);
        orderTrackings.add(orderTracking8);
        orderTrackings.add(orderTracking9);
        insert orderTrackings;

        FS_Order_Fulfillment__c orderFulfillment1 = new FS_Order_Fulfillment__c();
        orderFulfillment1.FS_Order__c = salesOrder.Id;
        orderFulfillment1.FS_Order_Line__c = salesOrderLine.Id;
        orderFulfillment1.FS_Order_Tracking__c = orderTracking1.id;
        //shipIntFulfillment1.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem1.Id;
        orderFulfillment1.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment1.FS_Shipping_Integration_Header_ID__c = shipIntLine1.Id;
        //shipIntFulfillment1.FS_Payment_Process_Status__c = true;
        FS_Order_Fulfillment__c orderFulfillment2 = new FS_Order_Fulfillment__c();
        orderFulfillment2.FS_Order__c = salesOrder.Id;
        orderFulfillment2.FS_Order_Line__c = salesOrderLine.Id;
        orderFulfillment2.FS_Order_Tracking__c = orderTracking2.id;
        //shipIntFulfillment2.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem2.Id;
        orderFulfillment2.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment2.FS_Shipping_Integration_Header_ID__c = shipIntLine2.Id;
        //shipIntFulfillment2.FS_Payment_Process_Status__c = true;
        FS_Order_Fulfillment__c orderFulfillment3 = new FS_Order_Fulfillment__c();
        orderFulfillment3.FS_Order__c = salesOrder2.Id;
        orderFulfillment3.FS_Order_Line__c = salesOrderLine2.Id;
        orderFulfillment3.FS_Quantity_Shipped__c = 1;
        orderFulfillment3.FS_Order_Tracking__c = orderTracking3.id;
        //shipIntFulfillment3.FS_Shipping_Integration_Header_ID__c = shipIntLine3.Id;
        //shipIntFulfillment3.FS_Payment_Process_Status__c = true;
        FS_Order_Fulfillment__c orderFulfillment4 = new FS_Order_Fulfillment__c();
        orderFulfillment4.FS_Order__c = salesOrder3.Id;
        orderFulfillment4.FS_Order_Line__c = salesOrderLine3.Id;
        orderFulfillment4.FS_Order_Tracking__c = orderTracking4.id;
        //shipIntFulfillment4.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem3.Id;
        orderFulfillment4.FS_Quantity_Shipped__c = 6;
        //shipIntFulfillment4.FS_Shipping_Integration_Header_ID__c = shipIntLine4.Id;
        FS_Order_Fulfillment__c orderFulfillment5 = new FS_Order_Fulfillment__c();
        orderFulfillment5.FS_Order__c = salesOrder3.Id;
        orderFulfillment5.FS_Order_Line__c = salesOrderLine3.Id;
        orderFulfillment5.FS_Order_Tracking__c = orderTracking5.id;
        //shipIntFulfillment5.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem4.Id;
        orderFulfillment5.FS_Quantity_Shipped__c = 6;
        //shipIntFulfillment5.FS_Shipping_Integration_Header_ID__c = shipIntLine5.Id;
        FS_Order_Fulfillment__c orderFulfillment6 = new FS_Order_Fulfillment__c();
        orderFulfillment6.FS_Order__c = salesOrder3.Id;
        orderFulfillment6.FS_Order_Line__c = salesOrderLine4.Id;
        orderFulfillment6.FS_Quantity_Shipped__c = 6;
        orderFulfillment6.FS_Order_Tracking__c = orderTracking6.id;
        //shipIntFulfillment6.FS_Shipping_Integration_Header_ID__c = shipIntLine6.Id;

        FS_Order_Fulfillment__c orderFulfillment7 = new FS_Order_Fulfillment__c();
        orderFulfillment7.FS_Order__c = salesOrder.Id;
        orderFulfillment7.FS_Order_Line__c = salesOrderLine.Id;
        //shipIntFulfillment7.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem1.Id;
        orderFulfillment7.FS_Quantity_Shipped__c = 4;
        orderFulfillment7.FS_Order_Tracking__c = orderTracking7.id;
        //shipIntFulfillment7.FS_Shipping_Integration_Header_ID__c = shipIntLine1.Id;
        FS_Order_Fulfillment__c orderFulfillment8 = new FS_Order_Fulfillment__c();
        orderFulfillment8.FS_Order__c = salesOrder.Id;
        orderFulfillment8.FS_Order_Line__c = salesOrderLine.Id;
        orderFulfillment8.FS_Order_Tracking__c = orderTracking8.id;
        //shipIntFulfillment8.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem2.Id;
        orderFulfillment8.FS_Quantity_Shipped__c = 4;
        //shipIntFulfillment8.FS_Shipping_Integration_Header_ID__c = shipIntLine2.Id;
        FS_Order_Fulfillment__c orderFulfillment9 = new FS_Order_Fulfillment__c();
        orderFulfillment9.FS_Order__c = salesOrder2.Id;
        orderFulfillment9.FS_Order_Line__c = salesOrderLine2.Id;
        orderFulfillment9.FS_Quantity_Shipped__c = 4;
        orderFulfillment9.FS_Order_Tracking__c = orderTracking9.id;

        //shipIntFulfillment9.FS_Shipping_Integration_Header_ID__c = shipIntLine3.Id;
        FS_Order_Fulfillment__c orderFulfillment7_2 = new FS_Order_Fulfillment__c();
        orderFulfillment7_2.FS_Order__c = salesOrder.Id;
        orderFulfillment7_2.FS_Order_Line__c = salesOrderLine.Id;
        orderFulfillment7_2.FS_Order_Tracking__c = orderTracking1.id;

        //shipIntFulfillment7_2.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem1.Id;
        orderFulfillment7_2.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment7_2.FS_Shipping_Integration_Header_ID__c = shipIntLine1.Id;
        FS_Order_Fulfillment__c orderFulfillment8_2 = new FS_Order_Fulfillment__c();
        orderFulfillment8_2.FS_Order__c = salesOrder.Id;
        orderFulfillment8_2.FS_Order_Line__c = salesOrderLine.Id;
        orderFulfillment8_2.FS_Order_Tracking__c = orderTracking2.id;
        //shipIntFulfillment8_2.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem2.Id;
        orderFulfillment8_2.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment8_2.FS_Shipping_Integration_Header_ID__c = shipIntLine2.Id;
        FS_Order_Fulfillment__c orderFulfillment9_2 = new FS_Order_Fulfillment__c();
        orderFulfillment9_2.FS_Order__c = salesOrder2.Id;
        orderFulfillment9_2.FS_Order_Line__c = salesOrderLine2.Id;
        orderFulfillment9_2.FS_Quantity_Shipped__c = 1;
        orderFulfillment9_2.FS_Order_Tracking__c = orderTracking3.id;
        //shipIntFulfillment9_2.FS_Shipping_Integration_Header_ID__c = shipIntLine3.Id;

        FS_Order_Fulfillment__c orderFulfillment10 = new FS_Order_Fulfillment__c();
        orderFulfillment10.FS_Order__c = salesOrder4.Id;
        orderFulfillment10.FS_Order_Line__c = salesOrderLine5.Id;
        orderFulfillment10.FS_Order_Tracking__c = orderTracking7.id;
        //shipIntFulfillment10.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem5.Id;
        orderFulfillment10.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment10.FS_Shipping_Integration_Header_ID__c = shipIntLine7.Id;
        FS_Order_Fulfillment__c orderFulfillment11 = new FS_Order_Fulfillment__c();
        orderFulfillment11.FS_Order__c = salesOrder4.Id;
        orderFulfillment11.FS_Order_Line__c = salesOrderLine5.Id;
        orderFulfillment11.FS_Order_Tracking__c = orderTracking8.id;
        //shipIntFulfillment11.FS_Bundled_SalesOrder_Line_ID__c = solBundleItem6.Id;
        orderFulfillment11.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment11.FS_Shipping_Integration_Header_ID__c = shipIntLine8.Id;

        FS_Order_Fulfillment__c orderFulfillment12 = new FS_Order_Fulfillment__c();
        orderFulfillment12.FS_Order__c = salesOrder4.Id;
        orderFulfillment12.FS_Order_Line__c = salesOrderLine6.Id;
        orderFulfillment12.FS_Order_Tracking__c = orderTracking9.id;
        orderFulfillment12.FS_Quantity_Shipped__c = 1;
        //shipIntFulfillment12.FS_Shipping_Integration_Header_ID__c = shipIntLine9.Id;



        List<FS_Order_Fulfillment__c> orderFulfillments = new List<FS_Order_Fulfillment__c>();
        orderFulfillments.add(orderFulfillment1);
        orderFulfillments.add(orderFulfillment2);
        orderFulfillments.add(orderFulfillment3);
        orderFulfillments.add(orderFulfillment4);
        orderFulfillments.add(orderFulfillment5);
        orderFulfillments.add(orderFulfillment6);
        orderFulfillments.add(orderFulfillment7);
        orderFulfillments.add(orderFulfillment8);
        orderFulfillments.add(orderFulfillment9);
        orderFulfillments.add(orderFulfillment7_2);
        orderFulfillments.add(orderFulfillment8_2);
        orderFulfillments.add(orderFulfillment9_2);
        orderFulfillments.add(orderFulfillment10);
        orderFulfillments.add(orderFulfillment11);
        orderFulfillments.add(orderFulfillment12);
        insert orderFulfillments;

        String cronExpression = '0 0 10 * * ?  ';
        FS_PreAuthorizationPaymentBatch pa = new FS_PreAuthorizationPaymentBatch();
        System.schedule('My job',cronExpression,pa);
        Test.stopTest();
    }
}