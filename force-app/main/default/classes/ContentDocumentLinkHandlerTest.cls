@isTest
private class ContentDocumentLinkHandlerTest {
	
    Private Static Final String ACCOUNT_NAME = 'Test Account';
    
    @testSetup
    static void setupData(){
    	//create our test data
        Account testAccount = New Account(name = ACCOUNT_NAME);
        insert testAccount;    
    }
    
    @isTest 
    static void TestNoteInsert(){
        Account testAct = [Select Id from Account where name = : ACCOUNT_NAME];
    	ContentVersion objCntNote = new ContentVersion();
        objCntNote.Title = 'Test Content Note by sfdcpanther.com';
        objCntNote.PathOnClient = objCntNote.Title + '.snote';
        objCntNote.VersionData = Blob.valueOf('Test Content Note');
        objCntNote.FirstPublishLocationId = testAct.Id; 
        insert objCntNote;   
        ContentDocumentLink cdlResult = [SELECT ContentDocumentId,LinkedEntityId,ShareType, systemmodstamp FROM ContentDocumentLink where LinkedEntityId = : testAct.Id limit 1];
        system.assert(cdlResult.ShareType == 'I');
    }
}