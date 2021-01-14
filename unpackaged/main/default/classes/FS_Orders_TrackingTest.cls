@IsTest
public class FS_Orders_TrackingTest {
@TestSetup
      private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install(); 

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule FS_Orders_TrackingRule = new Framework.RoutingRule();
          FS_Orders_TrackingRule.apexClass = FS_Orders_Tracking.class.getName();
          FS_Orders_TrackingRule.namespace = '';
          FS_Orders_TrackingRule.isEnabled = true;
          FS_Orders_TrackingRule.sObjectName = 'FS_Order_Tracking__c';
          FS_Orders_TrackingRule.executionOrder = 10;
          rules.add(FS_Orders_TrackingRule);
          Framework.Config.push(rules);
      }

      @Istest
      static void ordersTrackingTestInsert(){
          Contact con =new Contact();
          con.LastName = 'Test Contact';
          insert con;
          OrderApi__Item_Class__c oItemClass = new OrderApi__Item_Class__c(Name = 'Membership');
        insert oItemClass;

        OrderApi__Item__c item = new OrderApi__Item__c(Name = 'TestItem1', OrderApi__Item_Class__c = oItemClass.Id,
                OrderApi__Price__c = 50, OrderApi__Is_Active__c = true);
        insert item;
          
          
          OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = con.Id);
        insert salesOrder;


        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder.Id,
                OrderApi__Item__c = item.Id);
        insert salesOrderLine;
          
		  FS_Order_Tracking__c orderTrackings=new FS_Order_Tracking__c();
          	orderTrackings.FS_Sales_Order__c = salesOrder.Id;
			orderTrackings.FS_Sales_Order_Line__c = salesOrderLine.Id;
          insert orderTrackings;
          List<FS_Order_Tracking__c> orderTrackingList = [SELECT Id FROM FS_Order_Tracking__c WHERE Id=:orderTrackings.Id];
          FS_Orders_Tracking FSOrdersTrackingRoutingRule = new FS_Orders_Tracking(orderTrackingList);
          FS_Orders_Tracking.Constructor cons = new FS_Orders_Tracking.Constructor();
          cons.construct(orderTrackingList);
          Framework.Dispatcher.dispatchTrigger();
          }

}