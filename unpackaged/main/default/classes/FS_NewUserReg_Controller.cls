public without sharing class FS_NewUserReg_Controller {
    public static Set<String> pickListFields;
    public static Set<String> APINames;

    class FS_NewUserReg_ControllerException extends Exception{}

    @AuraEnabled
    public static Map<String, Object> newUserRegLoginSetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newUserRegAttorneySetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('fieldSet', getFieldSets('Contact', 'FS_NewUserReg_Attorney', 'Attorney'));
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
            result.put('CountryAndState', getDependentPicklist('User', 'countrycode', 'statecode'));
            Map<String, List<Map<String, String>>> picklistOptions = new Map<String, List<Map<String, String>>>();
            for (String tempPickList : pickListFields) {
                picklistOptions.put(tempPickList, getPicklistOptions('Contact', tempPickList));
            }

            result.put('picklistOptions', picklistOptions);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newUserRegStudentSetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('fieldSet', getFieldSets('Contact', 'FS_NewUserReg_Student', 'Student'));
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
            result.put('CountryAndState', getDependentPicklist('User', 'countrycode', 'statecode'));
            Map<String, List<Map<String, String>>> picklistOptions = new Map<String, List<Map<String, String>>>();
            for (String tempPickList : pickListFields) {
                picklistOptions.put(tempPickList, getPicklistOptions('Contact', tempPickList));
            }

            result.put('picklistOptions', picklistOptions);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newUserRegSomeoneElseSetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('fieldSet', getFieldSets('Contact', 'FS_NewUserReg_SomeoneElse', 'Someone Else'));
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
            result.put('CountryAndState', getDependentPicklist('User', 'countrycode', 'statecode'));
            Map<String, List<Map<String, String>>> picklistOptions = new Map<String, List<Map<String, String>>>();
            for (String tempPickList : pickListFields) {
                picklistOptions.put(tempPickList, getPicklistOptions('Contact', tempPickList));
            }

            result.put('picklistOptions', picklistOptions);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newUserRegCompanySearchSetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('fieldSet', getFieldSets('Account', 'FS_NewUserReg_Company_Search', 'Company'));
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
            result.put('CountryAndState', getDependentPicklist('User', 'countrycode', 'statecode'));
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newUserRegCompanySetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('fieldSet', getFieldSets('Account', 'FS_NewUserReg_Company_Search', 'Company'));
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
            result.put('CountryAndState', getDependentPicklist('User', 'countrycode', 'statecode'));
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> newUserRegGDPROptInSetup() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('isGuestUser', UserInfo.getUserType() == 'Guest');
            result.put('userId', UserInfo.getUserId());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> searchAccount(List<Map<String, Object>> fieldSet) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            String query = 'SELECT Id, Name, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE ';
            for (Map<String, Object> tempField : fieldSet) {
                if (!String.isEmpty((String) tempField.get('Value'))) {
                    if (((String) tempField.get('Type')) == 'text') {
                        query += ((String) tempField.get('APIName')) + ' LIKE ' + '\'%' + ((String) tempField.get('Value')) + '%\' AND ';
                    } else {
                        query += ((String) tempField.get('APIName')) + ' = ' + '\'' + ((String) tempField.get('Value')) + '\' AND ';
                    }
                }
            }
            query += '(NOT Name LIKE \'%Household\') AND FS_Hide_From_Portal__c = FALSE';
            List<Account> accountSearchResults = Database.query(query);
            result.put('Search Results', accountSearchResults);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> createAccount(Account account, String contactId, String oldAccountId) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Id ownerId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL ORDER BY CreatedDate ASC LIMIT 1][0].Id;
            account.OwnerId = ownerId;

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;

            Database.SaveResult sr = Database.insert(account, dml);

//            insert contactAttorney;

            if(!sr.isSuccess()) {
                throw new FS_NewUserReg_ControllerException('Issue with inserting Account. First Error' + sr.getErrors()[0].message);
            }
