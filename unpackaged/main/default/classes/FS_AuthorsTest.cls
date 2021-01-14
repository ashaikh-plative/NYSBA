@IsTest
public class FS_AuthorsTest {
	@TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_AuthorsRule = new Framework.RoutingRule();
        FS_AuthorsRule.apexClass = FS_Authors.class.getName();
        FS_AuthorsRule.namespace = '';
        FS_AuthorsRule.isEnabled = true;
        FS_AuthorsRule.sObjectName = 'FS_Authors__c';
        FS_AuthorsRule.executionOrder = 10;
        rules.add(FS_AuthorsRule);
        Framework.Config.push(rules);
    }
    
    @istest
    static void authorsTestInsert(){
        Contact con =new Contact();
        con.LastName = 'Test Contact';
        insert con;
        
        FS_Authors__c author = new FS_Authors__c();
        author.FS_Author_Name__c = con.Id;
        insert author;
        List<FS_Authors__c> authorList = [SELECT Id FROM FS_Authors__c WHERE Id=:author.Id];
        FS_Authors FSAuthorRoutingRule = new FS_Authors(authorList);
        FS_Authors.Constructor cons = new FS_Authors.Constructor();
        cons.construct(authorList);
        Framework.Dispatcher.dispatchTrigger();
    }
}