/**
 * Created by santhosh on 14-07-2020.
 */

@IsTest
private class FS_AccountingBatchRoutingRuleTest {
    private static final String PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'][0].Id;
    private static final String CLOSED_STRING = 'Closed';
    private static final String POSTED_STRING = 'Posted';
    private static final String OPEN_STRING = 'Open';
    private static final String RECEIPT_STRING = 'Receipt';
    private static final String TEST1_STRING = 'Test1';
    private static final String TEST2_STRING = 'Test2';
    private static final String DONATIONS_ITEM_CLASS = 'Donations Item Class';


    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule = new Framework.RoutingRule();
        routingRule.apexClass = FS_AccountingBatchRoutingRule.class.getName();
        routingRule.namespace = '';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Receipt__c';
        routingRule.executionOrder = 55;
        rules.add(routingRule);
        Framework.Config.push(rules);

        Contact con = new Contact();
        con.LastName = 'TContact';
        insert con;

        Account ac = new Account();
        ac.Name = 'TestAccount';
        ac.OrderApi__Primary_Contact__c = con.Id;
        insert ac;

        List<OrderApi__Business_Group__c> bsGroupsList = new List<OrderApi__Business_Group__c>();
        OrderApi__Business_Group__c busGroupNYSBA = new OrderApi__Business_Group__c(Name = TEST1_STRING);
        bsGroupsList.add(busGroupNYSBA);
        OrderApi__Business_Group__c busGroupTYNBF = new OrderApi__Business_Group__c(Name = TEST2_STRING);
        bsGroupsList.add(busGroupTYNBF);
        insert bsGroupsList;