//            insert account;
            FS_Affiliation__c affiliation = new FS_Affiliation__c(FS_Child_Contact__c = contactId, FS_Parent_Account__c = account.Id, FS_Primary_Affiliation__c = true);
            //Contact tempContact = new Contact(Id = contactId, AccountId = account.Id);
            //result.put('Success', Database.update(tempContact).isSuccess() && Database.delete(oldAccountId).isSuccess());
            result.put('Success', Database.insert(affiliation).isSuccess());
            result.put('Is GDPR Country', [SELECT Id, FS_GDPR_Country__c FROM Contact WHERE Id = :contactId][0].FS_GDPR_Country__c);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> createContactAttorney(Contact contactAttorney, String taskOwnerId, String password) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Id ownerId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL ORDER BY CreatedDate ASC LIMIT 1][0].Id;
            //	contactAttorney.OwnerId = ownerId;

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;

            Database.SaveResult sr = Database.insert(contactAttorney, dml);            

            // insert contactAttorney;

            if(!sr.isSuccess()) {
                system.debug('TEST:231:sr.getErrors: ' + sr.getErrors());
                throw new FS_NewUserReg_ControllerException('Issue with inserting Contact. First Error: ' + sr.getErrors()[0].message);
            }

            contactAttorney = [SELECT Id, AccountId, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id = :contactAttorney.Id][0];
            Account tempAccount = new Account(Id = contactAttorney.AccountId, OwnerId = ownerId);
            //  If Test is running, create a new Account for the contact
            if (!Test.isRunningTest()) {
				update tempAccount;                
            } else {
                tempAccount = new Account(Name = contactAttorney.LastName + 'test+Account', Id = contactAttorney.AccountId, OwnerId = ownerId);
                insert tempAccount;
            }
            

            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1][0].Id;
            User user = new User(
                    LastName = contactAttorney.LastName,
                    FirstName = contactAttorney.FirstName,
                    Alias = (contactAttorney.FirstName.substring(0, 1) + contactAttorney.LastName).left(8),
                    Email = contactAttorney.OrderApi__Preferred_Email__c,
                    Username = contactAttorney.OrderApi__Preferred_Email__c,
                    ProfileId = profileId,
                    IsActive = true,
                    TimeZoneSidKey = 'America/New_York',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US',
                    ContactId = contactAttorney.Id,
                    CommunityNickname = ((contactAttorney.OrderApi__Preferred_Email__c.substringBefore('@')).left(20) + '.' + String.valueOf(Math.abs(Crypto.getRandomLong()))).left(40)
            );
            insert user;
//            System.setPassword(user.Id, password);
            System.enqueueJob(new FS_OktaServices(contactAttorney.Id, user.Id, contactAttorney.FirstName, contactAttorney.LastName, contactAttorney.OrderApi__Preferred_Email__c, password, 'insert', 1));

            Task newTask = new Task(
                    Subject = 'Verify Contact Data',
                    ActivityDate = null,
                    OwnerId = taskOwnerId,
                    WhoId = contactAttorney.Id,
                    Status = 'Not Started',
                    Priority = 'Normal'
            );
            insert newTask;
            result.put('Contact Id', contactAttorney.Id);
            result.put('Account Id', contactAttorney.AccountId);
//            result.put('Login URL', Site.login(contactAttorney.OrderApi__Preferred_Email__c, password, '/nysbaportal/s/').getUrl());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());

            if (e.getMessage() != null && e.getMessage().contains('INVALID_EMAIL_ADDRESS')){
                result.put('Error', 'Invalid Email');
            } else {
                result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            }

            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> createContactStudent(Contact contactStudent, String taskOwnerId, String password) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Id ownerId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL ORDER BY CreatedDate ASC LIMIT 1][0].Id;
            //	contactStudent.OwnerId = ownerId;
            contactStudent.OrderApi__Preferred_Email_Type__c = 'Personal';
//            insert contactStudent;


            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;

            Database.SaveResult sr = Database.insert(contactStudent, dml);

