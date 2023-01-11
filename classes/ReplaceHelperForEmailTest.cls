@isTest 
private class ReplaceHelperForEmailTest {

	@isTest
	private static void getObjectsTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        SObject objects;
        Account accrec;
        Contact contactRec;
        test.startTest();
            objects = ReplaceHelperForEmail.getObjects('{!Case.CaseNumber} hello my friend {!Account.Name}', 'Case', caseRec.Id);
            caseRec = [SELECT Id, CaseNumber, AccountId FROM Case WHERE Id =: caseRec.Id];
        test.stopTest();
        System.assertEquals('Case:{CaseNumber='+caseRec.CaseNumber+', AccountId='+caseRec.AccountId+', Id='+caseRec.Id+'}', String.valueOf(objects));
	}
    @IsTest
    private static void NullablegetObjectsTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        SObject objects;
        Account accrec;
        Contact contactRec;
        test.startTest();
            objects = ReplaceHelperForEmail.getObjects('hello my friend hgbdfhgdfhgfdhfgdhfdghdfghdfgh', 'Case', caseRec.Id);
            caseRec = [SELECT Id, CaseNumber, AccountId FROM Case WHERE Id =: caseRec.Id];
        test.stopTest();
        System.assertEquals(null, String.valueOf(objects));
	}
    @isTest
	private static void getObjectNamesTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        Set<String> objects;
        Account accrec;
        Contact contactRec;
        test.startTest();
            objects = ReplaceHelperForEmail.getObjectNames('{!Case.CaseNumber} hello my friend {!Account.Name}', 'Case');
            caseRec = [SELECT Id, CaseNumber, AccountId FROM Case WHERE Id =: caseRec.Id];
        test.stopTest();
        System.assertEquals('{Account, Case}', String.valueOf(objects));
	}
    @IsTest
    private static void NullablegetObjectNamesTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        Set<String> objects;
        Account accrec;
        Contact contactRec;
        test.startTest();
            objects = ReplaceHelperForEmail.getObjectNames('hello my friend hgbdfhgdfhgfdhfgdhfdghdfghdfgh', 'Case');
            caseRec = [SELECT Id, CaseNumber, AccountId FROM Case WHERE Id =: caseRec.Id];
        test.stopTest();
        System.assertEquals('{}', String.valueOf(objects));
	}
    @isTest
	private static void replaceCaseTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        SObject sobjectRec;
        String replaced;
        test.startTest();
            sobjectRec = [SELECT Id, CaseNumber, Account.Name FROM Case WHERE Id =: caseRec.Id];
            replaced = ReplaceHelperForEmail.replace('{!Case.CaseNumber} hello my friend {!Account.Name}', 'Case', sobjectRec, 'Case');
        test.stopTest();
        System.assertEquals(sobjectRec.get('CaseNumber') + ' hello my friend {!Account.Name}', String.valueOf(replaced));
	}
    @isTest
	private static void replaceAccountTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        SObject sobjectRec;
        String replaced;
        test.startTest();
            sobjectRec = [SELECT Id, CaseNumber, Account.Name FROM Case WHERE Id =: caseRec.Id];
            replaced = ReplaceHelperForEmail.replace('{!Case.CaseNumber} hello my friend {!Account.Name}', 'Account', sobjectRec, 'Case');
        test.stopTest();
        System.assertEquals('{!Case.CaseNumber} hello my friend '+sobjectRec.getSObject('Account').get('Name'), replaced);
	}
    @IsTest
    private static void replaceNoToReplaceTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        SObject sobjectRec;
        String replaced;
        test.startTest();
            sobjectRec = [SELECT Id, CaseNumber, Account.Name FROM Case WHERE Id =: caseRec.Id];
            replaced = ReplaceHelperForEmail.replace('hello my friend', 'Case', sobjectRec, 'Case');
        test.stopTest();
        System.assertEquals('hello my friend', replaced);
	}
    @IsTest
    private static void replacetTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        String replaced;
        test.startTest();
            replaced = ReplaceHelperForEmail.replacet('{!Case.CaseNumber} {!Case.Account.Name} hello my friend {!Account.Name}', 'Case', caseRec.Id);
            caseRec = [SELECT CaseNumber, Owner.Id, Id, Account.Name FROM Case WHERE Id =:caseRec.Id];
        test.stopTest();
        System.assertEquals(caseRec.CaseNumber+' '+caseRec.Account.Name+' hello my friend '+caseRec.Account.Name, replaced);
	}
    @IsTest
    private static void replacetNullEmptyTest() {
        SetupData setupD = new SetupData();
        Case caseRec = setupD.setupDate();
        String replaced;
        test.startTest();
            replaced = ReplaceHelperForEmail.replacet('', 'Case', caseRec.Id);
        test.stopTest();
        System.assertEquals('', replaced);
	}



    private class SetupData {
        private Case setupDate() {
            Account acc = new Account(Name = 'Igor Account');
            insert acc;
            Contact con = new Contact(LastName = 'Glynka', AccountId = acc.Id);
            insert con;
            Case caseRecord = new Case(Status = 'New', Origin = 'Phone', AccountId = acc.Id, ContactId = con.Id);
            insert caseRecord;
            return caseRecord;
        }
    }
}