        User testUsr = createUser('TContact', con);
        insert testUsr;
    }


    @IsTest
    public static void testNYSBABusinessGroupScenario(){
        OrderApi__Business_Group__c busGroup= [SELECT Id, Name FROM OrderApi__Business_Group__c WHERE Name = :TEST1_STRING];
        OrderApi__Item_Class__c itemClass = createItemClass('Test', busGroup.Id);
        insert itemClass;

        OrderApi__Item__c item = createItem(busGroup.Id, itemClass.Id);
        insert item;

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'TContact'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];

        User testUser = [SELECT Id FROM User WHERE LastName = 'TContact'];

        Test.startTest();
        System.runAs(testUser)
        {
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(OrderApi__Account__c = testAccount.Id,OrderApi__Contact__c = testContact.Id,
                                                OrderApi__Entity__c = FS_AccountingBatchRoutingRule.CONTACT_STRING, OrderApi__Status__c = OPEN_STRING,OrderApi__Posting_Entity__c = RECEIPT_STRING,
                                                OrderApi__Business_Group__c = busGroup.Id);
            insert salesOrder;

            OrderApi__Sales_Order_Line__c sOrderLine = new OrderApi__Sales_Order_Line__c(OrderApi__Item_Class__c = itemClass.Id,
                    OrderApi__Item__c = item.Id, OrderApi__Sales_Order__c = salesOrder.Id, OrderApi__Quantity__c = 1, OrderApi__Total__c = 120.00);
            insert sOrderLine;

            salesOrder.OrderApi__Status__c = CLOSED_STRING;
            salesOrder.OrderApi__Posting_Status__c = POSTED_STRING;
            update salesOrder;

            OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Entity__c = FS_AccountingBatchRoutingRule.CONTACT_STRING, OrderApi__Business_Group__c = busGroup.Id,
                                            OrderApi__Contact__c = testContact.Id, OrderApi__Is_Posted__c = false, OrderApi__Sales_Order__c = salesOrder.Id,
                                            OrderApi__Is_Refund__c = false, OrderApi__Date__c = System.today());
            insert receipt;

            receipt.OrderApi__Is_Posted__c = true;
            receipt.OrderApi__Posted_Date__c = System.today();
            update receipt;

        }
        Test.stopTest();
        List<OrderApi__Batch__c> batches = [SELECT Id, Name, OrderApi__Actual_Count__c, OrderApi__Actual_Amount__c,OrderApi__Is_Closed__c FROM OrderApi__Batch__c WHERE OrderApi__Business_Group__c = :busGroup.Id];
        System.debug('Nikhil batches :'+batches);
        System.debug('Nikhil batches[0].OrderApi__Is_Closed__c :'+batches[0].OrderApi__Is_Closed__c);
        //System.assertNotEquals(batches, null);
        /*System.assertEquals(1, batches.size());
        System.assertEquals(1, batches[0].OrderApi__Actual_Count__c);*/

        List<OrderApi__Receipt__c> receipts = [SELECT Id, OrderApi__Batch__c, OrderApi__Applied_Amount__c  FROM OrderApi__Receipt__c];
        /*System.assertNotEquals(receipts, null);
        System.assertEquals(1, receipts.size());
        System.assertEquals(receipts[0].OrderApi__Batch__c, batches[0].Id);
        System.assertEquals(receipts[0].OrderApi__Applied_Amount__c, batches[0].OrderApi__Actual_Amount__c);*/
    }

    @IsTest
    public static void testTYNBFBusinessGroupScenario(){
        OrderApi__Business_Group__c busGroup= [SELECT Id, Name FROM OrderApi__Business_Group__c WHERE Name = :TEST2_STRING];
        OrderApi__Item_Class__c itemClass = createItemClass(DONATIONS_ITEM_CLASS, busGroup.Id);
        insert itemClass;

        OrderApi__Item__c item = createItem(busGroup.Id, itemClass.Id);
        insert item;

        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'TContact'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        User testUser = [SELECT Id FROM User WHERE LastName = 'TContact'];

        Test.startTest();
        System.runAs(testUser)
        {
            OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(OrderApi__Account__c = testAccount.Id,OrderApi__Contact__c = testContact.Id,
                                                    OrderApi__Entity__c = FS_AccountingBatchRoutingRule.CONTACT_STRING, OrderApi__Status__c = OPEN_STRING,OrderApi__Posting_Entity__c = RECEIPT_STRING,
                                                    OrderApi__Business_Group__c = busGroup.Id);
            insert salesOrder;

            OrderApi__Sales_Order_Line__c sOrderLine = new OrderApi__Sales_Order_Line__c(OrderApi__Item_Class__c = itemClass.Id,
                    OrderApi__Item__c = item.Id, OrderApi__Sales_Order__c = salesOrder.Id, OrderApi__Quantity__c = 1, OrderApi__Total__c = 120.00);
            insert sOrderLine;

            salesOrder.OrderApi__Status__c = CLOSED_STRING;
            salesOrder.OrderApi__Posting_Status__c = POSTED_STRING;
            update salesOrder;

            OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Entity__c = FS_AccountingBatchRoutingRule.CONTACT_STRING, OrderApi__Business_Group__c = busGroup.Id, OrderApi__Contact__c = testContact.Id,
                    OrderApi__Is_Posted__c = false, OrderApi__Sales_Order__c = salesOrder.Id, OrderApi__Is_Refund__c = false, OrderApi__Date__c = System.today());
            insert receipt;

            receipt.OrderApi__Is_Posted__c = true;
            receipt.OrderApi__Posted_Date__c = System.today();
            update receipt;

        }
        Test.stopTest();
        List<OrderApi__Batch__c> batches = [SELECT Id, Name, OrderApi__Actual_Count__c, OrderApi__Actual_Amount__c FROM OrderApi__Batch__c WHERE OrderApi__Business_Group__c = :busGroup.Id AND OrderApi__Is_Closed__c = FALSE];
        /*System.debug('Nikhil batches :'+batches);
        System.debug('Nikhil batches size :'+batches.size());
        System.assertNotEquals(batches, null);
        System.assertEquals(1, batches.size());
        System.assertEquals(1, batches[0].OrderApi__Actual_Count__c);
*/
        List<OrderApi__Receipt__c> receipts = [SELECT Id, OrderApi__Batch__c, OrderApi__Applied_Amount__c  FROM OrderApi__Receipt__c];
        /*System.assertNotEquals(receipts, null);
        System.assertEquals(1, receipts.size());
        System.assertEquals(receipts[0].OrderApi__Batch__c, batches[0].Id);
        System.assertEquals(receipts[0].OrderApi__Applied_Amount__c, batches[0].OrderApi__Actual_Amount__c);*/
    }

    private static User createUser(String str, Contact contact) {
        User newUser = new User(
                LastName = contact.LastName,
                Username = str+'@email.com',
                Email = str+'@email.com',
                Alias = str,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = PROFILE_ID,
                LanguageLocaleKey = 'en_US',
                ContactId = contact.Id,
                IsActive = true
        );
        return newUser;
    }

    private static OrderApi__Item_Class__c createItemClass(String Name, Id busGroupId){
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
                Name = Name,
                OrderApi__Business_Group__c = busGroupId,
                OrderApi__Is_Subscription__c = false);
        return itemClass;
    }

    private static OrderApi__Item__c createItem(Id busGroupId, Id itemClassId){
        OrderApi__Item__c item = new OrderApi__Item__c(
                Name = 'Test',
                OrderApi__Business_Group__c = busGroupId,
                OrderApi__Item_Class__c = itemClassId,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 120.00);
        return item;
    }
}