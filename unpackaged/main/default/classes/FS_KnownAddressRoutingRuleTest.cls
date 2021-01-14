/**
 *	@author:	cubiascaceres
 *	@date:		2019.Nov.11
 *	@desc:		Test Class for FS_KnownAddressRoutingRule
 */
@IsTest
public class FS_KnownAddressRoutingRuleTest {
    
    @TestSetup
    static void setupFramework() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_KnownAddressRoutingRule.class.getName();
        routingRule.namespace = 'OrderApi';
        routingRule.isEnabled = true;
        routingRule.sObjectName = 'OrderApi__Known_Address__c';
        routingRule.executionOrder = 30;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }
    
    @IsTest
    static void afterInsertTest() {
        Contact contact = new Contact(
            FirstName='FName Test',                                       
            LastName='LName Test',
        	MailingStreet = 'MailingStreet',
        	MailingCity = 'MailingCity',
        	OtherStreet= 'OtherStreet',
        	OtherCity = 'OtherCity');
        insert contact;
        OrderApi__Known_Address__c homeKnownAddress = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Home',
            OrderApi__Street__c='2210 Texas Pkwy', 
            OrderApi__City__c='Missouri City', 
            OrderApi__Province__c='TX', 
            OrderApi__Postal_Code__c='77489', 
            OrderApi__Country__c='US');        
        OrderApi__Known_Address__c workKnownAddress = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>{homeKnownAddress, workKnownAddress};
        Test.startTest();
        insert knownAddressList;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, 
                                      OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode,
                                      MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode 
                                  FROM Contact WHERE Id = :contact.Id LIMIT 1];
        //	Check if the contact was updated based on the Known Address record
        System.assertEquals(homeKnownAddress.OrderApi__Street__c, updatedContact.OtherStreet, 'Home Street does not match');
        System.assertEquals(homeKnownAddress.OrderApi__City__c, updatedContact.OtherCity, 'Home City does not match');
        System.assertEquals(homeKnownAddress.OrderApi__Province__c, updatedContact.OtherStateCode, 'Home State/Province does not match');
        System.assertEquals(homeKnownAddress.OrderApi__Postal_Code__c, updatedContact.OtherPostalCode, 'Home Postal Code does not match');
        System.assertEquals(homeKnownAddress.OrderApi__Country__c, updatedContact.OtherCountryCode, 'Home Country does not match');
        //	Check if the contact was updated based on the Known Address record
        System.assertEquals(workKnownAddress.OrderApi__Street__c, updatedContact.MailingStreet, 'Work Street does not match');
        System.assertEquals(workKnownAddress.OrderApi__City__c, updatedContact.MailingCity, 'Work City does not match');
        System.assertEquals(workKnownAddress.OrderApi__Province__c, updatedContact.MailingStateCode, 'Work State/Province does not match');
        System.assertEquals(workKnownAddress.OrderApi__Postal_Code__c, updatedContact.MailingPostalCode, 'Work Postal Code does not match');
        System.assertEquals(workKnownAddress.OrderApi__Country__c, updatedContact.MailingCountryCode, 'Work Country does not match');
    }
    
    @IsTest
    static void afterUpdateTest() {
        Contact contact = new Contact(FirstName='FName Test', LastName='LName Test');
        insert contact;
        OrderApi__Known_Address__c homeKnownAddress = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Home',
            OrderApi__Street__c='2210 Texas Pkwy', 
            OrderApi__City__c='Missouri City', 
            OrderApi__Province__c='TX', 
            OrderApi__Postal_Code__c='77489', 
            OrderApi__Country__c='US');        
        OrderApi__Known_Address__c workKnownAddress = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>{homeKnownAddress, workKnownAddress};
        insert knownAddressList;
        workKnownAddress.OrderApi__Is_Default__c = true;
        update workKnownAddress;
        
        Test.startTest();		
        homeKnownAddress.OrderApi__Street__c = '2 Texas Pkwy';
        workKnownAddress.OrderApi__Street__c = '7 8th Ave';
        update workKnownAddress;
        update homeKnownAddress;
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, 
                                      OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode,
                                      MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode 
                                  FROM Contact WHERE Id = :contact.Id LIMIT 1];
        //	Check if the contact was updated based on the Known Address record
        System.assertEquals(homeKnownAddress.OrderApi__Street__c, updatedContact.OtherStreet, 'Home Street does not match');
        System.assertEquals(homeKnownAddress.OrderApi__City__c, updatedContact.OtherCity, 'Home City does not match');
        System.assertEquals(homeKnownAddress.OrderApi__Province__c, updatedContact.OtherStateCode, 'Home State/Province does not match');
        System.assertEquals(homeKnownAddress.OrderApi__Postal_Code__c, updatedContact.OtherPostalCode, 'Home Postal Code does not match');
        System.assertEquals(homeKnownAddress.OrderApi__Country__c, updatedContact.OtherCountryCode, 'Home Country does not match');
        //	Check if the contact was updated based on the Known Address record
        System.assertEquals(workKnownAddress.OrderApi__Street__c, updatedContact.MailingStreet, 'Work Street does not match');
        System.assertEquals(workKnownAddress.OrderApi__City__c, updatedContact.MailingCity, 'Work City does not match');
        System.assertEquals(workKnownAddress.OrderApi__Province__c, updatedContact.MailingStateCode, 'Work State/Province does not match');
        System.assertEquals(workKnownAddress.OrderApi__Postal_Code__c, updatedContact.MailingPostalCode, 'Work Postal Code does not match');
        System.assertEquals(workKnownAddress.OrderApi__Country__c, updatedContact.MailingCountryCode, 'Work Country does not match');
        
    }

    @IsTest
    static void afterDeleteTest() {
        Contact contact = new Contact(FirstName='FName Test', LastName='LName Test');
        insert contact;
        OrderApi__Known_Address__c home1 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Home',
            OrderApi__Street__c='2210 Texas Pkwy', 
            OrderApi__City__c='Missouri City', 
            OrderApi__Province__c='TX', 
            OrderApi__Postal_Code__c='77489', 
            OrderApi__Country__c='US');        
        OrderApi__Known_Address__c work1 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>{home1, work1};
        insert knownAddressList;
        work1.OrderApi__Is_Default__c = true;
        update work1;
        
        Contact contact2 = new Contact(FirstName='FName Test', LastName='LName Test');
        insert contact2;
        OrderApi__Known_Address__c home21 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact2.Id,
            OrderApi__Type__c = 'Home',
            OrderApi__Street__c='2210 Texas Pkwy', 
            OrderApi__City__c='Missouri City', 
            OrderApi__Province__c='TX', 
            OrderApi__Postal_Code__c='77489', 
            OrderApi__Country__c='US');        
        OrderApi__Known_Address__c work21 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact2.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        OrderApi__Known_Address__c work22 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact2.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        knownAddressList = new List<OrderApi__Known_Address__c>{home21, work21, work22};
        insert knownAddressList;    
        
        Test.startTest();
        delete work1;
        delete home1;
        delete work21;
        Test.stopTest();
        
    }
    
    @IsTest
    static void afterUpdateChangeTypeWorkToHome() {
        Contact contact = new Contact(FirstName='FName Test', LastName='LName Test');
        insert contact;
        OrderApi__Known_Address__c home1 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Home',
            OrderApi__Street__c='2210 Texas Pkwy', 
            OrderApi__City__c='Missouri City', 
            OrderApi__Province__c='TX', 
            OrderApi__Postal_Code__c='77489', 
            OrderApi__Country__c='US');        
        OrderApi__Known_Address__c work1 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>{home1, work1};
        insert knownAddressList;
        work1.OrderApi__Is_Default__c = true;
        update work1;
        Test.startTest();
        work1.OrderApi__Type__c = 'Home';
        update work1;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, 
                                      MailingStreet, MailingCity, MailingStateCode, MailingPostalCode, MailingCountryCode 
                                  FROM Contact WHERE Id = :contact.Id LIMIT 1];
        System.assertEquals(null, updatedContact.MailingStreet);
        System.assertEquals(null, updatedContact.MailingCity);
        System.assertEquals(null, updatedContact.MailingStateCode);
        System.assertEquals(null, updatedContact.MailingPostalCode);
        System.assertEquals(null, updatedContact.MailingCountryCode);
    }
    
    @IsTest
    static void afterUpdateChangeTypeHomeToWork() {
        Contact contact = new Contact(FirstName='FName Test', LastName='LName Test');
        insert contact;
        OrderApi__Known_Address__c home1 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Home',
            OrderApi__Street__c='2210 Texas Pkwy', 
            OrderApi__City__c='Missouri City', 
            OrderApi__Province__c='TX', 
            OrderApi__Postal_Code__c='77489', 
            OrderApi__Country__c='US');        
        OrderApi__Known_Address__c work1 = new OrderApi__Known_Address__c(
            OrderApi__Contact__c = contact.Id,
            OrderApi__Type__c = 'Work',
            OrderApi__Street__c='761 7th Ave', 
            OrderApi__City__c='New York', 
            OrderApi__Province__c='NY', 
            OrderApi__Postal_Code__c='10019', 
            OrderApi__Country__c='US');
        List<OrderApi__Known_Address__c> knownAddressList = new List<OrderApi__Known_Address__c>{home1, work1};
        insert knownAddressList;
        work1.OrderApi__Is_Default__c = true;
        update work1;
        Test.startTest();
        home1.OrderApi__Type__c = 'Work';
        update home1;
        Test.stopTest();
        Contact updatedContact = [SELECT Id, 
                                      OtherStreet, OtherCity, OtherStateCode, OtherPostalCode, OtherCountryCode
                                  FROM Contact WHERE Id = :contact.Id LIMIT 1];
        System.assertEquals(null, updatedContact.OtherStreet);
        System.assertEquals(null, updatedContact.OtherCity);
        System.assertEquals(null, updatedContact.OtherStateCode);
        System.assertEquals(null, updatedContact.OtherPostalCode);
        System.assertEquals(null, updatedContact.OtherCountryCode);
    }
}