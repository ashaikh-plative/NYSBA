/**
 * Created by santhosh on 15-07-2020.
 */

@IsTest
private class FS_AccountingBatchesClosingJobTest {

    @TestSetup
    private static void install() {
        List<OrderApi__Business_Group__c> bsGroupsList = new List<OrderApi__Business_Group__c>();
        OrderApi__Business_Group__c busGroupNYSBA = new OrderApi__Business_Group__c(Name = FS_AccountingBatchesClosingJob.NYSBA_STRING);
        bsGroupsList.add(busGroupNYSBA);
        OrderApi__Business_Group__c busGroupTNYBF = new OrderApi__Business_Group__c(Name = FS_AccountingBatchesClosingJob.TNYBF_STRING);
        bsGroupsList.add(busGroupTNYBF);
        insert bsGroupsList;
    }

    @IsTest
    public static void testClosingNYSBABatch(){
        OrderApi__Business_Group__c busGroup= [SELECT Id, Name FROM OrderApi__Business_Group__c WHERE Name = :FS_AccountingBatchesClosingJob.NYSBA_STRING];
        Datetime timeNow = Datetime.now().addHours(-4);
        String todayDDMMYYYYDate = timeNow.format(FS_AccountingBatchesClosingJob.DDMMYYYY_FORMAT);

        OrderApi__Batch__c batch = createBatch('Portal NYSBA '+ todayDDMMYYYYDate, busGroup.Id);
        insert batch;

        Test.startTest();
        Database.executeBatch(new FS_AccountingBatchesClosingJob());
        Test.stopTest();

        List<OrderApi__Batch__c> batches = [SELECT Id, Name, OrderApi__Actual_Count__c, OrderApi__Actual_Amount__c, OrderApi__Expected_Count__c, OrderApi__Expected_Amount__c,
                                            OrderApi__Is_Closed__c, OrderApi__Closed_Date__c FROM OrderApi__Batch__c WHERE OrderApi__Business_Group__c = :busGroup.Id AND OrderApi__Is_Closed__c = TRUE];
        System.assertNotEquals(batches, null);
        System.assertEquals(1, batches.size());
        System.assertEquals('Portal NYSBA '+ todayDDMMYYYYDate, batches[0].Name);
        System.assertEquals(2, batches[0].OrderApi__Actual_Count__c);
        System.assertEquals(367.12, batches[0].OrderApi__Actual_Amount__c);
        System.assertEquals(batches[0].OrderApi__Expected_Amount__c, batches[0].OrderApi__Actual_Amount__c);
        System.assertEquals(batches[0].OrderApi__Expected_Count__c, batches[0].OrderApi__Actual_Count__c);
    }

    @IsTest
    public static void testClosingTNYBFBatch(){
        OrderApi__Business_Group__c busGroup= [SELECT Id, Name FROM OrderApi__Business_Group__c WHERE Name = :FS_AccountingBatchesClosingJob.TNYBF_STRING];
        Datetime timeNow = Datetime.now().addHours(-4);
        String todayDDMMYYDate = timeNow.format(FS_AccountingBatchesClosingJob.DDMMYY_FORMAT);

        OrderApi__Batch__c batch = createBatch('Portal TNYBF '+ todayDDMMYYDate, busGroup.Id);
        insert batch;

        Test.startTest();
        Database.executeBatch(new FS_AccountingBatchesClosingJob());
        Test.stopTest();


        List<OrderApi__Batch__c> batches = [SELECT Id, Name, OrderApi__Actual_Count__c, OrderApi__Actual_Amount__c, OrderApi__Expected_Count__c, OrderApi__Expected_Amount__c,
                OrderApi__Is_Closed__c, OrderApi__Closed_Date__c FROM OrderApi__Batch__c WHERE OrderApi__Business_Group__c = :busGroup.Id AND OrderApi__Is_Closed__c = TRUE];
        System.assertNotEquals(batches, null);
        System.assertEquals(1, batches.size());
        System.assertEquals('Portal TNYBF '+ todayDDMMYYDate, batches[0].Name);
        System.debug('Santhosh 1:'+'Portal TNYBF '+ todayDDMMYYDate);
        System.debug('Santhosh 2:'+batches[0].Name);
        System.assertEquals(2, batches[0].OrderApi__Actual_Count__c);
        System.assertEquals(367.12, batches[0].OrderApi__Actual_Amount__c);
        System.assertEquals(batches[0].OrderApi__Expected_Amount__c, batches[0].OrderApi__Actual_Amount__c);
        System.assertEquals(batches[0].OrderApi__Expected_Count__c, batches[0].OrderApi__Actual_Count__c);
    }

    private static OrderApi__Batch__c createBatch(String name, Id busGroupId){
        OrderApi__Batch__c batch = new OrderApi__Batch__c();
        batch.Name = name;
        batch.OrderApi__Expected_Count__c = null;
        batch.OrderApi__Expected_Amount__c = null;
        batch.OrderApi__Business_Group__c = busGroupId;
        batch.OrderApi__Entity__c = 'Contact';
        batch.OrderApi__Payment_Type__c = 'Credit Card';
        batch.OrderApi__Actual_Count__c = 2;
        batch.OrderApi__Actual_Amount__c = 367.12;

        return batch;
    }
}