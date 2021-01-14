@IsTest
public class FS_LogisticsTest {
	@TestSetup
      private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install();

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule FS_LogisticsRule = new Framework.RoutingRule();
          FS_LogisticsRule.apexClass = FS_Logistics.class.getName();
          FS_LogisticsRule.namespace = '';
          FS_LogisticsRule.isEnabled = true;
          FS_LogisticsRule.sObjectName = 'Logistics__c';
          FS_LogisticsRule.executionOrder = 11;
          rules.add(FS_LogisticsRule);
          Framework.Config.push(rules);
      }
    @Istest
    static void logisticsTestInsert(){
        List<Logistics__c> logisticsList = new List<Logistics__c>();
    	Logistics__c logistics = new Logistics__c(
			FS_Type__c='Microphone');
        logisticsList.add(logistics);
        insert logisticsList;
        FS_Logistics FS_LogisticsRule = new FS_Logistics(logisticsList);
        FS_Logistics.Constructor logi = new FS_Logistics.Constructor();
        logi.construct(logisticsList);
        Framework.Dispatcher.dispatchTrigger();
    }
          

}