/**
 * Created by Seshu on 11-03-2020.
 */

global without sharing class FS_HandlePreferredEmailChangeRule extends Framework.Domain {

    @TestVisible private static final String WORK_TYPE = 'Work';
    @TestVisible private static final String PERSONAL_TYPE = 'Personal';
    @TestVisible private static final String OTHER_TYPE = 'Other';
    @TestVisible private static final String ASSISTANT_TYPE = 'Assistant';

    public FS_HandlePreferredEmailChangeRule(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_HandlePreferredEmailChangeRule(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_HandlePreferredEmailChangeRule.class.getName(),'before Insert');
        updateEmailWhenContactInsert((Contact[]) records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_HandlePreferredEmailChangeRule.class.getName(),'Before update');
        updateEmailWhenContactInsert((Contact[]) records);
        Framework.Log.pop();
    }


    private static void updateEmailWhenContactInsert(List<Contact> contacts){
        for(Contact relatedContact: contacts){
            if(containsRelavantOptoutField(relatedContact) == true){
                if(getEmailBasedOnPreferredType(relatedContact) != NULL){
                    relatedContact.Email = getEmailBasedOnPreferredType(relatedContact);
                }
            }
        }
    }

    private static Boolean containsRelavantOptoutField(Contact relatedContact){

        return relatedContact.OrderApi__Personal_Email_Opt_Out__c || relatedContact.OrderApi__Work_Email_Opt_Out__c ||
                relatedContact.OrderApi__Assistant_Email_Opt_Out__c || relatedContact.OrderApi__Other_Email_Opt_Out__c ||
                relatedContact.HasOptedOutOfEmail;

    }

    private static String getEmailBasedOnPreferredType(Contact relatedContact){

        if(relatedContact.OrderApi__Preferred_Email_Type__c == WORK_TYPE && String.isNotBlank(relatedContact.OrderApi__Work_Email__c)){
            return relatedContact.OrderApi__Work_Email__c;
        }

        if(relatedContact.OrderApi__Preferred_Email_Type__c == PERSONAL_TYPE && String.isNotBlank(relatedContact.OrderApi__Personal_Email__c)){
            return relatedContact.OrderApi__Personal_Email__c;
        }

        if(relatedContact.OrderApi__Preferred_Email_Type__c == OTHER_TYPE && String.isNotBlank(relatedContact.OrderApi__Other_Email__c)){
            return relatedContact.OrderApi__Other_Email__c;
        }

        if(relatedContact.OrderApi__Preferred_Email_Type__c == ASSISTANT_TYPE && String.isNotBlank(relatedContact.OrderApi__Assistant_Email__c)){
            return relatedContact.OrderApi__Assistant_Email__c;
        }
        return null;
    }
}