//            insert contactAttorney;

            if(!sr.isSuccess()) {
                throw new FS_NewUserReg_ControllerException('Issue with inserting Contact. First Error' + sr.getErrors()[0].message);
            }

            contactStudent = [SELECT Id, AccountId, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id = :contactStudent.Id][0];
            Account tempAccount = new Account(Id = contactStudent.AccountId, OwnerId = ownerId);
            //  If Test is running, create a new Account for the contact
            if (!Test.isRunningTest()) {
				update tempAccount;                
            } else {
                tempAccount = new Account(Name = contactStudent.LastName + 'test+Account', Id = contactStudent.AccountId, OwnerId = ownerId);
                insert tempAccount;
            }

            System.debug('contactStudent');
            System.debug(contactStudent);

            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1][0].Id;
            User user = new User(
                    LastName = contactStudent.LastName,
                    FirstName = contactStudent.FirstName,
                    Alias = (contactStudent.FirstName.substring(0, 1) + contactStudent.LastName).left(8),
                    Email = contactStudent.OrderApi__Preferred_Email__c,
                    Username = contactStudent.OrderApi__Preferred_Email__c,
                    ProfileId = profileId,
                    IsActive = true,
                    TimeZoneSidKey = 'America/New_York',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US',
                    ContactId = contactStudent.Id,
                    CommunityNickname = ((contactStudent.OrderApi__Preferred_Email__c.substringBefore('@')).left(20) + '.' + String.valueOf(Math.abs(Crypto.getRandomLong()))).left(40)
            );
            insert user;
//            System.setPassword(user.Id, password);
            System.enqueueJob(new FS_OktaServices(contactStudent.Id, user.Id, contactStudent.FirstName, contactStudent.LastName, contactStudent.OrderApi__Preferred_Email__c, password, 'insert', 1));

            Task newTask = new Task(
                    Subject = 'Verify Contact Data',
                    ActivityDate = null,
                    OwnerId = taskOwnerId,
                    WhoId = contactStudent.Id,
                    Status = 'Not Started',
                    Priority = 'Normal'
            );
            insert newTask;
            result.put('Contact Id', contactStudent.Id);
            result.put('Account Id', contactStudent.AccountId);
            result.put('Is GDPR Country', [SELECT Id, FS_GDPR_Country__c FROM Contact WHERE Id = :contactStudent.Id][0].FS_GDPR_Country__c);
//            result.put('Login URL', Site.login(contactStudent.OrderApi__Preferred_Email__c, password, '/nysbaportal/s/').getUrl());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());

            if (e.getMessage() != null && e.getMessage().contains('INVALID_EMAIL_ADDRESS')){
                result.put('Error', 'Invalid Email');
            } else {
                result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            }

            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> createContactSomeoneElse(Contact contactSomeoneElse, String taskOwnerId, String password) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Id ownerId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE AND UserRoleId != NULL ORDER BY CreatedDate ASC LIMIT 1][0].Id;
            //	contactSomeoneElse.OwnerId = ownerId;
//            insert contactSomeoneElse;

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;

            Database.SaveResult sr = Database.insert(contactSomeoneElse, dml);

//            insert contactAttorney;

            if(!sr.isSuccess()) {
                throw new FS_NewUserReg_ControllerException('Issue with inserting Contact. First Error' + sr.getErrors()[0].message);
            }

            contactSomeoneElse = [SELECT Id, AccountId, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id = :contactSomeoneElse.Id][0];
            Account tempAccount = new Account(Id = contactSomeoneElse.AccountId, OwnerId = ownerId);
            //  If Test is running, create a new Account for the contact
            if (!Test.isRunningTest()) {
				update tempAccount;                
            } else {
                tempAccount = new Account(Name = contactSomeoneElse.LastName + 'test+Account', Id = contactSomeoneElse.AccountId, OwnerId = ownerId);
                insert tempAccount;
            }

            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User' LIMIT 1][0].Id;
            User user = new User(
                    LastName = contactSomeoneElse.LastName,
                    FirstName = contactSomeoneElse.FirstName,
                    Alias = (contactSomeoneElse.FirstName.substring(0, 1) + contactSomeoneElse.LastName).left(8),
                    Email = contactSomeoneElse.OrderApi__Preferred_Email__c,
                    Username = contactSomeoneElse.OrderApi__Preferred_Email__c,
                    ProfileId = profileId,
                    IsActive = true,
                    TimeZoneSidKey = 'America/New_York',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US',
                    ContactId = contactSomeoneElse.Id,
                    CommunityNickname = ((contactSomeoneElse.OrderApi__Preferred_Email__c.substringBefore('@')).left(20) + '.' + String.valueOf(Math.abs(Crypto.getRandomLong()))).left(40)
            );
            insert user;
