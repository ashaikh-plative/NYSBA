@isTest
public class FS_TestUtils{

    public static final String BUSINESS_GROUP_NAMESTRING = 'Manufacturers Alliance for Productivity and Innovation';
    public static final String COMM_GROUP_NAMESTRING = 'fusionSpan Council';
    public static final String COMPANY_MEMBERSHIP_NAME = 'Company Membership';
    public static final String CORPORATE_MEMBERSHIP_NAME = 'Corporate Membership';

    public static OrderApi__Subscription__c createSubscription(Id oItem,Id oSubsPlan, Id a, Id c, Id oSalesOrderLine){
        OrderApi__Subscription__c oSubscription = new OrderApi__Subscription__c();
        oSubscription.OrderApi__Subscription_Plan__c = oSubsPlan;
        oSubscription.OrderApi__Account__c = a;
        oSubscription.OrderApi__Contact__c = c;
        oSubscription.OrderApi__Item__c  = oItem; //'Basic Operator Membership'; // create legacy code
        oSubscription.OrderApi__Current_Term_End_Date__c = System.TODAY()+30;
        oSubscription.OrderApi__Current_Term_Start_Date__c =   System.TODAY()-5;

        oSubscription.OrderApi__Status__c = 'Active';
        oSubscription.OrderApi__Is_Active__c = true;
        oSubscription.OrderApi__Sales_Order_Line__c = oSalesOrderLine;

        return oSubscription;
    }
    public static Contact createContact(String lName, String emailId){
        Contact oContact = new Contact();
        oContact.lastName = lName;
        oContact.email = emailId;
        return oContact;
    }
    public static Account createAccount(String name){
        Account acc = new Account();
        acc.Name = name;
        return acc;
    }
    public static OrderApi__Item__c createItem(String name, Id oItemClassId){
        OrderApi__Item__c oItem = new OrderApi__Item__c();
        oItem.Name = name;
        oItem.OrderApi__Item_Class__c = oItemClassId;
        return oItem;

    }
    public static OrderApi__Item_Class__c createItemClass(String name){
        OrderApi__Item_Class__c oItemClass = new OrderApi__Item_Class__c ();
        oItemClass.Name = name;
        return oItemClass;
    }
    public static OrderApi__Subscription_Plan__c createSubsPlan(String name){
        OrderApi__Subscription_Plan__c oSubsPlan = new OrderApi__Subscription_Plan__c();
        oSubsPlan.Name= name;
        return oSubsPlan;
    }
    public static OrderApi__Sales_Order__c createSalesOrder(Id oContact, Id oAccount,String postingEntity, String status){
        OrderApi__Sales_Order__c oSalesOrder = new OrderApi__Sales_Order__c();
        oSalesOrder.OrderApi__Contact__c = oContact;
        oSalesOrder.OrderApi__Account__c = oAccount;
        oSalesOrder.OrderApi__Entity__c = 'Account';
        oSalesOrder.OrderApi__Posting_Entity__c = postingEntity; //Receipt
        oSalesOrder.OrderApi__Status__c = status; //Open
        return oSalesOrder;
    }
    public static OrderApi__Sales_Order_Line__c createSalesOrderLine(Id oItem, Id oSalesOrder, Id oContact, Id oAccount){
        OrderApi__Sales_Order_Line__c salesOrderLineObj = new OrderApi__Sales_Order_Line__c();
        salesOrderLineObj.OrderApi__Item__c  = oItem;
        salesOrderLineObj.OrderApi__Sales_Order__c = oSalesOrder;
        return salesOrderLineObj;
    }

    public static OrderApi__Business_Group__c createBusinessGroup(String name){
        OrderApi__Business_Group__c obusinessGroup = new OrderApi__Business_Group__c();
        oBusinessGroup.OrderApi__Type__c = 'test';
        oBusinessGroup.Name = name;
        return oBusinessGroup;
    }

    /*
    public static FS_Author__c createAuthor(Id oContact, Id oItem, Double royaltyPercentage){
        FS_Author__c oAuthor = new FS_Author__c();
        oAuthor.FS_Contact__c = oContact;
        oAuthor.FS_Item__c = oItem;
        oAuthor.FS_Royalty_Percentage__c = royaltyPercentage;
        return oAuthor;
    }
  */

