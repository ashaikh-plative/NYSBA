/**
 * Created by santhosh on 06-07-2020.
 */

global class FS_AccountingBatchesClosingJob  implements Database.Batchable<SObject>, Schedulable {

    @TestVisible
    private static final String DDMMYY_FORMAT = 'ddMMYY';
    @TestVisible
    private static final String DDMMYYYY_FORMAT = 'ddMMYYYY';
    @TestVisible
    private static final String NYSBA_STRING = 'NYSBA';
    @TestVisible
    private static final String TNYBF_STRING = 'TNYBF';

    private static Set<String> batchNamesSet;
    static{
        batchNamesSet = new Set<String>();
        Map<Id, String> batchNamesMap = getBatchNamesMap();
        if(batchNamesMap != null){
            for(String batchName : batchNamesMap.values()){
                batchNamesSet.add(batchName);
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OrderApi__Opened_Date__c, OrderApi__Actual_Count__c, OrderApi__Actual_Amount__c ' +
                ' FROM OrderApi__Batch__c WHERE OrderApi__Is_Closed__c = FALSE AND Name IN :batchNamesSet';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        for(OrderApi__Batch__c batch : (List<OrderApi__Batch__c>)scope){
            batch.OrderApi__Expected_Count__c = batch.OrderApi__Actual_Count__c;
            batch.OrderApi__Expected_Amount__c = batch.OrderApi__Actual_Amount__c;
            batch.OrderApi__Is_Closed__c = true;
            batch.OrderApi__Closed_Date__c = System.today();
        }
        update scope;
    }

    private static Map<Id, String> getBatchNamesMap(){
        List<FS_Accounting_Batch_Settings__mdt> accBatchSettings;
        if(!Test.isRunningTest()){
            accBatchSettings = [SELECT Id,FS_Batch_Name_Format__c, FS_Business_Group_Id__c FROM FS_Accounting_Batch_Settings__mdt];
        }else{
            accBatchSettings = new List<FS_Accounting_Batch_Settings__mdt>();
            for(OrderApi__Business_Group__c bsGroup : [SELECT Id, Name FROM OrderApi__Business_Group__c WHERE Name IN ('NYSBA', 'TNYBF')]){
                FS_Accounting_Batch_Settings__mdt setting = new FS_Accounting_Batch_Settings__mdt();
                if(NYSBA_STRING.equalsIgnoreCase(bsGroup.Name)){
                    setting.FS_Batch_Name_Format__c = 'Portal NYSBA DDMMYYYY';
                }else{
                    setting.FS_Batch_Name_Format__c = 'Portal TNYBF DDMMYY';
                }
                setting.MasterLabel = bsGroup.Name;
                setting.FS_Business_Group_Id__c = bsGroup.Id;
                accBatchSettings.add(setting);
            }
        }

        Map<Id, String> batchNamesMap = new Map<Id, String>();
        Datetime timeNow = Datetime.now().addHours(-4);//This batch supposed to be scheduled at 9:30PM EST
        String todayDDMMYYYYDate = timeNow.format(DDMMYYYY_FORMAT);
        String todayDDMMYYDate = timeNow.format(DDMMYY_FORMAT);

        for(FS_Accounting_Batch_Settings__mdt setting : accBatchSettings){
            if(String.isNotBlank(setting.FS_Batch_Name_Format__c)){
                String batchNameFormat = setting.FS_Batch_Name_Format__c;
                if(batchNameFormat.contains(DDMMYYYY_FORMAT.toUpperCase())){
                    batchNameFormat =  batchNameFormat.replace(DDMMYYYY_FORMAT.toUpperCase(), todayDDMMYYYYDate);
                }else if(batchNameFormat.contains(DDMMYY_FORMAT.toUpperCase())){
                    batchNameFormat =  batchNameFormat.replace(DDMMYY_FORMAT.toUpperCase(), todayDDMMYYDate);
                }
                batchNamesMap.put(setting.FS_Business_Group_Id__c, batchNameFormat);
            }
        }
        return batchNamesMap;
    }

    global void finish(Database.BatchableContext BC) {

    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new FS_AccountingBatchesClosingJob());
    }
}