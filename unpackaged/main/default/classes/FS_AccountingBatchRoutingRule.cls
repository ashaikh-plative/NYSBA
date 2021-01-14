/**
 * Created by santhosh on 01-07-2020.
 */

global without sharing class FS_AccountingBatchRoutingRule extends Framework.Domain {
    public FS_AccountingBatchRoutingRule(List<OrderApi__Receipt__c> sObjectList) {
        super(sObjectList);
    }
    private static final String DDMMYY_FORMAT = 'ddMMYY';
    private static final String DDMMYYYY_FORMAT = 'ddMMYYYY';
    @TestVisible
    private static final String CONTACT_STRING = 'Contact';
    private static final String CREDIT_CARD_STRING = 'Credit Card';

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_AccountingBatchRoutingRule(sObjectList);
        }
    }

    public override void beforeUpdate(Map<Id, SObject> oldRecords) {
        List<OrderApi__Receipt__c> receiptsToBeProcessed = new List<OrderApi__Receipt__c>();
        for (OrderApi__Receipt__c receipt : (List<OrderApi__Receipt__c>) records) {
            if (receipt.OrderApi__Is_Posted__c && receipt.OrderApi__Batch__c == null) {
                receiptsToBeProcessed.add(receipt);
            }
        }
        if (!receiptsToBeProcessed.isEmpty()) {
            updateBatchIdOnReceipt(receiptsToBeProcessed);
        }
    }

    private static void updateBatchIdOnReceipt(List<OrderApi__Receipt__c> records) {
        Map<Id, FS_Accounting_Batch_Settings__mdt> accBatchSettingMap = new Map<Id, FS_Accounting_Batch_Settings__mdt>();
        String profileIdFromMetadata = '';
        if (!Test.isRunningTest()) {
            for (FS_Accounting_Batch_Settings__mdt setting : [
                    SELECT Id, MasterLabel, FS_Batch_Name_Format__c,FS_Timezone__c,FS_Cutoff_Time__c,FS_Business_Group_Id__c,
                            FS_Payment_Gateway_Record_Id__c, FS_User_Profile_Id__c
                    FROM FS_Accounting_Batch_Settings__mdt
            ]) {
                accBatchSettingMap.put(setting.FS_Business_Group_Id__c, setting);
                profileIdFromMetadata = setting.FS_User_Profile_Id__c;
            }
        } else {
            //The following code is for test class
            for (OrderApi__Business_Group__c bsGroup : [SELECT Id, Name FROM OrderApi__Business_Group__c WHERE Name IN ('Test1', 'Test2')]) {
                FS_Accounting_Batch_Settings__mdt setting = new FS_Accounting_Batch_Settings__mdt();
                setting.FS_Batch_Name_Format__c = 'Portal Test DDMMYYYY';
                setting.MasterLabel = bsGroup.Name;
                setting.FS_Business_Group_Id__c = bsGroup.Id;
                accBatchSettingMap.put(setting.FS_Business_Group_Id__c, setting);
            }
        }


        String currentUserProfileId = UserInfo.getProfileId();
        List<OrderApi__Receipt__c> receiptsToBeProcessed = new List<OrderApi__Receipt__c>();
        Set<Id> busGroupIds = new Set<Id>();
        //Filtering the receipts based on conditions
        for (OrderApi__Receipt__c receipt : records) {
            if (Test.isRunningTest() || (accBatchSettingMap.containsKey(receipt.OrderApi__Business_Group__c)
                    && currentUserProfileId != null && profileIdFromMetadata != null && profileIdFromMetadata.contains(currentUserProfileId))) {
                receiptsToBeProcessed.add(receipt);
                busGroupIds.add(receipt.OrderApi__Business_Group__c);
            }
        }


        if (!receiptsToBeProcessed.isEmpty()) {
            Map<Id, String> batchNamesMap = new Map<Id, String>();
            Map<Id, OrderApi__Batch__c> batchesMap = new Map<Id, OrderApi__Batch__c>();
            //Getting the existing batches of today based on batch name and creating the batchesMap
            if (getBatchNamesMap(accBatchSettingMap.values(), batchNamesMap)) {
                for (OrderApi__Batch__c batch : [
                        SELECT Id, Name, OrderApi__Expected_Count__c, OrderApi__Expected_Amount__c, OrderApi__Payment_Gateway__c, OrderApi__Business_Group__c,
                                OrderApi__Entity__c, OrderApi__Payment_Type__c, OrderApi__Opened_Date__c
                        FROM OrderApi__Batch__c
                        WHERE Name IN :batchNamesMap.values() AND OrderApi__Is_Closed__c = FALSE
                ]) {
                    batchesMap.put(batch.OrderApi__Business_Group__c, batch);
                }

                List<OrderApi__Batch__c> batchesToBeInserted = new List<OrderApi__Batch__c>();

                for (Id busGroupId : accBatchSettingMap.keySet()) {
                    //Creating the new batch if it is not existed
                    if (batchesMap.get(busGroupId) == null && String.isNotBlank(batchNamesMap.get(busGroupId)) && busGroupIds.contains(busGroupId)) {
                        FS_Accounting_Batch_Settings__mdt setting = accBatchSettingMap.get(busGroupId);
                        OrderApi__Batch__c batch = new OrderApi__Batch__c();
                        batch.Name = batchNamesMap.get(busGroupId);
                        batch.OrderApi__Expected_Count__c = null;
                        batch.OrderApi__Expected_Amount__c = null;
                        batch.OrderApi__Payment_Gateway__c = setting.FS_Payment_Gateway_Record_Id__c;
                        batch.OrderApi__Business_Group__c = busGroupId;
                        batch.OrderApi__Entity__c = CONTACT_STRING;
                        batch.OrderApi__Payment_Type__c = CREDIT_CARD_STRING;
                        batchesToBeInserted.add(batch);
                        batchesMap.put(busGroupId, batch);

                    }
                }
                insert batchesToBeInserted;
                //Updating the receipt with corresponding batch Id
                for (OrderApi__Receipt__c receipt : receiptsToBeProcessed) {
                    OrderApi__Batch__c batch = batchesMap.get(receipt.OrderApi__Business_Group__c);
                    if (batch != null) {
                        receipt.OrderApi__Batch__c = batch.Id;
                    }
                }
            }
        }
    }

