@isTest
public class OutboundMessage_Test { 
    
    Private Static Final String ACCOUNT_NAME = 'Test Account'; 
    Private Static Final String eventType = 'com.collective.sfdc.task.completed';
    Private Static Final String STAGE_NAME = 'Take Intro Call';
    Private Static Final String ACCOUNTING_SOFTWARE_STAGE_NAME = 'Setup Accounting Software';
    Private Static Final String TASK_STATUS = 'Completed';
    Private Static Final String OUTCOME = 'Follow Up'; //Send Onboarding Email
    Private Static Final String PLAN = 'SP -> SC';
    
    private class MockOk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('success');
            return res;
        }
    }
    
    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('Bad Request');
            res.setStatusCode(400);
            res.setBody('error');
            return res;
        }
    }
    
    @testSetup static void setupData() {
        
        //create our test data
        Account testAccount = New Account(name = ACCOUNT_NAME);
        insert testAccount;
        
        Contact testContact = New Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Account', Email = 'testAccount@testing.net');
        insert testContact;
        
        Opportunity testOpp = New Opportunity(AccountId = testAccount.Id, Name = 'Test', StageName = 'Eligible', CloseDate = Date.today(), recordtypeid= '0126g0000001y5pAAA', Business_Solution_Advisor__c = Userinfo.getUserId(), Tax_Advisor__c = Userinfo.getUserId(), Tax_Team_Manager__c = Userinfo.getUserId(), Accounting_Advisor__c = Userinfo.getUserId(), Accounting_Manager__c =  Userinfo.getUserId());
        insert testOpp;
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'Django';
        cs.url__c = 'https://somefakeurl.net';
        cs.Token__c = '432kr32jhk3k2j432kjh4';
        
        insert cs;
        
    }
    
    @isTest static void testIntroCallCompleteOk() {
        
        String testOpptyId = setupIntroTask();
        Task introCall;
        //Run the Test
        Test.startTest();
        //Set the Test Moc
        Test.setMock(HttpCalloutMock.class, new MockOk());
        //query intro task and complete it, assert that the external system is called with a specific payload
        introCall = [Select Id, Status, Intro_Call_Outcome__c from Task where WhatId = : testOpptyId limit 1];
        introCall.status = TASK_STATUS;
        introCall.Intro_Call_Outcome__c = OUTCOME;
        introCall.Description = 'This is a test';
        introCall.Plan__c = PLAN;
        update introCall;
        
        Test.stopTest();
		
		OutboundMessage.OutboundMessageVars var = New OutboundMessage.OutboundMessageVars();
        var.recordId = introCall.Id;
        var.eventType = 'com_collective_sfdc_task_completed';
        var.eventReplayId = '34423';
        OutboundMessage.processOutboundMessage(New List<OutboundMessage.OutboundMessageVars> {var});        
    }
    
    @isTest static void updatePrimaryOpp(){
        //Query the opportunity and change the name to trigger an intro call to be created
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockOk());
        Account testAcc = [Select Id, Name, Primary_Opportunity__c from Account where Name = : ACCOUNT_NAME limit 1];
        Opportunity testOppty = [Select Id, Name, StageName from Opportunity where AccountId = : testAcc.Id limit 1];
        testAcc.Primary_Opportunity__c = testOppty.Id;
        update testAcc; 
        
        Test.stopTest();
        
		OutboundMessage.OutboundMessageVars var = New OutboundMessage.OutboundMessageVars();
        var.recordId = testAcc.Id;
        var.eventType = 'com_collective_primaryopp_updated';
        var.eventReplayId = '34424';
        OutboundMessage.processOutboundMessage(New List<OutboundMessage.OutboundMessageVars> {var});          
    }           
    
    @isTest static void testIntroCallCompleteError() {
        
        String testOpptyId = setupIntroTask();
        Task introCall;
        //Run the Test
        Test.startTest();
        //Set the Test Moc
        Test.setMock(HttpCalloutMock.class, new MockError());
        //query intro task and complete it, assert that the external system is called with a specific payload
        introCall = [Select Id, Status, Intro_Call_Outcome__c from Task where WhatId = : testOpptyId limit 1];
        introCall.status = TASK_STATUS;
        introCall.Intro_Call_Outcome__c = OUTCOME;
        introCall.Description = 'This is a test';
        introCall.Plan__c = PLAN;
        update introCall;        
        Test.stopTest();
        OutboundMessage.OutboundMessageVars var = New OutboundMessage.OutboundMessageVars();
        var.recordId = introCall.Id;
        var.eventType = 'com_collective_sfdc_task_completed';
        var.eventReplayId = '34423';
        OutboundMessage.processOutboundMessage(New List<OutboundMessage.OutboundMessageVars> {var});
        
    }
    
    private static String setupIntroTask(){
        //Query the opportunity and change the name to trigger an intro call to be created
        Opportunity testOppty = [Select Id, Name, StageName from Opportunity where Account.Name = : ACCOUNT_NAME limit 1];
        System.debug('testOppty: ' + testOppty);
        testOppty.StageName = STAGE_NAME;
        update testOppty;
        
        return testOppty.Id;
    }
    
    private static String setupAccountingSoftwareTask(){
        //Query the opportunity and change the name to trigger an intro call to be created
        Opportunity testOppty = [Select Id, Name, StageName from Opportunity where Account.Name = : ACCOUNT_NAME limit 1];
        testOppty.StageName = ACCOUNTING_SOFTWARE_STAGE_NAME;
        update testOppty; 
        
        return testOppty.Id;
    }    
    

    
    
    
}