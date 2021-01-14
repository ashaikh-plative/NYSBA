/**
 *  @author:    cubiascaceres
 *  @date:      2019.10.29
 */
@isTest
public class FS_AttorneyControllerTest {

    @IsTest
    static void hasPastFreeAttorneyMembershipTest() {
        Map<User, Contact> userContactMap = getCommunityUser();
        User communityUser = (new List<User>(userContactMap.keySet()))[0];
        
        Test.startTest();
        System.runAs(communityUser){
            Boolean hasPastFreeAttorneyMembership = FS_AttorneyController.hasPastFreeAttorneyMembership();
            System.assert(!hasPastFreeAttorneyMembership);
        }
        Test.stopTest();
        
    }
    @IsTest
    static void updateContactTest() {
        
        Map<User, Contact> userContactMap = getCommunityUser();
        User communityUser = (new List<User>(userContactMap.keySet()))[0];
        Contact contact = userContactMap.values().get(0);
        // Insert Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name = 'Membership Class';
        itemClass.OrderApi__Is_Active__c = true;
        insert itemClass;
        // Insert Item
        OrderApi__Item__c membershipItem = new OrderApi__Item__c();
        membershipItem.Name = 'Membership Item Name';
        membershipItem.OrderApi__Item_Class__c = itemClass.Id;
        insert membershipItem;

        Test.startTest();
        System.runAs(communityUser){
            Boolean isOrderCreated = FS_AttorneyController.updateContact(contact);
            System.assert(isOrderCreated, 'Contact update failed');
        }
        Test.stopTest();
        
    }

    @IsTest
    static void getSalutationOptionListTest() {
        Map<String, String> salutationMap = FS_AttorneyController.getSaluationOptionList();
        System.assert(!salutationMap.isEmpty(), 'Options for Salutation are not configured');
    }

    @IsTest
    static void getDesignationOptionListTest() {
        Map<String, String> designationMap = FS_AttorneyController.getDesignationOptionList();
        System.assert(!designationMap.isEmpty(), 'Options for Designation are not configured');
    }

    @IsTest
    static void getSuffixOptionListTest() {
        Map<String, String> suffixMap = FS_AttorneyController.getSuffixOptionList();
        System.assert(!suffixMap.isEmpty(), 'Options for Suffix are not configured');
    }

    @IsTest
    static void getJSONCountriesAndStatesTest() {
        Map<String, Object> countriesAndStatesMap = FS_AttorneyController.getJSONCountriesAndStates();
        System.assert(countriesAndStatesMap.get('countriesInfo') != null, 'Countries info was not found');
        System.assert(countriesAndStatesMap.get('statesInfo') != null, 'States info was not found');
    }

    @IsTest
    static void getContactTest() {
		Id customerCommunityId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Partner Community Login User'].Id;
       
        Account testAccount = new Account(name ='Fusion Span Test') ;
        insert testAccount; 
        Contact communityContact = new Contact();
        communityContact.FS_Degree_Type__c = 'LLM';
        communityContact.Birthdate = Date.today();
        communityContact.OrderApi__Preferred_Phone_Type__c = 'Personal';
        communityContact.HomePhone = '11-3333-55-444';
        communityContact.MobilePhone = '11-3333-55-444';
        communityContact.OrderApi__Work_Phone__c = '11-3333-55-444';
        communityContact.OrderApi__Preferred_Email_Type__c = 'Work';
        communityContact.OrderApi__Personal_Email__c = 'personal@email.com';
        communityContact.OrderApi__Other_Email__c = 'personal@email.com';
        communityContact.OrderApi__Work_Email__c = 'work@email.com';
        communityContact.LastName ='testCon'; 
        communityContact.AccountId = testAccount.Id;
        communityContact.Salutation = 'Mr.';
        communityContact.FirstName = 'FName Test';
        communityContact.MiddleName = 'MName Test';
        communityContact.LastName = 'LName Test';
        communityContact.DonorApi__Suffix__c = 'V';
        communityContact.FS_Designation__c = 'Esq.';
        communityContact.FS_Graduation_Date__c = Date.today(); 
        communityContact.Birthdate = Date.today();        
        insert communityContact;
        User communityUser = new User(Alias = 'commUser', 
                            Email='commUser@noemail.com',
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ProfileId = customerCommunityId, 
                            Country='United States', 
                            IsActive = true,
                            ContactId = communityContact.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='commuser@noemail.com');
        insert communityUser;
        System.runAs(communityUser) {
            Contact contact = FS_AttorneyController.getContact();
            System.assertEquals(contact.Id, communityContact.Id, 'Contact Id Failed validation.');
        }
    }
	/*
    @IsTest
    static void checkEmail() {
        Boolean emailCheck = FS_AttorneyController.checkEmail('test@email.com');
        System.assert(!emailCheck);
    }
	*/
    @IsTest
    static void getLookupFilterMapTest() {
        Map<String, String> lookupFilterMap = FS_AttorneyController.getLookupFilterMap();
        System.assertEquals(2, lookupFilterMap.size(), 'Company & School Filter must be returned');
    }

