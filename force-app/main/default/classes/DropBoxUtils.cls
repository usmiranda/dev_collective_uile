public class DropBoxUtils {

    @InvocableMethod(label='Create File Request From Drop Box' description='Creates a new send file request from Drop Box' category='Drop Box' callout=true)
  	public static List<DBFileRequestResult> createFileRequest(List<createRequestVars> requests) {
        List<DBFileRequestResult> newResults = New List<DBFileRequestResult>();
        List<DBFileRequestResult> closeResults = New List<DBFileRequestResult>();
        List<DBFileRequestResult> updateResults = New List<DBFileRequestResult>();
        List<DBFileRequestResult> results = New List<DBFileRequestResult>();
        for(createRequestVars request : requests){
            switch on request.reqType.toLowerCase() {
                when 'new_request' {
                    system.debug('new request');
                	newResults.add(callRequestAPI(request));
                }
                when 'close_request' {
					system.debug('close request');
                    closeResults.add(closeRequest(request));
                }
                when 'update_request' {
					system.debug('update request');
                    updateResults.add(updateRequest(request));
                }
            }
        }  
        
        createdFileRequestRecords(newResults);
        results.addAll(newResults);
        closedFileRequestRecords(closeResults);
        results.addAll(closeResults);
        updateFileRequestRecords(updateResults);
        results.addAll(updateResults);
        
        return results;
    }
    
    //used to create a new file request from Drop Box
    public static DBFileRequestResult callRequestAPI(createRequestVars request){
        
        Connection_Settings__c dropbox = Connection_Settings__c.getValues('DropboxFileRequest');
        
        Final String requestURI = dropbox.Url__c;
		
        Final String LOCAL_TOKEN = dropbox.Token__c;
        
        Final DateTime dt = datetime.newInstance(System.now().addYears(1).year(), 1, 24); 
        
        Final String theDate = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
		Final string requestBody = '{"title": "' + request.title + '",  "destination": "' + request.destination + '","deadline": {"deadline": "' + theDate + '","allow_late_uploads": "seven_days"},"open": true}';

        string calloutMethod = 'POST';

        Map<String, String> headers = New Map<String, String>{'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + LOCAL_TOKEN};
        
        Map<String, Object> parsedResponse = RestCallout.callService(requestURI, requestBody, calloutMethod, headers);
		DBFileRequestResult result = new DBFileRequestResult();
        result.requestUrl = (String)parsedResponse.get('url');
        result.relatedRecordId = request.relatedRecordId;
        result.requestId = (String)parsedResponse.get('id');
        result.destination = (String)parsedResponse.get('destination');
        result.subject = request.title;
        result.body = request.body;
        result.reqType = 'new_request';
        return result;
    }
    
    //used to close an existing file request from Drop Box
    public static DBFileRequestResult closeRequest(createRequestVars request){
        
        Connection_Settings__c dropbox = Connection_Settings__c.getValues('DropboxFileUpdate');
        
        Final String requestURI = dropbox.Url__c;
		
        Final String LOCAL_TOKEN = dropbox.Token__c;
        
        Final DateTime dt = datetime.newInstance(System.now().addYears(1).year(), 1, 24); 
        
        Final String theDate = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        Final string requestBody = '{"id": "' + request.requestId + '",  "open": false }';

        string calloutMethod = 'POST';

        Map<String, String> headers = New Map<String, String>{'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + LOCAL_TOKEN};
        
        Map<String, Object> parsedResponse = RestCallout.callService(requestURI, requestBody, calloutMethod, headers);
		DBFileRequestResult result = new DBFileRequestResult();
        result.isActive = (Boolean)parsedResponse.get('is_open');
        result.relatedRecordId = request.relatedRecordId;
        result.requestId = (String)parsedResponse.get('id');
        result.reqType = 'close_request';
        return result;
    }
    
    //used to close an existing file request from Drop Box
    public static DBFileRequestResult updateRequest(createRequestVars request){
        
        Connection_Settings__c dropbox = Connection_Settings__c.getValues('DropboxFileUpdate');
        
        Final String requestURI = dropbox.Url__c;
		
        Final String LOCAL_TOKEN = dropbox.Token__c;
        
        Final DateTime dt = datetime.newInstance(System.now().addYears(1).year(), 1, 24); 
        
        Final String theDate = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        Final string requestBody = '{"id": "' + request.requestId + '", "destination": "' + request.destination + ',"open": true }';

        string calloutMethod = 'POST';

        Map<String, String> headers = New Map<String, String>{'Content-Type'=> 'application/json','Authorization' => 'Bearer ' + LOCAL_TOKEN};
        
        Map<String, Object> parsedResponse = RestCallout.callService(requestURI, requestBody, calloutMethod, headers);
		DBFileRequestResult result = new DBFileRequestResult();
        result.isActive = (Boolean)parsedResponse.get('is_open');
        result.relatedRecordId = request.relatedRecordId;
        result.requestId = (String)parsedResponse.get('id');
        result.destination = (String)parsedResponse.get('destination');
        result.reqType = 'update_request';
        return result;
    }
    
    public static void createdFileRequestRecords(List<DBFileRequestResult> requests){
    	Dropbox_File_Request__c dbRequest;
        List<Dropbox_File_Request__c> dbRequests = New List<Dropbox_File_Request__c>();
        for(DBFileRequestResult r : requests){
        	dbRequest = New Dropbox_File_Request__c();
            dbRequest.Request_Id__c = r.requestId;
            dbRequest.Request_Url__c = r.requestUrl;
            dbRequest.Subject__c = r.subject;
            dbRequest.Body__c = r.body;
            dbRequest.Destination_Folder__c = r.destination;
            dbRequest.Status__c = 'Open';
            Id recordId = (Id)r.relatedRecordId;
            switch on String.valueOf(recordId.getsobjecttype()) {
                when 'Account' {		
                	dbRequest.Account__c = recordId;
                    dbRequest.Contact__c = getContact('account', recordId);
                }	
                when 'Opportunity' {		
                	dbRequest.Opportunity__c = recordId; 
                    dbRequest.Account__c = getAccount('opportunity', recordId);
                    dbRequest.Contact__c = getContact('opportunity', recordId);
                }
                when 'Task' {		
                	dbRequest.Task__c = r.relatedRecordId; 
                    dbRequest.Contact__c = getContact('task', recordId);
                }
                
            }    
            dbRequests.add(dbRequest);    
        }
        database.insert(dbRequests,false);
    }
    
    public static void closedFileRequestRecords(List<DBFileRequestResult> results){
    	Dropbox_File_Request__c dbRequest;
        Set<String> bdReqids = New Set<String>();
        for(DBFileRequestResult res : results ){
        	bdReqids.add(res.relatedRecordId);    
        }
        Map<Id,Dropbox_File_Request__c> dbRequests = New Map<Id,Dropbox_File_Request__c>([Select Id, Status__c from Dropbox_File_Request__c where id in : bdReqids]);
        for(DBFileRequestResult res : results){
            if(dbRequests.containsKey(res.relatedRecordId) && !res.isActive){
            	dbRequests.get(res.relatedRecordId).Status__c = 'Closed';			    
            }
        }
        database.update(dbRequests.values(), false);
    }
    
    public static void updateFileRequestRecords(List<DBFileRequestResult> results){
    	Dropbox_File_Request__c dbRequest;
        Set<String> bdReqids = New Set<String>();
        for(DBFileRequestResult res : results ){
        	bdReqids.add(res.relatedRecordId);    
        }
        Map<Id,Dropbox_File_Request__c> dbRequests = New Map<Id,Dropbox_File_Request__c>([Select Id, Status__c from Dropbox_File_Request__c where id in : bdReqids]);
        system.debug('updated file requests');
        system.debug(dbRequests);
        for(DBFileRequestResult res : results){
            if(dbRequests.containsKey(res.relatedRecordId)){
            	dbRequests.get(res.relatedRecordId).Destination_Folder__c = res.destination;			    
            }
        }
        database.update(dbRequests.values(), false);
    }
    
    public static String getAccount(String source, Id recordId){
        String returnValue = '';
        
        switch on source.toLowerCase() {	
                when 'opportunity' {		
                	returnValue = [Select Id, AccountId from opportunity where id =: recordId].AccountId; //query += ' Id, Primary_Contact__c from Opportunity where id =: recordId';
                }               
            } 
        
        return returnValue;
    }
    
    public static String getContact(String source, Id recordId){
        String returnValue = '';
        String query = 'select ';
        
        switch on source.toLowerCase() {
                when 'account' {		
                	returnValue = [Select Id, Primary_Contact__c from account where id =: recordId].Primary_Contact__c; //query += ' Id, Primary_Contact__c from account where id =: recordId';
                }	
                when 'opportunity' {		
                	returnValue = [Select Id, Primary_Contact__c from opportunity where id =: recordId].Primary_Contact__c; //query += ' Id, Primary_Contact__c from Opportunity where id =: recordId';
                }
                when 'task' {		
                	returnValue = [Select Id, WhoId from Task where id =: recordId].WhoId; //query += ' Id, WhoId from Task where id =: recordId';	
                }
                
            } 
        
        return returnValue;
    }
    
    //input details that comes to apex from flow
    public class createRequestVars {
        
        
        @InvocableVariable
        public String body;
        
        @InvocableVariable
        public String relatedRecordId;
        
        @InvocableVariable
        public String title;
        
        @InvocableVariable
        public String destination;
        
        @InvocableVariable
        public String reqType;
        
        @InvocableVariable
        public String requestId;
        
    }
    
    public class DBFileRequestResult {
    	@InvocableVariable
        public String requestUrl;	
        
        @InvocableVariable
        public String relatedRecordId;
        
        @InvocableVariable
        public String requestId;
        
        @InvocableVariable
        public String subject;
        
        @InvocableVariable
        public String body;
        
        @InvocableVariable
        public String reqType;
        
        @InvocableVariable
        public Boolean isActive;
        
        @InvocableVariable
        public String destination;
        
    }

}