/**
 * Created by Seshu on 24-03-2020.
 */


global without sharing class FS_PortalUserAccountRule extends Framework.Domain {

    private static final Id SYSTME_ADMIN_ID = [SELECT Id FROM User WHERE Profile.Name = 'System administrator' AND IsActive=TRUE LIMIT 1].Id;

    public FS_PortalUserAccountRule(List<Account> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_PortalUserAccountRule(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_PortalUserAccountRule.class.getName(),'Before Insert');
        updateAccountOwnerId((Account[]) records);
        Framework.Log.pop();
    }

    private static void updateAccountOwnerId(List<Account> accounts){

        Map<Id,Profile> profilesByIds = new Map<Id,Profile>([SELECT Id FROM Profile WHERE UserLicense.Name LIKE '%Customer Community Login%']);
        for(Account account: accounts){
            if(profilesByIds.containsKey(UserInfo.getProfileId())){
                if(SYSTME_ADMIN_ID != NULL){
                    account.ownerId = SYSTME_ADMIN_ID;
                }
            }
        }
    }
}