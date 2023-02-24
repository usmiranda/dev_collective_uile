public class DropboxURLBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    public final String Query;
    public List<String> related;
    
    public DropboxURLBatch(String q, List<String> r){
        
        Query=q;
        related = r;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<DropBoxUtils.createRequestVars> reqVals = New List<DropBoxUtils.createRequestVars>();
        DropBoxUtils.createRequestVars reqVars;
        
        for(Account a : scope){
            reqVars = New DropBoxUtils.createRequestVars();  
            reqVars.title = 'Statements';
            reqVars.destination = a.Dropbox_Folder__c;
            reqVars.relatedRecordId = a.Id;
            reqVars.body = '';
            reqVars.reqType = 'new_request';
            reqVals.add(reqVars);
            system.debug(reqVars);
        }

		List<DropBoxUtils.DBFileRequestResult> reqURLs = DropBoxUtils.createFileRequest(reqVals);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}