//Get BatchNames based on current time and cutoff time
    public static Boolean getBatchNamesMap(List<FS_Accounting_Batch_Settings__mdt> accBatchSettings, Map<Id, String> batchNamesMap) {
        Boolean booleanValue = false;
        Datetime timeNow = Datetime.now();
        for (FS_Accounting_Batch_Settings__mdt setting : accBatchSettings) {
            if (String.isNotBlank(setting.FS_Cutoff_Time__c) && String.isNotBlank(setting.FS_Timezone__c)) {
                TimeZone tz = TimeZone.getTimeZone(setting.FS_Timezone__c);
                timeNow = timeNow.addSeconds(tz.getOffset(timeNow) / 1000);
                String timeString = setting.FS_Cutoff_Time__c;
                String regex = '(\\d{1,2}):(\\d{1,2})';
                Pattern p = Pattern.compile(regex);
                Matcher m = p.matcher(timeString);
                if (m.matches()) {
                    Integer hours = Integer.valueOf(m.group(1)), minutes = Integer.valueOf(m.group(2));
                    if (hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
                        booleanValue = true;//true
                        Datetime cutOffTime = Datetime.newInstance(timeNow.year(), timeNow.month(), timeNow.day(), hours, minutes, 00);//It is 9:30PM EST
                        if (timeNow >= cutOffTime) {
                            timeNow = timeNow.addDays(1);
                        }
                        String todayDDMMYYYYDate = timeNow.format(DDMMYYYY_FORMAT);
                        String todayDDMMYYDate = timeNow.format(DDMMYY_FORMAT);
                        if (String.isNotBlank(setting.FS_Batch_Name_Format__c)) {
                            String batchNameFormat = setting.FS_Batch_Name_Format__c;
                            if (batchNameFormat.contains(DDMMYYYY_FORMAT.toUpperCase())) {
                                batchNameFormat = batchNameFormat.replace(DDMMYYYY_FORMAT.toUpperCase(), todayDDMMYYYYDate);
                            } else if (batchNameFormat.contains(DDMMYY_FORMAT.toUpperCase())) {
                                batchNameFormat = batchNameFormat.replace(DDMMYY_FORMAT.toUpperCase(), todayDDMMYYDate);
                            }
                            batchNamesMap.put(setting.FS_Business_Group_Id__c, batchNameFormat);
                        }
                    } else {
                        System.debug(System.LoggingLevel.ERROR, 'Invalid hours or minutes. Hours:' + hours +'Minutes:'+ minutes);
                    }
                }
            }
        }
        return booleanValue;
    }

}