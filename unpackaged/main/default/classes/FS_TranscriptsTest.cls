@istest
public class FS_TranscriptsTest {
	@TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule FS_TranscriptsRule = new Framework.RoutingRule();
        FS_TranscriptsRule.apexClass = FS_Transcripts.class.getName();
        FS_TranscriptsRule.namespace = '';
        FS_TranscriptsRule.isEnabled = true;
        FS_TranscriptsRule.sObjectName = 'FS_Transcript__c';
        FS_TranscriptsRule.executionOrder = 10;
        rules.add(FS_TranscriptsRule);
        Framework.Config.push(rules);
    }
    
    @istest
    static void transcriptsTestInsert(){
        
        FS_Transcript__c transcripts = new FS_Transcript__c();
        transcripts.FS_Status__c = 'Enrolled';
        insert transcripts;
        List<FS_Transcript__c> transcriptsList = [SELECT Id FROM FS_Transcript__c WHERE Id=:transcripts.Id];
        FS_Transcripts FSTranscriptsRoutingRule = new FS_Transcripts(transcriptsList);
        FS_Transcripts.Constructor cons = new FS_Transcripts.Constructor();
        cons.construct(transcriptsList);
        Framework.Dispatcher.dispatchTrigger();
    }
    
}