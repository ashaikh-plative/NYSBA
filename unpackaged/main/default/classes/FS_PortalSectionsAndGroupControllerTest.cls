@IsTest
private class FS_PortalSectionsAndGroupControllerTest {
    @TestSetup static void setup() {
        Framework.Installer.install();
//        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
//        EventApi.PackageScripts.install();

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
    }

    @IsTest
    static void testSetup() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        dml.duplicateRuleHeader.runAsCurrentUser = true;

        Account a = new Account(Name = 'Test Unique15 51xq', ShippingCountry = 'United States');
        Database.insert(a, dml);

        Contact c = new Contact(FirstName = 'TestUniqeName 123gvx', LastName = 'ContactUniqueName qweq1', AccountId = a.Id, OrderApi__Personal_Email__c='fsemailupdatetest@example.com', OrderApi__Preferred_Email_Type__c='Personal');
        Database.insert(c, dml);

        Id tempItemMembershipId = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Individual Membership' LIMIT 1].Id;

        OrderApi__Subscription__c newSubscription = new OrderApi__Subscription__c(
                OrderApi__Contact__c = c.Id,
                OrderApi__Account__c = a.Id,
                OrderApi__Item__c = tempItemMembershipId,
                OrderApi__Grace_Period_End_Date__c = System.today() + 180,
                OrderApi__Paid_Through_Date__c = System.today() + 120,
                OrderApi__Activated_Date__c = System.today() - 120,
                OrderApi__Is_Active__c = TRUE,
                OrderApi__Status__c = 'Active',
                OrderApi__Entity__c = 'Contact',
                OrderApi__Subscription_Plan__c = [SELECT Id FROM OrderApi__Subscription_Plan__c LIMIT 1].Id
        );
        insert newSubscription;

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

        Id tempCommunityGroupId = [SELECT Id FROM PagesApi__Community_Group__c WHERE Name = 'Young Lawyers Section' LIMIT 1].Id;

