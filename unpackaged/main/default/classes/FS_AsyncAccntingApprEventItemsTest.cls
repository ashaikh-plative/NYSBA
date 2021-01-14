/**
 * Created by Nikhil on 12-03-2020.
 */
@IsTest
public with sharing class FS_AsyncAccntingApprEventItemsTest {
    private static final String REQ_APPROVAL_STRING = 'Request Approval';
    @IsTest
    private static void eventItemTest() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Event Item Class');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        Set<Id> itemsIdSet = new Set<Id>();
        OrderApi__Item__c item = FS_TestUtils.createItem('Event Item', itemClass.Id);
        item.OrderApi__Business_Group__c = busGroup.Id;
        item.FS_Accounting_Approval__c = REQ_APPROVAL_STRING;
        item.OrderApi__Is_Event__c = true;
        item.OrderApi__Is_Active__c = true; 
        insert item;
        itemsIdSet.add(item.Id);

        Test.startTest();
        FS_AsyncAccountingApprovalForEventItems sc = new FS_AsyncAccountingApprovalForEventItems(itemsIdSet);
        String cron = '0 2 * * * ?';
        System.schedule('Event Item Update', cron, sc);
        Test.stopTest();

        List<OrderApi__Item__c> items = [
                SELECT Id,OrderApi__Is_Active__c,OrderApi__Is_Event__c,FS_Accounting_Approval__c
                FROM OrderApi__Item__c
        ];

        System.assertEquals(true, items[0].OrderApi__Is_Event__c);
        System.assertEquals(false, items[0].OrderApi__Is_Active__c);
        System.assertEquals(REQ_APPROVAL_STRING, items[0].FS_Accounting_Approval__c);
    }
}