/**
 *  @author:        cubiascaceres
 *  @date:          2019.09.30
 *  @description:   Test Class for Apex Controller: FS_MembershipJoinController
 */

@isTest
public class FS_MembershipJoinControllerTest {

    @TestSetup
    static void initTestData() {
        // Create Item Class Records
        OrderApi__Item_Class__c sectionDuesItemClass = new OrderApi__Item_Class__c();
        sectionDuesItemClass.Name = 'Section Dues';
        sectionDuesItemClass.OrderApi__Is_Active__c = true;
        insert sectionDuesItemClass;
        OrderApi__Item_Class__c individualSubscriptionClass = new OrderApi__Item_Class__c();
        individualSubscriptionClass.Name = 'NYSBA Individual Subscription';
        individualSubscriptionClass.OrderApi__Is_Active__c = true;
        insert individualSubscriptionClass;
        OrderApi__Item_Class__c TNYBFItemClass = new OrderApi__Item_Class__c();
        TNYBFItemClass.Name = 'TNYBF Donations';
        TNYBFItemClass.OrderApi__Is_Active__c = true;
        insert TNYBFItemClass;
        // Create Community Group records
        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c();
        communityGroup.Name = 'Fonteva Com. Silver Group Test';
        communityGroup.PagesApi__Type__c = 'Section';
        communityGroup.PagesApi__Is_Published__c = true;
        insert communityGroup;
        // Create Item Records
        OrderApi__Item__c antitrustItem = new OrderApi__Item__c();
        antitrustItem.OrderApi__Item_Class__c = sectionDuesItemClass.Id;
        antitrustItem.Name = 'Antitrust';
        antitrustItem.FS_Hidden_From_Student_Membership__c = false;
        antitrustItem.FS_Linked_Community_Group__c = communityGroup.Id;
        antitrustItem.OrderApi__Is_Active__c = true;
        antitrustItem.FS_Approved_By_Accounting__c = true;
        insert antitrustItem;
        OrderApi__Item__c TNYBFDonation = new OrderApi__Item__c();
        TNYBFDonation.OrderApi__Item_Class__c = TNYBFItemClass.Id;
        TNYBFDonation.Name = 'TNYBF Donation';
        TNYBFDonation.FS_Hidden_From_Student_Membership__c = false;
        TNYBFDonation.FS_Linked_Community_Group__c = communityGroup.Id;
        TNYBFDonation.OrderApi__Is_Active__c = true;
        TNYBFDonation.FS_Approved_By_Accounting__c = true;
        insert TNYBFDonation;
        OrderApi__Item__c youngLawyersItem = new OrderApi__Item__c();
        youngLawyersItem.OrderApi__Item_Class__c = sectionDuesItemClass.Id;
        youngLawyersItem.Name = 'Young Lawyers';
        youngLawyersItem.FS_Hidden_From_Student_Membership__c = true; // Young Lawyers item should not be displayed on the section list
        youngLawyersItem.FS_Linked_Community_Group__c = communityGroup.Id;
        youngLawyersItem.OrderApi__Is_Active__c = true;
        youngLawyersItem.FS_Approved_By_Accounting__c = true;
        insert youngLawyersItem;
        OrderApi__Item__c womenInLawItem = new OrderApi__Item__c();
        womenInLawItem.OrderApi__Item_Class__c = sectionDuesItemClass.Id;
        womenInLawItem.Name = 'Women in Law';
        womenInLawItem.FS_Hidden_From_Student_Membership__c = false;
        womenInLawItem.FS_Linked_Community_Group__c = communityGroup.Id;
        womenInLawItem.OrderApi__Is_Active__c = true;
        womenInLawItem.FS_Approved_By_Accounting__c = true;
        insert womenInLawItem;
        OrderApi__Item__c attorneyItem = new OrderApi__Item__c();
        attorneyItem.OrderApi__Item_Class__c = individualSubscriptionClass.Id;
        attorneyItem.Name = 'Attorney';
        attorneyItem.FS_Hidden_From_Student_Membership__c = true;
        attorneyItem.FS_Linked_Community_Group__c = communityGroup.Id;
        attorneyItem.OrderApi__Is_Active__c = true;
        attorneyItem.FS_Approved_By_Accounting__c = true;
        insert attorneyItem;
    }

