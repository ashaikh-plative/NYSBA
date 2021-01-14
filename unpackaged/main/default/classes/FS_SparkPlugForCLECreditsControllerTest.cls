@isTest
public class FS_SparkPlugForCLECreditsControllerTest {

    @TestSetup
    private static void setUpForTest() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(LastName = 'Test',Email = 'test1@gmail.com',AccountId = acc.Id,FS_Credits_Gained__c = 100,FS_Credits_Consumed__c=20,FS_Credits_Expired__c =10);
        insert con;
        Profile  p= [SELECT Id,Name FROM Profile WHERE Name =:'Fonteva Customer Community Login User' LIMIT 1];
        User testUser = new User(Alias = 'test', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id, CommunityNickname = 'Test',
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'test@testorg.com', ContactId = con.Id);
        insert testUser;

        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
                Name='test',OrderApi__Type__c = 'Testing');
        insert busGroup;


        //Insert ItemClass
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.OrderApi__Is_Subscription__c = true;

        insert itemClass;

        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        //Insert Item
        OrderApi__Item__c item1 = new OrderApi__Item__c();
        item1.Name = 'Test Item';
        item1.OrderApi__Is_Active__c = true;
        item1.OrderApi__Item_Class__c = itemClass.Id;
        item1.FS_Allow_purchase_for_CLE_credits__c= true;
        item1.FSAreas_of_Professional_Practice_Credits__c = 400;
        item1.OrderApi__Is_Subscription__c = true;
        item1.OrderApi__Price__c = 75;
        itemList.add(item1);
        insert itemList;

        //Insert SubscriptionPlan
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c ();
        subscriptionPlan.Name = 'Test plan';
        subscriptionPlan.OrderApi__Type__c = 'Termed';
        subscriptionPlan.OrderApi__Initial_Term_Months__c = 12;
        subscriptionPlan.OrderApi__Renewal_Term_Months__c =12;
        subscriptionPlan.OrderApi__Is_Active__c = true;
        subscriptionPlan.OrderApi__Grace_Period__c = 0;
        insert subscriptionPlan;

    }
    //This Method is used to test the functionality of the Items which are eligible to apply or remove credits on the check out page.
    @isTest
    private static void getItemsToApplyAndRemoveCreditsFromSOLine(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account' LIMIT 1];
        Contact con = [SELECT Id,Name,Email,FS_Credits_Available__c FROM Contact WHERE Email =: 'test1@gmail.com' LIMIT 1];
        User testUser =[SELECT Id, Username, Contact.FS_Credits_Available__c FROM User WHERE  Username = 'test@testorg.com' LIMIT 1];
        OrderApi__Item__c item1 = [SELECT Id FROM OrderApi__Item__c WHERE Name ='Test Item' LIMIT 1];
        OrderApi__Business_Group__c busGroup = [SELECT Id FROM OrderApi__Business_Group__c WHERE Name ='test' LIMIT 1];
        OrderApi__Subscription_Plan__c subscriptionPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name ='Test plan' LIMIT 1];
        //Insert subscription
        OrderApi__Subscription__c oSub= new OrderApi__Subscription__c(OrderApi__Contact__c=con.Id ,
                OrderApi__Account__c= acc.Id,
                OrderApi__Item__c = item1.Id,
                OrderApi__Status__c = 'Active',
                OrderApi__Business_Group__c= busGroup.Id,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Subscription_Plan__c = subscriptionPlan.Id,
                OrderApi__Paid_Through_Date__c = System.today().addDays(364)
        );
        insert oSub;

        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Price_Override__c = false;
        salesOrderLine.OrderApi__Sale_Price__c =100;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.FS_CLE_Credits_Applied__c= 0.0;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        insert salesOrderLine;


        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        term.OrderApi__Subscription__c = oSub.Id;
        term.OrderApi__Grace_Period_End_Date__c =System.today().addDays(380);
        term.OrderApi__Term_Start_Date__c = System.today();
        term.OrderApi__Term_End_Date__c = System.today().addDays(364);
        term.FS_Term_Credits_Gained__c = 350;
        term.OrderApi__Is_Active__c = true;
        term.OrderApi__Sales_Order__c=salesOrder.Id;
        term.OrderApi__Sales_Order_Line__c = salesOrderLine.Id;
        term.OrderApi__Contact__c = con.Id;
        term.OrderApi__Item__c =item1.Id;
        term.FS_Term_Credits_Consumed__c = 10;

        insert term;

        OrderApi__Sales_Order_Line__c soLine1 = [SELECT Id, Name, FS_CLE_Credits_Applied__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Price_Override__c = false LIMIT 1 ];
        System.runAs(testUser){
            testUser =[SELECT Id, Username, Contact.FS_Credits_Available__c FROM User WHERE  Username = 'test@testorg.com' LIMIT 1];

            FS_SparkPlugForCLECreditsController.applyCredits(soLine1.Id);
        }
        List<OrderApi__Sales_Order_Line__c> soLine = [SELECT Id, Name, FS_CLE_Credits_Applied__c FROM OrderApi__Sales_Order_Line__c WHERE Id =: soLine1.Id AND OrderApi__Contact__c =: con.Id ];
        System.assertEquals(soLine.size(), 1);
        FS_SparkPlugForCLECreditsController.removeSOLCredits(soLine[0].Id);
    }
    //This Method is used to test the functionality of the Credits applied on the SOLine, Term and Contact Objects.
    @isTest
    private static void applyCreditsOnTheSOLine(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name =:'Test Account'];
        Contact con = [SELECT Id,Name,Email FROM Contact WHERE Email =: 'test1@gmail.com'];
        User testUser =[SELECT Id, Username FROM User WHERE  Username = 'test@testorg.com' LIMIT 1];

        OrderApi__Item__c item1 = [SELECT Id FROM OrderApi__Item__c WHERE Name ='Test Item' LIMIT 1];
        OrderApi__Business_Group__c busGroup = [SELECT Id FROM OrderApi__Business_Group__c WHERE Name ='test' LIMIT 1];
        OrderApi__Subscription_Plan__c subscriptionPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name ='Test plan' LIMIT 1];
        //Insert subscription
        OrderApi__Subscription__c oSub= new OrderApi__Subscription__c(OrderApi__Contact__c=con.Id ,
                OrderApi__Account__c= acc.Id,
                OrderApi__Item__c = item1.Id,
                OrderApi__Status__c = 'Active',
                OrderApi__Business_Group__c= busGroup.Id,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Subscription_Plan__c = subscriptionPlan.Id,
                OrderApi__Paid_Through_Date__c = System.today().addDays(364)
        );
        insert oSub;



        //SalesOrder
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Account__c = acc.Id;
        salesOrder.OrderApi__Contact__c = con.Id;
        salesOrder.OrderApi__Posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__Status__c = 'open';
        insert salesOrder;

        //SalesOrderLine
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c();
        salesOrderLine.OrderApi__Item__c = item1.Id;
        salesOrderLine.OrderApi__Price_Override__c = false;
        salesOrderLine.OrderApi__Sale_Price__c =100;
        salesOrderLine.OrderApi__Sales_Order__c = salesOrder.Id;
        salesOrderLine.OrderApi__Account__c = acc.Id;
        salesOrderLine.FS_CLE_Credits_Applied__c= 105.0;
        salesOrderLine.OrderApi__Contact__c = con.Id;
        insert salesOrderLine;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        term.OrderApi__Subscription__c = oSub.Id;
        term.OrderApi__Grace_Period_End_Date__c =System.today().addDays(380);
        term.OrderApi__Term_Start_Date__c = System.today();
        term.OrderApi__Term_End_Date__c = System.today().addDays(364);
        term.FS_Term_Credits_Gained__c = 350;
        term.OrderApi__Is_Active__c = true;
        term.OrderApi__Sales_Order__c=salesOrder.Id;
        term.OrderApi__Sales_Order_Line__c = salesOrderLine.Id;
        term.OrderApi__Contact__c = con.Id;
        term.OrderApi__Item__c =item1.Id;
        term.FS_Term_Credits_Consumed__c = 10;

        insert term;
        OrderApi__Sales_Order_Line__c soLine = [SELECT Id, Name,OrderApi__Price_Override__c ,FS_CLE_Credits_Applied__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Price_Override__c = false LIMIT 1 ];

        System.runAs(testUser) {

            List<OrderApi__Sales_Order_Line__c> soLines1 = FS_SparkPlugForCLECreditsController.applyCredits(soLine.Id);
            System.assertEquals(soLines1[0].OrderApi__Price_Override__c, true);
        }
    }
}