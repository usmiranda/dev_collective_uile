@isTest
public class DropBoxUtils_Test {
    
    Private Static Final String ACCOUNT_NAME = 'Test Account';
    Private Static Final String STAGE_NAME = 'Take Intro Call';
    Private Static Final String TASK_STATUS = 'Completed';
    Private Static Final String OUTCOME = 'Follow Up'; //Send Onboarding Email
    Private Static Final String PLAN = 'SP -> SC';

    
    private class MockOk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"id": "jhmFoA2oHy4brMkRfwTD", "url": "https://www.dropbox.com/request/jhmFoA2oHy4brMkRfwTD", "title": "Please send a new Test File", "destination": "/Hyke Dropbox/Dev Collective Clients/some name here - Collective qa & 7269 LLC", "created": "2021-10-28T08:29:29Z", "deadline": {"deadline": "2021-10-28T08:29:29Z", "allow_late_uploads": {".tag": "seven_days"}}, "is_open": true, "file_count": 0}');
            return res;
        }
    }
    
    private class MockOkClose implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"id": "jhmFoA2oHy4brMkRfwTD", "is_open": false}');
            return res;
        }
    }
    
    private class MockOkUpdate implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"id": "jhmFoA2oHy4brMkRfwTD", "destination": "/Hyke Dropbox/Dev Collective Clients/some name here - Collective qa & 7370", "is_open": true}');
            return res;
        }
    }
    
    @testSetup static void setupData() {
        
        //create our test data
        Account testAccount = New Account(name = ACCOUNT_NAME);
        insert testAccount;
        testAccount.Dropbox_Folder__c = '/Dev Collective Clients/some name here - Collective qa & 7269 LLC';
        update testAccount;
        
        Contact testContact = New Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Account', Email = 'testAccount@testing.net');
        insert testContact;
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'DropboxFileRequest';
        cs.url__c = 'https://api.dropboxapi.com/2/file_requests/create';
        cs.Token__c = '432kr32jhk3k2j432kjh4';
        
        insert cs;
        
        Connection_Settings__c csc = new Connection_Settings__c();
        csc.Name = 'DropboxFileUpdate';
        csc.url__c = 'https://api.dropboxapi.com/2/file_requests/update';
        csc.Token__c = '432kr32jhk3k2j432kjh4';
        
        insert csc;
    }
    
    @isTest static void createFileRequestTest() {
        
        //get the test account
        Account testAccount = [Select Id, Name, Dropbox_Folder__c from Account where Name = : ACCOUNT_NAME];
        //get the test opportunity
        Opportunity testOppty = [Select Id from Opportunity where AccountId = : testAccount.Id];
        
        //Run the Test
        Test.startTest();
        //Set the Test Moc
        Test.setMock(HttpCalloutMock.class, new MockOk());
        DropBoxUtils.createRequestVars reqVars = New DropBoxUtils.createRequestVars();
        reqVars.title = 'Please send a new Test File';
        reqVars.destination = testAccount.Dropbox_Folder__c;
        reqVars.relatedRecordId = testOppty.Id;
        reqVars.reqType = 'new_request';
        reqVars.body = '';
        List<DropBoxUtils.DBFileRequestResult> reqURLs = DropBoxUtils.createFileRequest(New List<DropBoxUtils.createRequestVars>{reqVars});
        system.assert(reqURLs[0].requestUrl != null);
        Test.stopTest();
        Dropbox_File_Request__c testResult = [select id, Account__c, Opportunity__c, Request_Url__c from Dropbox_File_Request__c limit 1];
        system.assert(testResult.Account__c == testAccount.Id);
      	system.assert(testResult.Opportunity__c == testOppty.Id);
    }
    
    @isTest static void closeFileRequestTest() {
        
        //get the test account
        Account testAccount = [Select Id, Name, Dropbox_Folder__c from Account where Name = : ACCOUNT_NAME];
        //get the test opportunity
        Opportunity testOppty = [Select Id from Opportunity where AccountId = : testAccount.Id];
        
        //Create a new request file only
        Dropbox_File_Request__c dbRequest = New Dropbox_File_Request__c();
        dbRequest.Request_Id__c = 'jhmFoA2oHy4brMkRfwTD';
        dbRequest.Request_Url__c = 'https://www.dropbox.com/request/jhmFoA2oHy4brMkRfwTD';
        dbRequest.Subject__c = 'Test';
        dbRequest.Body__c = 'Test';
        dbRequest.Status__c = 'Open';
        dbRequest.Opportunity__c = testOppty.Id;
        dbRequest.Account__c = testAccount.Id; 
        insert dbRequest;
        //Run the Test
        Test.startTest();
        //Set the Test Moc
        Test.setMock(HttpCalloutMock.class, new MockOkClose());
        //get the 
        Dropbox_File_Request__c testReq = [select id, Account__c, Opportunity__c, Request_Url__c,Request_Id__c from Dropbox_File_Request__c Where Id = : dbRequest.Id];
        DropBoxUtils.createRequestVars reqVarsClose = New DropBoxUtils.createRequestVars();
        reqVarsClose.relatedRecordId = testReq.Id;
        reqVarsClose.requestId = testReq.Request_Id__c;
        reqVarsClose.reqType = 'close_request';
        List<DropBoxUtils.DBFileRequestResult> reqCloseResp = DropBoxUtils.createFileRequest(New List<DropBoxUtils.createRequestVars>{reqVarsClose});
    	Test.stopTest();
        Dropbox_File_Request__c testRes = [select id, Account__c, Opportunity__c, Status__c,Request_Url__c from Dropbox_File_Request__c limit 1];
		system.assert(testRes.Status__c == 'Closed');
    }
    
    @isTest static void updateFileRequestTest() {
        
        //get the test account
        Account testAccount = [Select Id, Name, Dropbox_Folder__c from Account where Name = : ACCOUNT_NAME];
        //get the test opportunity
        Opportunity testOppty = [Select Id from Opportunity where AccountId = : testAccount.Id];
        
        //Create a new request file only
        Dropbox_File_Request__c dbRequest = New Dropbox_File_Request__c();
        dbRequest.Request_Id__c = 'jhmFoA2oHy4brMkRfwTD';
        dbRequest.Request_Url__c = 'https://www.dropbox.com/request/jhmFoA2oHy4brMkRfwTD';
        dbRequest.Subject__c = 'Test';
        dbRequest.Body__c = 'Test';
        dbRequest.Status__c = 'Open';
        dbRequest.Opportunity__c = testOppty.Id;
        dbRequest.Account__c = testAccount.Id; 
        insert dbRequest;
        //Run the Test
        Test.startTest();
        //Set the Test Moc
        Test.setMock(HttpCalloutMock.class, new MockOkUpdate());
        //get the 
        Dropbox_File_Request__c testReq = [select id, Account__c, Opportunity__c, Request_Url__c,Request_Id__c from Dropbox_File_Request__c Where Id = : dbRequest.Id];
        DropBoxUtils.createRequestVars reqVarsUp = New DropBoxUtils.createRequestVars();
        reqVarsUp.relatedRecordId = testReq.Id;
        reqVarsUp.destination = '/Hyke Dropbox/Dev Collective Clients/some name here - Collective qa & 7370';
        reqVarsUp.requestId = testReq.Request_Id__c;
        reqVarsUp.reqType = 'update_request';
        List<DropBoxUtils.DBFileRequestResult> reqCloseResp = DropBoxUtils.createFileRequest(New List<DropBoxUtils.createRequestVars>{reqVarsUp});
    	Test.stopTest();
		Dropbox_File_Request__c testRes = [select id, Account__c, Opportunity__c, CreatedDate, Destination_Folder__c, LastModifiedDate, Status__c,Request_Url__c from Dropbox_File_Request__c limit 1];
		system.debug('md ' + testRes.Destination_Folder__c + ' cd ' + testRes.Destination_Folder__c);
        system.assert(testRes.Destination_Folder__c == '/Hyke Dropbox/Dev Collective Clients/some name here - Collective qa & 7370');
    }

}