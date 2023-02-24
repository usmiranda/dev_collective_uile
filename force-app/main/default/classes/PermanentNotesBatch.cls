public with sharing class PermanentNotesBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Perm__c FROM Account';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<ContentNote> listNotes = new List<ContentNote>();
        List<ContentDocumentLink> listContent = new List<ContentDocumentLink>();
       	Integer i = 0;
        for(Account acc : scope){
            system.debug('acc '+ i + '-> ' + acc );
            i++;
            if(String.IsEmpty(acc.Perm__c) || String.isBlank(acc.Perm__c) || acc.Perm__c == ''){continue;}
            ContentNote cn = new ContentNote();
            cn.Title = acc.Id;
            cn.Content = Blob.valueOf(acc.Perm__c);
            listNotes.add(cn);
            
            
        }
        insert listNotes;
        for(ContentNote note : listNotes){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = (Id)note.Title;
            cdl.ContentDocumentId = note.Id;
            listContent.add(cdl);
        }
        insert listContent;
    }
    public void finish(Database.BatchableContext BC){
        
    }
}