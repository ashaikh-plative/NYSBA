/**
 * Created by Nikhil on 02-09-2020.
 */

@IsTest
public without sharing class FS_AbandonedShoppingCartBatchTest {
    private static final String FON_COMMUNITY_USER = 'Fonteva Customer Community Login User';
    @IsTest
    static void sendEmailIfSalesOrderIsOpenForAnHour() {
        Account acc = new Account(Name = 'Test');
        insert acc;

        Contact con = new Contact(LastName = 'Test1', AccountId = acc.Id, Email = 'test+123@fusionspan.com',OrderApi__Personal_Email__c = 'test+123@fusionspan.com',OrderApi__Preferred_Email_Type__c='Personal');
        insert con;
        Profile profileId = [SELECT Id,Name FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1];
        User usr = new User(LastName = 'Test',
                FirstName = 'User',
                Alias = 'tuser',
                Email = 'test@fusionspan.com',
                Username = 'test@fusionspan.com',
                ContactId = con.Id,
                ProfileId = profileId.Id,
                TimeZoneSidKey = 'GMT',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US'
        );
        insert usr;
        System.runAs(usr) {

            //Inserting Business Group
            OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test');
            insert busGroup;

            OrderApi__Sales_Order__c salesOrder = FS_TestUtils.createSalesOrder(con.Id, acc.Id, 'Receipt', 'open');
            salesOrder.OrderApi__Business_Group__c = busGroup.Id;
            insert salesOrder;

            // Itemclass
            OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('TestItem');
            itemClass.OrderApi__Business_Group__c = busGroup.Id;
            insert itemClass;

            // Item
            OrderApi__Item__c item = FS_TestUtils.createItem('Test Item', itemClass.Id);
            item.OrderApi__Business_Group__c = busGroup.Id;
            insert item;

            //sales order lines
            OrderApi__Sales_Order_Line__c salesOrderLine1 = new OrderApi__Sales_Order_Line__c(
                    OrderApi__Item_Class__c = itemClass.Id,
                    OrderApi__Item__c = item.Id,
                    OrderApi__Business_Group__c = busGroup.Id,
                    OrderApi__Sales_Order__c = salesOrder.Id);
            insert salesOrderLine1;

            salesOrder.LastModifiedBy = usr;
            update salesOrder;
        }

        Test.startTest();
        FS_AbandonedShoppingCartBatch scheduler = new FS_AbandonedShoppingCartBatch();
        scheduler.execute(null);
        Test.stopTest();
    }
}