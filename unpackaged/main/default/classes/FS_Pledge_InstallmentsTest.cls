@IsTest
public class FS_Pledge_InstallmentsTest {
	@TestSetup
	private static void install() {
          Framework.Installer.install();
          PagesApi.PackageScripts.install();
          OrderApi.PackageScripts.install();

          Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
          Framework.RoutingRule pledgeInstallmentRule = new Framework.RoutingRule();
          pledgeInstallmentRule.apexClass = FS_Pledge_Installments.class.getName();
          pledgeInstallmentRule.namespace = '';
          pledgeInstallmentRule.isEnabled = true;
          pledgeInstallmentRule.sObjectName = 'FS_Pledge_Installments__c';
          pledgeInstallmentRule.executionOrder = 10;
          rules.add(pledgeInstallmentRule);
          Framework.Config.push(rules);
	}
    @IsTest
    static void pledgeInstallmentTestInsert(){
        //Inserting Contact
		Contact con =new Contact();
		con.LastName = 'Test Contact';
		insert con;
          
		//Inserting Fellow
		FS_Fellow__c fellow = new FS_Fellow__c(FS_Contact__c=con.Id);
		insert fellow;
        
        //Inserting Pledge Installation
        FS_Pledge_Installments__c pledgeInstallment = new FS_Pledge_Installments__c(FS_Fellow__c=fellow.Id);
        insert pledgeInstallment;
        
        List<FS_Pledge_Installments__c> pledgeInstallments = [SELECT Id FROM FS_Pledge_Installments__c WHERE Id =:pledgeInstallment.Id];
		FS_Pledge_Installments pledgeInstallmentRule = new FS_Pledge_Installments(pledgeInstallments);
        FS_Pledge_Installments.Constructor cons = new FS_Pledge_Installments.Constructor();
        cons.construct(pledgeInstallments);
        Framework.Dispatcher.dispatchTrigger();
    }
}