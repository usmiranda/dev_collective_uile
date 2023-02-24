public with sharing class PermanentNotesBatchOpp implements Database.Batchable<sObject>{
public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Permanent_Notes__c FROM Opportunity';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        List<ContentNote> listNotes = new List<ContentNote>();
        List<ContentDocumentLink> listContent = new List<ContentDocumentLink>();
       	Integer i = 0;
        for(Opportunity opp : scope){
            system.debug('opp '+ i + '-> ' + opp );
            i++;
            if(String.isEmpty(opp.Permanent_Notes__c) || opp.Permanent_Notes__c == '' || String.isBlank(opp.Permanent_Notes__c)){continue;}
            ContentNote cn = new ContentNote();
            cn.Title = opp.Id;
            cn.Content = Blob.valueOf(opp.Permanent_Notes__c);
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