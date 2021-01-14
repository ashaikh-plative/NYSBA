@IsTest
public class FS_ItemClassScheduledJobTest {
	private static final String APPROVED_STRING = 'Approved';
    private static final String REQ_APPROVAL_STRING = 'Request Approval';
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    @IsTest
    private static void itemTest() {
    OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test business group');
        insert busGroup;
        EventApi__Event_Category__c eventCategory = new EventApi__Event_Category__c(
                Name='Test Event Category',
                EventApi__Business_Group__c =busGroup.Id);
        insert eventCategory;
        OrderApi__Item_Class__c itemClass = FS_TestUtils.createItemClass('Event Item Class');
        itemClass.OrderApi__Business_Group__c = busGroup.Id;
        insert itemClass;
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(Name = 'Test GL Account',
					OrderApi__Business_Group__c = busGroup.id);
        insert glAcc;
        OrderApi__GL_Account__c glAcc2 = new OrderApi__GL_Account__c(Name = 'GL Account',
					OrderApi__Business_Group__c = busGroup.id);
        insert glAcc2;
        EventApi__Event__c event = new EventApi__Event__c(
                EventApi__Event_Category__c=eventCategory.Id,
                EventApi__Display_Name__c='Test Event',
                EventApi__Business_Group__c=busGroup.Id,
                FS_Accounting_Approval__c=REQ_APPROVAL_STRING,
                EventApi__Status__c ='Planned',
                EventApi__Event_Key__c='VX4FFH5',
                EventApi__Start_Time__c='08:00AM',
                EventApi__End_Time__c='09:00PM');
        insert event;
        EventApi__Ticket_Type__c ticketType = new EventApi__Ticket_Type__c(
            EventApi__Event__c = event.Id,
            Name='Test TicketType',
            EventApi__Is_Active__c=true,
            EventApi__Income_Account__c=glAcc.Id,
        	FS_Product_Code__c='1234');
        insert ticketType;
        EventApi__Schedule_Item__c scheduleItem = new EventApi__Schedule_Item__c(
        	Name='Test schedule Item',
            EventApi__Event__c=event.Id,
            EventApi__Is_Active__c=true,
            EventApi__Income_Account__c=glAcc.Id,
        	EventApi__Session_Start_Time__c='08:00AM',
        	EventApi__Session_End_Time__c='10:00PM');
        insert scheduleItem;
        EventApi__Sponsor_Package__c sponsorPackage = new EventApi__Sponsor_Package__c(
        	Name='Test sponsor Package',
        	EventApi__Event__c=event.Id,
        	EventApi__Is_Active__c=true,
        	EventApi__Income_Account__c=glAcc.Id,
        	EventApi__Price__c=100);
        insert sponsorPackage;
    
    List<Id> itemList = new List<Id>();
        OrderApi__Item__c item2 = FS_TestUtils.createItem('Event Item', itemClass.Id);
        item2.OrderApi__Business_Group__c = busGroup.Id;
        item2.FS_Accounting_Approval__c = REQ_APPROVAL_STRING;
        item2.OrderApi__Is_Event__c = true;
        item2.OrderApi__Is_Active__c = false;
        item2.EventApi__Event__c = event.Id;
        item2.EventApi__Ticket_Type__c = ticketType.Id;
        item2.EventApi__Schedule_Item__c = scheduleItem.Id;
        item2.EventApi__Sponsor_Package__c = sponsorPackage.Id;
        item2.OrderApi__Income_Account__c = glAcc.Id;
        item2.OrderApi__Refund_Account__c = glAcc.Id;
        item2.OrderApi__AR_Account__c = glAcc.Id;
        item2.OrderApi__Discount_Account__c = glAcc.Id;
        item2.OrderApi__Adjustment_Account__c = glAcc.Id;
        insert item2;
        itemList.add(item2.Id);
		
		item2.FS_Accounting_Approval__c = APPROVED_STRING;
		item2.OrderApi__Is_Active__c = true;
		update item2;
        
        Test.startTest();
        FS_ItemClassScheduledJob itemclsSC = new FS_ItemClassScheduledJob(itemList);
        String jobId1 = System.schedule('FS Event Item Update Job', CRON_EXP, itemclsSC);
        Test.stopTest();
    }
}