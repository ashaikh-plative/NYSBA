/**
 * Created by daweima on 4/14/20.
 */

@IsTest
public class FS_FileUploadControllerTest {

    static testMethod void test() {
        Account a = new Account(Name='Test Account Name');
        insert a;
        User adminUser = [SELECT Id FROM User WHERE Profile.Name='System Administrator' AND IsActive = TRUE LIMIT 1][0];

        Contact con = new Contact(AccountId = a.Id);
        con.LastName = 'Test Contact';
        con.FS_Graduation_Date__c = System.today() + 10;
        con.OwnerId = adminUser.Id;
        insert con;


        User user = new User();
        user.ProfileId = [SELECT Id FROM Profile WHERE Name='Fonteva Customer Community Login User'].get(0).Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@domain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = con.Id;
        insert user;

        FS_FileUploadController.getContact();
        Id tempId = FS_FileUploadController.saveChunk(con.Id,'test','test','.jpg','',con.LastName);
        FS_FileUploadController.setPublicLink(tempId,con.Id);
    }
}