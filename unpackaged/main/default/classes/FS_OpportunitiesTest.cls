/**
 * Created by fusionSpan on 10-10-2019.
 */

@Istest
public class FS_OpportunitiesTest {
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_OpportunitiesRule = new Framework.RoutingRule();
        FS_OpportunitiesRule.apexClass = FS_Opportunities.class.getName();
        FS_OpportunitiesRule.namespace = '';
        FS_OpportunitiesRule.isEnabled = true;
        FS_OpportunitiesRule.sObjectName = 'Opportunity';
        FS_OpportunitiesRule.executionOrder = 10;
        rules.add(FS_OpportunitiesRule);
        Framework.Config.push(rules);
    }

    @istest
    static void OpportunitiesTestInsert(){
        Account acc = new Account();
        acc.Name= 'testAccount';
        insert acc;

        Opportunity opp = new Opportunity();
        Opp.Name = 'Testing';
        Opp.CloseDate = System.Today();
        Opp.AccountId = acc.Id;
        Opp.StageName = 'Prospecting';
        insert opp;
        List<Opportunity> OpportunitiesList = [SELECT Id FROM Opportunity WHERE Id=:opp.Id];
        FS_Opportunities FSOpportunitiesRoutingRule = new FS_Opportunities(OpportunitiesList);
        FS_Opportunities.Constructor cons = new FS_Opportunities.Constructor();
        cons.construct(OpportunitiesList);
        Framework.Dispatcher.dispatchTrigger();
    }
}