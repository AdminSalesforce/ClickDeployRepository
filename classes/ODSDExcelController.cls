public class ODSDExcelController {
	public List<contact> contactList{get;set;}
    public List<Case> caseList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public ODSDExcelController(){
        contactList = [SELECT id,Name, LastName, Account.Name, Email FROM Contact WHERE Email != '' AND Account.Name != '' LIMIT 5];
        caseList = [Select id,CaseNumber,Subject,CreatedDate,Status,OwnerId,Description from Case limit 5];
    }
    
    public Pagereference exportAll(){
        return new Pagereference('/apex/exportAll');
    }
    
}