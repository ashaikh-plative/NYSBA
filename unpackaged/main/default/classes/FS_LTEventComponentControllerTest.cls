@IsTest
public class FS_LTEventComponentControllerTest {
    
    @IsTest
    static void encodeStringTest() {
        String urlEncoded = FS_LTEventComponentController.encodeString('http://www.google.com');
        System.assertEquals('http%3A%2F%2Fwww.google.com', urlEncoded);
    }

    @IsTest
    static void checkUserRegisteredTest(){
        Account ac = new Account();
        ac.Name='Test';
        insert ac;
        
        Contact testContact = new Contact();
        testContact.Email = 'Test7347826838878@Test.com';
        testContact.LastName = 'Test7347826838878';
        testContact.accountId = ac.Id;
        insert testContact; 
        
        User testUser= new User();
        
        testUser.profileid = [select id from profile where userLicense.Name like '%Community%' limit 1].Id; 
        testUser.Contactid = testContact.id;
        testUser.Username = testContact.Email;
        testUser.LastName = testContact.LastName;
        testUser.Email = testContact.Email;
        testUser.Alias = 'MNU'+String.ValueOf(testContact.id).right(5);
        testUser.CommunityNickname = testContact.Email;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.languagelocalekey = 'en_US';
        testUser.timezonesidkey = 'America/Los_Angeles';
        testUser.localesidkey = 'en_US';
        testUser.IsActive = true;
        Insert testUser;
        
        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
            Name='test');
        insert busGroup;
        
        // Inserting Event Category
        EventApi__Event_Category__c eCategory = new EventApi__Event_Category__c(
            Name='My Meeting',
            EventApi__Business_Group__c=busGroup.Id);
        insert eCategory;
        
        // Inserting EVent
        EventApi__Event__c event=new EventApi__Event__c(
            EventApi__Event_Category__c=eCategory.Id,
            Name='My Summit Meeting',
            EventApi__Status__c='Active',
            EventApi__Business_Group__c=busGroup.Id,
            EventApi__Event_Key__c='15506a-b170ac-1'
        );
        insert event;
    
        
        // Inserting Attendee
        EventApi__Attendee__c attendee=new EventApi__Attendee__c(
            EventApi__Status__c='Registered',
            EventApi__Account__c=ac.Id,
            EventApi__Contact__c=testContact.Id,
            
            EventApi__Event__c=event.Id
            
        );
        insert attendee;
        
        EventApi__Attendee__c atnde =[SELECT Id, Name,EventApi__Status__c,EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =:event.Id Limit 1];
        System.assertEquals('Registered',atnde.EventApi__Status__c);
        
