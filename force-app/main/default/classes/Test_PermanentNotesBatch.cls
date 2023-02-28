@isTest
public class Test_PermanentNotesBatch {
    Private Static Final String ACCOUNT_NAME = 'Test Account';
    
    @testSetup
    static void setupData() {
        List<Account> actList = new List<Account>();
        Account testAccount;
        for(integer i = 0; i < 10; i++){
            testAccount = New Account(name = ACCOUNT_NAME + ' ' + i, Perm__c = 'String ' + i);
            actList.add(testAccount);
        }
        insert actList;
    }
    @isTest 
    static void accountBatchTest() {
        Test.startTest();
        Database.executeBatch(new PermanentNotesBatch(),10);
        Test.stopTest();
    }
}