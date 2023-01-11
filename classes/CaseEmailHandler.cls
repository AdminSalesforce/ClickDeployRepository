global class CaseEmailHandler implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
 
    // Create an InboundEmailResult object for returning the result of the 
    // Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    
    string splitIdFromsubject = email.subject.substringAfter('ID:');
    String ImmediateParentId =  splitIdFromsubject.substringBefore(']');                                                      
    system.debug('subject ----->'+splitIdFromsubject);   
     
    Email_Message__c EmailMessageId = new Email_Message__c();
    EmailMessageId = [Select Id,name,Base_Parent_ID__c,Parent_Case__c from Email_Message__c where id =: ImmediateParentId.trim() limit 1];                                                       
    List<Email_Message__c> EmailMessageList = new List<Email_Message__c>();
    List<Attachment> AttachmentList = new List<Attachment>();                                                       
    
    Email_Message__c EmailMessageObject = new Email_Message__c();
    EmailMessageObject.Cc_Address__c = string.valueof(email.ccAddresses);
    EmailMessageObject.Body__c = email.htmlBody;
    EmailMessageObject.Email_Date__c = system.today();
    EmailMessageObject.From_Address__c = email.fromAddress;
    EmailMessageObject.Immediate_Parent_ID__c = ImmediateParentId.trim();
    EmailMessageObject.Parent_Case__c =   EmailMessageId.Parent_Case__c;                                                     
    EmailMessageObject.Base_Parent_ID__c = EmailMessageId.Base_Parent_ID__c == null ? ImmediateParentId.trim() :  EmailMessageId.Base_Parent_ID__c;                                       
    EmailMessageObject.Subject__c = email.subject;
    EmailMessageObject.To_Address__c = string.valueof(email.toAddresses); 
    
    EmailMessageList.add(EmailMessageObject);     

    if(!EmailMessageList.isEmpty())
    {
            insert EmailMessageList;
       }                                              
      
    
    if(email.textAttachments != null)
        {
            // Save attachments, if any
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
              Attachment attachment = new Attachment();
             
              attachment.Name = tAttachment.fileName;
              attachment.Body = Blob.valueOf(tAttachment.body);
              attachment.ParentId = EmailMessageList[0].Id;
              AttachmentList.add(attachment);
            }
        }
                                                           
        if(email.binaryAttachments != null)
        {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
              Attachment attachment = new Attachment();
             
              attachment.Name = bAttachment.fileName;
              attachment.Body = bAttachment.body;
              attachment.ParentId = EmailMessageList[0].Id;
              AttachmentList.add(attachment);
            }
        }
       if(!AttachmentList.isEmpty())
    	{
            insert AttachmentList;
        }
        
                                                             
   // Return the result for the Apex Email Service
   return result;
  }
}