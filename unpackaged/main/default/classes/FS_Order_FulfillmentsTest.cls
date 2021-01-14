@Istest
public class FS_Order_FulfillmentsTest {
    
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_Order_FulfillmentsRule = new Framework.RoutingRule();
        FS_Order_FulfillmentsRule.apexClass = FS_Order_Fulfillments.class.getName();
        FS_Order_FulfillmentsRule.namespace = '';
        FS_Order_FulfillmentsRule.isEnabled = true;
        FS_Order_FulfillmentsRule.sObjectName = 'FS_Order_Fulfillment__c';
        FS_Order_FulfillmentsRule.executionOrder = 10;
        rules.add(FS_Order_FulfillmentsRule);
        Framework.Config.push(rules);
    }
    
    @istest
    private static void FS_Order_FulfillmentsTestInsert(){
        //inserting orderTracking
        FS_Order_Tracking__c order=new FS_Order_Tracking__c();
        insert order;
        
        //inserting order fullfillmentList
        List<FS_Order_Fulfillment__c> orderList=new List<FS_Order_Fulfillment__c>();
        FS_Order_Fulfillment__c orderFullfill=new FS_Order_Fulfillment__c(FS_Order_Tracking__c=order.Id);
        orderList.add(orderFullfill);
        insert orderList;
        
        FS_Order_Fulfillments sRule=new FS_Order_Fulfillments(orderList);
        FS_Order_Fulfillments.Constructor fscc=new FS_Order_Fulfillments.Constructor();
        fscc.construct(orderList);
        
    }
}