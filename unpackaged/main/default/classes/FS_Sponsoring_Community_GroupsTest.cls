@IsTest
public class FS_Sponsoring_Community_GroupsTest {
	@TestSetup
      private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install();

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule FS_sponsoringComGroupRule = new Framework.RoutingRule();
          FS_sponsoringComGroupRule.apexClass = FS_Sponsoring_Community_Groups.class.getName();
          FS_sponsoringComGroupRule.namespace = '';
          FS_sponsoringComGroupRule.isEnabled = true;
          FS_sponsoringComGroupRule.sObjectName = 'FS_Sponsoring_Community_Groups__c';
          FS_sponsoringComGroupRule.executionOrder = 12;
          rules.add(FS_sponsoringComGroupRule);
          Framework.Config.push(rules);
      }
    @Istest
    static void sponsoringCommunityGroupTestInsert(){
        PagesApi__Community_Group__c communityGroup = new PagesApi__Community_Group__c(
        	Name = 'Test community Group');
        insert communityGroup;
        List<FS_Sponsoring_Community_Groups__c> sponsoringCommunityGroups = new List<FS_Sponsoring_Community_Groups__c>();
        FS_Sponsoring_Community_Groups__c sponsorComGroup = new FS_Sponsoring_Community_Groups__c(
        	FS_Community_Group__c = communityGroup.Id);
        sponsoringCommunityGroups.add(sponsorComGroup);
        insert sponsoringCommunityGroups;
        FS_Sponsoring_Community_Groups FS_Sponsoring_Community_Groups = new FS_Sponsoring_Community_Groups(sponsoringCommunityGroups);
        FS_Sponsoring_Community_Groups.Constructor sCommGroup = new FS_Sponsoring_Community_Groups.Constructor();
        sCommGroup.construct(sponsoringCommunityGroups);
        Framework.Dispatcher.dispatchTrigger();
    }

}