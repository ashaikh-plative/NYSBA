@isTest
public class FS_ContactsRuleServiceTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();

        Framework.RoutingRule ContactServiceRule = new Framework.RoutingRule();
        ContactServiceRule.apexClass = FS_ContactsRule.class.getName();
        ContactServiceRule.namespace = ' ';
        ContactServiceRule.isEnabled = true;
        ContactServiceRule.sObjectName = SObjectType.Contact.getName();
        ContactServiceRule.executionOrder = 0;
        rules.add(ContactServiceRule);
        Framework.Config.push(rules);
    }

    static testMethod void testContactTgr(){
        //insert custom settings

        ContactToUserFieldMapping__c oContactCustomSettings = new ContactToUserFieldMapping__c();
        oContactCustomSettings.Name = 'lastNameField';
        oContactCustomSettings.Is_Formula_Field__c = false ;
        oContactCustomSettings.IsActive__c= true ;
        oContactCustomSettings.UserField__c = 'LastName' ;
        oContactCustomSettings.ContactField__c = 'LastName';
        insert oContactCustomSettings;

        List<OrderApi__Subscription__c> oSubscriptionList = new List<OrderApi__Subscription__c>();
        Account a = FS_TestUtils.createAccount('TestAccountFS');
        insert a;
        Account a2 = FS_TestUtils.createAccount('TestAccountFS22');
        insert a2;
        List<Contact> oContactList  = new List<Contact>();
        Contact oContact1 = FS_TestUtils.createContact('testoContact1','fsSubsTest2@exampleFS.com');
        oContact1.AccountId =a.Id;
        oContact1.OrderApi__Preferred_Email_Type__c = 'Personal';
        oContact1.OrderApi__Personal_Email__c = 'test@FS1.com';
        oContact1.OrderApi__Work_Email__c = 'testWorkEmail4@FS2.com';
        oContact1.Email = 'test@FS.com';
        oContactList.add(oContact1);

        Contact oContact2 = FS_TestUtils.createContact('testoContact12','fsSubsTest22@exampleFS.com');
        oContact2.AccountId =a2.Id;
        oContact2.OrderApi__Preferred_Email_Type__c = 'Personal';
        oContact2.OrderApi__Personal_Email__c = 'test@FS5.com';
        oContact2.OrderApi__Work_Email__c = 'testWorkEmail3@FS6.com';
        oContactList.add(oContact2);

        Contact oContact3 = FS_TestUtils.createContact('testc','fsSubsTest12@exampleFS.org');
        oContact3.AccountId =a.Id;
        oContact3.OrderApi__Preferred_Email_Type__c = 'Personal';
        oContact3.OrderApi__Personal_Email__c = 'test@FS7.com';
        oContact3.OrderApi__Work_Email__c = 'testWorkEmail2@FS8.com';
        oContactList.add(oContact3);

        insert oContactList;

        OrderApi__Item_Class__c  oItemClass = FS_TestUtils.createItemClass('testItemClass');
        oItemClass.OrderApi__Enable_Assignments__c = true;
        oItemClass.OrderApi__Assignment_SObject__c = 'Contact';
        insert oItemClass;
        OrderApi__Item__c oItem = FS_TestUtils.createItem('Basic Operator Membership',oItemClass.id);
        insert oItem;
        OrderApi__Subscription_Plan__c oSubsPlan = FS_TestUtils.createSubsPlan('1 Year');
        oSubsPlan.OrderApi__Type__c = 'Termed';
        oSubsPlan.OrderApi__Initial_Term_Months__c =6;
        oSubsPlan.OrderApi__Is_Active__c = true;
        insert oSubsPlan;
        OrderApi__Sales_Order__c oSalesOrder = FS_TestUtils.createSalesOrder(oContact3.id,a.id,'Receipt','Open');
        insert oSalesOrder;
        OrderApi__Sales_Order_Line__c oSalesOrderLine = FS_TestUtils.createSalesOrderLine(oItem.id, oSalesOrder.id, oContact3.id, a.id);
        insert oSalesOrderLine;
        oSalesOrder.OrderApi__Status__c = 'Closed';
        update oSalesOrder;
        oSalesOrder.OrderApi__Posting_Status__c ='Posted';
        update oSalesOrder;

        OrderApi__Item__c oItemNULL = FS_TestUtils.createItem('',oItemClass.id);
        insert oItemNULL;

        OrderApi__Sales_Order_Line__c oSalesOrderLineNULL = FS_TestUtils.createSalesOrderLine(oItemNULL.id, oSalesOrder.id, oContact3.id, a.id);
        insert oSalesOrderLineNULL;
        oSalesOrder.OrderApi__Status__c = 'Closed';
        update oSalesOrder;
        oSalesOrder.OrderApi__Posting_Status__c ='Posted';
        update oSalesOrder;

        OrderApi__Subscription__c oSubscription = FS_TestUtils.createSubscription(oItem.id,oSubsPlan.id, a.Id, oContact3.Id, oSalesOrderLine.id);
        oSubscription.OrderApi__Current_Term_End_Date__c = System.TODAY().addDays(-20);
        oSubscription.OrderApi__Current_Term_Start_Date__c =   System.TODAY().addDays(-25);
        oSubscription.OrderApi__Status__c='Expired';
        oSubscription.OrderApi__Is_Active__c=false;
        oSubscriptionList.add(oSubscription);
        oSubscription = FS_TestUtils.createSubscription(oItem.id,oSubsPlan.id, a.Id, oContact3.Id, oSalesOrderLine.id);
        oSubscription.OrderApi__Current_Term_End_Date__c = System.TODAY().addDays(-10);
        oSubscription.OrderApi__Current_Term_Start_Date__c =   System.TODAY().addDays(-15);
        oSubscription.OrderApi__Status__c='Expired';
        oSubscription.OrderApi__Is_Active__c=false;
        oSubscriptionList.add(oSubscription);
        oSubscription = FS_TestUtils.createSubscription(oItemNULL.id,oSubsPlan.id, a.Id, oContact3.Id, oSalesOrderLineNULL.id);
        oSubscription.OrderApi__Current_Term_End_Date__c = System.TODAY().addDays(-10);
        oSubscription.OrderApi__Current_Term_Start_Date__c =   System.TODAY().addDays(-35);
        oSubscription.OrderApi__Status__c='Expired';
        oSubscription.OrderApi__Is_Active__c=false;
        oSubscriptionList.add(oSubscription);
        oSubscription = FS_TestUtils.createSubscription(oItemNULL.id,oSubsPlan.id, a.Id, oContact3.Id, oSalesOrderLineNULL.id);
        oSubscription.OrderApi__Current_Term_End_Date__c = System.TODAY().addDays(10);
        oSubscription.OrderApi__Current_Term_Start_Date__c =   System.TODAY().addDays(-35);
        oSubscription.OrderApi__Is_Active__c=true;
        oSubscriptionList.add(oSubscription);
        oSubscription = FS_TestUtils.createSubscription(oItemNULL.id,oSubsPlan.id, a.Id, oContact3.Id, oSalesOrderLineNULL.id);
        oSubscription.OrderApi__Current_Term_End_Date__c = System.TODAY().addDays(10);
        oSubscription.OrderApi__Current_Term_Start_Date__c =   System.TODAY().addDays(-35);
        oSubscription.OrderApi__Is_Active__c=true;

        oSubscriptionList.add(oSubscription);

        insert oSubscriptionList;

        OrderApi__Assignment_Role__c oAssignmentRole = new OrderApi__Assignment_Role__c();
        oAssignmentRole.OrderApi__Is_Active__c = true;
        oAssignmentRole.OrderApi__Item_Class__c = oItemClass.Id;
        oAssignmentRole.Name = 'testRole';
        insert oAssignmentRole;
        OrderApi__Assignment__c oAssignments = new OrderApi__Assignment__c();
        oAssignments.OrderApi__Subscription__c = oSubscriptionList[0].Id;
        oAssignments.OrderApi__Item_Class__c = oItemClass.Id;
        oAssignments.OrderApi__Assignment_Role__c = oAssignmentRole.Id;
        oAssignments.OrderApi__Contact__c = oContact1.Id;
        oAssignments.OrderApi__Is_Primary__c= true;
        insert oAssignments;

        ID adminProfileId = [SELECT Id,Name FROM Profile WHERE Name='System Administrator'].ID;
        ID communityProfileId = [SELECT Id,Name FROM Profile WHERE Name='Fonteva Customer Community Login User'].ID;

        List<User> oUserList = new List<User>();
        User u1 = createTestUser( adminProfileId, 'fusionSpan', 'Testing');
        /*new User(Alias = 'standt', Email='admin_test@FS9.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p1,
                           TimeZoneSidKey='America/Los_Angeles', UserName='admin_test@FS10.com');*/
        //u1.ContactId =c.Id;
        oUserList.add( u1 );
        User u21 = createTestUser( adminProfileId, 'fusionSpan2', 'Testing2');
        /*new User(Alias = 'standt', Email='admin_fsSubsTest2@example.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p1,
                        TimeZoneSidKey='America/Los_Angeles', UserName='FS101Admin0011@example.com');*/
        //u21.ContactId =oContact1.Id;
        oUserList.add(u21);

        User ucc =  createTestUser(communityProfileId, 'fuisonSpan3', 'Testing3');
        /*new User(Alias = 'standt', Email='New_'+oContact3.Email,
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = communityProfileId,
                            TimeZoneSidKey='America/Los_Angeles', UserName='New_'+oContact3.Email); */
        ucc.ContactId =oContact3.Id;
        ucc.userName = oContact3.Email;
        oUserList.add( ucc);

        insert oUserList;
        system.runAs(u1){
            test.startTest();

            List<Contact> oContact_NewList = new List<Contact>();
            oContact1.Email = 'New_'+oContact1.Email;
            oContact1.OrderApi__Personal_Email__c = 'New_'+oContact1.OrderApi__Personal_Email__c;
            oContact1.OrderApi__Work_Email__c = 'New_'+oContact1.OrderApi__Work_Email__c;
            oContact1.AccountId = a2.Id;
            oContact_NewList.add(oContact1);
            oContact2.Email = 'New_'+oContact2.Email;
            oContact2.OrderApi__Personal_Email__c = 'New_'+oContact2.OrderApi__Personal_Email__c;
            oContact2.OrderApi__Work_Email__c = 'New_'+oContact2.OrderApi__Work_Email__c;
            oContact2.AccountId = a2.Id;
            oContact_NewList.add(oContact2);
            oContact3.Email = 'New_'+oContact3.Email;
            oContact3.OrderApi__Personal_Email__c = 'New_'+oContact3.OrderApi__Personal_Email__c;
            oContact3.OrderApi__Work_Email__c = 'New_'+oContact3.OrderApi__Work_Email__c;
            oContact3.AccountId = a2.Id;
            oContact_NewList.add(oContact3);

            update oContact_NewList;

            Test.stopTest();
        }
    }
    public static User createTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString =
                String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                lastName = lName,
                email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = profId);
        return tuser;
    }

}