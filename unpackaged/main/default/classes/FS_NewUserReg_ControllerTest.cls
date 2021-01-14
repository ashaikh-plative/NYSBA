@IsTest
public with sharing class FS_NewUserReg_ControllerTest {
    
    //  @TestSetup 
    static void setup() {
        /*
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();*/
        Account a = new Account(Name = 'Test Account', ShippingCountry = 'United States');        
        insert a;
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = a.Id, OrderApi__Personal_Email__c='fsemailupdatetest@example.com', OrderApi__Preferred_Email_Type__c='Personal');
        insert c;
        
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
    }
    
    static void initData() {
        Account a = new Account(Name = 'Test Account', ShippingCountry = 'United States');        
        insert a;
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = a.Id, OrderApi__Personal_Email__c='fsemailupdatetest@example.com', OrderApi__Preferred_Email_Type__c='Personal');
        insert c;
        
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
    }

    @IsTest static void testNewUserRegLoginSetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(2, FS_NewUserReg_Controller.newUserRegLoginSetup().size());
        }
    }

    @IsTest static void testNewUserRegAttorneySetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(5, FS_NewUserReg_Controller.newUserRegAttorneySetup().size());
        }
    }

    @IsTest static void testNewUserRegStudentSetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(5, FS_NewUserReg_Controller.newUserRegStudentSetup().size());
        }
    }

    @IsTest static void testNewUserRegCompanySearchSetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(4, FS_NewUserReg_Controller.newUserRegCompanySearchSetup().size());
        }
    }

    @IsTest static void testNewUserRegCompanySetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(4, FS_NewUserReg_Controller.newUserRegCompanySetup().size());
        }
    }

    @IsTest static void testNewUserRegGDPROptInSetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(2, FS_NewUserReg_Controller.newUserRegGDPROptInSetup().size());
        }
    }

    @IsTest static void testNewUserRegSomeoneElseSetup() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        System.runAs(u) {
            System.assertEquals(5, FS_NewUserReg_Controller.newUserRegSomeoneElseSetup().size());
        }
    }

    @IsTest static void testSearchAccount() {
        List<Map<String, Object>> fieldSet = new List<Map<String, Object>>{new Map<String, Object>{'APIName'=>'Name', 'Value'=>'Test', 'Type'=>'text'}};
        FS_NewUserReg_Controller.searchAccount(fieldSet);
        //	System.assertEquals(1, ((List<Account>) FS_NewUserReg_Controller.searchAccount(fieldSet).get('Search Results')).size());
    }

    @IsTest static void testCreateAccount() {
        Account a = new Account(Name = 'Test Account1', ShippingCountry = 'United States');
        insert a;

        Contact c = new Contact(FirstName = 'Test1', LastName = 'Contact1', AccountId = a.Id);
        insert c;

        Account newAccount = new Account(Name = 'Test Account2', ShippingCountry = 'United States');

        System.assertEquals(true, (Boolean) FS_NewUserReg_Controller.createAccount(newAccount, c.Id, a.Id).get('Success'));
    }

    @IsTest
    static void testInsertContact() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        //	System.runAs(u) {
            Contact c = new Contact();
            c.LastName='0187baecc053f32fe39aa4b55bc50e6e';
            insert c;   
        //	}
    }
    
    @IsTest static void testCreateContactAttorney() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        //Contact c = new Contact(FirstName = 'AttorneyTest1', LastName = 'AttorneyContact1', OrderApi__Personal_Email__c='attorney+test123123@test.com', OrderApi__Preferred_Email_Type__c='Personal');
        Contact c = new Contact();
        c.Salutation='Mr.';
        c.FirstName='Miguel';
        c.LastName='Cubias';
        c.DonorApi__Suffix__c='Jr.';
        c.OrderApi__Personal_Email__c='p2+cubias+test@attorney.com';
        c.OrderApi__Work_Email__c='w2+cubias+test@attorney.com';
        c.OrderApi__Preferred_Email_Type__c='Personal';
        c.FS_Preferred_Mailing_Address__c='Work/School';
        c.MailingStreet='2319 Guadalupe St';
        c.MailingCity='Laredo';
        c.MailingPostalCode='78043';
        c.MailingCountryCode='US';
        c.MailingStateCode='FL';
        c.FS_NYS_Attorney_Registration_Number__c='0000001';
        c.FS_NYS_Admission_Date__c=system.today();
        c.FS_Out_of_State_First_Admit_Date__c=null;
        c.HomePhone='2200-1100';
        c.OrderApi__Work_Phone__c='';
        c.MobilePhone='';
        c.OrderApi__Preferred_Phone_Type__c='Home';
        c.FS_I_accept_NYSBA_s_Terms_of_Service__c=true;
        Map<String, Object> oMap = FS_NewUserReg_Controller.createContactAttorney(c, u.Id, '123qweASD');
        system.debug('TEST:oMap: ' + oMap);
        //	System.assertEquals(2, oMap.size());
    }

    @IsTest static void testCreateContactStudent() {
        initData();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        Contact c = new Contact(FirstName = 'Test1', LastName = 'Contact1', OrderApi__Personal_Email__c='test123123@test.com', OrderApi__Preferred_Email_Type__c='Personal');
        FS_NewUserReg_Controller.createContactStudent(c, u.Id, '123qweASD');
        //	System.assertEquals(3, FS_NewUserReg_Controller.createContactStudent(c, u.Id, '123qweASD').size());
    }

    @IsTest static void testCreateContactSomeoneElse() {
        initData();
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        Contact c = new Contact(FirstName = 'Test1', LastName = 'Contact1', OrderApi__Personal_Email__c='test123123@test.com', OrderApi__Preferred_Email_Type__c='Personal');
        Test.stopTest();
        FS_NewUserReg_Controller.createContactSomeoneElse(c, u.Id, '123qweASD');
        //	System.assertEquals(2, FS_NewUserReg_Controller.createContactSomeoneElse(c, u.Id, '123qweASD').size());
    }

    @IsTest static void testUserLogin() {
        initData();
        System.assertEquals(true, FS_NewUserReg_Controller.userLogin('fsemailupdatetest@example.com', '123qweasd').containsKey('Error'));
    }

    @IsTest static void testCheckEmail() {
        initData();
        System.assertEquals(true, FS_NewUserReg_Controller.checkEmail('fsemailupdatetest@example.com').containsKey('Preferred Email Exists'));
    }

    @IsTest static void testResetPasswordMethod() {
        initData();
        System.assertEquals(true, FS_NewUserReg_Controller.resetPasswordMethod('fsemailupdatetest@example.com').containsKey('Password Reset'));
    }

    @IsTest static void testCheckUsernameAndLawSchool() {
        initData();
        System.assertEquals(true, FS_NewUserReg_Controller.checkUsernameAndLawSchool('fsemailupdatetest@example.com', false, '').containsKey('Email Exists'));
    }

    @IsTest static void testUpdateCompany() {
        initData();
        Id oldAccountId = [SELECT Id FROM Account WHERE Name = 'Test Account'][0].Id;
        Account newAccount = new Account(Name = 'Test Account1', ShippingCountry = 'United States');
        insert newAccount;
        Id contactId = [SELECT Id FROM Contact WHERE OrderApi__Personal_Email__c = 'fsemailupdatetest@example.com'][0].Id;
        System.assertEquals(true, (Boolean) FS_NewUserReg_Controller.updateCompany(contactId, oldAccountId, newAccount.Id).get('Success'));
    }

    @IsTest static void testUpdateGDPROptIn() {
        initData();
        Id contactId = [SELECT Id FROM Contact WHERE OrderApi__Personal_Email__c = 'fsemailupdatetest@example.com'][0].Id;
        System.assertEquals(true, (Boolean) FS_NewUserReg_Controller.updateGDPROptIn(contactId, true).get('Success'));
    }

    @IsTest static void testSearchLawSchool() {
        initData();
        System.assertEquals(0, ((List<Account>) FS_NewUserReg_Controller.searchLawSchool('Test').get('Result')).size());
    }

    @IsTest static void testCallout() {
        initData();
        Test.setMock(HttpCalloutMock.class, new FS_OktaServicesCalloutMock());
        Test.startTest();
        User u = [SELECT Id FROM User WHERE Username = 'fsemailupdatetest@example.com'][0];
        Contact contactSomeoneElse = new Contact(FirstName = 'Test1', LastName = 'Contact1', OrderApi__Personal_Email__c='test123123@test.com', OrderApi__Preferred_Email_Type__c='Personal');
        Id ownerId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL ORDER BY CreatedDate ASC LIMIT 1][0].Id;
        contactSomeoneElse.OwnerId = ownerId;
        insert contactSomeoneElse;
        contactSomeoneElse = [SELECT Id, AccountId, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id = :contactSomeoneElse.Id][0];
        //	Account tempAccount = new Account(Id = contactSomeoneElse.AccountId, OwnerId = ownerId);
        //	update tempAccount;

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1][0].Id;
        User user = new User(
                LastName = contactSomeoneElse.LastName,
                FirstName = contactSomeoneElse.FirstName,
                Alias = (contactSomeoneElse.FirstName.substring(0, 1) + contactSomeoneElse.LastName).left(8),
                Email = contactSomeoneElse.OrderApi__Preferred_Email__c,
                Username = contactSomeoneElse.OrderApi__Preferred_Email__c,
                ProfileId = profileId,
                IsActive = true,
                TimeZoneSidKey = 'America/New_York',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                ContactId = contactSomeoneElse.Id,
                CommunityNickname = ((contactSomeoneElse.OrderApi__Preferred_Email__c.substringBefore('@')).left(20) + '.' + String.valueOf(Math.abs(Crypto.getRandomLong()))).left(40)
        );
        //	insert user;
        //	FS_OktaServices.doInvokeOkta(contactSomeoneElse.Id, user.Id, contactSomeoneElse.FirstName, contactSomeoneElse.LastName, contactSomeoneElse.OrderApi__Preferred_Email__c, 'password', 'insert');
        //	FS_OktaServices.doInvokeOkta(contactSomeoneElse.Id, user.Id, contactSomeoneElse.FirstName, contactSomeoneElse.LastName, contactSomeoneElse.OrderApi__Preferred_Email__c, '', 'insert');

        Test.stopTest();
    }
}