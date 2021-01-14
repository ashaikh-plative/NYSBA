public without sharing class FS_ContactRuleServiceHelper {

    //removing onBeforeInsert per Jason - function needs reworking
    /*
    public static void onBeforeInsert(List<Contact> conList){
        system.debug('inside test');
        for(Contact oContact: conList){
            if(String.isBlank(oContact.OrderApi__Personal_Email__c) && !String.isBlank(oContact.Email)){
                oContact.OrderApi__Preferred_Email_Type__c= 'Personal';
                oContact.OrderApi__Personal_Email__c = oContact.Email;
            }
        }
    }
    */

//    class FS_ContactRuleServiceException extends Exception{}


    public static void isDuplicateEmailOnUser(List<Contact> conList, Map<Id, SObject> oldMap) { // email: *abc@mail.com
        Set<Id> contactIds = new Set<Id>();
        Set<String> emailIds = new Set<String>();

        //Map<Id, Contact> contact2ProcessforDuplicates = new Map<Id, Contact>();
        Map<Id, Contact> oldcMap = new Map<Id, Contact>();
        for (SObject sObj : oldMap.values()) {
            Contact con = (Contact) sObj;
            oldcMap.put(con.Id, con);
        }


        for (Contact con : conList) {
            if (oldcMap.containsKey(con.Id)) {
                if (con.Email != oldcMap.get(con.Id).Email) { //if email changed
                    if ((!String.isBlank(con.Email) || !String.isBlank(con.FS_Preferred_Email__c))) {
                        //eliminate all contacts having null emails
                        contactIds.add(con.Id);
                        emailIds.add(con.Email);
                    }
                }
            }
        }

        Set<Id> contactIdsToUpdate = new Set<Id>();
        Map<String, User> usernameMap = new Map<String, User>();

        if (!emailIds.isEmpty()) {
            //get such user which has same username email as we are trying to update from contact
            for (User u : [SELECT Id, Email, Username, ContactId FROM User WHERE Username IN :emailIds]) {
                usernameMap.put(u.Username, u);
            }//email: *abc@mail.com [1]
            for (Contact oContact : conList) {
                if (usernameMap.size() > 0) {
                    if (usernameMap.containsKey(oContact.Email)) {
                        if (usernameMap.get(oContact.Email) != null && usernameMap.get(oContact.Email) != null
                                && usernameMap.get(oContact.Email).ContactId != oContact.Id) {
                            oContact.addError('Duplicate email for this Contact. Duplicate Email is On: ' + usernameMap.get(oContact.Email).ContactId);
//                            throw new FS_ContactRuleServiceException('Duplicate email for Contact Id: ' + oContact.Id);
                        }
                    }
                }
            }
        }
    }


//    @Future
//    public static void updateUser(Set<Id> contactIds) {
//
//        String contactQuerySet


    /*try {
        List<User> userList = new List<User>();
        Map<String, Contact> contactMap = new Map<String, Contact>();
        for (Contact con :[SELECT Id, Email, FirstName, LastName FROM Contact
                           WHERE Id IN :contactIds AND (Email != NULL OR OrderApi__Personal_Email__c != NULL)]) {
            contactMap.put(con.Id, con);
        }
        for (User u: [SELECT Id, Email, FirstName, LastName, ContactId, ProfileId FROM User
                      WHERE ContactId IN :contactIds AND ContactId != NULL]) {
            if (contactMap.containsKey(u.ContactId)) {
                if (contactMap.get(u.ContactId).Email != null) {
                    u.Email = contactMap.get(u.ContactId).Email;
                    u.Username = contactMap.get(u.ContactId).Email;
                }
                u.FirstName = contactMap.get(u.ContactId).FirstName;
                u.LastName = contactMap.get(u.ContactId).LastName;
                userList.add(u);
            }
        }
        if (userList.size() > 0){
            Database.update(userList,false);
        }
    } catch (DmlException e){
        //send send email
        String errorMsg = e.getMessage();
        System.debug(errorMsg);
    }*/
//    }


    /*update contact info to user*/

    public static void updateRelatedUserInfo(List<Contact> records, Map<Id, Contact> oldMap) {
        List<ContactToUserFieldMapping__c> fieldsMappedToUser = ContactToUserFieldMapping__c.getAll().values();
        List<User> usersRelatedToContacts = [SELECT Id, ContactId FROM User WHERE ContactId IN :records];
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(records);
        Set<Id> usersIdsWithUpdatedContacts = new Set<Id>();

        for (User user : usersRelatedToContacts) {
            Contact contact = contactsMap.get(user.ContactId);
            for (ContactToUserFieldMapping__c fieldMapping : fieldsMappedToUser) {
                if (fieldMapping.IsActive__c && !fieldMapping.Is_Formula_Field__c &&
                        contact.get(fieldMapping.ContactField__c) != oldMap.get(contact.Id).get(fieldMapping.ContactField__c)) {
                    usersIdsWithUpdatedContacts.add(user.Id);
                    break;
                }
            }
        }
        //UpdateUserInformationFuture(usersIdsWithUpdatedContacts);
        if (Test.isRunningTest() || (usersIdsWithUpdatedContacts.size() > 0 && !System.isQueueable())) {
            Id jobID = System.enqueueJob(new UpdateUserInformation(usersIdsWithUpdatedContacts));
        }
    }

    public without sharing class UpdateUserInformation implements Queueable {
        private Set<Id> userIds;

        public UpdateUserInformation(Set<Id> userIds) {
            this.userIds = userIds;
        }

        public void execute(QueueableContext context) {
            List<ContactToUserFieldMapping__c> fieldsMappedToUser = ContactToUserFieldMapping__c.getAll().values();
            Set<String> userFieldsNames = new Set<String>();
            Set<String> contactFieldsNames = new Set<String>();
            Boolean activeMappingAvailable = false;
            for (ContactToUserFieldMapping__c fieldMapping : fieldsMappedToUser) {
                if (fieldMapping.IsActive__c && String.isNotBlank(fieldMapping.UserField__c)) {
                    userFieldsNames.add(fieldMapping.UserField__c);
                    contactFieldsNames.add('Contact.' + fieldMapping.ContactField__c);
                    activeMappingAvailable = true;
                }
            }
            contactFieldsNames.add('Contact.Email');


            if (!activeMappingAvailable) {
                //return;
            }
            String query = 'SELECT Id,' + String.join(new List<String>(userFieldsNames), ',') + ',' + String.join(new List<String>(contactFieldsNames), ',')
                    + ' FROM User WHERE Id IN :userIds';
            List<User> usersToUpdate = Database.query(query);

            for (User user : usersToUpdate) {
                //user.put('Email', user.getSObject('Contact').get('Email'));
                if (!String.isBlank((String) user.getSObject('Contact').get('Email'))) {
                    user.put('Username', user.getSObject('Contact').get('Email'));
                }
                for (ContactToUserFieldMapping__c fieldMapping : fieldsMappedToUser) {
                    if (fieldMapping.IsActive__c) {
                        user.put(fieldMapping.UserField__c, user.getSObject('Contact').get(fieldMapping.ContactField__c));
                    }
                }
            }
            if (Test.isRunningTest()) {
                Profile testProfile = [
                        SELECT Id
                        FROM Profile
                        WHERE Name = 'System Administrator'
                        LIMIT 1
                ];
                String orgId = UserInfo.getOrganizationId();
                String dateString =
                        String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
                Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));
                String uniqueName = orgId + dateString + randomInt;
                User testUser2 = new User(LastName = 'test user 2',
                        Username = uniqueName + '@test' + orgId + '.org',
                        Email = uniqueName + '@test' + orgId + '.org',
                        Alias = 'te2322',
                        TimeZoneSidKey = 'GMT',
                        LocaleSidKey = 'en_GB',
                        EmailEncodingKey = 'ISO-8859-1',
                        ProfileId = testProfile.Id,
                        LanguageLocaleKey = 'en_US');
                List<User> allUsers = [SELECT Id FROM User WHERE Username = :testUser2.Username];
                if (allUsers.size() > 0) {
                    testUser2.Username += '.tfs';
                }
                System.runAs(testUser2) {
                    update usersToUpdate;
                }
            } else {
                update usersToUpdate;
            }

        }
    }

}