    public static OrderApi__Payment_Terms__c createPaymentTerms() {
        OrderApi__Payment_Terms__c paymentTerms = new OrderApi__Payment_Terms__c(Name = 'Due on Receipt',
                OrderApi__Display_Name__c = 'Due at the time of Receipt',
                OrderApi__Display_Message__c = 'Please remit payment upon receipt of this invoice.',
                OrderApi__Variable__c = 0);
        insert paymentTerms;
        return paymentTerms;
    }

    public static OrderApi__Subscription_Plan__c createSubscriptionPlan(OrderApi__Payment_Terms__c paymentTerms, OrderApi__Business_Group__c busGroup) {
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
                Name = '1 Year',
                OrderApi__Type__c = 'Termed', OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12,
//                OrderApi__Advanced_Calendar_Days__c = 60, OrderApi__Advanced_Calendar_Free_Paid__c = 'Paid',
                OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec',OrderApi__Enable_Proration__c = true,
                OrderApi__Proration_Rule__c = 'Bi-Annually',
                OrderApi__Invoice_Days_Variable__c= 31, OrderApi__Auto_Renew_Option__c = 'Enabled',
                OrderApi__Payment_Terms__c = paymentTerms.Id ,OrderApi__Bill_Cycle__c = 'AUTO',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Active__c = true
        );
        insert subscriptionPlan;
        return subscriptionPlan;
    }

    public static OrderApi__Item__c createSubItem(OrderApi__Business_Group__c busGroup, PagesApi__Community_Group__c commGroup) {
        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(Name = CORPORATE_MEMBERSHIP_NAME,
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true);
        insert itemClass;
        OrderApi__Item__c  item = new OrderApi__Item__c(Name=COMPANY_MEMBERSHIP_NAME,
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup.Id);
        insert item;
        return item;
    }
    public static OrderApi__Item_Subscription_Plan__c createSubscriptionPlanItemLink(OrderApi__Subscription_Plan__c subPlan, OrderApi__Item__c item) {

        OrderApi__Item_Subscription_Plan__c subPlanLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Item__c = item.Id, OrderApi__Is_Default__c = true
        );
        insert subPlanLink;
        item.OrderApi__Is_Active__c = true;
        update item;
        return subPlanLink;
    }

    public static PagesApi__Community_Group__c createCommunityGroup(PagesApi__Site__c site) {

        PagesApi__Community_Group__c commGroup = new PagesApi__Community_Group__c(
                Name = COMM_GROUP_NAMESTRING,
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id
        );
        insert commGroup;
        return commGroup;
    }

    public static PagesApi__Site__c createCommunitySite(OrderApi__Business_Group__c busGroup) {

        PagesApi__Site__c site = new PagesApi__Site__c(
                Name = 'Test Site',
                OrderApi__Business_Group__c=busGroup.Id
        );

        insert site;
        return site;
    }

    public static PagesApi__Community_Group_Member__c createCommGroupMember(PagesApi__Community_Group__c commGroup, Contact con, Account acc) {

        System.debug(con);

        PagesApi__Community_Group_Member__c commGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = commGroup.Id,
                PagesApi__Contact__c = con.Id
//                PagesApi__Account__c = acc.Id
        );
        insert commGroupMember;
        return commGroupMember;
    }

    public static OrderApi__Renewal__c createTermForTesting(Contact con, OrderApi__Item__c item, OrderApi__Sales_Order_Line__c line) {
        OrderApi__Renewal__c term = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c = System.today(),
                OrderApi__Term_End_Date__c = System.today().addYears(1),
                OrderApi__Contact__c = con.Id,
                OrderApi__Item__c = item.Id,
                OrderApi__Sales_Order_Line__c = line.Id,
                OrderApi__Sales_Order__c = line.OrderApi__Sales_Order__c,
                OrderApi__Subscription__c = line.OrderApi__Subscription__c
        );

        insert term;
        return term;
    }
/*
    public static Community_Group_Member_Term__c createTermForTesting(PagesApi__Community_Group_Member__c commGroupMem) {
        Community_Group_Member_Term__c term = new Community_Group_Member_Term__c(
                FS_Community_Group_Member__c = commGroupMem.Id,
                FS_Term_Start_Date__c = System.today().toStartOfMonth(),
                FS_Term_End_Date__c = System.today().toStartOfMonth().addDays(-1),
                FS_Term_Grace_Period_End_Date__c = System.today().toStartOfMonth().addDays(-1).addMonths(3),
                FS_Term_Role__c = 'Member'
        );

        insert term;
        return term;
    }
    
 */
}