/**
 * Created by daweima on 3/31/20.
 */


public with sharing class FS_FileUploadController {

    @AuraEnabled
    public static Contact getContact() {
        User loggedInUser = [SELECT Id, Username, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        try {
            Contact loggedContact = [
                    SELECT Id, Name, FS_Profile_Picture_URL__c,(SELECT Id, Title, ContentDocumentId FROM AttachedContentDocuments)
                    FROM Contact
                    WHERE Id = :loggedInUser.ContactId
            ][0];

            System.debug('logged contact: ' + loggedContact.Name);
            return loggedContact;
        } catch (Exception e ) {
            System.debug(LoggingLevel.ERROR, 'Issue query contact associated with user: ' + UserInfo.getUserId());
        }

        return null;
    }

    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, String contactName) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType, contactName, parentId);
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }
    @AuraEnabled
    public static Boolean setPublicLink(Id cdId, Id conId) {
        ContentDistribution publicLink = [SELECT Id,DistributionPublicUrl,ContentDownloadUrl,ContentVersionId
        FROM ContentDistribution
        WHERE Id = :cdId][0];

        Contact c = [SELECT Id, Name FROM Contact WHERE Id = :conId][0];
        if (String.isNotBlank(publicLink.DistributionPublicUrl)) {
            c.FS_Profile_Picture_URL__c = publicLink.ContentDownloadUrl;
            update c;
            return true;
        } else {
            return false;
        }
    }

    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String contactName, Id conId) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        String yourFilesContent = 'TheBlogReaders.com File upload content';

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion

        Contact c = [SELECT Id, Name FROM Contact WHERE Id = :conId][0];
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.ShareType = 'V';
        insert conDocLink;


        //create public link
        ContentDistribution cd = new ContentDistribution(
                ContentVersionId = conVer.Id,
                RelatedRecordId = parentId,
                Name = c.Name + ' Public Directory Photo',
                PreferencesAllowViewInBrowser = true,
                PreferencesLinkLatestVersion = true,
                PreferencesNotifyOnVisit = false,
                PreferencesPasswordRequired = false,
                PreferencesAllowOriginalDownload = true
        );
        insert cd;
        return cd.Id;
    }

    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = [
                SELECT Id, Body
                FROM Attachment
                WHERE Id =: fileId
        ];

        String existingBody = EncodingUtil.base64Encode(a.Body);

        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);

        update a;
    }
}