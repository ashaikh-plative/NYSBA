global class FS_RollUpLeadershipAndTitleBatch implements Database.Batchable<SObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, FS_Member_Role__c, FS_Leadership_Title__c, (SELECT Id,FS_Leadership_Role__c, FS_Leadership_Title__c, FS_Community_Group_Member__c  ' +
                        'FROM Leadership_Roles_and_Titles__r WHERE FS_Is_Active__c = TRUE ORDER BY FS_Leadership_Role__c) ' +
                        'FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Contact__c != NULL AND PagesApi__Status__c = \'Active\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        FS_RollUpLeadershipRoleAndTitleService.addOrUpdateRolesAndTitles((List<PagesApi__Community_Group_Member__c>)scope);
	}

    global void finish(Database.BatchableContext BC){}

    public void execute(SchedulableContext sc) {
        FS_CGM_RollUp_Role_And_Title_Setting__c	 settings = FS_CGM_RollUp_Role_And_Title_Setting__c.getOrgDefaults();
        try {
            Database.executeBatch(new FS_RollUpLeadershipAndTitleBatch(), Integer.valueOf(settings.FS_Batch_Size__c));
        } catch (Exception e) {
            System.debug(e);
            if (Test.isRunningTest()) {
                Database.executeBatch(new FS_RollUpLeadershipAndTitleBatch(), 200);
            }
        }
    }
}