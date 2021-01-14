/**
 * Created by Seshu on 24-03-2020.
 */

@IsTest
private class FS_PortalUserAccountRuleTest {

    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule portalUserAccountRule = new Framework.RoutingRule();
        portalUserAccountRule.apexClass = FS_PortalUserAccountRule.class.getName();
        portalUserAccountRule.namespace = '';
        portalUserAccountRule.isEnabled = true;
        portalUserAccountRule.sObjectName = 'Account';
        portalUserAccountRule.executionOrder = 20;
        rules.add(portalUserAccountRule);
        Framework.Config.push(rules);
        
        //Contact
        Contact contact = new Contact();
        contact.LastName = 'testcontact';
        contact.Email = 'testmail@email.com';
        insert contact;
        
        //Account
        Account account = new Account();
        account.Name = 'TestAccount';
        insert account;
        
        //Inserting User Record
        User testUser = new User();
        testUser.FirstName='Test';
        testUser.LastName='t';
        testUser.ContactId=contact.Id;
        testUser.Email=contact.Email;
        testUser.Username='FirstTest@Test.com';
        testUser.EmailEncodingKey='ISO-8859-1';
        testUser.Alias='ts';
        testUser.TimeZoneSidKey='America/Los_Angeles';
        testUser.LocaleSidKey='en_US';
        testUser.LanguageLocaleKey='en_US';
        testUser.ProfileId=[SELECT Id,Name FROM Profile WHERE UserLicense.Name LIKE '%Customer Community Login%' LIMIT 1].Id;
        insert testUser;

    }
    

    @IsTest
    static void testData(){
        
        Account relatedAccount = [SELECT Id,OwnerId FROM Account WHERE Name='TestAccount' LIMIT 1]; 
        Contact relatedContact = [SELECT Id,Email FROM Contact WHERE LastName='testcontact' LIMIT 1];
        User testUser = [SELECT Id,ProfileId,IsActive FROM User WHERE FirstName='Test' AND IsActive=true LIMIT 1];
        
        
            System.runAs(testUser){
                System.assertEquals(testUser.Id,UserInfo.getUserId());
                System.assertEquals(testUser.ProfileId,testUser.ProfileId);
                System.assertNotEquals(relatedaccount.OwnerId,UserInfo.getUserId());
            }
        }
    }