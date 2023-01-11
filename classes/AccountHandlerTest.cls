@isTest
public class AccountHandlerTest {
    public static void init(){
        Account a = new Account();
        a.name = 'TestAcc';
        a.description = 'Test';
        insert a;
        system.debug('a:'+a);
        
    }
    public static testmethod void test(){
        init();
        Test.startTest();
        AccountHandler.queryaccount();
        //AccountHandler.queryAccDescription();
        Test.stopTest();
    }
    

}