        Boolean result= FS_LTEventComponentController.checkUserRegistered(event.Id);
        System.assertEquals(true, result);
        
        
    }
    @IsTest
    static void checkUserCancelledTest(){
        Account ac = new Account();
        ac.Name='Test';
        insert ac;
        
        Contact testContact = new Contact();
        testContact.Email = 'Test7347826838878@Test.com';
        testContact.LastName = 'Test7347826838878';
        testContact.accountId = ac.Id;
        insert testContact; 
        
        User testUser= new User();
        
        testUser.profileid = [select id from profile where userLicense.Name like '%Community%' limit 1].Id; 
        testUser.Contactid = testContact.id;
        testUser.Username = testContact.Email;
        testUser.LastName = testContact.LastName;
        testUser.Email = testContact.Email;
        testUser.Alias = 'MNU'+String.ValueOf(testContact.id).right(5);
        testUser.CommunityNickname = testContact.Email;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.languagelocalekey = 'en_US';
        testUser.timezonesidkey = 'America/Los_Angeles';
        testUser.localesidkey = 'en_US';
        testUser.IsActive = true;
        Insert testUser;
        
        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
            Name='test');
        insert busGroup;
        
        // Inserting Event Category
        EventApi__Event_Category__c eCategory = new EventApi__Event_Category__c(
            Name='My Meeting',
            EventApi__Business_Group__c=busGroup.Id);
        insert eCategory;
        
        // Inserting EVent
        EventApi__Event__c event=new EventApi__Event__c(
            EventApi__Event_Category__c=eCategory.Id,
            Name='My Summit Meeting',
            EventApi__Status__c='Active',
            EventApi__Business_Group__c=busGroup.Id,
            EventApi__Event_Key__c='15506a-b170ac-1'
        );
        insert event;
    
        
        // Inserting Attendee
        EventApi__Attendee__c attendee=new EventApi__Attendee__c(
            EventApi__Status__c='Cancelled',
            EventApi__Account__c=ac.Id,
            EventApi__Contact__c=testContact.Id,
            
            EventApi__Event__c=event.Id
            
        );
        insert attendee;
        
        EventApi__Attendee__c atnde =[SELECT Id, Name,EventApi__Status__c,EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =:event.Id Limit 1];
        System.assertEquals('Cancelled',atnde.EventApi__Status__c);
        
        Boolean result= FS_LTEventComponentController.checkUserRegistered(event.Id);
        System.assertEquals(false, result);
        
    }
    @IsTest
    static void checkUserInvitedTest(){
        Account ac = new Account();
        ac.Name='Test';
        insert ac;
        
        Contact testContact = new Contact();
        testContact.Email = 'Test7347826838878@Test.com';
        testContact.LastName = 'Test7347826838878';
        testContact.accountId = ac.Id;
        insert testContact; 
        
        User testUser= new User();
        
        testUser.profileid = [select id from profile where userLicense.Name like '%Community%' limit 1].Id; 
        testUser.Contactid = testContact.id;
        testUser.Username = testContact.Email;
        testUser.LastName = testContact.LastName;
        testUser.Email = testContact.Email;
        testUser.Alias = 'MNU'+String.ValueOf(testContact.id).right(5);
        testUser.CommunityNickname = testContact.Email;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.languagelocalekey = 'en_US';
        testUser.timezonesidkey = 'America/Los_Angeles';
        testUser.localesidkey = 'en_US';
        testUser.IsActive = true;
        Insert testUser;
        
        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
            Name='test');
        insert busGroup;
        
        // Inserting Event Category
        EventApi__Event_Category__c eCategory = new EventApi__Event_Category__c(
            Name='My Meeting',
            EventApi__Business_Group__c=busGroup.Id);
        insert eCategory;
        
        // Inserting EVent
        EventApi__Event__c event=new EventApi__Event__c(
            EventApi__Event_Category__c=eCategory.Id,
            Name='My Summit Meeting',
            EventApi__Status__c='Active',
            EventApi__Business_Group__c=busGroup.Id,
            EventApi__Event_Key__c='15506a-b170ac-1'
        );
        insert event;
    
        
        // Inserting Attendee
        EventApi__Attendee__c attendee=new EventApi__Attendee__c(
            EventApi__Status__c='Invited',
            EventApi__Account__c=ac.Id,
            EventApi__Contact__c=testContact.Id,
            
            EventApi__Event__c=event.Id
            
        );
        insert attendee;
        
        EventApi__Attendee__c atnde =[SELECT Id, Name,EventApi__Status__c,EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =:event.Id Limit 1];
        System.assertEquals('Invited',atnde.EventApi__Status__c);
        
        Boolean result= FS_LTEventComponentController.checkUserRegistered(event.Id);
        System.assertEquals(false, result);
        
    }
    @IsTest
    static void checkUserHasNoAttendeeTest(){
        Account ac = new Account();
        ac.Name='Test';
        insert ac;
        
        Contact testContact = new Contact();
        testContact.Email = 'Test7347826838878@Test.com';
        testContact.LastName = 'Test7347826838878';
        testContact.accountId = ac.Id;
        insert testContact; 
        
        User testUser= new User();
        
        testUser.profileid = [select id from profile where userLicense.Name like '%Community%' limit 1].Id; 
        testUser.Contactid = testContact.id;
        testUser.Username = testContact.Email;
        testUser.LastName = testContact.LastName;
        testUser.Email = testContact.Email;
        testUser.Alias = 'MNU'+String.ValueOf(testContact.id).right(5);
        testUser.CommunityNickname = testContact.Email;
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.languagelocalekey = 'en_US';
        testUser.timezonesidkey = 'America/Los_Angeles';
        testUser.localesidkey = 'en_US';
        testUser.IsActive = true;
        Insert testUser;
        
        //Inserting Business Group
        OrderApi__Business_Group__c busGroup = new OrderApi__Business_Group__c(
            Name='test');
        insert busGroup;
        
        // Inserting Event Category
        EventApi__Event_Category__c eCategory = new EventApi__Event_Category__c(
            Name='My Meeting',
            EventApi__Business_Group__c=busGroup.Id);
        insert eCategory;
        
        // Inserting EVent
        EventApi__Event__c event=new EventApi__Event__c(
            EventApi__Event_Category__c=eCategory.Id,
            Name='My Summit Meeting',
            EventApi__Status__c='Active',
            EventApi__Business_Group__c=busGroup.Id,
            EventApi__Event_Key__c='15506a-b170ac-1'
        );
        insert event;
        
        Boolean result= FS_LTEventComponentController.checkUserRegistered(event.Id);
        System.assertEquals(false, result);
        
    }

}