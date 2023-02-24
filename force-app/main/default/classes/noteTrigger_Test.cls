@isTest
public with sharing class noteTrigger_Test {
    
    static testMethod void insertNote() {
        Account testAccount = New Account();
        testAccount.name = 'Test Account';
        insert testAccount;
        
        Note testNote = new Note();
        testNote.Title = 'Test insert note';
        testNote.Body = 'Test insert note trigger';
        testNote.ParentId = testAccount.Id;
        insert testNote;
        
        ContentDocumentLink cdl = [Select Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility 
                                    FROM ContentDocumentLink WHERE LinkedEntityId = : testAccount.Id LIMIT 1];
        ContentNote cn = [Select Id, Title, TextPreview, Content, CreatedDate, FileType, FileExtension, IsReadOnly, SharingPrivacy 
                                    FROM ContentNote WHERE ID = :cdl.ContentDocumentId LIMIT 1];
        
        Test.startTest();
        System.assertEquals(testNote.Title, cn.Title);
        System.assertEquals(Blob.valueOf(testNote.Body), cn.Content);
        Test.stopTest();

    }
}