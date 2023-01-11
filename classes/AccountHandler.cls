public class AccountHandler {
    public static void queryaccount(){
        List<Account> acclist = new list<Account>();
        List<Id> AccountIds = new List<Id>();
        acclist = [Select id,name from Account limit 5];
        system.debug('acclist:'+acclist);
        for(Account a:acclist){
            AccountIds.add(a.id);
        }
        system.debug('AccountIds:'+AccountIds);
    }
    
   /* public static void queryAccDescription(){
        List<Account> acclistdesc = new list<Account>();
        acclistdesc = [Select id,name,description from Account limit 5];
        system.debug('acclistdesc:'+acclistdesc);
    }*/
    //Test01
    //New version Test Apex class
    //Rollback test in Production
}