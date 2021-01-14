global without sharing class FS_RollUpLeadershipAndTitleRoutingRule extends Framework.Domain {
    public FS_RollUpLeadershipAndTitleRoutingRule(List<FS_Leadership_Role_and_Title__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_RollUpLeadershipAndTitleRoutingRule(sObjectList);
        }
    }

    public override void afterUpdate(Map<Id, SObject> oldMap){
        Framework.Log.push(FS_RollUpLeadershipAndTitleRoutingRule.class.getName(), 'afterUpdate');
        Set<Id> cgmIds=new Set<Id>();
        for(FS_Leadership_Role_and_Title__c roleAndTitle : (List<FS_Leadership_Role_and_Title__c>)records){
            FS_Leadership_Role_and_Title__c oldRoleAndTitle = (FS_Leadership_Role_and_Title__c)oldMap.get(roleAndTitle.Id);
            if((roleAndTitle.FS_Is_Active__c && (roleAndTitle.FS_Leadership_Role__c != oldRoleAndTitle.FS_Leadership_Role__c)
                || (roleAndTitle.FS_Leadership_Title__c != oldRoleAndTitle.FS_Leadership_Title__c)) ||
                	roleAndTitle.FS_Is_Active__c != oldRoleAndTitle.FS_Is_Active__c) {
                cgmIds.add(roleAndTitle.FS_Community_Group_Member__c);
            }
        }
        if(!cgmIds.isEmpty()){
            processRecords(cgmIds);
        }
        Framework.Log.pop();
    }

    public override void afterInsert(){
        Framework.Log.push(FS_RollUpLeadershipAndTitleRoutingRule.class.getName(), 'afterInsert');
        addOrUpdateRolesAndTitles((List<FS_Leadership_Role_and_Title__c>)records);
        Framework.Log.pop();
    }

    public override void afterDelete(){
        Framework.Log.push(FS_RollUpLeadershipAndTitleRoutingRule.class.getName(), 'afterDelete');
        addOrUpdateRolesAndTitles((List<FS_Leadership_Role_and_Title__c>)records);
        Framework.Log.pop();
    }

    private static void addOrUpdateRolesAndTitles(List<FS_Leadership_Role_and_Title__c> records){
        Set<Id> cgmIds=new Set<Id>();
        for(FS_Leadership_Role_and_Title__c roleAndTitle : records){
            if(roleAndTitle.FS_Is_Active__c) {
                cgmIds.add(roleAndTitle.FS_Community_Group_Member__c);
            }
        }
        if(!cgmIds.isEmpty()){
            processRecords(cgmIds);
        }
    }

    private static void processRecords(Set<Id> cgmIds){
        FS_RollUpLeadershipRoleAndTitleService.addOrUpdateRolesAndTitles([SELECT Id, (SELECT Id,FS_Leadership_Role__c, FS_Leadership_Title__c,
                                                                            FS_Community_Group_Member__c FROM Leadership_Roles_and_Titles__r
                                                                            WHERE FS_Is_Active__c = TRUE ORDER BY FS_Leadership_Role__c)
                                                                          FROM PagesApi__Community_Group_Member__c WHERE Id IN : cgmIds
                                                                          AND PagesApi__Status__c = 'Active' AND PagesApi__Contact__c != NULL ]);
    }
}