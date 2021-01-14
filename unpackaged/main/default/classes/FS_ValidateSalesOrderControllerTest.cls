@IsTest
public class FS_ValidateSalesOrderControllerTest {
    @IsTest
    static void test1() {
        OrderApi__Business_Group__c businessGroup = new OrderApi__Business_Group__c(Name='test');
        insert businessGroup;

        Account acc = new Account(Name='Test');
        insert acc;

        Contact con = new Contact(FirstName='Contact',LastName='Test', Email='test@fusionspan.com',AccountId=acc.Id);
        insert con;

        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name='Test Item Class',OrderApi__Is_Subscription__c=true,FS_Is_Membership__c=true);
        insert itemClass;
        OrderApi__Item__c item = new OrderApi__Item__c(
                Name='Test Item',OrderApi__Item_Class__c=itemClass.Id,OrderApi__Is_Subscription__c=true,OrderApi__Price__c=1,OrderApi__Business_Group__c=businessGroup.Id);
        insert item;

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c=con.Id,OrderApi__Entity__c='Contact',OrderApi__Status__c='Open');
        insert so;

        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c=item.Id,OrderApi__Sales_Order__c=so.Id);
        insert soLine;

        PageReference pageRef = Page.FS_ValidateSalesOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('soId', so.Id);
        System.assertEquals('login', FS_ValidateSalesOrderController.getValidationResult());
    }

    @IsTest
    static void test2() {
        OrderApi__Business_Group__c businessGroup = new OrderApi__Business_Group__c(Name='test');
        insert businessGroup;

        Account acc = new Account(Name='Test');
        insert acc;

        Contact con = new Contact(FirstName='Contact',LastName='Test', Email='test@fusionspan.com',AccountId=acc.Id);
        insert con;

        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name='Donations Item Class',OrderApi__Is_Subscription__c=true,FS_Is_Membership__c=true);
        insert itemClass;
        OrderApi__Item__c item = new OrderApi__Item__c(
                Name='Test Item',OrderApi__Item_Class__c=itemClass.Id,OrderApi__Is_Subscription__c=true,OrderApi__Price__c=1,OrderApi__Business_Group__c=businessGroup.Id);
        insert item;

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c=con.Id,OrderApi__Entity__c='Contact',OrderApi__Status__c='Open');
        insert so;

        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c=item.Id,OrderApi__Sales_Order__c=so.Id);
        insert soLine;

        PageReference pageRef = Page.FS_ValidateSalesOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('soId', so.Id);
        System.assertEquals('guest', FS_ValidateSalesOrderController.getValidationResult());
    }
}