    @IsTest
    static void getPracticeInterestOptionsTest() {
        Map<String, String> practiceMap = FS_AttorneyController.getPracticeInterestOptions();
        System.assert(!practiceMap.isEmpty(), 'Practice Options not configured');
    }

    private static Map<User, Contact> getCommunityUser() {
        Id customerCommunityId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Partner Community Login User'].Id;
       
        Account testAccount = new Account(name ='Fusion Span Test') ;
        insert testAccount; 
        Contact communityContact = new Contact();
        communityContact.FS_Degree_Type__c = 'LLM';
        communityContact.Birthdate = Date.today();
        communityContact.OrderApi__Preferred_Phone_Type__c = 'Personal';
        communityContact.HomePhone = '11-3333-55-444';
        communityContact.MobilePhone = '11-3333-55-444';
        communityContact.OrderApi__Work_Phone__c = '11-3333-55-444';
        communityContact.OrderApi__Preferred_Email_Type__c = 'Work';
        communityContact.OrderApi__Personal_Email__c = 'personal@email.com';
        communityContact.OrderApi__Other_Email__c = 'personal@email.com';
        communityContact.OrderApi__Work_Email__c = 'work@email.com';
        communityContact.LastName ='testCon'; 
        communityContact.AccountId = testAccount.Id;
        communityContact.Salutation = 'Mr.';
        communityContact.FirstName = 'FName Test';
        communityContact.MiddleName = 'MName Test';
        communityContact.LastName = 'LName Test';
        communityContact.DonorApi__Suffix__c = 'V';
        communityContact.FS_Designation__c = 'Esq.';
        communityContact.FS_Graduation_Date__c = Date.today(); 
        communityContact.Birthdate = Date.today();        
        insert communityContact;
        User communityUser = new User(Alias = 'commUser', 
                            Email='commUser@noemail.com',
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ProfileId = customerCommunityId, 
                            Country='United States', 
                            IsActive = true,
                            ContactId = communityContact.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='commuser@noemail.com');
        insert communityUser;
        Map<User, Contact> userContactMap = new Map<User, Contact>();
        userContactMap.put(communityUser, communityContact);
        return userContactMap;
    }

    @IsTest
    static void initSummaryTest() {
        // Create CoPro Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
            Name = 'Subscription',
            FS_Is_Membership__c = True
        );
        insert itemClass;
        // Create Item
        OrderApi__Item__c item = new OrderApi__Item__c(
            Name = 'Attorney',
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Is_Subscription__c = true
        );
        insert item;
        
