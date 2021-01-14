/**
 * Created by jzhou on 2/6/20.
 */

@IsTest
private class FS_AffiliationControllerTest {

    @TestSetup 
    static void setup() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(Name = 'Test Business Group');
        insert busGroup;
        PagesApi__Site__c site = new PagesApi__Site__c(
                Name = 'Test Site', OrderApi__Business_Group__c = busGroup.Id
        );
        insert site;
        OrderApi__Item_Class__c itemClassMembership = new OrderApi__Item_Class__c(
                Name = 'Membership',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Subscription__c = true
        );
        insert itemClassMembership;
        OrderApi__Item__c itemMembership = new OrderApi__Item__c(
                Name = 'Individual Membership', OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClassMembership.Id, OrderApi__Is_Subscription__c = true,
                OrderApi__Is_Active__c = false, OrderApi__Price__c = 0);
        insert itemMembership;
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
                Name = '1 Year', OrderApi__Type__c = 'Termed', OrderApi__Grace_Period__c = 90, OrderApi__Initial_Term_Months__c = 12,
                OrderApi__Renewal_Term_Months__c = 12,
                OrderApi__Calendar_End_Day__c = '31',
                OrderApi__Calendar_End_Month__c = '12-Dec',OrderApi__Enable_Proration__c = true,
                OrderApi__Proration_Rule__c = 'Bi-Annually',
                OrderApi__Invoice_Days_Variable__c= 31, OrderApi__Auto_Renew_Option__c = 'Enabled',
                OrderApi__Bill_Cycle__c = 'AUTO',
                OrderApi__Business_Group__c = busGroup.Id, OrderApi__Is_Active__c = true
        );
        insert subscriptionPlan;

        OrderApi__Item_Subscription_Plan__c subPlanLink = new OrderApi__Item_Subscription_Plan__c(
                OrderApi__Subscription_Plan__c = subscriptionPlan.Id,
                OrderApi__Item__c = itemMembership.Id, OrderApi__Is_Default__c = true
        );
        insert subPlanLink;
        itemMembership.OrderApi__Is_Active__c = true;
        update itemMembership;

        PagesApi__Community_Group__c commGroup = new PagesApi__Community_Group__c(
                Name = 'Senior Lawyers Section',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section'
        );
        insert commGroup;

        PagesApi__Community_Group__c commGroup1 = new PagesApi__Community_Group__c(
                Name = 'Young Lawyers Section',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section'
        );
        insert commGroup1;

        PagesApi__Community_Group__c commGroup2 = new PagesApi__Community_Group__c(
                Name = 'Test',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section'
        );
        insert commGroup2;

        PagesApi__Community_Group__c commGroup3 = new PagesApi__Community_Group__c(
                Name = 'Section',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section Committee',
                FS_Parent_Section__c = commGroup1.Id
        );
        insert commGroup3;

        PagesApi__Community_Group__c commGroup4 = new PagesApi__Community_Group__c(
                Name = 'Test123',
                PagesApi__Enable_Members__c = true,
                PagesApi__Privacy_Setting__c = 'Public',
                PagesApi__Is_Published__c = true,
                Is_Test_Data__c = true,
                PagesApi__Site__c = site.Id,
                PagesApi__Type__c = 'Section Committee',
                FS_Parent_Section__c = commGroup3.Id
        );
        insert commGroup4;

        OrderApi__Item_Class__c itemClass= new OrderApi__Item_Class__c(
                Name = 'Test',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Is_Subscription__c = false);
        insert itemClass;

        OrderApi__Item__c item = new OrderApi__Item__c(
                Name='Test',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup1.Id);
        OrderApi__Item__c item1 = new OrderApi__Item__c(
                Name='Test1',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup1.Id);
        OrderApi__Item__c item2 = new OrderApi__Item__c(
                Name='Test2',
                OrderApi__Business_Group__c = busGroup.Id,
                OrderApi__Item_Class__c = itemClass.Id,
                OrderApi__Is_Subscription__c = false,
                OrderApi__Is_Active__c = true,
                OrderApi__Price__c = 0,
                FS_Linked_Community_Group__c = commGroup2.Id);
        insert new List<OrderApi__Item__c>{item, item1, item2};
            
		Contact newContact = new Contact(
            FirstName = 'Test',
            LastName = 'Test'
        );
        // This will trigger an exception, since an EMPTY contact is expected.
        insert newContact;
        
        Account primaryAffiliation = new Account(
            Name = 'Primary Aff. Account'
        );
        insert primaryAffiliation;
        // default account
        Account defaultAccount = new Account(
            Name = 'Default Account'
        );
        insert defaultAccount;
        
        Account a = new Account(Name = 'Test Account', ShippingCountry = 'United States');
        insert a;

        Contact c = new Contact(FirstName = 'Test Account', LastName = 'Contact', AccountId = a.Id, OrderApi__Personal_Email__c='fsemailupdatetest@example.com', OrderApi__Preferred_Email_Type__c='Personal');
        insert c;
        
    }

    @IsTest
    static void testCheckOrganizationId() {
        
        Account a = [SELECT Id, Name, ShippingCountry FROM Account WHERE Name = 'Test Account' AND ShippingCountry = 'United States'];
        Contact c = [SELECT Id, FirstName, LastName, AccountId, OrderApi__Personal_Email__c, OrderApi__Preferred_Email_Type__c 
                     FROM Contact WHERE FirstName = 'Test Account' AND LastName = 'Contact' 
                     AND AccountId = :a.Id AND OrderApi__Personal_Email__c='fsemailupdatetest@example.com' AND OrderApi__Preferred_Email_Type__c='Personal'];

        Profile prf = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'];

        User u = new User(
                Username='fsemailupdatetest@example.com',
                Email='fsemailupdatetest@example.com',
                LastName='test',
                Alias='test',
                CommunityNickname='test12341234',
                TimeZoneSidKey='America/Los_Angeles',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId = prf.Id,
                ContactId=c.Id);
        insert u;

        System.runAs(u) {
            System.assertEquals(3, FS_AffiliationController.checkOrganizationId(a.Id).size());
        }
    }

    @IsTest
    static void testNewContactSetup() {
        System.assertEquals(3, FS_AffiliationController.newContactSetup().size());
    }

    @IsTest
    static void testGetRoleOptions() {
        
        Account a = [SELECT Id, Name, ShippingCountry FROM Account WHERE Name = 'Test Account' AND ShippingCountry = 'United States'];
        Contact c = [SELECT Id, FirstName, LastName, AccountId, OrderApi__Personal_Email__c, OrderApi__Preferred_Email_Type__c 
                     FROM Contact WHERE FirstName = 'Test Account' AND LastName = 'Contact' 
                     AND AccountId = :a.Id AND OrderApi__Personal_Email__c='fsemailupdatetest@example.com' AND OrderApi__Preferred_Email_Type__c='Personal'];
        

        Profile prf = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'];

        User u = new User(
                Username='fsemailupdatetest@example.com',
                Email='fsemailupdatetest@example.com',
                LastName='test',
                Alias='test',
                CommunityNickname='test12341234',
                TimeZoneSidKey='America/Los_Angeles',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                ProfileId = prf.Id,
                ContactId=c.Id);
        insert u;

        System.runAs(u) {
            System.assertEquals(2, FS_AffiliationController.getRoleOptions(a.Id).size());
        }
    }

    @IsTest
    static void createRecordControllerTest() {
        Contact newContact = new Contact(
            FirstName = 'New Test',
            LastName = 'New Test'
        );
        Map<String, Object> newAffiliationMap = new Map<String, Object>();
        newAffiliationMap.put('FS_Start_Date__c', '2020-01-01');
        newAffiliationMap.put('FS_Other_Reason__c', 'Other Reason Text');
        
        Account primaryAffiliation = [SELECT Id, Name FROM Account WHERE Name = 'Primary Aff. Account'];
        Account defaultAccount = [SELECT Id, Name FROM Account WHERE Name = 'Default Account'];
        
        Map<String, Object> result = FS_AffiliationController.createRecordController(newContact, newAffiliationMap, primaryAffiliation.Id, defaultAccount.Id);
        // System.assertNotEquals(null, result.get('Success'), 'No Success key has been returned');
    }

    @IsTest
    static void createRecordControllerExceptionTest() {
        Contact newContact = [SELECT Id, LastName, FirstName FROM Contact WHERE LastName = 'Test'];
        Map<String, Object> newAffiliationMap = new Map<String, Object>();
        newAffiliationMap.put('FS_Start_Date__c', '2020-01-01');
        newAffiliationMap.put('FS_Other_Reason__c', 'Other Reason Text');
        
        Account primaryAffiliation = [SELECT Id, Name FROM Account WHERE Name = 'Primary Aff. Account'];
        Account defaultAccount = [SELECT Id, Name FROM Account WHERE Name = 'Default Account'];
            
        Map<String, Object> result = FS_AffiliationController.createRecordController(newContact, newAffiliationMap, primaryAffiliation.Id, defaultAccount.Id);
        System.assertNotEquals(null, result.get('Error'), 'An error should be returned');
    }
}