@Istest
public class FS_FellowsTest {
       @TestSetup
      private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install();

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule FS_FellowsRule = new Framework.RoutingRule();
          FS_FellowsRule.apexClass = FS_Fellows.class.getName();
          FS_FellowsRule.namespace = '';
          FS_FellowsRule.isEnabled = true;
          FS_FellowsRule.sObjectName = 'FS_Fellow__c';
          FS_FellowsRule.executionOrder = 10;
          rules.add(FS_FellowsRule);
          Framework.Config.push(rules);
      }
 @Istest
      static void fellowsTestInsert(){
          //Inserting Contact
          Contact con =new Contact();
          con.LastName = 'Test Contact';
          insert con;
          
          //inserting Fellow
          FS_Fellow__c fellow = new FS_Fellow__c(FS_Contact__c=con.Id);
          insert fellow;
          
          
          List<FS_Fellow__c> fellowList = [SELECT Id FROM FS_Fellow__c WHERE Id=:fellow.Id];
          FS_Fellows FSFellowRoutingRule = new FS_Fellows(fellowList);
          FS_Fellows.Constructor cons = new FS_Fellows.Constructor();
          cons.construct(fellowList);
          Framework.Dispatcher.dispatchTrigger();
          }
}