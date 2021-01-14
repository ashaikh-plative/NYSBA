/**
 * Created by santhosh on 07-04-2020.
 */
@IsTest
private class FS_ItemsLastModifiedRestServiceTest {
    private static final String BUSINESS_GROUP_NAME = 'NYSBA';

    @IsTest
    private static void getLastModifiedItemsTest(){


        OrderApi__Business_Group__c obusGroup = new OrderApi__Business_Group__c(Name = BUSINESS_GROUP_NAME, OrderApi__Type__c = 'test');
        insert obusGroup;

        OrderApi__Item_Class__c oItemClass = new OrderApi__Item_Class__c (Name = 'Test', FS_Is_Merchandise__c = true);
        insert oItemClass;

        OrderApi__Item__c item = new OrderApi__Item__c(Name='Test Item', Is_Test_Data__c = true, OrderApi__Is_Event__c = false,
                OrderApi__Business_Group__c = obusGroup.Id, OrderApi__Is_Subscription__c = false, OrderApi__Item_Class__c = oItemClass.Id);
        insert item;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/itemsLastModified/10';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<OrderApi__Item__c> itemsList = FS_ItemsLastModifiedRestService.getItemsList();
        System.assert(itemsList != null);
        System.assertEquals(1, itemsList.size());
        System.assertEquals(item.Id, itemsList[0].Id);
        Test.stopTest();
    }

    @IsTest
    private static void getLastModifiedEventObjectsTest(){
        OrderApi__Business_Group__c obusGroup = new OrderApi__Business_Group__c(Name = BUSINESS_GROUP_NAME, OrderApi__Type__c = 'test');
        insert obusGroup;

        OrderApi__Item_Class__c oItemClass = new OrderApi__Item_Class__c (Name = 'Test', FS_Is_Merchandise__c = true);
        insert oItemClass;

        OrderApi__Item__c item = new OrderApi__Item__c(Name='Test Item', Is_Test_Data__c = true, OrderApi__Is_Event__c = false,
                OrderApi__Business_Group__c = obusGroup.Id, OrderApi__Is_Subscription__c = false, OrderApi__Item_Class__c = oItemClass.Id);
        insert item;

        OrderApi__Price_Rule__c pr = new OrderApi__Price_Rule__c(Name='Test Price Rule', OrderApi__Price__c = 12, Is_Test_Data__c = true, OrderApi__Item__c = item.Id);
        insert pr;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/itemsLastModified/10';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<OrderApi__Item__c> itemsList = FS_ItemsLastModifiedRestService.getItemsList();
        System.assert(itemsList != null);
        System.assertEquals(1, itemsList.size());
        System.assertEquals(item.Id, itemsList[0].Id);
        Test.stopTest();
    }

    @IsTest
    private static void invalidLastNDaysTest(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/itemsLastModified/text';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<OrderApi__Item__c> itemsList = FS_ItemsLastModifiedRestService.getItemsList();
        System.assert(itemsList != null);
        System.assertEquals(0, itemsList.size());
        System.assertEquals(400, res.statusCode);
        Test.stopTest();
    }

    @IsTest
    private static void invalidURLTest(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/itemsLastModified/10/';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        List<OrderApi__Item__c> itemsList = FS_ItemsLastModifiedRestService.getItemsList();
        System.assert(itemsList != null);
        System.assertEquals(0, itemsList.size());
        System.assertEquals(400, res.statusCode);
        Test.stopTest();
    }
}