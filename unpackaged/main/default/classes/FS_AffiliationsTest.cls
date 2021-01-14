@Istest
public class FS_AffiliationsTest {
	@TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_AffiliationsRule = new Framework.RoutingRule();
        FS_AffiliationsRule.apexClass = FS_Affiliations.class.getName();
        FS_AffiliationsRule.namespace = '';
        FS_AffiliationsRule.isEnabled = true;
        FS_AffiliationsRule.sObjectName = 'FS_Affiliation__c';
        FS_AffiliationsRule.executionOrder = 10;
        rules.add(FS_AffiliationsRule);
        Framework.Config.push(rules);
    }
    
    @istest
    static void affiliationsTestInsert(){
        Contact con =new Contact();
        con.LastName = 'Test Contact';
        insert con;
        
        FS_Affiliation__c affiliations = new FS_Affiliation__c();
        affiliations.FS_Child_Contact__c = con.Id;
        insert affiliations;
        List<FS_Affiliation__c> affiliationList = [SELECT Id FROM FS_Affiliation__c WHERE Id=:affiliations.Id];
        FS_Affiliations FSAffiliationsRoutingRule = new FS_Affiliations(affiliationList);
        FS_Affiliations.Constructor cons = new FS_Affiliations.Constructor();
        cons.construct(affiliationList);
        Framework.Dispatcher.dispatchTrigger();
    }
    
}