@IsTest
private class FS_GetToCorrectCartSparkPlugTest {
    @TestSetup
    private static void setup() {
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test Business Group');
        insert busGroup;
        PagesApi__Site__c site = new PagesApi__Site__c(
                Name = 'Test Site', OrderApi__Business_Group__c = busGroup.Id
        );
        insert site;


        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
                Name = 'Test',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Subscription__c = false);
        insert itemClass;

        OrderApi__Item__c item = new OrderApi__Item__c(
                Name = 'Test',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 0);
        insert item;

        Account a = new Account(Name = 'Test Account', ShippingCountry = 'United States');
        insert a;

        Contact c = new Contact(FirstName = 'Test Account', LastName = 'Contact', AccountId = a.Id, OrderApi__Personal_Email__c = 'fsemailupdatetest@example.com', OrderApi__Preferred_Email_Type__c = 'Personal');
        insert c;

        Profile prf = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'];

        User u = new User(
                Username='fsemailupdatetest@example.com',
                Email='fsemailupdatetest@example.com',
                LastName='test',
                Alias='test',
                CommunityNickname='test12341234',
                TimeZoneSidKey='America/Los_Angeles',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId = prf.Id,
                ContactId=c.Id);
        insert u;

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(
                OrderApi__Contact__c=c.Id,OrderApi__Entity__c='Contact',OrderApi__Status__c='Open');
        insert so;

        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Item__c=item.Id,OrderApi__Sales_Order__c=so.Id);
        insert soLine;

        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        update so;
    }

    @IsTest
    private static void test() {
        User u = [SELECT Id, ContactId FROM User WHERE Username = :'fsemailupdatetest@example.com'];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c = :u.ContactId];
        System.runAs(u) {
            FS_GetToCorrectCartSparkPlugController.getCorrectSalesOrder(so.Id);
        }
    }
}