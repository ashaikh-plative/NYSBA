/**
 * Created by Nikhil on 17-11-2019.
 */

@IsTest
public class FS_Opportunity_Product_BenefitsTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_OppProductBenefitRule = new Framework.RoutingRule();
        FS_OppProductBenefitRule.apexClass = FS_Opportunity_Product_Benefits.class.getName();
        FS_OppProductBenefitRule.namespace = '';
        FS_OppProductBenefitRule.isEnabled = true;
        FS_OppProductBenefitRule.sObjectName = 'Opportunity_Product_Benefits__c';
        FS_OppProductBenefitRule.executionOrder = 0;
        rules.add(FS_OppProductBenefitRule);
        Framework.Config.push(rules);
    }
    @Istest
    static void oppProductBenefitInsert(){
        List<Opportunity_Product_Benefits__c> oppProdBenefitsList = new List<Opportunity_Product_Benefits__c>();
        Opportunity_Product_Benefits__c oppProdBenefits = new Opportunity_Product_Benefits__c(FS_Benefit_Name__c='Test Opportunity Benefit Name');
        oppProdBenefitsList.add(oppProdBenefits);
        insert oppProdBenefitsList;

        FS_Opportunity_Product_Benefits FS_oppProdBenefitsRule = new FS_Opportunity_Product_Benefits(oppProdBenefitsList);
        FS_Opportunity_Product_Benefits.Constructor oppProdB = new FS_Opportunity_Product_Benefits.Constructor();
        oppProdB.construct(oppProdBenefitsList);
        Framework.Dispatcher.dispatchTrigger();
    }
}