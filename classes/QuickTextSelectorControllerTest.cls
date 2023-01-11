@isTest 
private class QuickTextSelectorControllerTest {

	@isTest
	private static void testGetQuickText() {
        Brand__c testBrand = new Brand__c(Name='TestBrand');
        insert testBrand;
        Language__c testLanguage = new Language__c(Name='TestBrand');
        insert testLanguage;
        Quick_Text__c testQuickText = new Quick_Text__c(
            Name = 'TEST',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id,
            Quick_Text_Message__c = 'HELLO',
            Quick_Text_Category__c = 'Email');
        insert testQuickText;    

        Contact testContact = new Contact(
            LastName = 'TEST',
            Brand__c = testBrand.Id,
            Language__c = testLanguage.Id);
        insert testContact;

        Test.startTest();
            List<Quick_Text__c> quickTestArray = QuickTextSelectorController.getQuickText(testContact.Id);
            String actualValue = quickTestArray.get(0).Quick_Text_Message__c;
        Test.stopTest();

        System.assertEquals('HELLO', actualValue);
	}
}