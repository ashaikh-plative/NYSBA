global without sharing class FS_PrimaryAffiliationUpdateRule extends Framework.Domain{
    public FS_PrimaryAffiliationUpdateRule(List<FS_Affiliation__c> sObjectList) {
        super(sObjectList);
    }
    
  global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_PrimaryAffiliationUpdateRule(sObjectList);
        }
    }
    
    public override void beforeInsert() {
        Framework.Log.push(FS_PrimaryAffiliationUpdateRule.class.getName(), 'beforeInsert');
        FS_PrimaryAffiliationUpdateOnContact.beforeInsert((List<FS_Affiliation__c>) records);
        FS_PrimaryAffiliationUpdateOnContact.primaryAffiliationOnBeforeInsert((List<FS_Affiliation__c>) records);
        Framework.Log.pop();
    }
    
    public override void afterInsert() {
        Framework.Log.push(FS_PrimaryAffiliationUpdateRule.class.getName(), 'afterInsert');
        FS_PrimaryAffiliationUpdateOnContact.afterInsert((List<FS_Affiliation__c>) records);
        Framework.Log.pop();
    }
    
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_PrimaryAffiliationUpdateRule.class.getName(), 'beforeUpdate');
        FS_PrimaryAffiliationUpdateOnContact.beforeUpdatePrimary((List<FS_Affiliation__c>) records, (Map<Id, FS_Affiliation__c>) oldMap);
        FS_PrimaryAffiliationUpdateOnContact.beforeUpdate((List<FS_Affiliation__c>) records, (Map<Id, FS_Affiliation__c>) oldMap);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_PrimaryAffiliationUpdateRule.class.getName(), 'afterUpdate');
        FS_PrimaryAffiliationUpdateOnContact.afterUpdate((List<FS_Affiliation__c>) records, oldMap);
        Framework.Log.pop();
    }
    
    
}