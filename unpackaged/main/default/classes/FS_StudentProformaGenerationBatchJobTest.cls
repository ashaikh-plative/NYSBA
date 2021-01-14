/**
 * Created by santhosh on 26-02-2020.
 */
@IsTest
private class FS_StudentProformaGenerationBatchJobTest {
    private static final String ACTIVE_STRING = 'Active';
    private static final String CLOSED_STRING = 'Closed';
    private static final String PENDING_STRING = 'Pending';
    private static final String RECEIPT_STRING = 'Receipt';
    private static final String CONTACT_STRING = 'Contact';
    private static final String LAW_STUDENT = 'Law Student';

    @IsTest
    private static void renewStudentMembership(){
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.FS_Graduation_Date__c = System.today()+365;
        insert con;

        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name='Test');
        insert busGroup;

        OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c(Name = 'TestSubPlan',OrderApi__Business_Group__c=busGroup.Id,
                OrderApi__Invoice_Days_Variable__c = 90);
        insert subPlan;

        //Inserting Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name='Test item', OrderApi__Business_Group__c=busGroup.Id, FS_Is_Membership__c = true);
        insert itemClass;

        //Inserting Item
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Item__c item = new OrderApi__Item__c(Name=LAW_STUDENT,
                OrderApi__Item_Class__c=itemClass.Id,
                OrderApi__Business_Group__c=busGroup.Id);
        insert item;
        itemList.add(item);

        OrderApi__Subscription__c subscription = new OrderApi__Subscription__c(OrderApi__Contact__c = con.Id, OrderApi__Item__c=item.Id, OrderApi__Entity__c = CONTACT_STRING,
                OrderApi__Status__c=ACTIVE_STRING, OrderApi__Subscription_Plan__c=subPlan.Id);
        insert subscription;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=subscription.Id,OrderApi__Contact__c=con.Id, OrderApi__Term_Start_Date__c = System.today()- 150,
                OrderApi__Is_Active__c=true, OrderApi__Item__c=item.Id, OrderApi__Subscription_Plan__c = subPlan.Id, OrderApi__Term_End_Date__c=System.today()+89);
        insert term;

        Test.startTest();
        Database.executeBatch(new FS_StudentProformaGenerationBatchJob());
        Test.stopTest();
        List<OrderApi__Sales_Order__c> soList = [SELECT Id,OrderApi__Contact__c, OrderApi__Status__c, OrderApi__Entity__c, OrderApi__Posting_Entity__c,
                                                OrderApi__Posting_Status__c, (SELECT Id, OrderApi__Item__c FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c];

        System.assertEquals(soList.size(), 1);
        System.assertEquals(soList[0].OrderApi__Status__c, CLOSED_STRING);
        System.assertEquals(soList[0].OrderApi__Entity__c, CONTACT_STRING);
        System.assertEquals(soList[0].OrderApi__Posting_Entity__c, RECEIPT_STRING);
        System.assertEquals(soList[0].OrderApi__Posting_Status__c, PENDING_STRING);
        System.assertEquals(soList[0].OrderApi__Sales_Order_Lines__r.size(), 1);
        System.assertEquals(soList[0].OrderApi__Sales_Order_Lines__r[0].OrderApi__Item__c, item.Id);
    }
}