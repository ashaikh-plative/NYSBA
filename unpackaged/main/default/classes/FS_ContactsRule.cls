/**
* Routing rule for below purpose: 
* 1. sync email on user whenever there is change in email on contact and validate if email being not used by any other user 
* 2. copy contact field values to user fields - as mapped on the custom setting 'Contact To User SAML Field Mapping' | API Name	'ContactToUserFieldMapping__c'
* @author fusionSpan
**/
global without sharing class FS_ContactsRule extends Framework.Domain {
    public static Boolean skipRoutingRule = false;

    public FS_ContactsRule(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ContactsRule(sObjectList);
        }
    }

//    public override void beforeInsert() {
//        Framework.Log.push(FS_ContactsRule.class.getName(),'beforeInsert');
//        FS_ContactRuleService.beforeInsert((Contact[]) records);
//        Framework.Log.pop();
//    }


    public override void beforeUpdate(Map<Id,SObject> oldMap) {
        if(!skipRoutingRule) {
            Framework.Log.push(FS_ContactsRule.class.getName(), 'beforeUpdate');
            FS_ContactRuleService.beforeUpdate((Contact[]) records, oldMap);
            Framework.Log.pop();
        }
    }

    public override void afterUpdate(Map<Id,SObject> oldMap){
        if(!skipRoutingRule) {
            Framework.Log.push(FS_ContactsRule.class.getName(), 'afterUpdate');
            FS_ContactRuleService.afterUpdate((Contact[]) records, oldMap);
            Framework.Log.pop();
        }
    }
}