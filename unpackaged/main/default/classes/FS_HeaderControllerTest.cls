@IsTest
public class FS_HeaderControllerTest {
    
    @IsTest
    static void decodeStringTest() {
        String decodedString = FS_HeaderController.decodeString('http%3A%2F%2Fwww.google.com');
        System.assertEquals('http://www.google.com', decodedString);
    }

    @IsTest
    static void encodeStringTest() {
        String encodedString = FS_HeaderController.encodeString('http://www.google.com');
        System.assertEquals('http%3A%2F%2Fwww.google.com', encodedString);
    }
    
    @IsTest
    static void isJoinMembershipUserTest() {
        
        //Inserting Account
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        //Inserting Contact
        Contact con = new Contact(LastName = 'Lauren',FirstName = 'Test',accountId = acc.Id);
        insert con;
        
        
        //Inserting User
        User user = new User();
        user.ProfileId = [SELECT Id FROM Profile WHERE Name='Fonteva Customer Community Login User'].get(0).Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@domain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = con.Id;
        insert user;
        
          //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'test');
        insert busGroup;
        
        //Inserting Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name = 'Item Class1', OrderApi__Is_Subscription__c = true);
		insert itemClass;
            
        // Insertiing Subscription plan
        OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c(Name = '1 Year',OrderApi__Type__c = 'Calender',
        OrderApi__Is_Active__c = True, OrderApi__Initial_Term_Months__c = 12, OrderApi__Renewal_Term_Months__c = 12, OrderApi__Grace_Period__c = 90);
        insert subPlan;
        
         //Inserting Items
        OrderApi__Item__c subscriptionItem = new OrderApi__Item__c(Name = 'TextBooks',OrderApi__Item_Class__c = itemClass.Id,
        OrderApi__Is_Subscription__c = True);
        insert subscriptionItem;
        
        //Inserting SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(OrderApi__Account__c = acc.Id,OrderApi__Contact__c = con.Id,
        OrderApi__Status__c = 'Open',OrderApi__Posting_Entity__c = 'Receipt',OrderApi__Posting_Status__c = 'Pending',OrderApi__Business_Group__c = busGroup.Id);
        insert salesOrder;
        
        //Inserting SalesOrderLine
        OrderApi__Sales_Order_Line__c sOrderLine = new OrderApi__Sales_Order_Line__c(OrderApi__Item_Class__c = itemClass.Id,
        OrderApi__Item__c = subscriptionItem.Id,OrderApi__Sales_Order__c = salesOrder.Id, OrderApi__Quantity__c = 1, OrderApi__Subscription_Plan__c = subPlan.Id );
        insert sOrderLine;
        
       
       // Updating SalesOrder
        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = 'Posted';
        update salesOrder;
        
        // Inserting Subscription
        
        OrderApi__Subscription__c subscription = new OrderApi__Subscription__c(OrderApi__Item__c = subscriptionItem.Id,
        OrderApi__Entity__c = 'Contact',OrderApi__Activated_Date__c = system.today()+1,OrderApi__Subscription_Plan__c = subPlan.Id,
        OrderApi__Account__c = acc.Id,OrderApi__Contact__c = con.Id);        
		insert subscription;
        
       	Test.startTest();
        
            FS_HeaderController.isJoinMembershipUser(user.Id);
        
        Test.stopTest();
        
    }
    
}