//            System.setPassword(user.Id, password);
            System.enqueueJob(new FS_OktaServices(contactSomeoneElse.Id, user.Id, contactSomeoneElse.FirstName, contactSomeoneElse.LastName, contactSomeoneElse.OrderApi__Preferred_Email__c, password, 'insert', 1));

            Task newTask = new Task(
                    Subject = 'Verify Contact Data',
                    ActivityDate = null,
                    OwnerId = taskOwnerId,
                    WhoId = contactSomeoneElse.Id,
                    Status = 'Not Started',
                    Priority = 'Normal'
            );
            insert newTask;
            result.put('Contact Id', contactSomeoneElse.Id);
            result.put('Account Id', contactSomeoneElse.AccountId);
//            result.put('Login URL', Site.login(contactSomeoneElse.OrderApi__Preferred_Email__c, password, '/nysbaportal/s/').getUrl());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());

            if (e.getMessage() != null && e.getMessage().contains('INVALID_EMAIL_ADDRESS')){
                result.put('Error', 'Invalid Email');
            } else {
                result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            }

            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> userLogin(String username, String password) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('Redirect URL', Site.login(username, password, null).getUrl());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            if (e.getMessage().contains('Your login attempt has failed. Make sure the username and password are correct.')) {
                result.put('Login Failed', e.getMessage());
            } else {
                result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            }
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> checkEmail(String emailAddress) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<Contact> tempContacts = [SELECT Id FROM Contact WHERE OrderApi__Preferred_Email__c = :emailAddress OR OrderApi__Personal_Email__c = :emailAddress OR OrderApi__Work_Email__c = :emailAddress OR OrderApi__Other_Email__c = :emailAddress OR OrderApi__Assistant_Email__c = :emailAddress];
            Boolean emailExists = !tempContacts.isEmpty();

            if(!emailExists) {
                // check if a user already has this email. Irrespective of whether they are active or not
                List<User> usersWithEmail = [SELECT Id FROM User WHERE Username = :emailAddress];
                emailExists = !usersWithEmail.isEmpty();
            }


            result.put('Email Exists', emailExists);
            if (emailExists) {
                Boolean preferredEmailExists = [SELECT Id FROM Contact WHERE OrderApi__Preferred_Email__c = :emailAddress].size() > 0;
                result.put('Preferred Email Exists', preferredEmailExists);
                if (!preferredEmailExists) {
                    Boolean otherEmailExists = [SELECT Id FROM Contact WHERE OrderApi__Preferred_Email__c != :emailAddress AND (OrderApi__Personal_Email__c = :emailAddress OR OrderApi__Work_Email__c = :emailAddress OR OrderApi__Other_Email__c = :emailAddress OR OrderApi__Assistant_Email__c = :emailAddress)].size() > 0;
                    result.put('Other Email Exists', otherEmailExists);
                }
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> resetPasswordMethod(String emailAddress) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            List<User> users = [SELECT Id FROM User WHERE Username = :emailAddress];
            if (!users.isEmpty()) {
                System.resetPassword(users[0].Id, true);
                result.put('Password Reset', true);
            } else {
                result.put('Password Reset', false);
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> checkUsernameAndLawSchool(String username, Boolean needToCheckLawSchool, String lawSchoolSelectedId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result = checkEmail(username);

            if (needToCheckLawSchool) {
                if (lawSchoolSelectedId != null && lawSchoolSelectedId != '') {
                    result.put('Law School Error', [SELECT Id FROM Account WHERE Id = :lawSchoolSelectedId].size() == 0);
                } else {
                    result.put('Law School Error', true);
                }
            } else {
                result.put('Law School Error', false);
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> updateCompany(String contactId, String accountId, String newAccountId) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            FS_Affiliation__c affiliation = new FS_Affiliation__c(FS_Child_Contact__c = contactId, FS_Parent_Account__c = newAccountId, FS_Primary_Affiliation__c = true);
            //Contact tempContact = new Contact(Id = contactId, AccountId = newAccountId);
            //result.put('Success', Database.update(tempContact).isSuccess() && Database.delete(accountId).isSuccess());
            result.put('Success', Database.insert(affiliation).isSuccess());
            result.put('Is GDPR Country', [SELECT Id, FS_GDPR_Country__c FROM Contact WHERE Id = :contactId][0].FS_GDPR_Country__c);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> updateGDPROptIn(String contactId, Boolean GDPROptIn) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        try {
            Contact tempContact = new Contact(Id = contactId, FS_GDPR_OptIn__c = GDPROptIn);
            result.put('Success', Database.update(tempContact).isSuccess());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
            Database.rollback(sp);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> searchLawSchool(String searchString) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            searchString = '%' + searchString + '%';
            result.put('Result', [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Educational Institution' AND FS_School_Type__c = 'Law School' AND FS_Accredited__c = TRUE AND FS_Hide_From_Portal__c = FALSE AND (Name LIKE :searchString OR FS_Law_School_Alias__c LIKE :searchString)]);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> checkGDPR(String contactId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('Is GDPR Country', [SELECT Id, FS_GDPR_Country__c FROM Contact WHERE Id = :contactId][0].FS_GDPR_Country__c);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            result.put('Error', e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber() + '; ' + e.getCause());
        }
        return result;
    }

    private static List<Map<String, Object>> getFieldSets(String objectName, String fieldSetAPI, String contactType) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetAPI);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        pickListFields = new Set<String>();
        APINames = new Set<String>();

        List<Map<String, Object>> fieldSetsList = new List<Map<String, Object>>();
        for (Schema.FieldSetMember tempFieldSetMember : fieldSetMembers) {
            String type = String.valueOf(tempFieldSetMember.getType()).toLowerCase();
            if (type == 'string') {
                type = 'text';
            }
            if (type == 'phone') {
                type = 'tel';
            }
            if (type == 'double') {
                type = 'number';
            }
            if (type == 'picklist') {
                pickListFields.add(tempFieldSetMember.fieldPath);
            }
            if (type == 'reference') {
                type = 'lookup';
            }
            APINames.add(tempFieldSetMember.fieldPath);
            Map<String, Object> tempMap;

            String tempLabel;
            switch on tempFieldSetMember.fieldPath {
                when 'Salutation' {
                    tempLabel = 'Prefix';
                }
                when 'FirstName' {
                    tempLabel = 'First Name (Given)';
                }
                when 'LastName' {
                    tempLabel = 'Last Name (Surname)';
                }
                when 'OrderApi__Personal_Email__c' {
                    tempLabel = 'Personal Email Address';
                }
                when 'OrderApi__Work_Email__c' {
                    tempLabel = (contactType == 'Attorney' || contactType == 'Someone Else') ? 'Work Email Address' : 'School (.edu) Email Address';
                }
                when 'OrderApi__Preferred_Email_Type__c' {
                    tempLabel = 'Preferred Email';
                }
                when 'FS_NYS_Admission_Date__c' {
                    tempLabel = 'First Admission Date in Any Jurisdiction';
                }
                when 'FS_Out_of_State_First_Admit_Date__c' {
                    tempLabel = 'First Admission Date in Any Jurisdiction';
                }
                when 'FS_Graduation_Date__c' {
                    tempLabel = 'Expected Graduation Date';
                }
                when 'Name' {
                    tempLabel = 'Company Name';
                }
                when 'BillingCountryCode' {
                    tempLabel = 'Country';
                }
                when 'BillingStateCode' {
                    tempLabel = 'State/Province';
                }
                when 'BillingCity' {
                    tempLabel = 'City';
                }
                when 'BillingPostalCode' {
                    tempLabel = 'Postal Code';
                }
                when 'OrderApi__Preferred_Phone_Type__c' {
                    tempLabel = 'Preferred Phone Type';
                }
                when 'OrderApi__Work_Phone__c' {
                    tempLabel = 'Preferred Phone';
                }
                when 'HomePhone' {
                    tempLabel = 'Preferred Phone';
                }
                when 'MobilePhone' {
                    tempLabel = 'Preferred Phone';
                }
                when 'Birthdate' {
                    tempLabel = 'Date of Birth';
                }
                when 'MailingPostalCode' {
                    tempLabel = 'Preferred Zip Code';
                }
                when 'MailingCountryCode' {
                    tempLabel = 'Preferred Country';
                }
                when 'MailingStreet' {
                    tempLabel = 'Preferred Street';
                }
                when 'MailingCity' {
                    tempLabel = 'Preferred City';
                }
                when 'MailingStateCode' {
                    tempLabel = 'Preferred State';
                }
                when else {
                    tempLabel = tempFieldSetMember.label;
                }
            }

            if (type == 'checkbox') {
                tempMap = new Map<String, Object>{
                        'APIName' => tempFieldSetMember.fieldPath,
                        'Label' => tempLabel,
                        'Required' => tempFieldSetMember.required,
                        'DBRequired' => tempFieldSetMember.DBRequired,
                        'Type' => type,
                        'Value' => false
                };
            } else {
                tempMap = new Map<String, Object>{
                        'APIName' => tempFieldSetMember.fieldPath,
                        'Label' => tempLabel,
                        'Required' => tempFieldSetMember.required,
                        'DBRequired' => tempFieldSetMember.DBRequired,
                        'Type' => type,
                        'Value' => ''
                };
            }
            fieldSetsList.add(tempMap);
        }
        return fieldSetsList;
    }

    private static List<Map<String, String>> getPicklistOptions(String objectName, String fieldAPI) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Schema.describeSObjects(new List<String>{objectName})[0].fields.getMap().get(fieldAPI).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(new Map<String, String>{
                    'label' => f.getLabel(), 'value' => f.getValue()
            });
        }

        return options;
    }

    public class MyPickListInfo {
        public String validFor;
    }

    public static Map<String, Object> getDependentPicklist(String objectName, String controllingField, String dependentField) {
        Map<String, List<Map<String, String>>> dependentMap = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> controllingList = new List<Map<String, String>>();

        if (objectName.equals('User') && controllingField.equals('countrycode') && dependentField.equals('statecode')) {
            controllingList.add(new Map<String, String>{'value' => 'US', 'label' => 'United States'});
            controllingList.add(new Map<String, String>{'value' => 'CA', 'label' => 'Canada'});
        }

        Map<String, SObjectField> tempDescribeSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        Schema.DescribeFieldResult controllingFieldInfo = tempDescribeSObjectResult.get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = tempDescribeSObjectResult.get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            dependentMap.put(currControllingValue.getValue(), new List<Map<String, String>>());
            if (objectName.equals('User') && controllingField.equals('countrycode') && dependentField.equals('statecode')) {
                if (!currControllingValue.getValue().equals('US') && !currControllingValue.getValue().equals('CA')) {
                    controllingList.add(new Map<String, String>{
                            'value' => currControllingValue.getValue(), 'label' => currControllingValue.getLabel()
                    });
                }
            } else {
                controllingList.add(new Map<String, String>{
                        'value' => currControllingValue.getValue(), 'label' => currControllingValue.getLabel()
                });
            }
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;

            Map<String, String> temp = new Map<String, String>();
            temp.put('label', currDependentValue.getLabel());
            temp.put('value', currDependentValue.getValue());

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    dependentMap.get(controllingValues[baseCount + 0].getValue()).add(temp);
                }
                if ((val & 4) == 4) {
                    dependentMap.get(controllingValues[baseCount + 1].getValue()).add(temp);
                }
                if ((val & 2) == 2) {
                    dependentMap.get(controllingValues[baseCount + 2].getValue()).add(temp);
                }
                if ((val & 1) == 1) {
                    dependentMap.get(controllingValues[baseCount + 3].getValue()).add(temp);
                }

                baseCount += 4;
            }
        }
        Map<String, Object> result = new Map<String, Object>();
        result.put('controllingList', controllingList);
        result.put('dependentMap', dependentMap);
        return result;
    }
}