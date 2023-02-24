@isTest
public class Test_PermanentNotesOpp{
    Private Static Final String ACCOUNT_NAME = 'Test Account';
    @testSetup
    static void setupData() {
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOpp;
        for(integer i = 0; i < 10; i++){
            testOpp = New Opportunity(name = ACCOUNT_NAME + ' ' + i, Permanent_Notes__c = 'String ' + i,StageName = 'Receive Entity Information',CloseDate = Date.today());
            oppList.add(testOpp);
        }
        insert oppList;
    }
    @isTest 
    static void opportityBatchTest() {
        Test.startTest();
        Database.executeBatch(new PermanentNotesBatchOpp(), 10);
        Test.stopTest();
    }
}