@IsTest
public class FS_AwardsTest {
@TestSetup
      private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install(); 

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule FS_AwardsRule = new Framework.RoutingRule();
          FS_AwardsRule.apexClass = FS_Awards.class.getName();
          FS_AwardsRule.namespace = '';
          FS_AwardsRule.isEnabled = true;
          FS_AwardsRule.sObjectName = 'FS_Awards__c';
          FS_AwardsRule.executionOrder = 10;
          rules.add(FS_AwardsRule);
          Framework.Config.push(rules);
      }

      @istest
      static void awardsTestInsert(){
          Contact con =new Contact();
          con.LastName = 'Test Contact';
          insert con;
          
		  FS_Awards__c awards=new FS_Awards__c();
          awards.FS_Contact__c = con.Id;
          insert awards;
          
          List<FS_Awards__c> awardsList = [SELECT Id FROM FS_Awards__c WHERE Id=:awards.Id];
          FS_Awards FSAwardsRoutingRule = new FS_Awards(awardsList);
          FS_Awards.Constructor cons = new FS_Awards.Constructor();
          cons.construct(awardsList);
          Framework.Dispatcher.dispatchTrigger();
          }
}