        PagesApi__Community_Group_Member__c newCommunityGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = tempCommunityGroupId,
                PagesApi__Contact__c = c.Id,
                PagesApi__Status__c = 'Active'
        );
        insert newCommunityGroupMember;

        Id tempCommunityGroupId1 = [SELECT Id FROM PagesApi__Community_Group__c WHERE Name = 'Section' LIMIT 1].Id;

        PagesApi__Community_Group_Member__c newCommunityGroupMember1 = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = tempCommunityGroupId1,
                PagesApi__Contact__c = c.Id,
                PagesApi__Status__c = 'Active'
        );
        insert newCommunityGroupMember1;

        System.runAs(u) {
            System.assertEquals(4, FS_PortalSectionsAndGroupController.setup().size());
        }
    }

    @IsTest
    static void testUpdateCGM() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        dml.duplicateRuleHeader.runAsCurrentUser = true;


        Account a = new Account(Name = 'Test Unique15 51xq', ShippingCountry = 'United States');
        Database.insert(a, dml);

        Contact c = new Contact(FirstName = 'TestUniqeName 123gvx', LastName = 'ContactUniqueName qweq1', AccountId = a.Id, OrderApi__Personal_Email__c='fsemailupdatetest@example.com', OrderApi__Preferred_Email_Type__c='Personal');
        Database.insert(c, dml);

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

        OrderApi__Sales_Order__c tempOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c=c.Id,OrderApi__Account__c=a.Id,OrderApi__Entity__c='Contact');
        insert tempOrder;
        OrderApi__Sales_Order_Line__c tempLine = new OrderApi__Sales_Order_Line__c(OrderApi__Contact__c=c.Id,OrderApi__Account__c=a.Id,OrderApi__Sales_Order__c=tempOrder.Id);
        insert tempLine;
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];
        OrderApi__Subscription__c tempSub = new OrderApi__Subscription__c(OrderApi__Subscription_Plan__c=subPlan.Id,OrderApi__Contact__c=c.Id,OrderApi__Item__c=item.Id);
        insert tempSub;
        OrderApi__Renewal__c tempTerm = new OrderApi__Renewal__c(OrderApi__Contact__c=c.Id,OrderApi__Subscription__c=tempSub.Id,
                OrderApi__Term_Start_Date__c=System.today().addDays(-7), OrderApi__Term_End_Date__c=System.today().addDays(7),
                OrderApi__Grace_Period_End_Date__c=System.today().addDays(37),OrderApi__Sales_Order_Line__c=tempLine.Id);
        insert tempTerm;

        Id tempCommunityGroupId = [SELECT Id FROM PagesApi__Community_Group__c WHERE Name = 'Young Lawyers Section' LIMIT 1].Id;

        PagesApi__Community_Group_Member__c newCommunityGroupMember = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = tempCommunityGroupId,
                PagesApi__Contact__c = c.Id,
                PagesApi__Status__c = 'Active'
        );
        insert newCommunityGroupMember;

        Id tempCommunityGroupId1 = [SELECT Id FROM PagesApi__Community_Group__c WHERE Name = 'Section' LIMIT 1].Id;

        PagesApi__Community_Group_Member__c newCommunityGroupMember1 = new PagesApi__Community_Group_Member__c(
                PagesApi__Community_Group__c = tempCommunityGroupId1,
                PagesApi__Contact__c = c.Id,
                PagesApi__Status__c = 'Active'
        );
        insert newCommunityGroupMember1;

        Id itemId = [SELECT Id FROM OrderApi__Item__c WHERE Name = 'Test' LIMIT 1].Id;

        System.runAs(u) {
            String tempString = '[{"sectionItem": {"attributes": {"type": "OrderApi__Item__c","url": "/services/data/v47.0/sobjects/OrderApi__Item__c/'+itemId+'"},"Id": "'+itemId+'","Name": "Young Lawyers Section - Renewal","OrderApi__Price__c": 20,"FS_Linked_Community_Group__c": "'+tempCommunityGroupId+'","FS_Linked_Community_Group__r": {"attributes": {"type": "PagesApi__Community_Group__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group__c/'+tempCommunityGroupId+'"},"Name": "Young Lawyers Section","Id": "'+tempCommunityGroupId+'"}},"sectionCommittees": [{"sectionSubCommittees": [],"communityGroupMember": {"attributes": {"type": "PagesApi__Community_Group_Member__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group_Member__c/'+newCommunityGroupMember1.Id+'"},"Id": "'+newCommunityGroupMember1.Id+'","PagesApi__Community_Group__c": "'+tempCommunityGroupId1+'","PagesApi__Is_Active__c": true,"PagesApi__Community_Group__r": {"attributes": {"type": "PagesApi__Community_Group__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group__c/'+tempCommunityGroupId1+'"},"Name": "Youn: Committee on Membership","FS_Parent_Section__c": "'+tempCommunityGroupId+'","Id": "'+tempCommunityGroupId1+'"}},"checked": false}],"communityGroupMember": {"attributes": {"type": "PagesApi__Community_Group_Member__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group_Member__c/'+newCommunityGroupMember.Id+'"},"Id": "'+newCommunityGroupMember.Id+'","PagesApi__Contact__c": "'+c.Id+'","PagesApi__Community_Group__c": "'+tempCommunityGroupId+'","PagesApi__Community_Group__r": {"attributes": {"type": "PagesApi__Community_Group__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group__c/'+tempCommunityGroupId+'"},"Name": "Young Lawyers Section","Id": "'+tempCommunityGroupId+'"}},"checked": true}]';
            String tempString2 = '[{"sectionItem": {"attributes": {"type": "OrderApi__Item__c","url": "/services/data/v47.0/sobjects/OrderApi__Item__c/'+itemId+'"},"Id": "'+itemId+'","Name": "Young Lawyers Section - Renewal","OrderApi__Price__c": 20,"FS_Linked_Community_Group__c": "'+tempCommunityGroupId+'","FS_Linked_Community_Group__r": {"attributes": {"type": "PagesApi__Community_Group__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group__c/'+tempCommunityGroupId+'"},"Name": "Young Lawyers Section","Id": "'+tempCommunityGroupId+'"}},"sectionCommittees": [{"sectionSubCommittees": [],"communityGroupMember": {"attributes": {"type": "PagesApi__Community_Group_Member__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group_Member__c/'+newCommunityGroupMember1.Id+'"},"Id": "'+newCommunityGroupMember1.Id+'","PagesApi__Community_Group__c": "'+tempCommunityGroupId1+'","PagesApi__Is_Active__c": true,"PagesApi__Community_Group__r": {"attributes": {"type": "PagesApi__Community_Group__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group__c/'+tempCommunityGroupId1+'"},"Name": "Youn: Committee on Membership","FS_Parent_Section__c": "'+tempCommunityGroupId+'","Id": "'+tempCommunityGroupId1+'"}},"checked": true}],"communityGroupMember": {"attributes": {"type": "PagesApi__Community_Group_Member__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group_Member__c/'+newCommunityGroupMember.Id+'"},"Id": "'+newCommunityGroupMember.Id+'","PagesApi__Contact__c": "'+c.Id+'","PagesApi__Community_Group__c": "'+tempCommunityGroupId+'","PagesApi__Community_Group__r": {"attributes": {"type": "PagesApi__Community_Group__c","url": "/services/data/v47.0/sobjects/PagesApi__Community_Group__c/'+tempCommunityGroupId+'"},"Name": "Young Lawyers Section","Id": "'+tempCommunityGroupId+'"}},"checked": false}]';
            System.assertEquals(0, FS_PortalSectionsAndGroupController.updateCGM(tempString, tempString2, c.Id).size());
        }
    }
}