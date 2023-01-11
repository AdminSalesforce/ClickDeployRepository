@isTest 
private class MasterEmailSaverSenderControllerTest {

    @isTest
    private static void testGetDraftEmailMessage() {
        
        Account testAccount = new Account (Name = 'testAccount');
        insert testAccount;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            AccountId = testAccount.Id);
        insert testContact;

        Letter_Template__c testLetterTemplate = new Letter_Template__c();
        insert testLetterTemplate;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id,
            AccountId = testAccount.Id);
        insert testCase;

        Email_Message__c testMessage = new Email_Message__c(
            Body__c = 'TestMsg1',
            Status__c = 'Draft',
            Parent_Case__c = testCase.Id,
            Letter_Template__c = testLetterTemplate.Id);
        insert testMessage;

        Attachment testAttachment = new Attachment( 
            Name = 'Test Attachment',
            Body = Blob.valueOf(''),
            ParentId = testMessage.Id );
        insert testAttachment;

        Test.startTest();
            MasterEmailSaverSenderController.InitModel initModel;
            try {
                initModel = MasterEmailSaverSenderController.loadInitDate(testCase.Id);
            } catch (AuraHandledException e) {
                System.debug(e.getTypeName() + ': ' + e.getMessage());
            }
        Test.stopTest();

        System.assertEquals(testContact.Id, initModel.contactId);
        System.assertEquals(testAccount.Id, initModel.account.Id);
        System.assertEquals(testMessage.Id, initModel.email.Id);
        System.assertEquals(testLetterTemplate.Id, initModel.email.Letter_Template__c);
    }
    @IsTest
    private static void testGetDraftEmailMessageWhenItUndefined() {
        
        Account testAccount = new Account (Name = 'testAccount');
        insert testAccount;

        Brand__c testBrand = new Brand__c (Name = 'TestBrand');
        insert testBrand;
        
        Language__c testLanguage = new Language__c (Name = 'TestLanguage');
        insert testLanguage;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id,
            AccountId = testAccount.Id);
        insert testCase;

        Letter_Template__c testLetterTemplate = new Letter_Template__c(
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testLetterTemplate;

        Test.startTest();
            MasterEmailSaverSenderController.InitModel initModel = MasterEmailSaverSenderController.loadInitDate(testCase.Id);
        Test.stopTest();

        System.assertEquals(testContact.Id, initModel.contactId);
        System.assertEquals(testAccount.Id, initModel.account.Id);
        System.assertNotEquals(null, initModel.email);
        System.assertEquals(testLetterTemplate.Id, initModel.email.Letter_Template__c); 
    }
    /*
    @IsTest
    private static void testGetDraftEmailMessageWhenLetterTemplateUndefined() {
        
        Brand__c testBrand = new Brand__c (Name = 'TestBrand');
        insert testBrand;
        
        Language__c testLanguage = new Language__c (Name = 'TestLanguage');
        insert testLanguage;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id);
        insert testCase;

        Test.startTest();
            Email_Message__c lastDraftEmail = MasterEmailSaverSenderController.getEmailMessage(String.valueOf(testCase.Id));
        Test.stopTest();
        System.debug(lastDraftEmail);
        System.assertEquals(null, lastDraftEmail.Letter_Template__c);  
        System.assertNotEquals(null, lastDraftEmail);  
    }

*/
    @isTest(seealldata='true')
    private static void testReplaceString(){
        Contact testContact = new Contact (LastName = 'TestContact');
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id);
        insert testCase;

        String current = '{!Case.Status}';
        String expected = 'New';

        Test.startTest();
            String actual = MasterEmailSaverSenderController.replaceString(current, String.valueOf(testCase.Id));
        Test.stopTest();

        System.assertEquals(expected, actual);
    }

    @isTest(seealldata='true')
    private static void testSaveSendEmail(){

        Brand__c testBrand = new Brand__c (Name = 'TestBrand');
        insert testBrand;
        
        Language__c testLanguage = new Language__c (Name = 'TestLanguage');
        insert testLanguage;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id,
            Email = 'aa@gmail.com');
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id);
        insert testCase;

        Letter_Template__c testLetterTemplate = new Letter_Template__c(
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testLetterTemplate;

        Email_Message__c testEmailMessage = new Email_Message__c(
            Letter_Template__c = testLetterTemplate.Id,
            Body__c = 'dsfasdf',
            Subject__c = '{!Case.Id}',
            Parent_Case__c = testCase.Id,
            Related_To_Contact__c = testContact.Id,
            From_Address__c = 'DSa@gmail.com',
            Cc_Address__c = 'asd@gmail.com',
            Bcc_Address__c = 'sadasd@gmail.com'); 

         Attachment testAttachment = new Attachment( 
            Name = 'Test Attachment',
            body = Blob.valueOf('Heytdssdaf'),
            ParentId = testEmailMessage.Id );

        List<Attachment> attachmentsArray = new List<Attachment>(new Attachment[]{testAttachment});

        Test.startTest();
            MasterEmailSaverSenderController.SaveResult result = MasterEmailSaverSenderController.saveSendEmail(JSON.serialize(testEmailMessage), 'Sent', '{"name":"Toggl_time_entries_2019-05-27_to_2019-05-27.csv","body":"data:application/octet-stream;base64,77u/VXNlcixFbWFpbCxDbGllbnQsUHJvamVjdCxUYXNrLERlc2NyaXB0aW9uLEJpbGxhYmxlLFN0YXJ0IGRhdGUsU3RhcnQgdGltZSxFbmQgZGF0ZSxFbmQgdGltZSxEdXJhdGlvbixUYWdzLEFtb3VudCAoKQpPIEJ1cnluc2t5aSxvLmJ1cnluc2t5aUBwb2x5dGVjaC5zb2Z0d2FyZSwsQXBwbGljYXR1cmUsLEFwcGxpY2F0dXJlLE5vLDIwMTktMDUtMjcsMTE6MDg6MjMsMjAxOS0wNS0yNywxMToxMTo0OCwwMDowMzoyNSwsCk8gQnVyeW5za3lpLG8uYnVyeW5za3lpQHBvbHl0ZWNoLnNvZnR3YXJlLCxBcHBsaWNhdHVyZSwsQXBwbGljYXR1cmUsTm8sMjAxOS0wNS0yNywxMToxMzoyNSwyMDE5LTA1LTI3LDEzOjAwOjU3LDAxOjQ3OjMyLCwKTyBCdXJ5bnNreWksby5idXJ5bnNreWlAcG9seXRlY2guc29mdHdhcmUsLEFwcGxpY2F0dXJlLCxBcHBsaWNhdHVyZSxObywyMDE5LTA1LTI3LDE0OjQ4OjAxLDIwMTktMDUtMjcsMTk6MDY6NTcsMDQ6MTg6NTYsLApPIEJ1cnluc2t5aSxvLmJ1cnluc2t5aUBwb2x5dGVjaC5zb2Z0d2FyZSwsU2VsZiBsZWFybmluZywsRW5nbGlzaCBjbGFzc2VzLE5vLDIwMTktMDUtMjcsMTg6MjI6MDcsMjAxOS0wNS0yNywxOTowNzowOCwwMDo0NTowMSwsCg=="}');
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals('Send', result.status);

    }

    //@IsTest(seealldata='true')
    //private static void createAttachmentsTest() {
        //Email_Message__c emailMessageRec = [SELECT Id FROM Email_Message__c LIMIT 1];
        //String attachments = '[{"name":"Toggl_time_entries_2019-05-27_to_2019-05-27.csv","body":"data:application/octet-stream;base64,77u/VXNlcixFbWFpbCxDbGllbnQsUHJvamVjdCxUYXNrLERlc2NyaXB0aW9uLEJpbGxhYmxlLFN0YXJ0IGRhdGUsU3RhcnQgdGltZSxFbmQgZGF0ZSxFbmQgdGltZSxEdXJhdGlvbixUYWdzLEFtb3VudCAoKQpPIEJ1cnluc2t5aSxvLmJ1cnluc2t5aUBwb2x5dGVjaC5zb2Z0d2FyZSwsQXBwbGljYXR1cmUsLEFwcGxpY2F0dXJlLE5vLDIwMTktMDUtMjcsMTE6MDg6MjMsMjAxOS0wNS0yNywxMToxMTo0OCwwMDowMzoyNSwsCk8gQnVyeW5za3lpLG8uYnVyeW5za3lpQHBvbHl0ZWNoLnNvZnR3YXJlLCxBcHBsaWNhdHVyZSwsQXBwbGljYXR1cmUsTm8sMjAxOS0wNS0yNywxMToxMzoyNSwyMDE5LTA1LTI3LDEzOjAwOjU3LDAxOjQ3OjMyLCwKTyBCdXJ5bnNreWksby5idXJ5bnNreWlAcG9seXRlY2guc29mdHdhcmUsLEFwcGxpY2F0dXJlLCxBcHBsaWNhdHVyZSxObywyMDE5LTA1LTI3LDE0OjQ4OjAxLDIwMTktMDUtMjcsMTk6MDY6NTcsMDQ6MTg6NTYsLApPIEJ1cnluc2t5aSxvLmJ1cnluc2t5aUBwb2x5dGVjaC5zb2Z0d2FyZSwsU2VsZiBsZWFybmluZywsRW5nbGlzaCBjbGFzc2VzLE5vLDIwMTktMDUtMjcsMTg6MjI6MDcsMjAxOS0wNS0yNywxOTowNzowOCwwMDo0NTowMSwsCg==","id":"newAdded"}]';
        //List<String> attachmentId = new List<String>();
        //Attachment attachId;
        //test.startTest();
            //attachmentId = MasterEmailSaverSenderController.createAttachments(attachments, emailMessageRec.Id);
            //attachId = [SELECT Id FROM Attachment WHERE ParentId =: emailMessageRec.Id LIMIT 1];
        //test.stopTest();
        //System.assertEquals(attachId.ID, attachmentId[0]);
    //}
    
    @IsTest(seealldata='true')
    private static void createEmailTest() {
        Brand__c testBrand = new Brand__c (Name = 'TestBrand');
        insert testBrand;
        
        Language__c testLanguage = new Language__c (Name = 'TestLanguage');
        insert testLanguage;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id,
            Email = 'aa@gmail.com');
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id);
        insert testCase;

        Letter_Template__c testLetterTemplate = new Letter_Template__c(
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testLetterTemplate;

        Email_Message__c testEmailMessage = new Email_Message__c(
            Letter_Template__c = testLetterTemplate.Id,
            Body__c = 'dsfasdf',
            Subject__c = '{!Case.Id}',
            Parent_Case__c = testCase.Id,
            Related_To_Contact__c = testContact.Id,
            From_Address__c = 'DSa@gmail.com',
            Cc_Address__c = 'asd@gmail.com',
            Bcc_Address__c = 'sadasd@gmail.com'); 
        insert testEmailMessage;
        Test.startTest();
            Email_Message__c emailMess = [SELECT Parent_Case__c FROM Email_Message__c WHERE Id =:testEmailMessage.Id];
            Messaging.SingleEmailMessage singleEmail = MasterEmailSaverSenderController.createEmail(testEmailMessage);
        Test.stopTest();
        System.assertEquals(emailMess.Parent_Case__c, singleEmail.getSubject());
    }

    @IsTest
    private static void getLetterTemplateForContactTest() {
        Brand__c testBrand = new Brand__c (Name = 'TestBrand');
        insert testBrand;
        
        Language__c testLanguage = new Language__c (Name = 'TestLanguage');
        insert testLanguage;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id,
            Email = 'aa@gmail.com');
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id);
        insert testCase;

        Letter_Template__c testLetterTemplate = new Letter_Template__c(
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testLetterTemplate;
        Test.startTest();
            Letter_Template__c letter = MasterEmailSaverSenderController.getLetterTemplateContact(testContact.Id);
        Test.stopTest();
        System.assertEquals(testLetterTemplate.Brand__c,letter.Brand__c);
    }
    
    @isTest
    private static void getEmailMessageTest() {
        Brand__c testBrand = new Brand__c (Name = 'TestBrand');
        insert testBrand;
        
        Language__c testLanguage = new Language__c (Name = 'TestLanguage');
        insert testLanguage;

        Contact testContact = new Contact (
            LastName = 'TestContact',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id,
            Email = 'aa@gmail.com');
        insert testContact;

        Case testCase = new Case (
            Status = 'new',
            Origin = 'Email',
            ContactId = testContact.Id);
        insert testCase;

        Letter_Template__c testLetterTemplate = new Letter_Template__c(
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testLetterTemplate;

        Email_Message__c testEmailMessage = new Email_Message__c(
            Letter_Template__c = testLetterTemplate.Id,
            Body__c = 'dsfasdf',
            Subject__c = '{!Case.Id}',
            Parent_Case__c = testCase.Id,
            Related_To_Contact__c = testContact.Id,
            From_Address__c = 'DSa@gmail.com',
            Cc_Address__c = 'asd@gmail.com',
            Bcc_Address__c = 'sadasd@gmail.com',
            Status__c = 'Draft'); 
        insert testEmailMessage;
        Test.startTest();
            Email_Message__c emailmess = MasterEmailSaverSenderController.getEmailMessage(testCase.Id);
        Test.stopTest();
        System.assertEquals(testEmailMessage.Id, emailmess.Id);
    }

    @IsTest
    private static void deleteFileTest() {
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'Toggl_time_entries_2019-05-27_to_2019-05-27.csv'; 
        conVer.Title = 'Proposal '; 
        conVer.VersionData = EncodingUtil.base64Decode('77u/VXNlcixFbWFpbCxDbGllbnQsUHJvamVjdCxUYXNrLERlc2NyaXB0aW9uLEJpbGxhYmxlLFN0YXJ0IGRhdGUsU3RhcnQgdGltZSxFbmQgZGF0ZSxFbmQgdGltZSxEdXJhdGlvbixUYWdzLEFtb3VudCAoKQpPIEJ1cnluc2t5aSxvLmJ1cnluc2t5aUBwb2x5dGVjaC5zb2Z0d2FyZSwsQXBwbGljYXR1cmUsLEFwcGxpY2F0dXJlLE5vLDIwMTktMDUtMjcsMTE6MDg6MjMsMjAxOS0wNS0yNywxMToxMTo0OCwwMDowMzoyNSwsCk8gQnVyeW5za3lpLG8uYnVyeW5za3lpQHBvbHl0ZWNoLnNvZnR3YXJlLCxBcHBsaWNhdHVyZSwsQXBwbGljYXR1cmUsTm8sMjAxOS0wNS0yNywxMToxMzoyNSwyMDE5LTA1LTI3LDEzOjAwOjU3LDAxOjQ3OjMyLCwKTyBCdXJ5bnNreWksby5idXJ5bnNreWlAcG9seXRlY2guc29mdHdhcmUsLEFwcGxpY2F0dXJlLCxBcHBsaWNhdHVyZSxObywyMDE5LTA1LTI3LDE0OjQ4OjAxLDIwMTktMDUtMjcsMTk6MDY6NTcsMDQ6MTg6NTYsLApPIEJ1cnluc2t5aSxvLmJ1cnluc2t5aUBwb2x5dGVjaC5zb2Z0d2FyZSwsU2VsZiBsZWFybmluZywsRW5nbGlzaCBjbGFzc2VzLE5vLDIwMTktMDUtMjcsMTg6MjI6MDcsMjAxOS0wNS0yNywxOTowNzowOCwwMDo0NTowMSwsCg=='); 
        insert conVer;
        Test.startTest();
            conVer = [SELECT ContentDocumentId, ContentDocument.IsDeleted, IsDeleted FROM ContentVersion WHERE Id =: conVer.Id];
            MasterEmailSaverSenderController.deleteFile(String.valueOf(conVer.ContentDocumentId));
        Test.stopTest();
        System.assertEquals(false, conVer.ContentDocument.IsDeleted);
    }
}