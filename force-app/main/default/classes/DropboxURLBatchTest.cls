@isTest
private class DropboxURLBatchTest {

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
    
    @testSetup static void setupData() {
        
        //create our test data
        List<Account> actList = new List<Account>();
        Account testAccount;
        for(integer i = 0; i < 20; i++){
        	testAccount = New Account(name = ACCOUNT_NAME + ' ' + i);
            actList.add(testAccount);
        }
        insert actList;
        for(Account a : actList){
       		a.Dropbox_Folder__c = '/Dev Collective Clients/' + a.name;
        }
        update actList;
        
        List<Contact> testContacts  = New List<Contact>();
        Contact testContact;
        for(integer i = 0; i < 20; i++){
       		testContact = New Contact(AccountId = actList[i].Id, FirstName = 'Test', LastName = 'Account ' + i , Email = 'testAccount' + i + '@testing.net');
            testContacts.add(testContact);
        }
        insert testContact;
        for(integer i = 0; i < 20; i++){
        	actList[0].Primary_Contact__c = testContacts[i].Id;	    
        }
        update actList;
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'DropboxFileRequest';
        cs.url__c = 'https://api.dropboxapi.com/2/file_requests/create';
        cs.Token__c = '432kr32jhk3k2j432kjh4';
        
        insert cs;
        
    }
    
    @isTest static void batchTest() {
        
        Test.setMock(HttpCalloutMock.class, new MockOk());
        Test.startTest();
            //Set the Test Moc  
        List<String> emails = New List<String>();
        for(Account a : [Select Id, Email__c from Account where Email__c != null limit 20]){
            emails.add(a.Email__c);
        }
        DropboxURLBatch urlBatch = New DropboxURLBatch('Select Id, Dropbox_Folder__c from Account', emails);
        	ID batchprocessid = Database.executeBatch(urlBatch);
        Test.stopTest();
        List<Account> actList = new List<Account>([Select id from Account]);
        Map<Id,Dropbox_File_Request__c> reqURLs = New Map<Id,Dropbox_File_Request__c>();
        for(Dropbox_File_Request__c dpreq : [Select Id, Account__c from Dropbox_File_Request__c]){
        	reqURLs.put(dpreq.Account__c,dpreq);    
        }
        for(Account a : actList){
        	system.assert(reqURLs.containsKey(a.Id));    
        }
    }
    
}