        OrderApi__Item__c generalContribution = new OrderApi__Item__c(
            Name = 'General Contribution',
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Is_Subscription__c = true
        );
        insert generalContribution;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        insert salesOrder;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Item__c = item.Id,
            OrderApi__Quantity__c = 1,
            OrderApi__Total__c = 15.99,
            OrderApi__End_Date__c = System.today()
        );
        insert salesOrderLine;

        FS_AttorneySummaryWrapper wrapper = FS_AttorneyController.initSummary(salesOrder.Id, generalContribution.Id);

        System.assert(wrapper.effectiveUntil != null, 'End Date from Subscription Item must be returned.');
        System.assertEquals(8, wrapper.duesCategoryList.size(), 'There must be 8 Categories configured');
        System.assertEquals(15.99, wrapper.membershipBillAmount, 'Amount from Subscription Item must be returned');
    }

    @isTest
    static void oneTimePaymentAttorneyOrderTest() {

        // Create CoPro Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
            Name = 'Subscription',
            FS_Is_Membership__c = True
        );
        insert itemClass;
        
        OrderApi__Item_Class__c donationItemClass = new OrderApi__Item_Class__c(
            Name = 'Donation'
        );
        insert donationItemClass;

        // Create Item
        OrderApi__Item__c item = new OrderApi__Item__c(
            Name = 'Attorney',
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Is_Subscription__c = true
        );
        insert item;

        OrderApi__Item__c charitableItem = new OrderApi__Item__c(
            Name = 'General Contribution',
            OrderApi__Item_Class__c = donationItemClass.Id
        );
        insert charitableItem;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        insert salesOrder;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Item__c = item.Id,
            OrderApi__Quantity__c = 1,
            OrderApi__Total__c = 15.99,
            OrderApi__End_Date__c = System.today()
        );
        insert salesOrderLine;

        FS_AttorneyController.oneTimePaymentAttorneyOrder(salesOrder.Id, item.Id, charitableItem.Id, true, 30.5, 'FSP_FonMPP__Long_URL__c');
    }

    @isTest
    static void recurringPaymentAttorneyOrderTest() {
        // Create CoPro Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(
            Name = 'Subscription',
            FS_Is_Membership__c = True
        );
        insert itemClass;
        
        OrderApi__Item_Class__c donationItemClass = new OrderApi__Item_Class__c(
            Name = 'Donation'
        );
        insert donationItemClass;

        // Create Item
        OrderApi__Item__c item = new OrderApi__Item__c(
            Name = 'Attorney',
            OrderApi__Item_Class__c = itemClass.Id,
            OrderApi__Is_Subscription__c = true
        );
        insert item;

        OrderApi__Item__c charitableItem = new OrderApi__Item__c(
            Name = 'General Contribution',
            OrderApi__Item_Class__c = donationItemClass.Id
        );
        insert charitableItem;

        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        insert salesOrder;

        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Item__c = item.Id,
            OrderApi__Quantity__c = 1,
            OrderApi__Total__c = 15.99,
            OrderApi__End_Date__c = System.today()
        );
        insert salesOrderLine;
        
        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
            Name = '1 Year Calendar - Annual Auto Renew',
            OrderApi__Type__c = 'Calendar',
            OrderApi__Calendar_End_Month__c = '12 - December'
        );
        insert subscriptionPlan;
        FS_AttorneyController.recurringPaymentAttorneyOrder(salesOrder.Id, item.Id, charitableItem.Id, true, 30.5, 'monthly', subscriptionPlan.Id, 'FSP_FonMPP__Long_URL__c');
    }
    
    @IsTest
    static void getExistingSalesOrderIdTest() {
        //	Create Item
        // Insert Item Class
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.Name = 'Membership Class';
        itemClass.OrderApi__Is_Active__c = true;
        itemClass.FS_Is_Membership__c = true;
        insert itemClass;
        // Insert Item
        OrderApi__Item__c membershipItem = new OrderApi__Item__c();
        membershipItem.Name = 'Membership Item Name';
        membershipItem.OrderApi__Item_Class__c = itemClass.Id;
        insert membershipItem;
        
        Map<User, Contact> userContactMap = getCommunityUser();
        User communityUser = (new List<User>(userContactMap.keySet()))[0];
        //	create sales Order record
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
            OrderApi__Contact__c = communityUser.ContactId
        );
        insert salesOrder;
        
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;
        
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Item__c = membershipItem.Id,
            OrderApi__Is_Renewal__c = false
        );
        insert salesOrderLine;
        
        Test.startTest();
        System.runAs(communityUser){
            Map<String, String> responseMap = FS_AttorneyController.getExistingSalesOrderId(membershipItem.Id);
            System.assertEquals(salesOrder.Id, responseMap.get('salesOrderId'), 'Sales Order with Membership Item should be returned.');
        }
        Test.stopTest();        
    }
}