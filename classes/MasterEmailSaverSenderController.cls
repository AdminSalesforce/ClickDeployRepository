public class MasterEmailSaverSenderController  {
    //----------------------------------------------------------------------
    // Contants
    public final static String EMAIL_STATUS_DRAFT = 'Draft';
    public final static String EMAIL_STATUS_SENT = 'Sent';

    //----------------------------------------------------------------------
    // Methods

    @AuraEnabled
    public static InitModel loadInitDate(Id caseId) {
        InitModel result = new InitModel();
       
        String sObjName = caseId.getSObjectType().getDescribe().getName();
        
        if(sObjName == 'Case')
        {
 		result = loadCaseData(caseId);
        system.debug(result);
        }
        
        else if(sObjName == 'Email_Message__c')
        {
 		result = replyEmailData(caseId);
		system.debug(result);            
        }
        
        return  result;
    }

    public static InitModel replyEmailData(Id mailId) {
        InitModel result = new InitModel();
        
     Email_Message__c EmailMessageId = new Email_Message__c();
     EmailMessageId = [Select Id,name,Subject__c,Base_Parent_ID__c,Parent_Case__c from Email_Message__c where id =: mailId limit 1];                                                       
	 result = loadCaseData(EmailMessageId.Parent_Case__c);
     result.parentCaseId = EmailMessageId.Parent_Case__c;
     result.subject =  EmailMessageId.Subject__c;  
     result.parentMailId = mailId;
        return result;
    }
    
    public static InitModel loadCaseData(Id caseId) {
        InitModel result = new InitModel();
        

        try {
            Case caseRecord = [
              SELECT Id, ContactId, Contact.Brand__r.FromAddress__c, AccountId, Account.Name
              FROM Case
              WHERE Id = :caseId
            ];

            result.vfUrl = EmailSettings__c.getOrgDefaults().Visualforce_URL__c;
            result.contactId = caseRecord.ContactId;
            result.account = caseRecord.Account;
            result.parentCaseId = caseRecord.Id;
            result.fromAddress = (String.isNotBlank(caseRecord.Contact.Brand__r.FromAddress__c))
                ? caseRecord.Contact.Brand__r.FromAddress__c
                : UserInfo.getUserEmail();

            Email_Message__c email = getEmailMessage(caseId);
            if (null != email) { // found Draft
                result.email = email;
                result.template = getLetterTemplateContact(caseRecord.ContactID);
            } else {
                Letter_Template__c template = getLetterTemplateContact(caseRecord.ContactID);
                result.email = newMessage(caseRecord, template);
                result.template = template;
            }
        } catch (Exception ex) {
          throw new AuraHandledException(ex.getTypeName() + ': ' + ex.getMessage());
        }

        return result;
 
    }
    
    @AuraEnabled
    public  static Letter_Template__c getLetterTemplateContact(String contactId) {
        Letter_Template__c result;

        try {
            if (null != contactId) {
                List<Contact> contactList = [SELECT Brand__c, Language__c, Email FROM Contact WHERE Id =: contactId];

                if ( contactList[0].Brand__c == null || contactList[0].Language__c == null )
                    return null;

                List<Letter_Template__c> letterList = [
                    SELECT Id, Header__c, Footer__c, Salutation__c, Brand__c, Brand__r.FromAddress__c, Language__c
                    FROM Letter_Template__c 
                    WHERE Brand__c =: contactList[0].Brand__c AND Language__c =: contactList[0].Language__c 
                    ORDER BY LastModifiedDate DESC 
                    LIMIT 1
                ];

        
                if (!letterList.isEmpty()) {
                  result = letterList[0];
                }
            }
        } catch (Exception ex) {
          throw new AuraHandledException(ex.getTypeName() + ': ' + ex.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static String replaceString(String strToReplace, String caseId) {
        try {
            return replaceMergeFields(strToReplace, caseId);
        } catch (Exception ex) {
          throw new AuraHandledException(ex.getTypeName() + ': ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static SaveResult saveSendEmail(String emailStr, String status, String attachments, String parentMailId) {
        try {
            SaveResult result = new SaveResult();
			system.debug('parent mail id savesendemail -' + parentMailId);
            Email_Message__c emailToSend = (Email_Message__c) JSON.deserialize(emailStr, Email_Message__c.class);
            emailToSend.Email_Date__c = Datetime.now();
            saveEmailMessage(emailToSend, status, parentMailId);

            if (status == EMAIL_STATUS_SENT) {
                sendEmailMessage(emailToSend);
                result.status = 'Send';

                Case caseRecord = [
                  SELECT Id, ContactId, Contact.Brand__r.FromAddress__c, AccountId, Account.Name
                  FROM Case
                  WHERE Id = :emailToSend.Parent_Case__c
                ];
                result.newEmail = newMessage(caseRecord, emailToSend.Letter_Template__r);
            } else {
                result.status = 'Saved';
            }

            return result;
        } catch (Exception ex) {
          System.debug(LoggingLevel.Error, '~Exception Type: ' + ex.getTypeName());
          System.debug(LoggingLevel.Error, '~Exception Message: ' + ex.getMessage());
          System.debug(LoggingLevel.Error, '~Exception Stack Trace: ' + ex.getStackTraceString());
          
          throw new AuraHandledException(ex.getTypeName() + ': ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<FileModel> queryFiles(String emailId) {
      List<FileModel> result = new List<FileModel>();
      for (ContentDocument doc : queryFilesList(emailId)) {
        result.add(new FileModel(doc));
      }

      return result;
    }

    @AuraEnabled
    public static void deleteFile(String fileId) {
      try {
        delete new ContentDocument(Id = fileId);
      } catch (Exception ex) {
        throw new AuraHandledException(ex.getTypeName() + ': ' + ex.getMessage());
      }
    }

    //----------------------------------------------------------------------
    // Helpers
    public class InitModel {
      @AuraEnabled
      public Id contactId { get; private set; }

      @AuraEnabled
      public Account account { get; private set; }

      @AuraEnabled
      public Email_Message__c email { get; private set; }

      @AuraEnabled
      public Letter_Template__c template { get; private set; }

      @AuraEnabled
      public String vfUrl { get; private set; }

      @AuraEnabled
      public String fromAddress { get; private set; }
        
     @AuraEnabled
      public String parentCaseId { get; private set; } 
        
     @AuraEnabled
      public String subject { get; private set; }   
        
        @AuraEnabled
       public String parentMailId { get; private set; }   
    }

    public class FileModel {
      @AuraEnabled
      public String fileId { get; private set; }

      @AuraEnabled
      public String fileName { get; private set; }
      
      @AuraEnabled
      public String fileSize { get; private set; }

      public FileModel(ContentDocument doc) {
        fileId = doc.Id;
        fileName = doc.Title + '.' + doc.FileExtension;
        fileSize = fileSizeToString(doc.ContentSize);
      }

      /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
      private String fileSizeToString(Long Value) { // Bytes
        if (Value < 1024) {
          return string.valueOf(Value) + ' Bytes';
        } else if (Value >= 1024 && Value < (1024*1024)) { // KB
          Decimal kb = Decimal.valueOf(Value);
          kb = kb.divide(1024,2);
          return string.valueOf(kb) + ' KB';
        } else if (Value >= (1024*1024) && Value < (1024*1024*1024)) { // MB
          Decimal mb = Decimal.valueOf(Value);
          mb = mb.divide((1024*1024),2);
          return string.valueOf(mb) + ' MB';
        } else { // GB
          Decimal gb = Decimal.valueOf(Value);
          gb = gb.divide((1024*1024*1024),2);
          return string.valueOf(gb) + ' GB';
        }    
      }
    } 

    public class SaveResult {
      @AuraEnabled
      public String status { get; private set; }

      @AuraEnabled
      public Email_Message__c newEmail { get; private set; }
    }

    @TestVisible
    private static Email_Message__c getEmailMessage(String caseId) {
        List<Email_Message__c> emailList = [
            SELECT Bcc_Address__c, Body__c, Cc_Address__c, Name, Letter_Template__c, Parent_Case__c, 
                    Related_To_Contact__r.Email, Related_To_Contact__c, Status__c, Subject__c, To_Address__c,
                    
                    Letter_Template__r.Header__c, Letter_Template__r.Footer__c, 
                    Letter_Template__r.Salutation__c, Letter_Template__r.Brand__r.FromAddress__c,
                    Letter_Template__r.Brand__c, Letter_Template__r.Language__c
            FROM Email_Message__c 
            WHERE (Parent_Case__c =: caseId AND Status__c = :EMAIL_STATUS_DRAFT)
            ORDER BY LastModifiedDate DESC 
            LIMIT 1
        ];

        return emailList.isEmpty() ? null : emailList[0];
    }

    @AuraEnabled
    public static Contact getContactById(Id contactId){
        if ( contactId == null ){
            return null;
        }
        
        return [SELECT Name, Email FROM Contact WHERE Id =: contactId];
    }

    @TestVisible
    private static Email_Message__c newMessage(Case caseRecord, Letter_Template__c template) {
        Email_Message__c result = new Email_Message__c(
            Status__c = EMAIL_STATUS_DRAFT,
            Parent_Case__c = caseRecord.Id,
            Related_To_Contact__c = caseRecord.ContactId,
            Letter_Template__c = (null != template) ? template.Id : null,
            Letter_Template__r = template,
            Subject__c = '',
            Body__c = '',
            Cc_Address__c = '',
            Bcc_Address__c = ''
        );
        insert result;
        return result;
    }

    @TestVisible
    private static void saveEmailMessage(Email_Message__c messageToSave, String status, String parentMailId) {
        
        messageToSave.Subject__c = replaceMergeFields(messageToSave.Subject__c, messageToSave.Parent_Case__c);
        messageToSave.Status__c = status;
        messageToSave.Body__c = replaceMergeFields(messageToSave.Body__c, messageToSave.Parent_Case__c);

       
        // handle to address - get email from contact
        List<Contact> contacts = [SELECT Id, Email, Brand__r.FromAddress__c FROM Contact WHERE ID = :messageToSave.Related_To_Contact__c];
        if (!contacts.isEmpty()) {
          messageToSave.To_Address__c = contacts[0].Email;
        }

        // handle from address
        messageToSave.From_Address__c = contacts.isEmpty() || String.isBlank(contacts[0].Brand__r.FromAddress__c)
          ? UserInfo.getUserEmail()
          : contacts[0].Brand__r.FromAddress__c;
        
        system.debug(parentMailId);
        if(parentMailId != null)
        {
         	Email_Message__c EmailMessageId = new Email_Message__c();
    		EmailMessageId = [Select Id,name,Base_Parent_ID__c,Parent_Case__c from Email_Message__c where id =: parentMailId.trim() limit 1];  
		 	messageToSave.Immediate_Parent_ID__c =   parentMailId.trim();                                                     
    		messageToSave.Base_Parent_ID__c = EmailMessageId.Base_Parent_ID__c == null ? parentMailId.trim() :  EmailMessageId.Base_Parent_ID__c;                    
        }
        upsert messageToSave;
    }

    private static String replaceMergeFields(String emailBody, String caseIdStr) {
        Id caseId = (Id) caseIdStr;
         
        // handle merge fields
        emailBody = ReplaceHelperForEmail.replacet(emailBody, String.valueOf(caseId.getSobjectType()), caseIdStr);
		system.debug('emailbody:' + emailBody);
        // handle images from rich text fields
        //EmailSettings__c setting = EmailSettings__c.getOrgDefaults();
        //emailBody = emailBody.replaceAll(setting.Internal_Image_URL_Domain__c, setting.Public_Image_URL_Domain__c);

        return emailBody;
    }

    private static void sendEmailMessage(Email_Message__c messageToSend) {
        Messaging.SingleEmailMessage emailToSend = createEmail(messageToSend);
        System.Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailToSend}, true);
    }

    @TestVisible
    private static Messaging.SingleEmailMessage createEmail(Email_Message__c customEmail) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        List<String> ccRecords;
        List<String> bccRecords;
        if (customEmail.Cc_Address__c != '' && customEmail.Cc_Address__c != null) {
            ccRecords = customEmail.Cc_Address__c.replace(' ','').split(';');
        }

        if (customEmail.Bcc_Address__c != '' && customEmail.Bcc_Address__c != null) {
            bccRecords = customEmail.Bcc_Address__c.replace(' ','').split(';');
        }

        List<Letter_Template__c> letterTemplates = [
            SELECT Header__c, Id, Footer__c, Salutation__c, Brand__r.FromAddress__c
            FROM Letter_Template__c 
            WHERE Id = :customEmail.Letter_Template__c
        ];

        List<OrgWideEmailAddress> orgWideEmailAddress = [SELECT ID FROM OrgWideEmailAddress WHERE Address = :customEmail.From_Address__c];
        if (!orgWideEmailAddress.isEmpty()) {
          newEmail.setOrgWideEmailAddressId(orgWideEmailAddress[0].Id);
        }

        final String emailBody;
        if (letterTemplates.isEmpty()) {
            emailBody = (String.isNotBlank(customEmail.Body__c) ? '<p>' + customEmail.Body__c + '</p>' : '');
        } else {
            emailBody = (String.isNotBlank(letterTemplates[0].Header__c) ? '<p>' + letterTemplates[0].Header__c + '</p>' : '')
              + (String.isNotBlank(letterTemplates[0].Salutation__c) ? '<p>' + letterTemplates[0].Salutation__c + '</p>' : '')
              + (String.isNotBlank(customEmail.Body__c) ? '<p>' + customEmail.Body__c + '</p>' : '')
              + (String.isNotBlank(letterTemplates[0].Footer__c) ? '<p>' + letterTemplates[0].Footer__c + '</p>' : '');
        }
        
        newEmail.setTargetObjectId(customEmail.Related_To_Contact__c);
        newEmail.setWhatId(customEmail.Parent_Case__c);
        newEmail.setBccAddresses(bccRecords);
        newEmail.setCcAddresses(ccRecords);
        newEmail.setReferences(customEmail.To_Address__c);
        
        newEmail.setReplyTo('caseemailhandler@z-2avajmkbotsv9pyytodtsn4d2nfxxxmdny6qz89fcrhacka55h.5c-debsua4.cs62.apex.sandbox.salesforce.com');
        newEmail.setToAddresses(new ID[] {customEmail.Related_To_Contact__c});
        //newEmail.setSubject(replaceMergeFields(customEmail.Subject__c, customEmail.Parent_Case__c));
        
        String subject = replaceMergeFields(customEmail.Subject__c, customEmail.Parent_Case__c);
        System.debug('subject 1 ---------> '+subject);

        subject = subject + ' [ Please do not change this subject ID:' +customEmail.Id +' ]';
        system.debug(subject);
        newEmail.setSubject(subject);
                
        
        newEmail.setHtmlBody(replaceMergeFields(emailBody, customEmail.Parent_Case__c));

        // set attachments
        List<String> attachmentsIds = new List<String>();
        for (ContentDocument doc : queryFilesList(customEmail.Id)) {
          attachmentsIds.add(doc.LatestPublishedVersionId);
        }
        newEmail.setEntityAttachments(attachmentsIds);
        return newEmail;
    }

    @TestVisible
    private static List<ContentDocument> queryFilesList(String emailId) {
      // query links between email object and content document
      Set<Id> contentDocumentsIds = new Set<Id>();
      for (ContentDocumentLink link : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :emailId]) {
        contentDocumentsIds.add(link.ContentDocumentId);
      }

      // query documents
      return [
        SELECT ID, Title, FileExtension, ContentSize, LatestPublishedVersionId 
        FROM ContentDocument 
        WHERE ID IN :contentDocumentsIds 
        ORDER BY CreatedDate ASC
      ];
    }
}