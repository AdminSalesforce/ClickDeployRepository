public class QuickTextSelectorController  {
    
    @AuraEnabled
    public static Quick_Text__c[] getQuickText(Id contactIdVal) {
        try {
            Contact currentContact = [SELECT Id, Name, Brand__c, Language__c FROM Contact WHERE Id =: contactIdVal];

            if (String.isBlank(currentContact.Brand__c)){
                return null;
            }

            List<Quick_Text__c> result;

            if (!String.isBlank(currentContact.Language__c)) {
                result = [
                  SELECT Name, Quick_Text_Message__c, Quick_Text_Category__c, Brand__c, Language__c 
                  FROM Quick_Text__c 
                  WHERE Quick_Text_Category__c = 'Email' 
                      AND Brand__c =: currentContact.Brand__c 
                      AND Language__c =: currentContact.Language__c
                ];
            } else {
                result = [
                  SELECT Name, Quick_Text_Message__c, Quick_Text_Category__c, Brand__c, Language__c 
                  FROM Quick_Text__c 
                  WHERE Quick_Text_Category__c = 'Email' 
                      AND Brand__c =: currentContact.Brand__c
                ];
            }


            return result;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getTypeName() + ': ' + ex.getMessage());
        }
    }
}