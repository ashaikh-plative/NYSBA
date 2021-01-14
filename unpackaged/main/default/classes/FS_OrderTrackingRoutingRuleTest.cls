@IsTest
public class FS_OrderTrackingRoutingRuleTest {
 @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_OrderTrackingRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Sales_Order__c';
        routingRule.executionOrder = 19;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }
      @IsTest
     Static void createOrderTracking(){
         
         //inserting Contact
         Contact con=new Contact(LastName='Test');
         insert con;
         
         //inserting sales order
         OrderApi__Sales_Order__c salesOrder=new OrderApi__Sales_Order__c(OrderApi__Contact__c=con.Id,OrderApi__Status__c='open');
         insert salesOrder;
         
         //insert item class
         OrderApi__Item_Class__c itemClass=new OrderApi__Item_Class__c(Name='test');
         insert itemClass;
         
         //insert item
         OrderApi__Item__c item=new OrderApi__Item__c(Name='testItem',OrderApi__Item_Class__c=itemClass.Id,OrderApi__Require_PreAuthorized_Payment__c=True,OrderApi__Require_Shipping__c=True);
         insert item;
         
         //insert  sales Order Line
         OrderApi__Sales_Order_Line__c soLine=new OrderApi__Sales_Order_Line__c(OrderApi__Item__c=item.Id,OrderApi__Quantity__c=2,OrderApi__Sales_Order__c=salesOrder.Id);
         insert soLine;
         
         //update sales order
         salesOrder.OrderApi__Posting_Status__c='Posted';
         salesOrder.OrderApi__Status__c='Closed';
         update salesOrder;
         
         //inserting order Tracking
         FS_Order_Tracking__c order=new FS_Order_Tracking__c();
         order.FS_Quantity__c=String.valueOf(soLine.OrderApi__Quantity__c);
         order.FS_Sales_Order_Line__c=soLine.Id;
         order.FS_Sales_Order__c=soLine.OrderApi__Sales_Order__c;
         insert order;
         System.assertEquals('2',  order.FS_Quantity__c);
     }
}