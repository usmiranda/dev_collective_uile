@isTest
public class RegenerateSignupLinkCallout_Test {
    Private Static Final String ACCOUNT_NAME = 'Test Acc';
    Private Static Final String MEMBER_EMAIL = 'itslukestonetest@gmail.com';
    
    @testSetup static void setupData() {
        Account testAccount = New Account(Name = ACCOUNT_NAME, State_of_Business__c = 'California', Original_Entity_Type__c = 'SP -> SC', Tax_Calc_Discount_Code__c = 'ABCDEF0', Tax_Calculator_ID__c = '123456');
        insert testAccount;                          
        
        Contact testContact = New Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Account', Email = MEMBER_EMAIL, Secondary_Email__c = 'testAccount1234@testing.net');
        insert testContact;
        
        Opportunity testOpportunity = [SELECT Id, Email__c FROM Opportunity WHERE AccountId =: testAccount.Id LIMIT 1];     
        testOpportunity.Plan__c = Opportunity.Plan__c.getDescribe().getPicklistValues()[0].getValue();
        update testOpportunity;       
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'AcquisitionFormRequest';
        cs.url__c = 'https://somefakeurl.net';
        cs.Token__c = '432kr32jhk3k2j432kjh4';        
        insert cs;            
        system.debug('11135');
    }         
    
    private class MockOk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"email": "ewewewe@collective.com","frontend_url": "https://collective.heroku.com/signup-link/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9","backend_url":"https://collective.com/","token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"}');
            return res;
        }
    }
    
    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('Bad Request');
            res.setStatusCode(400);
            res.setBody('{"error": "Unable to find existing signup link for this member"}');
            return res;
        }
    }        
    
    @isTest static void InvokeSignupLinkEndpoint() {
        Test.startTest();
        
        Account acct = [SELECT Id, Name, Tax_Calc_Discount_Code__c, State_of_Business__c, Tax_Calculator_ID__c FROM Account WHERE Name=: ACCOUNT_NAME LIMIT 1];
        System.debug('acct: ' + acct);
        Opportunity oppt = [SELECT Id, Email__c FROM Opportunity WHERE AccountId =: acct.Id];
        System.debug('oppt: ' + oppt);        
        
        Test.setMock(HttpCalloutMock.class, new MockOk());
        String response;        
        response = RegenerateSignupLinkCallout.InvokeSignupLinkEndpoint(oppt.Id);
        System.assertNotEquals('{"error": "Unable to find existing signup link for this member"}', response);
     
        Test.stopTest();
        
    }    
    
    @isTest static void InvokeSignupLinkEndpointError() {
        Test.startTest();
        
        Account acct = [SELECT Id, Name, Tax_Calc_Discount_Code__c, State_of_Business__c, Tax_Calculator_ID__c FROM Account WHERE Name=: ACCOUNT_NAME LIMIT 1];
        System.debug('acct: ' + acct);
        Opportunity oppt = [SELECT Id, Email__c FROM Opportunity WHERE AccountId =: acct.Id];
        System.debug('oppt: ' + oppt);        
        
        String response;  
        Test.setMock(HttpCalloutMock.class, new MockError());
        response = RegenerateSignupLinkCallout.InvokeSignupLinkEndpoint(oppt.Id);
        System.assertEquals('{"error": "Unable to find existing signup link for this member"}', response);    
        Test.stopTest();
        
    }    
        
    

}