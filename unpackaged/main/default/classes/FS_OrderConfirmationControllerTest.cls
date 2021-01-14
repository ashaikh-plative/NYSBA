@isTest
public class FS_OrderConfirmationControllerTest {
    private static final String FS_PAYMENT_SUCCESSFUL='Payment Successful';
    private static  String orderNumber;
    @isTest
    private static void FS_OrderConfirm(){
        Account a = new Account(Name = 'Test Account', ShippingCountry = 'United States');
        insert a;
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = a.Id, OrderApi__Personal_Email__c = 'fsemailupdatetest@example.com',
                                OrderApi__Preferred_Email_Type__c = 'Personal');
        insert c;
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test');
        insert busGroup;
        
        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = 'Test',
                                                                       OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = false);
        insert itemClass;
        OrderApi__Item__c  item1 = new OrderApi__Item__c(Name='Test Chapter1',
                                                         OrderApi__Business_Group__c = busGroup.Id,
                                                         OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = false,
                                                        OrderApi__Is_Active__c = true, OrderApi__Price__c = 70);
        OrderApi__Sales_Order__c salesOrderOne = new OrderApi__Sales_Order__c(OrderApi__Contact__c = c.Id,OrderApi__Posting_Status__c='Pending',OrderApi__Status__c='Open');
        insert salesOrderOne;
        OrderApi__Sales_Order_Line__c soLine=new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=salesOrderOne.Id,OrderApi__Item__c=item1.Id,OrderApi__Item_Class__c=itemClass.Id);
        insert soLine;
        OrderApi__Sales_Order__c so = [SELECT Id, Name FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderOne.Id LIMIT 1];
        if(so != null){
            Map<String, Object> result = FS_OrderConfirmationController.getOrderNumberApex(so.Name);
            System.assertNotEquals(null, result);
            System.assertEquals('Order Confirmation', result.get('buttonLabel'));
        }

        OrderApi__Receipt__c receipt=new OrderApi__Receipt__c(OrderApi__Contact__c=c.Id,OrderApi__Total__c=250);
        insert receipt;

        OrderApi__Receipt__c rec=[SELECT Id,Name FROM OrderApi__Receipt__c WHERE Id=:receipt.Id LIMIT 1];
        if(rec != null){
            Map<String, Object> result = FS_OrderConfirmationController.getOrderNumberApex(rec.Name);
            System.assertNotEquals(null, result);
            System.assertEquals('Order Confirmation', result.get('buttonLabel'));
        }
    }

    @IsTest
    private static void testEventItem(){
        Account a = new Account(Name = 'Test Account1', ShippingCountry = 'United States');
        insert a;

        Contact c = new Contact(FirstName = 'Test',
                LastName = 'Contact1',
                AccountId = a.Id,
                OrderApi__Personal_Email__c = 'fsemailupdatetest1@example.com',
                OrderApi__Preferred_Email_Type__c = 'Personal'
        );
        insert c;

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test');
        insert busGroup;

        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = 'Test',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Event__c = true
        );
        insert itemClass;

        OrderApi__Item__c  item1 = new OrderApi__Item__c(Name='Test Chapter1',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Event__c = true,
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 70
        );
        insert item1;

        OrderApi__Sales_Order__c salesOrderOne = new OrderApi__Sales_Order__c(OrderApi__Contact__c = c.Id,
                OrderApi__Posting_Status__c='Pending',
                OrderApi__Status__c='Open'
        );
        insert salesOrderOne;

        OrderApi__Sales_Order_Line__c soLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=salesOrderOne.Id,
                OrderApi__Item__c=item1.Id,
                OrderApi__Item_Class__c=itemClass.Id
        );
        insert soLine;

        OrderApi__Sales_Order__c so = [SELECT Id, Name FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderOne.Id LIMIT 1];
        if(so != null){
            Map<String, Object> result = FS_OrderConfirmationController.getOrderNumberApex(so.Name);
            System.assertNotEquals(null, result);
            System.assertEquals('Order Confirmation', result.get('buttonLabel'));
        }

        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Contact__c = c.Id,
                OrderApi__Total__c = 250);
        insert receipt;

        OrderApi__Receipt_Line__c receiptLine = new OrderApi__Receipt_Line__c(OrderApi__Contact__c = c.Id,
        OrderApi__Sales_Order_Line__c = soLine.Id,
        OrderApi__Receipt__c = receipt.Id,
        OrderApi__Item__c = item1.Id
        );
        insert receiptLine;

        // Inserting Event Category
        EventApi__Event_Category__c eCategory = new EventApi__Event_Category__c(
                Name='My Meeting',
                EventApi__Business_Group__c = busGroup.Id
        );
        insert eCategory;

        Datetime todayDate = Datetime.now();
        String eventTime = todayDate.format('HH:mm:ss','America/New_York');
        // Inserting EVent
        EventApi__Event__c event=new EventApi__Event__c(
                EventApi__Event_Category__c = eCategory.Id,
                Name = 'My Summit Meeting',
                EventApi__Status__c = 'Active',
                EventApi__Business_Group__c = busGroup.Id,
                EventApi__Event_Key__c = '15506a-b170ac-1',
                EventApi__Start_Date__c = System.today().addDays(25),
                EventApi__End_Date__c = System.today().addDays(30),
                EventApi__Start_Time__c = eventTime,
                EventApi__End_Time__c = eventTime
        );
        insert event;

        EventApi__Attendee__c attendee = new EventApi__Attendee__c(EventApi__Contact__c = c.Id,
                EventApi__Sales_Order_Line__c = soLine.Id,
                EventApi__Sales_Order__c = salesOrderOne.Id,
                EventApi__Event__c = event.Id
        );
        insert attendee;

        OrderApi__Receipt__c rec = [SELECT Id,Name FROM OrderApi__Receipt__c WHERE Id=:receipt.Id LIMIT 1];
        if(rec != null){
            List<Object> result = FS_OrderConfirmationController.getEventReceiptLines(rec.Name);
            System.assertNotEquals(null, result);
        }
    }
}