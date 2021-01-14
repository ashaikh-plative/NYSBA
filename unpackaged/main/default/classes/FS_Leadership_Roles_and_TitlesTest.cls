@IsTest
public class FS_Leadership_Roles_and_TitlesTest {
	@TestSetup
      private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install();

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule FS_RolesAndTitlesRule = new Framework.RoutingRule();
          FS_RolesAndTitlesRule.apexClass = FS_Leadership_Roles_and_Titles.class.getName();
          FS_RolesAndTitlesRule.namespace = '';
          FS_RolesAndTitlesRule.isEnabled = true;
          FS_RolesAndTitlesRule.sObjectName = 'FS_Leadership_Role_and_Title__c';
          FS_RolesAndTitlesRule.executionOrder = 0;
          rules.add(FS_RolesAndTitlesRule);
          Framework.Config.push(rules);
      }
    @Istest
    static void rolesAndTitlesInsert(){
        //Inserting Contact
        Contact con = new Contact(LastName='Test Con');
        insert con;
        //Inserting community Group
        PagesApi__Community_Group__c cGroup = new PagesApi__Community_Group__c(Name='Test');
        insert cGroup;
        //Inserting community Group Member
        PagesApi__Community_Group_Member__c cGroupMember = new PagesApi__Community_Group_Member__c(PagesApi__Community_Group__c=cGroup.Id,PagesApi__Status__c='Active',PagesApi__Contact__c=con.Id);
        insert cGroupMember;
        List<FS_Leadership_Role_and_Title__c> rolesAndTitleList = new List<FS_Leadership_Role_and_Title__c>();
        FS_Leadership_Role_and_Title__c roleAndTitles = new FS_Leadership_Role_and_Title__c(FS_Community_Group_Member__c=cGroupMember.Id);
        rolesAndTitleList.add(roleAndTitles);
        insert rolesAndTitleList;
        FS_Leadership_Roles_and_Titles FS_RolesAndTitlesRule = new FS_Leadership_Roles_and_Titles(rolesAndTitleList);
        FS_Leadership_Roles_and_Titles.Constructor rolesAndTitles = new FS_Leadership_Roles_and_Titles.Constructor();
        rolesAndTitles.construct(rolesAndTitleList);
        Framework.Dispatcher.dispatchTrigger();
	}
}