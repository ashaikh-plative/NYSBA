/**
 * Created by dfitzgerald on 1/22/20.
 */

global without sharing class FS_ContactVerifyStatusRoutingRule extends Framework.Domain {

//    public static Boolean mailingGettingVerified = false;
//    public static Boolean otherGettingVerified = false;


    public static Boolean contactAddressChanged = false;

    public FS_ContactVerifyStatusRoutingRule(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ContactVerifyStatusRoutingRule(sObjectList);
        }
    }

    public override void beforeInsert() {
        Framework.Log.push(FS_ContactAddressRoutingRule.class.getName(), 'beforeInsert');
        setVerificationFlags((List<Contact>) records);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> existingRecordsMap) {
        Framework.Log.push(FS_ContactAddressRoutingRule.class.getName(), 'beforeUpdate');
        setVerificationFlags((List<Contact>) records);
        Framework.Log.pop();
    }

    private void setVerificationFlags(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (!String.isBlank(contact.MailingStreet) &&
                    (String.isBlank(contact.smartystreets__Mailing_Return_Code__c) ||
                            contact.smartystreets__Mailing_Return_Code__c == 'Changed')) {
                contactAddressChanged = true;
                break;
            }

            if (!String.isBlank(contact.OtherStreet) &&
                    (String.isBlank(contact.smartystreets__Other_Return_Code__c) ||
                            contact.smartystreets__Other_Return_Code__c == 'Changed')) {
                contactAddressChanged = true;
                break;
            }
        }

        for (Contact contact : contacts) {
            if (!String.isBlank(contact.MailingStreet) &&
                    (String.isBlank(contact.smartystreets__Mailing_Return_Code__c) ||
                            contact.smartystreets__Mailing_Return_Code__c != 'Changed')) {
                contactAddressChanged = false;
                break;
            }

            if (!String.isBlank(contact.OtherStreet) &&
                    (String.isBlank(contact.smartystreets__Other_Return_Code__c) ||
                            contact.smartystreets__Other_Return_Code__c != 'Changed')) {
                contactAddressChanged = false;
                break;
            }
        }
    }
}