    @IsTest
    static void updateContactTest() {
        User communityUser = getCommunityUser(true, 'Home', 'Personal');
        System.runAs(communityUser) {
			FS_ContactWrapper wrapper = FS_MembershipJoinController.getContact();
			wrapper.userContact.FS_Graduation_Date__c  = Date.newInstance(2020, 2, 15);
			FS_MembershipJoinController.updateContact(wrapper);            
        }        
    }
    
    @IsTest
    static void updateContactFailTest() {
        //	Calling update method on new object
        FS_ContactWrapper wrapper = new FS_ContactWrapper();
        wrapper.userContact = new Contact();
        try {
            FS_MembershipJoinController.updateContact(wrapper);
        } catch(Exception e) {
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
    }

    @IsTest
    static void getExistingSalesOrderIdTest() {
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Young Lawyers' LIMIT 1];
        User communityUser = getCommunityUser(true, 'Home', 'Personal');
        
        //	Create sales order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
            OrderApi__Contact__c = communityUser.ContactId
        );
        insert salesOrder;
        
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;
        
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Item__c = item.Id
        );
        insert salesOrderLine;
        
        System.runAs(communityUser) {
			FS_MembershipJoinController.getExistingSalesOrderId(item.Id);            
        }        
    }
    
    @IsTest
    static void getSalesOrderIdTest() {
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Young Lawyers' LIMIT 1];
        User communityUser = getCommunityUser(true, 'Home', 'Personal');

        OrderApi__Subscription_Plan__c subscriptionPlan = new OrderApi__Subscription_Plan__c(
            Name = '1 Year Calendar - Annual Auto Renew',
            OrderApi__Type__c = 'Calendar',
            OrderApi__Calendar_End_Month__c = '12 - December'
        );
        insert subscriptionPlan;
        
        //	Create sales order
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
            OrderApi__Contact__c = communityUser.ContactId
        );
        insert salesOrder;
        
        salesOrder.OrderApi__Posting_Status__c = 'Pending';
        salesOrder.OrderApi__Status__c = 'Closed';
        update salesOrder;
        
        OrderApi__Sales_Order_Line__c salesOrderLine = new OrderApi__Sales_Order_Line__c(
            OrderApi__Sales_Order__c = salesOrder.Id,
            OrderApi__Item__c = item.Id,
            OrderApi__Is_Renewal__c = TRUE,
            OrderApi__Subscription_Plan__c = subscriptionPlan.Id
        );
        insert salesOrderLine;
        
        System.runAs(communityUser) {
			FS_MembershipJoinController.getSalesOrderId(item.Id);            
        }        
    }
    
    @IsTest
    static void isAttorneyEnabledTest() {
        OrderApi__Item__c attorneyItem = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Attorney' LIMIT 1];
        User communityUser = getCommunityUser(true, 'Home', 'Personal');
        System.runAs(communityUser) {
            Boolean isAttorneyEnabled = FS_MembershipJoinController.isAttorneyEnabled(attorneyItem.Id);
            System.assert(isAttorneyEnabled);
        }
    }

    @IsTest
    static void isStudentEnabledTest() {
        OrderApi__Item__c attorneyItem = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Attorney' LIMIT 1];
        OrderApi__Item__c youngLawyerItem = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Young Lawyers' LIMIT 1];
        User communityUser = getCommunityUser(true, 'Home', 'Personal');
        System.runAs(communityUser) {
            Boolean isStudentEnabled = FS_MembershipJoinController.isStudentEnabled(youngLawyerItem.Id, attorneyItem.Id);
            System.assert(isStudentEnabled);
        }
    }

    @IsTest
    static void getLookupFilterMapTest() {
        String lasSchoolFilter = FS_MembershipJoinController.getLookupFilterMap();
        System.assert(lasSchoolFilter != null);
    }

    @IsTest
    static void getJSONCountriesAndStatesTest() {
        Map<String, Object> countryStateMap = FS_MembershipJoinController.getJSONCountriesAndStates();
        System.assert(null != countryStateMap);
    }

    @IsTest
    static void isLoggedInAsGuest() {
        Boolean isLoggedIn = true;
        String uniqueUserName = 'communityuser' + DateTime.now().getTime() + '@test.com';
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name='Standard Guest'];
        User communityUser = new User(Alias = 'gUser', 
                                        Email = 'communityuser@test.com', 
                                        EmailEncodingKey = 'UTF-8', 
                                        LastName ='Testing', 
                                        LanguageLocaleKey = 'en_US', 
                                        LocaleSidKey = 'en_US', 
                                        ProfileId = communityProfile.Id, 
                                        TimeZoneSidKey ='America/Los_Angeles', 
                                        UserName = uniqueUserName);
        Test.startTest();
        System.runAs(communityUser) {
            isLoggedIn = FS_MembershipJoinController.isLoggedIn();
        }
        System.assert(!isLoggedIn, 'User must be logged in as Guest');
        Test.stopTest();
    }

    @IsTest
    static void isNotLoggedInAsGuest() {
        Test.startTest();
        Boolean isLoggedIn = FS_MembershipJoinController.isLoggedIn();
        System.assert(isLoggedIn, 'User must be logged in as non Guest');
        Test.stopTest();
    }

    @IsTest
    static void getUserTypeListTest() {
        Test.startTest();
        List<FS_Membership_Join_User_Type__mdt> membershipJoinTypeList = FS_MembershipJoinController.getUserTypeList();
        system.assertEquals(4, membershipJoinTypeList.size(), 'There should be 4 records for FS Membership Join User Type Custom Metadata Type');
        Test.stopTest();        
    }

    @IsTest
    static void getDegreeTypeListTest() {        
        Test.startTest();
        Map<String, String> degreeTypeMap = FS_MembershipJoinController.getDegreeTypeList();
        System.assert(degreeTypeMap.containsKey('JD'), 'JD must be configured as a Degree Type');
        System.assert(degreeTypeMap.containsKey('LLM'), 'LLM must be configured as a Degree Type');
        Test.stopTest();
    }

    @IsTest
    static void getSectionDuesItemListTest() {        
        Test.startTest();
        List<OrderApi__Item__c> sectionDuesItemList = FS_MembershipJoinController.getSectionDuesItemList();
        System.assertEquals(3, sectionDuesItemList.size(), 'Only Section Due and Active Items are returned');
        Test.stopTest();        
    }

    @IsTest
    static void createSalesOrderTest() {        
        Test.startTest();
        String orderId;
        User communityUser = getCommunityUser(true, 'Home', 'Personal');
        System.runAs(communityUser) {
            FS_ContactWrapper contactWrapper = FS_MembershipJoinController.getContact();
            contactWrapper.isYoungLawyer = false;
            orderId = FS_MembershipJoinController.createSalesOrder(contactWrapper);
        }
        OrderApi__Sales_Order__c saleOrder = [SELECT Id, Name FROM OrderApi__Sales_Order__c WHERE Id = :orderId];
        System.assert(saleOrder != null, 'Sales Order was not created');
        List<OrderApi__Sales_Order_Line__c> orderLineList = [SELECT Id FROM OrderApi__Sales_Order_Line__c 
                                                            WHERE OrderApi__Sales_Order__c = :orderId];
        // Only one item is added to the order (membership item)
        System.assertEquals(1, orderLineList.size(), 'Order does not have the right quantity of items');
        Test.stopTest();        
    }

    @IsTest
    static void createSalesOrderSchoolDefaultTest() {
        Test.startTest();
        String orderId;
        User communityUser = getCommunityUser(false, 'Mobile', 'Other');
        System.runAs(communityUser) {
            FS_ContactWrapper contactWrapper = FS_MembershipJoinController.getContact();
            orderId = FS_MembershipJoinController.createSalesOrder(contactWrapper);
        }
        OrderApi__Sales_Order__c saleOrder = [SELECT Id, Name FROM OrderApi__Sales_Order__c WHERE Id = :orderId];
        System.assert(saleOrder != null, 'Sales Order was not created');
        List<OrderApi__Sales_Order_Line__c> orderLineList = [SELECT Id FROM OrderApi__Sales_Order_Line__c 
                                                            WHERE OrderApi__Sales_Order__c = :orderId];
        System.assertEquals(1, orderLineList.size(), 'Order does not have the right quantity of items');
        Test.stopTest();
    }

    @IsTest
    static void getContactHomeDefaultTest() {        
        User communityUser = getCommunityUser(true, 'Home', 'Other');
        Test.startTest();
        System.runAs(communityUser) {
            FS_ContactWrapper contactWrapper = FS_MembershipJoinController.getContact();
            System.assert(contactWrapper != null, 'Contact not found');
            System.assert(contactWrapper.isYoungLawyer, 'Young Lawyers must be checked by default');
        }        
        Test.stopTest();
    }

    @IsTest
    static void getContactSchoolDefaultTest() {        
        User communityUser = getCommunityUser(false, 'Work', 'Personal');
        Test.startTest();
        System.runAs(communityUser) {
            FS_ContactWrapper contactWrapper = FS_MembershipJoinController.getContact();
            System.assert(contactWrapper != null, 'Contact not found');
            System.assert(contactWrapper.isYoungLawyer, 'Young Lawyers must be checked by default');
        }
        Test.stopTest();
    }

    private static User getCommunityUser(Boolean preferredAddress, String preferredPhoneType, String preferredEmailType) {
        Id customerCommunityId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Partner Community Login User'].Id;
       
        Account testAccount = new Account(name ='Fusion Span Test') ;
        insert testAccount; 
       
        Contact communityContact = new Contact();
        communityContact.FS_Degree_Type__c = 'LLM';
        communityContact.Birthdate = Date.today();
        communityContact.OrderApi__Preferred_Phone_Type__c = preferredPhoneType;
        switch on preferredPhoneType {
                when 'Home' {
                    communityContact.HomePhone = '11-3333-55-444';
                }
                when 'Mobile' {
                    communityContact.MobilePhone = '11-3333-55-444';
                }
                when 'Work' {
                    communityContact.OrderApi__Work_Phone__c = '11-3333-55-444';
                }
            }
        communityContact.OrderApi__Preferred_Email_Type__c = preferredEmailType;
        switch on preferredEmailType {
                when 'Personal' {
                    communityContact.OrderApi__Personal_Email__c = 'personal@email.com';
                }
                when 'Other' {
                    communityContact.OrderApi__Other_Email__c = 'personal@email.com';
                }
            }        
        communityContact.LastName ='testCon'; 
        communityContact.AccountId = testAccount.Id;
        insert communityContact;

        OrderApi__Known_Address__c homeAddress = new OrderApi__Known_Address__c();
        homeAddress.OrderApi__Type__c = 'Home';
        homeAddress.OrderApi__Contact__c = communityContact.Id;
        homeAddress.FS_Preferred_Billing_Address__c = preferredAddress;
        homeAddress.FS_Preferred_Mail_Address__c = preferredAddress;
        homeAddress.OrderApi__Street__c = '47th N.E.';
        homeAddress.OrderApi__City__c = 'Tampa';
        homeAddress.OrderApi__Province__c = 'Florida';
        homeAddress.OrderApi__Postal_Code__c = '06654';
        homeAddress.OrderApi__Country__c = 'USA';        
        insert homeAddress;
        OrderApi__Known_Address__c schoolAddress = new OrderApi__Known_Address__c();
        schoolAddress.OrderApi__Type__c = 'School';
        schoolAddress.OrderApi__Contact__c = communityContact.Id;
        schoolAddress.FS_Preferred_Billing_Address__c = !preferredAddress;
        schoolAddress.FS_Preferred_Mail_Address__c = !preferredAddress;
        schoolAddress.OrderApi__Street__c = '2nd S.W.';
        schoolAddress.OrderApi__City__c = 'Fort Lauderdale';
        schoolAddress.OrderApi__Province__c = 'Florida';
        schoolAddress.OrderApi__Postal_Code__c = '08896';
        schoolAddress.OrderApi__Country__c = 'USA';        
        insert schoolAddress;

        User communityUser = new User(Alias = 'commUser', Email='commUser@noemail.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = customerCommunityId, 
                                Country='United States', IsActive = true,
                                ContactId = communityContact.Id, TimeZoneSidKey='America/Los_Angeles', UserName='commuser@noemail.com');
        insert communityUser;
        return communityUser;
    }
}