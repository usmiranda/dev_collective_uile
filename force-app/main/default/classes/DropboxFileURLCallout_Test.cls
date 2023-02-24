@isTest
public class DropboxFileURLCallout_Test {
    Private Static Final String ACCOUNT_NAME = 'Test Acc';
    Private Static Final String FILE_ID = 'id:zroDv_tp_GAAAAAAAABVGQ';
    
    
    private class MockOk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"link": "https://www.dropbox.com/s/cgq2s26mpj5kljp/Operating%20Agreement.pdf?dl=0"}');
            return res;
        }
    }
    
    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('Bad Request');
            res.setStatusCode(400);
            res.setBody('{"error": "Missing required id"}');
            return res;
        }
    }    
    
    @testSetup static void setupData() {
        Account testAccount = New Account(Name = ACCOUNT_NAME, State_of_Business__c = 'California', Original_Entity_Type__c = 'SP -> SC', Tax_Calc_Discount_Code__c = 'ABCDEF0', Tax_Calculator_ID__c = '123456');
        insert testAccount;                          
        
        Contact testContact = New Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Account', Email = 'testAccount@testing.net', Secondary_Email__c = 'testAccount1234@testing.net');
        insert testContact;
        
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id LIMIT 1];     
        testOpportunity.Plan__c = Opportunity.Plan__c.getDescribe().getPicklistValues()[0].getValue();
        update testOpportunity;       
        
        /*DropboxFile__x testDropboxFile = New DropboxFile__x(file_id__c = FILE_ID, sfaccountid__c = testAccount.Id, sfopportunityid__c = testOpportunity.Id);
        insertAsync testDropboxFile;                      */
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'DropboxFileUrl';
        cs.url__c = 'https://somefakeurl.net';
        cs.Token__c = '432kr32jhk3k2j432kjh4';        
        insert cs;            
       
    }    
    
    
    @isTest static void InvokeDropboxURL() {
        Test.startTest();
        
        DropboxFileURLRequestBody reqBody = new DropboxFileURLRequestBody();
        reqBody.file_id = FILE_ID;
        
        Test.setMock(HttpCalloutMock.class, new MockOk());
        String linkUrl;        
        linkUrl = DropboxFileURLCallout.InvokeDropboxURL(FILE_ID);
        System.assertNotEquals(null, linkUrl);
        Test.setMock(HttpCalloutMock.class, new MockError());
        linkUrl = DropboxFileURLCallout.InvokeDropboxURL(FILE_ID);
        System.assertEquals(null, linkUrl);        
        Test.stopTest();
    }
}